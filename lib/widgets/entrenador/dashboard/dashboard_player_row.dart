import 'package:flutter/material.dart';

import 'dashboard_avatar.dart';
import 'dashboard_models.dart';
import 'dashboard_theme.dart';

class DashboardPlayerRow extends StatelessWidget {
  final int rank;
  final EntrenadorUltimoPartido partido;
  final Color color;
  final Color bg;
  final VoidCallback onTap;

  const DashboardPlayerRow({
    super.key,
    required this.rank,
    required this.partido,
    required this.color,
    required this.bg,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final pct = partido.porcentajeSets;

    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        hoverColor: DashboardTheme.border,
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
                text: partido.iniciales,
                bg: bg,
                size: 32,
                fontSize: 13,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'vs ${partido.rival} (${partido.setsGanados}-${partido.setsPerdidos})',
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
                    color: DashboardTheme.border,
                    alignment: Alignment.centerLeft,
                    child: TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0, end: (pct.clamp(0, 100)) / 100),
                      duration: const Duration(milliseconds: 800),
                      curve: Curves.easeOut,
                      builder: (_, v, _) => FractionallySizedBox(
                        widthFactor: v,
                        child: Container(color: color),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              SizedBox(
                width: 38,
                child: Text(
                  '$pct%',
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: color,
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
