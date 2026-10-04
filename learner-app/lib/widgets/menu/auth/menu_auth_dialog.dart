import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/app_design_tokens.dart';
import '../../../core/onboarding_design_tokens.dart';
import '../../../l10n/app_localizations.dart';
import '../../../view_models/menu/menu_auth_dialog_view_model.dart';
import '../../onboarding/onboarding_game_button.dart';
import '../settings/settings_dialog_shell.dart';

part 'menu_auth_dialog_content.dart';

const _minimumPasswordLength = 6;

class MenuAuthDialog extends StatefulWidget {
  const MenuAuthDialog({super.key});

  @override
  State<MenuAuthDialog> createState() => _MenuAuthDialogState();
}

class _MenuAuthDialogState extends State<MenuAuthDialog> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  var _emailAuthMode = _EmailAuthMode.signIn;
  var _showEmailForm = false;
  String? _errorText;

  bool get _canSubmitEmailForm =>
      _emailController.text.trim().isNotEmpty &&
      _passwordController.text.isNotEmpty &&
      (_emailAuthMode == _EmailAuthMode.signIn ||
          _confirmPasswordController.text.isNotEmpty);

  @override
  void initState() {
    super.initState();
    _emailController.addListener(_handleEmailFormChanged);
    _passwordController.addListener(_handleEmailFormChanged);
    _confirmPasswordController.addListener(_handleEmailFormChanged);
  }

  @override
  void dispose() {
    _emailController.removeListener(_handleEmailFormChanged);
    _passwordController.removeListener(_handleEmailFormChanged);
    _confirmPasswordController.removeListener(_handleEmailFormChanged);
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<MenuAuthDialogViewModel>();
    final showApple = Theme.of(context).platform == TargetPlatform.iOS;
    final l10n = AppLocalizations.of(context);

    return SettingsDialogShell(
      headerText: l10n.syncProgressTitle.toUpperCase(),
      iconAsset: AppAssets.iconLevelRank,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            l10n.syncProgressDescription,
            textAlign: TextAlign.center,
            style: AppTokens.qzdsBody1.copyWith(
              color: AppTokens.qzdsBlack600,
              height: 1.4,
            ),
          ),
          const SizedBox(height: AppTokens.spacingMd),
          AnimatedSize(
            key: const ValueKey('auth-method-form-size'),
            duration: _authSizeDuration,
            curve: Curves.easeOutCubic,
            alignment: Alignment.topCenter,
            clipBehavior: Clip.none,
            child: AnimatedSwitcher(
              key: const ValueKey('auth-method-form-switcher'),
              duration: _authFadeDuration,
              reverseDuration: _authFadeDuration,
              switchInCurve: Curves.easeOutCubic,
              switchOutCurve: Curves.easeInCubic,
              transitionBuilder: _authFadeSlideTransition,
              layoutBuilder: _authSwitcherLayout,
              child: _showEmailForm
                  ? _EmailForm(
                      key: const ValueKey('auth-email-form'),
                      l10n: l10n,
                      emailController: _emailController,
                      passwordController: _passwordController,
                      confirmPasswordController: _confirmPasswordController,
                      mode: _emailAuthMode,
                      errorText: _errorText,
                      canSubmit: _canSubmitEmailForm && !viewModel.isLoading,
                      onSignIn: _submitEmailSignIn,
                      onSignUp: _submitEmailSignUp,
                      onShowRegister: _showRegisterForm,
                      onShowSignIn: _showSignInForm,
                      onBack: _hideEmailForm,
                    )
                  : _AuthMethodButtons(
                      key: const ValueKey('auth-method-buttons'),
                      l10n: l10n,
                      showApple: showApple,
                      onSignInWithGoogle: () {
                        viewModel.signInWithGoogle();
                      },
                      onSignInWithApple: () {
                        viewModel.signInWithApple();
                      },
                      onShowEmailForm: _showEmailFormView,
                      onContinueAsGuest: viewModel.continueAsGuest,
                    ),
            ),
          ),
        ],
      ),
    );
  }

  void _handleEmailFormChanged() {
    if (!mounted) return;
    setState(() => _errorText = null);
  }

  void _showEmailFormView() => _setAuthFormState(showEmailForm: true);

  void _showSignInForm() {
    _confirmPasswordController.clear();
    _setAuthFormState();
  }

  void _showRegisterForm() => _setAuthFormState(mode: _EmailAuthMode.register);

  void _hideEmailForm() => _setAuthFormState(showEmailForm: false);

  void _setAuthFormState({
    bool? showEmailForm,
    _EmailAuthMode mode = _EmailAuthMode.signIn,
  }) {
    setState(() {
      if (showEmailForm != null) _showEmailForm = showEmailForm;
      _emailAuthMode = mode;
      _errorText = null;
    });
  }

  Future<void> _submitEmailSignIn() async {
    if (!_validateEmailForm()) return;

    await context.read<MenuAuthDialogViewModel>().signInWithEmail(
      email: _emailController.text,
      password: _passwordController.text,
    );
  }

  Future<void> _submitEmailSignUp() async {
    if (!_validateRegisterForm()) return;

    await context.read<MenuAuthDialogViewModel>().signUpWithEmail(
      email: _emailController.text,
      password: _passwordController.text,
    );
  }

  void _setError(String? errorText) => setState(() => _errorText = errorText);

  bool _validateEmailForm() {
    final email = _emailController.text.trim();
    if (email.isEmpty || _passwordController.text.isEmpty) {
      _setError(AppLocalizations.of(context).enterEmailPasswordError);
      return false;
    }

    if (!email.contains('@')) {
      _setError(AppLocalizations.of(context).enterValidEmailError);
      return false;
    }

    _setError(null);
    return true;
  }

  bool _validateRegisterForm() {
    if (!_validateEmailForm()) return false;

    if (_confirmPasswordController.text.isEmpty) {
      _setError(AppLocalizations.of(context).confirmPasswordError);
      return false;
    }

    if (_passwordController.text.length < _minimumPasswordLength) {
      _setError(AppLocalizations.of(context).passwordMinLengthError);
      return false;
    }

    if (_passwordController.text != _confirmPasswordController.text) {
      _setError(AppLocalizations.of(context).passwordsDoNotMatchError);
      return false;
    }

    _setError(null);
    return true;
  }
}
