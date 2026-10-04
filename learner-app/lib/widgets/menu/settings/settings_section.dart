import 'package:flutter/material.dart';

import '../../../core/app_design_tokens.dart';

/// Labelled group inside the settings dialog. Grouping replaces the previous
/// flat row list so related switches read as one decision.
class SettingsSection extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const SettingsSection({
    super.key,
    required this.title,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          title.toUpperCase(),
          style: AppTokens.caption2.copyWith(color: AppTokens.qzdsPurple600),
        ),
        const SizedBox(height: AppTokens.spacingXs),
        for (var index = 0; index < children.length; index++) ...[
          if (index > 0) const SizedBox(height: AppTokens.qzdsSpacingXs + 2),
          children[index],
        ],
      ],
    );
  }
}
