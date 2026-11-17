import 'package:flutter/material.dart';

import 'dashboard_models.dart';
import 'dashboard_theme.dart';

class DashboardKpiCard extends StatelessWidget {
  final DashboardKpi kpi;
  final bool narrow;

  const DashboardKpiCard({super.key, required this.kpi, required this.narrow});

  @override
  Widget build(BuildContext context) {
    final iconSize = narrow ? 34.0 : 44.0;

    final icon = Container(
      width: iconSize,
      height: iconSize,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: kpi.color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(kpi.icon, style: TextStyle(fontSize: narrow ? 17 : 20)),
    );

    final details = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          kpi.label,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: DashboardTheme.textSecondary,
          ),
        ),
        const SizedBox(height: 6),
        TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: kpi.value.toDouble()),
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeOut,
          builder: (_, value, __) => Text(
            '${value.floor()}${kpi.suffix}',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: narrow ? 25 : 28,
              fontWeight: FontWeight.w700,
              height: 1.05,
              color: DashboardTheme.textPrimary,
            ),
          ),
        ),
        if (kpi.sub != null) ...[
          const SizedBox(height: 4),
          Text(
            kpi.sub!,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 11,
              color: DashboardTheme.textMuted,
            ),
          ),
        ],
        if (kpi.delta != null) ...[
          const SizedBox(height: 5),
          Text(
            kpi.delta!,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: DashboardTheme.green,
            ),
          ),
        ],
      ],
    );

    return Container(
      constraints: BoxConstraints(minHeight: narrow ? 150 : 120),
      padding: EdgeInsets.all(narrow ? 12 : 18),
      decoration: BoxDecoration(
        color: DashboardTheme.bgCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: DashboardTheme.border),
      ),
      child: narrow
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [icon, const SizedBox(height: 10), details],
            )
          : Row(
              children: [
                icon,
                const SizedBox(width: 14),
                Expanded(child: details),
              ],
            ),
    );
  }
}
