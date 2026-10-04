import 'package:flutter/material.dart';

import '../../core/app_design_tokens.dart';
import '../../data/settings/supported_language_data.dart';

/// Segmented language picker shared by onboarding and the settings dialog.
class LanguageChipRow extends StatelessWidget {
  static const double chipMinHeight = AppTokens.qzdsChipHeight;

  final String? selectedLanguageCode;
  final ValueChanged<SupportedLanguageData> onLanguageSelected;

  const LanguageChipRow({
    super.key,
    required this.selectedLanguageCode,
    required this.onLanguageSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (final language in SupportedLanguageData.values) ...[
          Expanded(
            child: _LanguageChip(
              language: language,
              selected: selectedLanguageCode == language.code,
              onTap: () => onLanguageSelected(language),
            ),
          ),
          if (language != SupportedLanguageData.values.last)
            const SizedBox(width: AppTokens.qzdsSpacingXs * 2),
        ],
      ],
    );
  }
}

class _LanguageChip extends StatelessWidget {
  final SupportedLanguageData language;
  final bool selected;
  final VoidCallback onTap;

  const _LanguageChip({
    required this.language,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      selected: selected,
      button: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: AnimatedContainer(
          duration: AppTokens.motionMedium,
          constraints: const BoxConstraints(
            minHeight: LanguageChipRow.chipMinHeight,
          ),
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(
            horizontal: AppTokens.spacingXs,
            vertical: AppTokens.qzdsSpacingXs,
          ),
          decoration: BoxDecoration(
            color: selected ? AppTokens.qzdsYellow500 : AppTokens.white100,
            borderRadius: BorderRadius.circular(AppTokens.qzdsRadiusMd),
            border: Border.all(
              color: selected
                  ? AppTokens.qzdsYellow600
                  : AppTokens.qzdsPurple100,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                selected ? Icons.check_circle : Icons.circle_outlined,
                size: AppTokens.qzdsIconXs,
                color: selected
                    ? AppTokens.white100
                    : AppTokens.qzdsPurple100,
              ),
              const SizedBox(width: AppTokens.qzdsSpacingXs + 2),
              Flexible(
                child: Text(
                  language.nativeName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: AppTokens.body5.copyWith(
                    color: selected
                        ? AppTokens.white100
                        : AppTokens.qzdsBlack600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
