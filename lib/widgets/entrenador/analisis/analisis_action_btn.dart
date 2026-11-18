import 'package:flutter/material.dart';

import 'analisis_theme.dart';

class AnalisisActionBtn extends StatefulWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback? onTap;
  final bool confirmed;

  const AnalisisActionBtn({
    super.key,
    required this.icon,
    required this.tooltip,
    required this.onTap,
    this.confirmed = false,
  });

  @override
  State<AnalisisActionBtn> createState() => _AnalisisActionBtnState();
}

class _AnalisisActionBtnState extends State<AnalisisActionBtn> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final fg = widget.confirmed
        ? AnalisisTheme.confirmed
        : _hover
        ? AnalisisTheme.text
        : AnalisisTheme.text2;
    final borderColor = widget.confirmed
        ? AnalisisTheme.confirmed
        : _hover
        ? AnalisisTheme.accent.withValues(alpha: 0.6)
        : Colors.transparent;

    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: Tooltip(
        message: widget.tooltip,
        child: InkWell(
          borderRadius: BorderRadius.circular(7),
          onTap: widget.onTap,
          child: Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: _hover ? AnalisisTheme.surface2 : Colors.transparent,
              borderRadius: BorderRadius.circular(7),
              border: Border.all(color: borderColor),
            ),
            child: Icon(widget.icon, size: 15, color: fg),
          ),
        ),
      ),
    );
  }
}
