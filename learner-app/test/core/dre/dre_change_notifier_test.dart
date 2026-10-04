import 'dart:async';

import 'package:ai_millionaire_course/core/dre/dre.dart';
import 'package:ai_millionaire_course/core/dre/dre_change_notifier.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DreChangeNotifier', () {
    test('dispatch applies reducer state and notifies listeners', () {
      final viewModel = _TestDreViewModel();
      var notifyCount = 0;
      viewModel.addListener(() => notifyCount++);
      addTearDown(viewModel.dispose);

      viewModel.send(const _Increment());

      expect(viewModel.state.count, 1);
      expect(notifyCount, 1);
    });

    test('dispatch delivers effects without requiring state change', () async {
      final viewModel = _TestDreViewModel();
      addTearDown(viewModel.dispose);
      final effectExpectation = expectLater(
        viewModel.effects,
        emits(const _TestEffect('saved')),
      );

      viewModel.send(const _EmitEffect('saved'));

      await effectExpectation;
      expect(viewModel.state.count, 0);
    });

    test('async op receives post-reduce state snapshot', () async {
      final viewModel = _TestDreViewModel();
      addTearDown(viewModel.dispose);
      final snapshotExpectation = expectLater(
        viewModel.asyncSnapshots,
        emits(const _TestState(1)),
      );

      viewModel.send(const _StartAsync());

      await snapshotExpectation;
    });

    test('unchanged state does not notify listeners', () {
      final viewModel = _TestDreViewModel();
      var notifyCount = 0;
      viewModel.addListener(() => notifyCount++);
      addTearDown(viewModel.dispose);

      viewModel.send(const _NoChange());

      expect(viewModel.state.count, 0);
      expect(notifyCount, 0);
    });

    test('dispatch after dispose is ignored without leaking effects', () async {
      final viewModel = _TestDreViewModel();

      viewModel.dispose();
      viewModel.send(const _EmitEffect('ignored'));

      await expectLater(viewModel.effects, neverEmits(isA<_TestEffect>()));
      expect(viewModel.state.count, 0);
    });
  });
}

final class _TestDreViewModel
    extends
        DreChangeNotifier<_TestState, _TestAction, _TestEffect, _TestAsyncOp> {
  _TestDreViewModel()
    : _asyncSnapshots = StreamController<_TestState>.broadcast(),
      super(reducer: const _TestReducer(), initialState: const _TestState(0));

  final StreamController<_TestState> _asyncSnapshots;

  Stream<_TestState> get asyncSnapshots => _asyncSnapshots.stream;

  void send(_TestAction action) => dispatch(action);

  @override
  Future<void> executeAsyncOp(
    _TestAsyncOp asyncOp,
    _TestState stateSnapshot,
  ) async {
    _asyncSnapshots.add(stateSnapshot);
  }

  @override
  void dispose() {
    _asyncSnapshots.close();
    super.dispose();
  }
}

final class _TestReducer
    implements DreReducer<_TestState, _TestAction, _TestEffect, _TestAsyncOp> {
  const _TestReducer();

  @override
  DreResult<_TestState, _TestEffect, _TestAsyncOp> reduce(
    _TestState state,
    _TestAction action,
  ) {
    return switch (action) {
      _Increment() => DreResult(state: _TestState(state.count + 1)),
      _EmitEffect(:final message) => DreResult(
        state: state,
        effects: [_TestEffect(message)],
      ),
      _StartAsync() => DreResult(
        state: _TestState(state.count + 1),
        asyncOp: const _LoadAsync(),
      ),
      _NoChange() => DreResult(state: state),
    };
  }
}

final class _TestState {
  final int count;

  const _TestState(this.count);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is _TestState &&
          runtimeType == other.runtimeType &&
          count == other.count;

  @override
  int get hashCode => count.hashCode;
}

sealed class _TestAction implements DreAction {
  const _TestAction();
}

final class _Increment extends _TestAction {
  const _Increment();
}

final class _EmitEffect extends _TestAction {
  final String message;

  const _EmitEffect(this.message);
}

final class _StartAsync extends _TestAction {
  const _StartAsync();
}

final class _NoChange extends _TestAction {
  const _NoChange();
}

final class _TestEffect implements DreEffect {
  final String message;

  const _TestEffect(this.message);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is _TestEffect &&
          runtimeType == other.runtimeType &&
          message == other.message;

  @override
  int get hashCode => message.hashCode;
}

sealed class _TestAsyncOp implements DreAsyncOp {
  const _TestAsyncOp();
}

final class _LoadAsync extends _TestAsyncOp {
  const _LoadAsync();
}
