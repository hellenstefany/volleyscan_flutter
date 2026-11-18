import 'package:flutter/material.dart';
import '../../../models/notification_data.dart';
import '../../../theme/dash_colors.dart';

/// Chips horizontales para filtrar notificaciones.
class NotificationFilters extends StatelessWidget {
  final String selected;
  final ValueChanged<String> onSelect;

  const NotificationFilters({
    super.key,
    required this.selected,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final filters = NotificationsData.filters;

    return SizedBox(
      height: 38,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: filters.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final f = filters[i];
          final active = f.value == selected;
          return GestureDetector(
            onTap: () => onSelect(f.value),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: active ? DashColors.blueLight : DashColors.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: active ? DashColors.blueLight : DashColors.border,
                ),
              ),
              child: Text(
                f.label,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  color: active ? DashColors.textPrimary : DashColors.muted,
                  fontSize: 13.5,
                  fontWeight: active ? FontWeight.w600 : FontWeight.w500,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
