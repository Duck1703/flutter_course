---
title: Lộ trình M01–M29
description: Toàn bộ 29 milestone của khoá học — từ flutter create đến tái xây dựng app senior.
sidebar:
  order: 2
---

Khoá học gồm **29 milestone** chia thành 7 phase (A–G). Mỗi milestone là một bước
có kết quả chạy được trong learner app — không có milestone thuần lý thuyết.

<span class="status status-available">AVAILABLE</span> = đã có nội dung đầy đủ ·
<span class="status status-planned">PLANNED</span> = đã thiết kế, chưa biên soạn.

## Phase A — Định hướng

| # | Milestone | Bạn học được | Kết quả nhìn thấy | Trạng thái |
|---|-----------|--------------|-------------------|-----------|
| M01 | Định hướng Flutter & chạy lần đầu | Giải phẫu project, `main()`/`runApp`, widget tree, Hot Reload | Màn hình tuỳ biến đầu tiên chạy được | <span class="status status-available">AVAILABLE</span> |
| M02 | Composition & layout tĩnh | Constraint flow (constraints xuống, size lên), Column/Row/Container/Expanded | Menu tĩnh giống cấu trúc app senior | <span class="status status-available">AVAILABLE</span> |
| M03 | Tương tác: StatefulWidget & setState | Widget/State split, `setState`, lifecycle cơ bản | Menu có tương tác: toggle + đếm bấm | <span class="status status-available">AVAILABLE</span> |

## Phase B — Nền tảng app nhỏ

| # | Milestone | Bạn học được | Kết quả nhìn thấy | Trạng thái |
|---|-----------|--------------|-------------------|-----------|
| M04 | Model bất biến & unit test đầu tiên | `final`, `copyWith`, `==`, null safety | Menu render từ model; `flutter test` xanh | <span class="status status-available">AVAILABLE</span> |
| M05 | Dart bất đồng bộ: Future | Event loop, `async`/`await`, `FutureBuilder` | Loading → hiện profile; `main()` async | <span class="status status-available">AVAILABLE</span> |
| M06 | Stream & StreamBuilder | `Stream`, subscription, dispose | Đồng hồ đếm live; stats theo stream | <span class="status status-available">AVAILABLE</span> |
| M07 | Điều hướng: Navigator push/pop | Route stack kiểu imperative | Menu → Game và quay lại | <span class="status status-available">AVAILABLE</span> |

## Phase C — Vòng lặp game cốt lõi

| # | Milestone | Bạn học được | Kết quả nhìn thấy | Trạng thái |
|---|-----------|--------------|-------------------|-----------|
| M08 | Mini-quiz: chọn đáp án | Enum nhẹ, list render, widget test đầu tiên | Quiz 3–5 câu chơi được | <span class="status status-available">AVAILABLE</span> |
| M09 | Trọn vẹn một ván game | Phase machine, `Timer`, `showDialog` | Thắng/thua/restart đầy đủ | <span class="status status-available">AVAILABLE</span> |
| M10 | Lưu local: SharedPreferences & JSON | Plugin, `toMap`/`fromMap` phòng thủ | Stats sống qua restart | <span class="status status-available">AVAILABLE</span> |

## Phase D — Kiến trúc state

| # | Milestone | Bạn học được | Kết quả nhìn thấy | Trạng thái |
|---|-----------|--------------|-------------------|-----------|
| M11 | ChangeNotifier & ListenableBuilder | Vì sao `setState` không scale | State menu nằm trong VM | <span class="status status-available">AVAILABLE</span> |
| M12 | Provider & dependency scope | Tree lookup, `read`/`watch` | AppScope + VM per screen | <span class="status status-available">AVAILABLE</span> |
| M13 | UI event một lần | Broadcast event stream + bridge | Điều hướng/snackbar qua VM | <span class="status status-available">AVAILABLE</span> |

## Phase E — App local giàu tính năng

| # | Milestone | Bạn học được | Kết quả nhìn thấy | Trạng thái |
|---|-----------|--------------|-------------------|-----------|
| M14 | Repository & BehaviorSubject | Contract + `ValueStream` | Repos stream vào UI | <span class="status status-available">AVAILABLE</span> |
| M15 | Sealed class & UI theo state | `sealed` + `switch` exhaustive | Dialog state sealed | <span class="status status-available">AVAILABLE</span> |
| M16 | Settings (persisted) | Switch rows, time picker | Cài đặt lưu qua restart | <span class="status status-available">AVAILABLE</span> |
| M17 | Localization en/vi | ARB + gen-l10n | Đổi ngôn ngữ runtime | <span class="status status-available">AVAILABLE</span> |
| M18 | Onboarding overlay | Overlay trong Stack, cờ show-once | Onboarding 3 bước | <span class="status status-available">AVAILABLE</span> |

## Phase F — Chiều sâu senior

| # | Milestone | Bạn học được | Kết quả nhìn thấy | Trạng thái |
|---|-----------|--------------|-------------------|-----------|
| M19 | Game v2: VM có cấu trúc | `GamePhase`, timer, thang tiền thật | Game chạy bằng VM | <span class="status status-available">AVAILABLE</span> |
| M20 | Lifeline & feature button | Feature một-lần, set/map | 50:50, khán giả, AI, walk-away | <span class="status status-available">AVAILABLE</span> |
| M21 | Dialog layer kiểu senior | Dialog = state trong `Stack`, `PopScope` | Bỏ hết `showDialog` trong game | <span class="status status-available">AVAILABLE</span> |
| M22 | Lưu kết quả & lên cấp | XP/level rules, save một lần | Menu cập nhật stats live | <span class="status status-available">AVAILABLE</span> |
| M23 | Supabase: bootstrap & leaderboard | dart-define, remote read, request guard | Leaderboard static→remote | <span class="status status-available">AVAILABLE</span> |
| M24 | Authentication | Sealed session, contract+disabled, provider thật | Guest + email/Google sign-in | <span class="status status-available">AVAILABLE</span> |
| M25 | Profile sync | Merge/upsert local↔remote | Stats đồng bộ backend | <span class="status status-available">AVAILABLE</span> |
| M26 | Kiến trúc senior: refactor DRE | dispatch→reduce→effects, `flowToken` | Game VM theo reducer senior | <span class="status status-available">AVAILABLE</span> |
| M27 | Platform extras | Notifications+tz, share, package_info | Nhắc lịch hằng ngày, share kết quả | <span class="status status-available">AVAILABLE</span> |
| M28 | Polish: animation & CustomPainter | `AnimationController`, painter, SVG | Vòng timer vẽ tay, motion | <span class="status status-available">AVAILABLE</span> |

## Phase G — Căn chỉnh với senior

| # | Milestone | Bạn học được | Kết quả nhìn thấy | Trạng thái |
|---|-----------|--------------|-------------------|-----------|
| M29 | Senior alignment pass | Menu dialog layer, audit cấu trúc, fidelity sweep | Parity checklist hoàn chỉnh | <span class="status status-available">AVAILABLE</span> |

:::note[Vì sao thứ tự này?]
Mỗi milestone chỉ phụ thuộc vào khái niệm đã dạy trước đó — đồ thị phụ thuộc được
suy ra từ code senior thật, không phải syllabus chung. Các phần nâng cao của app
senior (reducer DRE, dialog layer trong Stack, Supabase auth, CustomPainter) cố
ý nằm ở cuối vì chúng cần nền móng đã vững.
:::

Bắt đầu với [M01 — Định hướng Flutter & chạy lần đầu](/m01/).
