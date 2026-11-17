import 'package:flutter/material.dart';

import 'dashboard_models.dart';
import 'dashboard_theme.dart';

/// Selector de período (menú desplegable).
class DashboardDatePicker extends StatelessWidget {
  final String label;
  final ValueChanged<String> onSelected;

  const DashboardDatePicker({
    super.key,
    required this.label,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      color: DashboardTheme.bgCard,
      offset: const Offset(0, 46),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: DashboardTheme.border),
      ),
      onSelected: onSelected,
      itemBuilder: (_) => dashboardDateOptions
          .map(
            (d) => PopupMenuItem(
              value: d,
              child: Text(
                d,
                style: TextStyle(
                  fontSize: 13,
                  color: d == label
                      ? DashboardTheme.blue
                      : DashboardTheme.textSecondary,
                ),
              ),
            ),
          )
          .toList(),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        decoration: BoxDecoration(
          color: DashboardTheme.bgCard,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: DashboardTheme.border),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                color: DashboardTheme.textPrimary,
              ),
            ),
            const SizedBox(width: 8),
            const Icon(
              Icons.keyboard_arrow_down,
              size: 16,
              color: DashboardTheme.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}
