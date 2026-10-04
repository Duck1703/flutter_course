sealed class MenuDialogState {
  const MenuDialogState();

  bool get isVisible => this is! MenuDialogNone;

  Object get transitionKey => runtimeType;
}

final class MenuDialogNone extends MenuDialogState {
  const MenuDialogNone();

  @override
  bool operator ==(Object other) => other is MenuDialogNone;

  @override
  int get hashCode => 0;
}

final class MenuDialogLeaderboard extends MenuDialogState {
  const MenuDialogLeaderboard();

  @override
  bool operator ==(Object other) => other is MenuDialogLeaderboard;

  @override
  int get hashCode => 1;
}

final class MenuDialogSettings extends MenuDialogState {
  const MenuDialogSettings();

  @override
  bool operator ==(Object other) => other is MenuDialogSettings;

  @override
  int get hashCode => 2;
}

final class MenuDialogAuth extends MenuDialogState {
  const MenuDialogAuth();

  @override
  bool operator ==(Object other) => other is MenuDialogAuth;

  @override
  int get hashCode => 3;
}

final class MenuDialogSignOut extends MenuDialogState {
  const MenuDialogSignOut();

  @override
  bool operator ==(Object other) => other is MenuDialogSignOut;

  @override
  int get hashCode => 4;
}
