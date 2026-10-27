import 'package:flutter/material.dart';
import '../../models/session_data.dart';
import '../../theme/routine_colors.dart';

/// Botón desplegable "Todas las técnicas".
class SessionFilterDropdown extends StatelessWidget {
  final String selected;
  final ValueChanged<String> onChanged;

  const SessionFilterDropdown({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final filters = SessionsData.filters;
    final label = filters.firstWhere((f) => f.value == selected).label;

    return PopupMenuButton<String>(
      onSelected: onChanged,
      offset: const Offset(0, 48),
      color: RoutineColors.card,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: RoutineColors.border),
      ),
      itemBuilder: (_) => [
        for (final f in filters)
          PopupMenuItem<String>(
            value: f.value,
            child: Text(
              f.label,
              style: TextStyle(
                color: f.value == selected ? RoutineColors.blue : Colors.white,
                fontWeight: f.value == selected
                    ? FontWeight.w700
                    : FontWeight.w400,
              ),
            ),
          ),
      ],
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: RoutineColors.cardDark,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: RoutineColors.border),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: const TextStyle(color: Colors.white, fontSize: 14),
            ),
            const SizedBox(width: 10),
            const Icon(
              Icons.keyboard_arrow_down_rounded,
              size: 20,
              color: Colors.white,
            ),
          ],
        ),
      ),
    );
  }
}
