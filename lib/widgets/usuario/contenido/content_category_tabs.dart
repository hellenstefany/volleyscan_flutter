import 'package:flutter/material.dart';
import '../../../models/content_data.dart';
import '../../../theme/app_theme.dart';
import '../../../theme/dash_colors.dart';

/// Desplegable "Todos los temas" (`.filter-btn` + `.filter-dropdown` en `contenido.css`).
class ContentTopicDropdown extends StatelessWidget {
  final String selected;
  final ValueChanged<String> onChanged;

  const ContentTopicDropdown({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  String _label(ContentTab t) =>
      t.value == 'all' ? 'Todos los temas' : t.label;

  @override
  Widget build(BuildContext context) {
    final tabs = ContentData.tabs;
    final current = tabs.firstWhere(
      (t) => t.value == selected,
      orElse: () => tabs.first,
    );

    return PopupMenuButton<String>(
      onSelected: onChanged,
      offset: const Offset(0, 44),
      color: DashColors.surface,
      elevation: 10,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadii.sm),
        side: const BorderSide(color: DashColors.border2),
      ),
      itemBuilder: (_) => [
        for (final t in tabs)
          PopupMenuItem<String>(
            value: t.value,
            height: 40,
            child: Text(
              _label(t),
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 13,
                color: t.value == selected
                    ? DashColors.blueLight
                    : DashColors.textSecondary,
                fontWeight: t.value == selected
                    ? FontWeight.w600
                    : FontWeight.w400,
              ),
            ),
          ),
      ],
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: DashColors.surface,
          borderRadius: BorderRadius.circular(AppRadii.sm),
          border: Border.all(color: DashColors.border2),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _label(current),
              style: const TextStyle(
                fontFamily: 'Poppins',
                color: DashColors.textSecondary,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: 8),
            const Icon(
              Icons.keyboard_arrow_down_rounded,
              size: 18,
              color: DashColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}

/// Pestañas de categorías (`.category-tabs` / `.tab-btn` en `contenido.css`).
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
      height: 36,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: tabs.length,
        separatorBuilder: (_, _) => const SizedBox(width: 6),
        itemBuilder: (_, i) {
          final t = tabs[i];
          final active = t.value == selected;
          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => onSelect(t.value),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: active ? DashColors.blueLight : DashColors.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: active ? DashColors.blueLight : DashColors.border,
                ),
              ),
              child: Text(
                t.label,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  color: active
                      ? DashColors.textPrimary
                      : DashColors.textSecondary,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
