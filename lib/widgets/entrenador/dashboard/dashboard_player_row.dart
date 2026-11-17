import 'package:flutter/material.dart';

import 'dashboard_avatar.dart';
import 'dashboard_models.dart';
import 'dashboard_theme.dart';

class DashboardPlayerRow extends StatelessWidget {
  final int rank;
  final DashboardPlayerData player;
  final VoidCallback onTap;

  const DashboardPlayerRow({
    super.key,
    required this.rank,
    required this.player,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        hoverColor: Colors.white.withOpacity(0.04),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          child: Row(
            children: [
              SizedBox(
                width: 16,
                child: Text(
                  '$rank',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: DashboardTheme.textMuted,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              DashboardAvatar(
                text: player.initials,
                bg: player.bg,
                size: 32,
                fontSize: 13,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  player.name,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: DashboardTheme.textPrimary,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    height: 5,
                    color: Colors.white.withOpacity(0.08),
                    alignment: Alignment.centerLeft,
                    child: TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0, end: player.pct / 100),
                      duration: const Duration(seconds: 1),
                      curve: Curves.easeOut,
                      builder: (_, v, __) => FractionallySizedBox(
                        widthFactor: v,
                        child: Container(color: player.color),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              SizedBox(
                width: 38,
                child: Text(
                  '${player.pct}%',
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: player.color,
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
