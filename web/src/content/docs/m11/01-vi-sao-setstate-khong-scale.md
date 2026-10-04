---
title: "Bài 1 · Vì sao setState không scale"
description: "Đọc lại _MenuScreenState cuối M10 để thấy nỗi đau, ChangeNotifier là nguyên thuỷ 'có ai nghe thì báo', và tạo MenuViewModel."
sidebar:
  label: "Bài 1 · Vì sao setState không scale"
  order: 1
---

## Mục tiêu

Nhìn thẳng vào giới hạn của `setState`-cho-mọi-thứ trong
`_MenuScreenState` cuối M10, hiểu `ChangeNotifier` là gì, và tạo file
`MenuViewModel` chứa state "to" của menu.

## Bạn đang ở đâu

- Milestone: **M11** (bài 1/3)
- App hiện tại: menu hoạt động đầy đủ — load từ prefs, áp kết quả
  game, reset — nhưng *toàn bộ* sống trong `_MenuScreenState`:
  `_profile`, `_profileLoadFuture`, `_loadProfile`, `_resetProfile`,
  `_onPlayTap` vừa điều hướng vừa áp kết quả vừa persist.

## Vì sao việc này quan trọng ngay bây giờ

`setState` không sai — nó là đúng công cụ cho *state của một widget*.
Vấn đề là scale:

1. **State lẫn logic lẫn UI.** `_MenuScreenState` giờ làm ba việc: giữ
   profile + loadState (dữ liệu), gọi store + áp result (logic), build
   cây widget (UI). Mỗi việc thêm một nét → file phình ra, đọc khó.
2. **Không test được mà không render.** Muốn kiểm chứng "áp result
   đúng một lần" bạn phải `pumpWidget` cả màn hình — chậm và giòn,
   trong khi logic thật ra là Dart thuần.
3. **Prop drilling sắp đến.** Thêm màn cần profile (leaderboard,
   settings…) thì phải truyền `UserProfileData` qua từng ctor widget
   — M12 sẽ giải phần "lấy từ đâu", M11 giải phần "state nằm đâu".

Flutter không ép bạn dùng ViewModel — nhưng framework *cho sẵn* một
nguyên thuỷ để tự viết nó: `Listenable`/`ChangeNotifier`.

## Bạn đã biết gì

- `setState`/lifecycle (M03), `FutureBuilder` (M05), `Stream`/`listen`
  (M06) — `ChangeNotifier` cùng họ "có biến cố thì báo", nhưng không
  phải Stream: chỉ báo "đổi rồi", không mang payload.
- Model bất biến + `applyGameResult` (M04, M10) — VM sẽ *giữ* bản
  profile hiện tại và swap bằng bản mới.

## Mental model mới

**ChangeNotifier = object bình thường có hệ thống "ai quan tâm thì
addListener, có gì đổi thì notifyListeners".** Không stream, không
event loop phức tạp:

```
MenuViewModel extends ChangeNotifier
  _profile, _loadState          ← state (private)
  profile, loadState            ← getter public (đọc được, ghi không)
  load() / applyGameResult()    ← hành vi: đổi state → notifyListeners()
        │
        ▼ notifyListeners()
ListenableBuilder(listenable: vm) → builder chạy lại → UI mới
```

Phân ranh giới trong milestone này:

| Thuộc **VM** | Thuộc **State widget** |
|---|---|
| `_profile`, `_loadState` | `_soundOn`, `_playTapCount`, `_sessionTicker` |
| `load`, `applyGameResult`, `resetProfile` | `_onPlayTap` (điều hướng), `_toggleSound` |

Quy tắc chọn: state nào *diễn tả dữ liệu của màn hình* và cần sống/
chia sẻ/test độc lập → VM. State nào chỉ là hành vi tương tác cục bộ
của widget → giữ trong `State`. Điều hướng (`Navigator.push`) là
việc widget — VM không chạm `BuildContext`.

## Dart cần dùng

| Cú pháp | Ví dụ | Nghĩa |
|---------|-------|-------|
| `extends ChangeNotifier` | `class MenuViewModel extends ChangeNotifier` | Kế thừa cơ chế listener; từ `package:flutter/foundation.dart` — không cần material |
| `_field` + getter | `UserProfileData get profile => _profile;` | Bên ngoài đọc được, không sửa được — muốn đổi phải qua method của VM |
| `notifyListeners()` | `notifyListeners();` | Báo mọi listener "tôi vừa đổi" — **không** tự kiểm "đổi thật chưa" |
| `unawaited` | `unawaited(_viewModel.load());` | `dart:async`: nói rõ "Future này cố ý không await" — khác quên await |
| enum trạng thái | `MenuLoadState { loading, ready, failed }` | Thay snapshot/connectionState của FutureBuilder bằng enum tự đặt tên |

## Flutter cần dùng

| Widget/API | Vai trò |
|------------|---------|
| `ListenableBuilder` | Nghe một `Listenable` và rebuild `builder` khi nó notify — bài 2 gắn vào |
| `State.initState` | Chỗ tạo VM và kick-off `load()` (bài 3) |
| `State.dispose` | Chỗ `_viewModel.dispose()` — VM là tài nguyên phải huỷ (bài 3) |

## Android / Compose bridge

- SIMILARITY: `MenuViewModel` ≈ `ViewModel` + `MutableStateFlow`:
  `notifyListeners` ≈ `_state.value = …` (post state mới),
  `ListenableBuilder` ≈ `collectAsStateWithLifecycle` (rebuild khi
  phát). Getter che `_field` ≈ expose `StateFlow` immutable bọc
  `MutableStateFlow` private — *chính xác cùng một pattern*.
- IMPORTANT DIFFERENCE: **không có `viewModelScope`**. VM Flutter không
  tự sống qua config change và không tự huỷ — *ai tạo người đó dispose*.
  Và `ChangeNotifier` không phát "giá trị mới" như StateFlow: nó chỉ
  phát tín hiệu "đổi rồi" — listener tự đọc lại getter.
- DO NOT ASSUME: `notifyListeners` tự diff. Nó báo vô điều kiện —
  muốn chỉ báo khi đổi thật thì *bạn* so sánh trước (senior làm đúng
  điều này: `_userData != userData` mới notify).

## Senior project connection

- `flutter-accelerator-ai/lib/view_models/menu/menu_screen_view_model.dart` —
  `MenuScreenViewModel extends ChangeNotifier`, giữ `_userData`, expose
  `UserProfileData get userData`, và `_handleUserProfile` *so sánh*
  `!=` trước khi `notifyListeners()`. `MenuViewModel` của ta là cùng
  hình dạng ở quy mô một màn.
- Senior VM còn có `_events` `StreamController` (UI event một-lần —
  snackbar, điều hướng) — ta **cố ý chưa có**: đó là M13.
- Senior đặt VM dưới `lib/view_models/menu/` — learner đi theo cùng
  convention thư mục.

## Build it step by step

### Bước 1 — File VM mới

```dart
// lib/view_models/menu/menu_view_model.dart — FILE MỚI
import 'package:flutter/foundation.dart';

import '../../data/game/game_result.dart';
import '../../data/profile/profile_store.dart';
import '../../data/profile/user_profile_data.dart';

/// Vòng đời tải profile của menu — enum thay snapshot FutureBuilder.
///
/// TEMPORARY (senior fidelity): menu senior KHÔNG có load-state —
/// repository của nó stream-seeded (BehaviorSubject) nên VM nhận data
/// qua subscription và menu render ngay profile đã seed. Enum này chỉ
/// tồn tại vì learner còn `load()` tay; nó retire ở M14 khi contract
/// repository + `userProfileStream` vào thay.
enum MenuLoadState {
  loading,
  ready,
  failed,
}

/// Giữ state "to" của MenuScreen — M11 tách khỏi `_MenuScreenState`.
class MenuViewModel extends ChangeNotifier {
  MenuViewModel({required ProfileStore store}) : _store = store;

  final ProfileStore _store;

  MenuLoadState _loadState = MenuLoadState.loading;
  MenuLoadState get loadState => _loadState;

  UserProfileData _profile = const UserProfileData();
  UserProfileData get profile => _profile;

  /// Đọc profile từ storage — gọi từ initState của màn và khi retry.
  Future<void> load() async {
    _setLoadState(MenuLoadState.loading);
    try {
      _profile = await _store.load();
      _setLoadState(MenuLoadState.ready);
    } catch (_) {
      _setLoadState(MenuLoadState.failed);
    }
  }

  /// Áp kết quả phiên chơi: đổi profile → báo UI → ghi disk.
  Future<void> applyGameResult(GameResult result) async {
    _profile = _profile.applyGameResult(result);
    notifyListeners();
    await _store.save(_profile);
  }

  /// Đặt lại profile — reset trước, state sau, notify chỉ khi đổi.
  /// `reset()` ghi profile mặc định đè lên key (đúng semantics
  /// `resetUserProfile()` của senior — không xoá key).
  Future<void> resetProfile() async {
    await _store.reset();
    const defaults = UserProfileData();
    if (_profile == defaults) return;
    _profile = defaults;
    notifyListeners();
  }

  /// Đổi loadState có kiểm soát — notify chỉ khi giá trị thật sự khác.
  void _setLoadState(MenuLoadState next) {
    if (_loadState == next) return;
    _loadState = next;
    notifyListeners();
  }
}
```

Ba điểm đọc kỹ:

- `import 'package:flutter/foundation.dart'` — **không phải
  material.dart**: VM là logic, không widget. Đây là dấu hiệu file
  không-UI.
- `load()` gọi `_setLoadState(loading)` mà *lần đầu không notify* —
  guard `if (_loadState == next) return` chặn báo-thừa (loading →
  loading). Retry sau `failed` thì guard cho notify đúng — UI quay về
  spinner.
- `notifyListeners` nằm *trước* `await _store.save` trong
  `applyGameResult` — UI cập nhật ngay, write chạy sau.

### Bước 2 — `_MenuScreenState` sở hữu VM

```dart
// lib/screens/menu_screen.dart — _MenuScreenState:
class _MenuScreenState extends State<MenuScreen> {
  // Ephemeral UI state — thuộc widget, không đưa vào VM.
  bool _soundOn = true;
  int _playTapCount = 0;
  final Stream<int> _sessionTicker = menuSessionTicker();

  /// State "to" của màn — tạo một lần, huỷ trong dispose.
  late final MenuViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = MenuViewModel(store: widget.profileStore);
    unawaited(_viewModel.load()); // kick-off — VM tự báo khi xong
  }

  @override
  void dispose() {
    _viewModel.dispose(); // ai tạo người đó huỷ — không còn auto-scope
    super.dispose();
  }
  // ...
}
```

`_profile`, `_profileLoadFuture`, `_loadProfile`, `_retryLoadProfile`,
`_resetProfile` — toàn bộ **biến mất** khỏi State.

### Bước 3 — `_onPlayTap` ủy quyền cho VM

```dart
Future<void> _onPlayTap() async {
  setState(() {
    _playTapCount++;
  });
  final result = await Navigator.of(context).push<GameResult>(
    MaterialPageRoute<GameResult>(
      builder: (context) => const GameScreen(),
    ),
  );
  if (!mounted || result == null) return;
  await _viewModel.applyGameResult(result); // đổi + persist trong VM
}
```

Điều hướng vẫn ở widget (Navigator cần `context`); *áp kết quả* sang
VM — chia đôi sạch sẽ: "cái gì cần BuildContext → widget, cái gì là
dữ liệu/logic → VM".

## Hiểu code

- **Vì sao `_viewModel` là `late final` mà không khởi tại khai báo
  field?** Vì cần `widget.profileStore` — `widget` chỉ tồn tại sau khi
  State được gắn vào cây, tức trong `initState` trở đi.
- **`unawaited` làm gì mà không bỏ luôn?** `load()` trả Future —
  không await thì compiler vẫn chạy, nhưng `unawaited()` ghi rõ *cố ý*:
  người đọc biết đây là kick-off không-chờ chứ không phải quên.
- **`resetProfile` so `_profile == defaults` trước khi notify** — đây
  là pattern compare-before-notify của senior: nếu đã là mặc định rồi
  thì clear disk vẫn chạy (xoá key cho sạch) nhưng UI không rebuild thừa.

## Chạy và quan sát

- `flutter analyze` sẽ phàn `ListenableBuilder` chưa được dùng và
  `MenuLoadState` unused — bài 2 nối UI.
- `flutter test` nhóm mới `MenuViewModel` xanh ngay — logic VM test
  được *trước khi* UI gắn vào. Đây là thu hoạch của bài 3.

## Lỗi hay gặp

1. **VM `import material.dart`** — compile được nhưng sai ranh giới:
   VM không cần widget; `foundation.dart` đủ và là "signature" file
   logic.
2. **Expose field public `UserProfileData profile`** — ai cũng gán
   được `vm.profile = …` mà không notify → UI lệch. Getter + `_field`.
3. **Quên `_viewModel.dispose()`** — listener rò, VM sống sót sau khi
   màn chết. State nào tạo, State đó huỷ.
4. **`await _viewModel.load()` trong initState** — `initState` là sync;
   không await được. `unawaited(...)` là cách nói đúng.

## Kiểm tra hiểu biết

1. `setState` và `notifyListeners`+`ListenableBuilder` khác nhau bản
   chất chỗ nào? — *`setState` báo "rebuild State này" từ chính nó;
   `notifyListeners` báo từ một object *ngoài* widget — bất kỳ
   `ListenableBuilder` nào đang nghe đều rebuild, widget không phải
   là chủ sở hữu state.*
2. Vì sao `load()` dùng `_setLoadState` còn `applyGameResult` gọi
   `notifyListeners()` trực tiếp? — *load có thể no-op (loading→loading)
   nên cần guard; applyGameResult luôn sinh profile mới
   (gamesJoined luôn +1) nên luôn đổi thật — guard thừa.*
3. `_sessionTicker` giữ trong State chứ không vào VM — tiêu chí gì? —
   *Ticker là tài nguyên UI-phiên thuần hiển thị: không có logic nghiệp
   vụ, không ai ngoài widget này quan tâm. Nguyên tắc: vào VM khi là
   dữ liệu màn hình hoặc cần test/chia sẻ; giữ trong State khi thuần
   ephemeral.*

## Ta cố ý chưa thêm

- **Provider/`ChangeNotifierProvider`** — M12: tay bạn vừa tự làm
  create+dispose để cảm nhận provider sẽ tự hoá điều gì.
- **Event stream một-lần** (`MenuGameRequested`, snackbar) — M13.
- **`GameViewModel`** — `GameScreen` giữ `setState` cố ý; M19 mới
  refactor game vì game cần timer/phase nặng hơn, và giữ nó cho bạn
  thấy hai mô hình tồn tại song song.

## Checkpoint hoàn thành

- [ ] `lib/view_models/menu/menu_view_model.dart` tồn tại, extends
  `ChangeNotifier`, chỉ import `foundation.dart` + data.
- [ ] VM có `_profile`/`profile`, `_loadState`/`loadState`,
  `load`/`applyGameResult`/`resetProfile`, `_setLoadState` guard.
- [ ] `_MenuScreenState` tạo VM trong `initState`, `dispose` nó, và
  không còn `_profile`/`_profileLoadFuture`.
