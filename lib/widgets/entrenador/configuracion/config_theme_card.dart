import 'package:flutter/material.dart';

import 'config_data.dart';
import 'config_theme.dart';

class ConfigThemeCard extends StatelessWidget {
  final ConfigThemeOpt theme;
  final bool selected;
  final VoidCallback onTap;

  const ConfigThemeCard({
    super.key,
    required this.theme,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 120,
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: ConfigTheme.panel,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? ConfigTheme.accent : ConfigTheme.border,
            width: selected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Stack(
              children: [
                Container(
                  height: 60,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [theme.colors[0], theme.colors[1]],
                    ),
                  ),
                ),
                Positioned(
                  left: 8,
                  right: 8,
                  bottom: 6,
                  child: Container(
                    height: 4,
                    decoration: BoxDecoration(
                      color: theme.colors[2].withValues(alpha: 0.7),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
                if (selected)
                  Positioned(
                    top: 4,
                    right: 4,
                    child: Container(
                      width: 18,
                      height: 18,
                      decoration: const BoxDecoration(
                        color: ConfigTheme.accent,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check,
                        size: 12,
                        color: Colors.white,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              theme.name,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: ConfigTheme.text,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
