import 'package:flutter/material.dart';

import 'analisis_theme.dart';

class AnalisisActionBtn extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;
  final bool confirmed;
  const AnalisisActionBtn({
    super.key,
    required this.icon,
    required this.tooltip,
    required this.onTap,
    this.confirmed = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = confirmed
        ? AnalisisTheme.success
        : AnalisisTheme.textSecondary;
    return Tooltip(
      message: tooltip,
      child: InkWell(
        borderRadius: BorderRadius.circular(7),
        onTap: onTap,
        child: Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(7),
            border: Border.all(
              color: confirmed ? AnalisisTheme.success : Colors.transparent,
            ),
          ),
          child: Icon(icon, size: 15, color: color),
        ),
      ),
    );
  }
}
