import 'package:flutter/material.dart';
import '../../models/content_data.dart';
import '../../theme/routine_colors.dart';

/// Desplegable "Todos los temas".
class ContentTopicDropdown extends StatelessWidget {
  final String selected;
  final ValueChanged<String> onChanged;

  const ContentTopicDropdown({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  String _label(ContentTab t) => t.value == 'all' ? 'Todos los temas' : t.label;

  @override
  Widget build(BuildContext context) {
    final tabs = ContentData.tabs;
    final current = tabs.firstWhere((t) => t.value == selected);

    return PopupMenuButton<String>(
      onSelected: onChanged,
      offset: const Offset(0, 48),
      color: RoutineColors.card,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: RoutineColors.border),
      ),
      itemBuilder: (_) => [
        for (final t in tabs)
          PopupMenuItem<String>(
            value: t.value,
            child: Text(
              _label(t),
              style: TextStyle(
                color: t.value == selected ? RoutineColors.blue : Colors.white,
                fontWeight: t.value == selected
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
              _label(current),
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

/// Chips horizontales de categorías.
class ContentCategoryTabs extends StatelessWidget {
  final String selected;
  final ValueChanged<String> onSelect;

  const ContentCategoryTabs({
    super.key,
    required this.selected,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final tabs = ContentData.tabs;

    return SizedBox(
      height: 38,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: tabs.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final t = tabs[i];
          final active = t.value == selected;
          return GestureDetector(
            onTap: () => onSelect(t.value),
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
                t.label,
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
