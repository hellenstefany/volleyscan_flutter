import 'package:flutter/material.dart';

import 'config_data.dart';
import 'config_nav_title.dart';

/// Navegación entre secciones: vertical (pantallas anchas) u horizontal (móvil).
class ConfigNav extends StatelessWidget {
  final String section;
  final ValueChanged<String> onSelect;
  final bool horizontal;

  const ConfigNav({
    super.key,
    required this.section,
    required this.onSelect,
    this.horizontal = false,
  });

  @override
  Widget build(BuildContext context) {
    if (!horizontal) {
      return Column(
        children: [
          for (final n in configNavItems)
            ConfigNavTile(
              icon: n.$3,
              label: n.$2,
              active: section == n.$1,
              onTap: () => onSelect(n.$1),
            ),
        ],
      );
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (final n in configNavItems)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ConfigNavTile(
                icon: n.$3,
                label: n.$2,
                active: section == n.$1,
                compact: true,
                onTap: () => onSelect(n.$1),
              ),
            ),
        ],
      ),
    );
  }
}
