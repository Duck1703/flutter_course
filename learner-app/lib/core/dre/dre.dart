abstract interface class DreAction {}

abstract interface class DreEffect {}

abstract interface class DreAsyncOp {}

abstract interface class DreReducer<
  S,
  A extends DreAction,
  E extends DreEffect,
  O extends DreAsyncOp
> {
  DreResult<S, E, O> reduce(S state, A action);
}

final class DreResult<S, E extends DreEffect, O extends DreAsyncOp> {
  final S state;
  final List<E> effects;
  final O? asyncOp;

  const DreResult({required this.state, this.effects = const [], this.asyncOp});
}
