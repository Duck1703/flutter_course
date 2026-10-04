part of 'menu_auth_dialog.dart';

enum _EmailAuthMode { signIn, register }

const _authFadeDuration = Duration(milliseconds: 380);
const _authSizeDuration = Duration(milliseconds: 320);
const double _googleGlyphSize = 26;
const double _appleGlyphSize = 20;

Widget _authFadeSlideTransition(Widget child, Animation<double> animation) {
  final fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
    CurvedAnimation(
      parent: animation,
      curve: Curves.easeInOutCubic,
      reverseCurve: Curves.easeInOutCubic,
    ),
  );
  final offsetAnimation =
      Tween<Offset>(begin: const Offset(0, 0.08), end: Offset.zero).animate(
        CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
          reverseCurve: Curves.easeInCubic,
        ),
      );
  final scaleAnimation = Tween<double>(begin: 0.96, end: 1).animate(
    CurvedAnimation(
      parent: animation,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    ),
  );

  return FadeTransition(
    opacity: fadeAnimation,
    child: SlideTransition(
      position: offsetAnimation,
      child: ScaleTransition(
        scale: scaleAnimation,
        alignment: Alignment.topCenter,
        child: child,
      ),
    ),
  );
}

Widget _authFadeOnlyTransition(Widget child, Animation<double> animation) {
  final fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
    CurvedAnimation(
      parent: animation,
      curve: Curves.easeInOutCubic,
      reverseCurve: Curves.easeInOutCubic,
    ),
  );

  return FadeTransition(opacity: fadeAnimation, child: child);
}

Widget _authSwitcherLayout(
  Widget? currentChild,
  List<Widget> previousChildren,
) {
  return Stack(
    alignment: Alignment.topCenter,
    clipBehavior: Clip.none,
    children: <Widget>[...previousChildren, ?currentChild],
  );
}

class _AuthMethodButtons extends StatelessWidget {
  final AppLocalizations l10n;
  final bool showApple;
  final VoidCallback onSignInWithGoogle;
  final VoidCallback onSignInWithApple;
  final VoidCallback onShowEmailForm;
  final VoidCallback onContinueAsGuest;

  const _AuthMethodButtons({
    super.key,
    required this.l10n,
    required this.showApple,
    required this.onSignInWithGoogle,
    required this.onSignInWithApple,
    required this.onShowEmailForm,
    required this.onContinueAsGuest,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedSize(
      key: const ValueKey('auth-method-buttons-size'),
      duration: _authSizeDuration,
      curve: Curves.easeOutCubic,
      alignment: Alignment.topCenter,
      clipBehavior: Clip.none,
      child: Column(
        children: [
          OnboardingGameButton(
            text: l10n.signInWithGoogleButton,
            color: OnboardingTokens.purple500,
            icon: Icons.g_mobiledata,
            iconSize: _googleGlyphSize,
            onTap: onSignInWithGoogle,
          ),
          AnimatedSwitcher(
            duration: _authFadeDuration,
            reverseDuration: _authFadeDuration,
            switchInCurve: Curves.easeOutCubic,
            switchOutCurve: Curves.easeInCubic,
            transitionBuilder: _authFadeSlideTransition,
            layoutBuilder: _authSwitcherLayout,
            child: showApple
                ? Column(
                    key: const ValueKey('auth-apple-method-visible'),
                    children: [
                      const SizedBox(height: AppTokens.spacingXs),
                      OnboardingGameButton(
                        text: l10n.signInWithAppleButton,
                        color: AppTokens.blue900,
                        icon: Icons.apple,
                        iconSize: _appleGlyphSize,
                        onTap: onSignInWithApple,
                      ),
                    ],
                  )
                : const SizedBox.shrink(
                    key: ValueKey('auth-apple-method-hidden'),
                  ),
          ),
          const SizedBox(height: AppTokens.spacingXs),
          OnboardingGameButton(
            text: l10n.signInWithEmailButton,
            color: OnboardingTokens.blue500,
            icon: Icons.mail,
            onTap: onShowEmailForm,
          ),
          const SizedBox(height: AppTokens.spacingXs),
          OnboardingGameButton(
            text: l10n.continueAsGuestButton,
            color: OnboardingTokens.grey600,
            icon: Icons.person,
            onTap: onContinueAsGuest,
          ),
        ],
      ),
    );
  }
}

class _EmailForm extends StatelessWidget {
  final AppLocalizations l10n;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final TextEditingController confirmPasswordController;
  final _EmailAuthMode mode;
  final String? errorText;
  final bool canSubmit;
  final VoidCallback onSignIn;
  final VoidCallback onSignUp;
  final VoidCallback onShowRegister;
  final VoidCallback onShowSignIn;
  final VoidCallback onBack;

  const _EmailForm({
    super.key,
    required this.l10n,
    required this.emailController,
    required this.passwordController,
    required this.confirmPasswordController,
    required this.mode,
    required this.errorText,
    required this.canSubmit,
    required this.onSignIn,
    required this.onSignUp,
    required this.onShowRegister,
    required this.onShowSignIn,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    final isRegisterMode = mode == _EmailAuthMode.register;
    final submitColor = canSubmit
        ? (isRegisterMode
              ? OnboardingTokens.purple500
              : OnboardingTokens.blue500)
        : OnboardingTokens.grey600;

    return AnimatedSize(
      key: const ValueKey('auth-email-form-size'),
      duration: _authSizeDuration,
      curve: Curves.easeOutCubic,
      alignment: Alignment.topCenter,
      clipBehavior: Clip.none,
      child: Column(
        children: [
          _AuthTextField(
            controller: emailController,
            labelText: l10n.emailFieldLabel,
            icon: Icons.mail,
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: AppTokens.qzdsSpacingSm),
          _AuthTextField(
            controller: passwordController,
            labelText: l10n.passwordFieldLabel,
            icon: Icons.lock,
            obscureText: true,
          ),
          _AnimatedAuthSection(
            visible: isRegisterMode,
            visibleKey: 'auth-confirm-password-field',
            child: Column(
              children: [
                const SizedBox(height: AppTokens.qzdsSpacingSm),
                _AuthTextField(
                  controller: confirmPasswordController,
                  labelText: l10n.confirmPasswordFieldLabel,
                  icon: Icons.lock,
                  obscureText: true,
                ),
              ],
            ),
          ),
          _AnimatedAuthSection(
            visible: errorText != null,
            visibleKey: 'auth-error-text',
            child: Column(
              children: [
                const SizedBox(height: AppTokens.spacingXs),
                Text(
                  errorText ?? '',
                  textAlign: TextAlign.center,
                  style: AppTokens.qzdsCaption1.copyWith(
                    color: AppTokens.red500,
                  ),
                ),
              ],
            ),
          ),
          _EmailFormActions(
            mode: mode,
            l10n: l10n,
            submitColor: submitColor,
            canSubmit: canSubmit,
            onSignIn: onSignIn,
            onSignUp: onSignUp,
            onShowRegister: onShowRegister,
            onShowSignIn: onShowSignIn,
          ),
          const SizedBox(height: AppTokens.spacingXs),
          TextButton.icon(
            onPressed: onBack,
            icon: const Icon(
              Icons.arrow_back,
              size: AppTokens.qzdsIconSm,
              color: OnboardingTokens.blue500,
            ),
            label: Text(
              l10n.backButton,
              style: AppTokens.qzdsBody1.copyWith(
                color: OnboardingTokens.blue500,
                fontWeight: FontWeight.w600,
                fontSize: 15,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmailFormActions extends StatelessWidget {
  final _EmailAuthMode mode;
  final AppLocalizations l10n;
  final Color submitColor;
  final bool canSubmit;
  final VoidCallback onSignIn;
  final VoidCallback onSignUp;
  final VoidCallback onShowRegister;
  final VoidCallback onShowSignIn;

  const _EmailFormActions({
    required this.mode,
    required this.l10n,
    required this.submitColor,
    required this.canSubmit,
    required this.onSignIn,
    required this.onSignUp,
    required this.onShowRegister,
    required this.onShowSignIn,
  });

  @override
  Widget build(BuildContext context) {
    final isRegisterMode = mode == _EmailAuthMode.register;

    return Column(
      children: [
        const SizedBox(height: AppTokens.spacingMd),
        AnimatedSwitcher(
          duration: _authFadeDuration,
          reverseDuration: _authFadeDuration,
          switchInCurve: Curves.easeInOutCubic,
          switchOutCurve: Curves.easeInOutCubic,
          transitionBuilder: _authFadeOnlyTransition,
          layoutBuilder: _authSwitcherLayout,
          child: OnboardingGameButton(
            key: ValueKey('auth-submit-button-${mode.name}'),
            text: isRegisterMode ? l10n.createAccountButton : l10n.signInButton,
            color: submitColor,
            icon: isRegisterMode ? Icons.person_add : Icons.login,
            onTap: canSubmit ? (isRegisterMode ? onSignUp : onSignIn) : null,
          ),
        ),
        const SizedBox(height: AppTokens.spacingXs),
        AnimatedSwitcher(
          duration: _authFadeDuration,
          reverseDuration: _authFadeDuration,
          switchInCurve: Curves.easeInOutCubic,
          switchOutCurve: Curves.easeInOutCubic,
          transitionBuilder: _authFadeOnlyTransition,
          layoutBuilder: _authSwitcherLayout,
          child: TextButton.icon(
            key: ValueKey('auth-mode-toggle-${mode.name}'),
            onPressed: isRegisterMode ? onShowSignIn : onShowRegister,
            icon: Icon(
              isRegisterMode ? Icons.login : Icons.person_add,
              size: AppTokens.qzdsIconXs,
              color: OnboardingTokens.blue500,
            ),
            label: Text(
              isRegisterMode ? l10n.signInButton : l10n.createAccountButton,
              style: AppTokens.qzdsCaption1.copyWith(
                color: OnboardingTokens.blue500,
                fontWeight: FontWeight.w700,
                fontSize: 13,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _AnimatedAuthSection extends StatelessWidget {
  final bool visible;
  final String visibleKey;
  final Widget child;

  const _AnimatedAuthSection({
    required this.visible,
    required this.visibleKey,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedCrossFade(
      duration: _authFadeDuration,
      reverseDuration: _authFadeDuration,
      firstCurve: Curves.easeInOutCubic,
      secondCurve: Curves.easeInOutCubic,
      sizeCurve: Curves.easeOutCubic,
      firstChild: SizedBox.shrink(key: ValueKey('$visibleKey-hidden')),
      secondChild: KeyedSubtree(
        key: ValueKey('$visibleKey-visible'),
        child: child,
      ),
      crossFadeState: visible
          ? CrossFadeState.showSecond
          : CrossFadeState.showFirst,
    );
  }
}

class _AuthTextField extends StatelessWidget {
  final TextEditingController controller;
  final String labelText;
  final IconData icon;
  final TextInputType? keyboardType;
  final bool obscureText;

  const _AuthTextField({
    required this.controller,
    required this.labelText,
    required this.icon,
    this.keyboardType,
    this.obscureText = false,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      enableSuggestions: !obscureText,
      autocorrect: !obscureText,
      style: AppTokens.qzdsBody1.copyWith(color: AppTokens.qzdsBlack600),
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: AppTokens.qzdsCaption1.copyWith(
          color: AppTokens.qzdsBlack600,
        ),
        prefixIcon: Icon(
          icon,
          size: AppTokens.qzdsIconSm,
          color: AppTokens.qzdsBlack600,
        ),
        filled: true,
        fillColor: AppTokens.qzdsGrey100,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppTokens.spacingMd,
          vertical: AppTokens.spacingSm,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTokens.qzdsRadiusMd),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
