import 'package:flutter/material.dart';

import 'dashboard_avatar.dart';
import 'dashboard_models.dart';
import 'dashboard_theme.dart';

class DashboardActivityRow extends StatelessWidget {
  final DashboardActivity activity;

  const DashboardActivityRow({super.key, required this.activity});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        hoverColor: Colors.white.withOpacity(0.04),
        onTap: () {},
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          child: Row(
            children: [
              DashboardAvatar(
                text: activity.initials,
                bg: activity.bg,
                size: 36,
                fontSize: activity.icon ? 18 : 13,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      activity.name,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: DashboardTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 1),
                    Text(
                      activity.action,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 11,
                        color: DashboardTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                activity.time,
                style: const TextStyle(
                  fontSize: 11,
                  color: DashboardTheme.textMuted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
