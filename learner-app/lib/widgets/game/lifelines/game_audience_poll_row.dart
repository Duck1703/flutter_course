import 'package:flutter/material.dart';

import '../../../core/app_design_tokens.dart';
import '../../../data/game/game_session_state_data.dart';

class AudiencePollRow extends StatelessWidget {
  final GameAudiencePollItemData item;

  const AudiencePollRow({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: AppTokens.spacingXl,
      child: Row(
        children: [
          SizedBox(
            width: AppTokens.iconLg,
            child: Text(
              item.option,
              textAlign: TextAlign.center,
              style: AppTokens.qzdsSubtitle2.copyWith(color: Colors.black),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppTokens.spacingSm,
              ),
              child: LinearProgressIndicator(
                value: item.progress,
                color: AppTokens.qzdsPurple500,
                backgroundColor: Colors.black12,
                borderRadius: BorderRadius.circular(AppTokens.radiusN),
              ),
            ),
          ),
          Text(
            item.percentage,
            style: AppTokens.qzdsSubtitle2.copyWith(color: Colors.black),
          ),
        ],
      ),
    );
  }
}
