import 'package:flutter/material.dart';

import 'config_theme.dart';

enum ConfigBtnStyle { ghost, primary, danger, success }

class ConfigBtn extends StatelessWidget {
  final String label;
  final ConfigBtnStyle style;
  final VoidCallback onTap;
  final bool expand;
  final bool small;

  const ConfigBtn({
    super.key,
    required this.label,
    required this.style,
    required this.onTap,
    this.expand = false,
    this.small = false,
  });

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color fg;
    Color bd;
    switch (style) {
      case ConfigBtnStyle.primary:
        bg = ConfigTheme.accent;
        fg = Colors.white;
        bd = ConfigTheme.accent;
        break;
      case ConfigBtnStyle.danger:
        bg = ConfigTheme.danger.withValues(alpha: 0.1);
        fg = ConfigTheme.danger;
        bd = ConfigTheme.danger.withValues(alpha: 0.35);
        break;
      case ConfigBtnStyle.success:
        bg = ConfigTheme.accent5.withValues(alpha: 0.12);
        fg = ConfigTheme.accent5;
        bd = ConfigTheme.accent5.withValues(alpha: 0.35);
        break;
      case ConfigBtnStyle.ghost:
        bg = Colors.transparent;
        fg = ConfigTheme.muted;
        bd = ConfigTheme.border;
        break;
    }

    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: onTap,
      child: Container(
        width: expand ? double.infinity : null,
        padding: EdgeInsets.symmetric(
          horizontal: small ? 10 : 18,
          vertical: small ? 5 : 10,
        ),
        alignment: expand ? Alignment.center : null,
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: bd),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: small ? 11 : 13,
            fontWeight: FontWeight.w600,
            color: fg,
          ),
        ),
      ),
    );
  }
}
