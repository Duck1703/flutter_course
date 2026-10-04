sealed class MenuScreenUiEvent {
  const MenuScreenUiEvent();
}

final class MenuGameRequested extends MenuScreenUiEvent {
  const MenuGameRequested();
}

final class MenuSnackBarRequested extends MenuScreenUiEvent {
  final String message;

  const MenuSnackBarRequested(this.message);
}
