import 'package:flutter/material.dart';
import '../../models/notification_data.dart';
import '../../theme/routine_colors.dart';

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
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final f = filters[i];
          final active = f.value == selected;
          return GestureDetector(
            onTap: () => onSelect(f.value),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: active ? RoutineColors.blue : RoutineColors.cardDark,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: active ? RoutineColors.blue : RoutineColors.border,
                ),
              ),
              child: Text(
                f.label,
                style: TextStyle(
                  color: active ? Colors.white : RoutineColors.textMuted,
                  fontSize: 14,
                  fontWeight: active ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
