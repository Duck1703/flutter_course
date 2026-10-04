import 'dart:async';

import 'package:flutter/foundation.dart';

import 'dre.dart';

abstract class DreChangeNotifier<
  S,
  A extends DreAction,
  E extends DreEffect,
  O extends DreAsyncOp
>
    extends ChangeNotifier {
  final DreReducer<S, A, E, O> reducer;
  final StreamController<E> _effects;
  S _state;
  var _isDisposed = false;

  DreChangeNotifier({required this.reducer, required S initialState})
    : _state = initialState,
      _effects = StreamController<E>.broadcast();

  S get state => _state;

  Stream<E> get effects => _effects.stream;

  @protected
  void dispatch(A action) {
    if (_isDisposed) {
      return;
    }

    final result = reducer.reduce(_state, action);
    final previousState = _state;
    _state = result.state;

    if (previousState != _state) {
      notifyListeners();
    }

    for (final effect in result.effects) {
      if (!_effects.isClosed) {
        _effects.add(effect);
      }
    }

    final asyncOp = result.asyncOp;
    if (asyncOp != null) {
      unawaited(_executeAsyncOp(asyncOp, _state));
    }
  }

  @protected
  Future<void> executeAsyncOp(O asyncOp, S stateSnapshot);

  @protected
  void onAsyncOpError(Object error, StackTrace stackTrace) {}

  Future<void> _executeAsyncOp(O asyncOp, S stateSnapshot) async {
    try {
      await executeAsyncOp(asyncOp, stateSnapshot);
    } catch (error, stackTrace) {
      if (!_isDisposed) {
        onAsyncOpError(error, stackTrace);
      }
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    _effects.close();
    super.dispose();
  }
}
