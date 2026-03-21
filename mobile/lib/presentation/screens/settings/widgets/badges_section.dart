import 'package:flutter/material.dart';
import '../../../../data/services/badge_service.dart';

class BadgesSection extends StatelessWidget {
  const BadgesSection({super.key, required this.earnedBadges});

  final Set<String> earnedBadges;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
        ),
        itemCount: BadgeService.allBadges.length,
        itemBuilder: (ctx, i) {
          final badge = BadgeService.allBadges[i];
          final earned = earnedBadges.contains(badge.id);
          return Tooltip(
            message: badge.description,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  badge.icon,
                  style: TextStyle(
                    fontSize: 28,
                    color: earned ? null : Colors.grey,
                  ),
                ),
                Text(
                  badge.name,
                  style: TextStyle(
                    fontSize: 9,
                    color: earned ? null : Colors.grey,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
