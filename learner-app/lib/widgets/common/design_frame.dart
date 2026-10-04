import 'package:flutter/material.dart';
import '../../core/app_design_tokens.dart';

class DesignFrame extends StatelessWidget {
  final Widget child;

  const DesignFrame({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth: AppTokens.screenDesignWidth,
        ),
        child: child,
      ),
    );
  }
}
