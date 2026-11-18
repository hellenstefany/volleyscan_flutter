import 'package:flutter/material.dart';

import 'analisis_theme.dart';

class AnalisisSuggestionChip extends StatefulWidget {
  final String glifo;
  final String texto;
  final VoidCallback? onTap;

  const AnalisisSuggestionChip({
    super.key,
    required this.glifo,
    required this.texto,
    required this.onTap,
  });

  @override
  State<AnalisisSuggestionChip> createState() => _AnalisisSuggestionChipState();
}

class _AnalisisSuggestionChipState extends State<AnalisisSuggestionChip> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final disabled = widget.onTap == null;
    return Opacity(
      opacity: disabled ? 0.55 : 1,
      child: MouseRegion(
        onEnter: (_) => setState(() => _hover = true),
        onExit: (_) => setState(() => _hover = false),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(999),
            onTap: widget.onTap,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
              decoration: BoxDecoration(
                color: AnalisisTheme.surface,
                borderRadius: BorderRadius.circular(999),
                border: Border.all(
                  color: _hover && !disabled
                      ? AnalisisTheme.accent.withValues(alpha: 0.6)
                      : AnalisisTheme.lineStrong,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    widget.glifo,
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 10.9,
                      fontWeight: FontWeight.w700,
                      color: AnalisisTheme.accent,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    widget.texto,
                    style: TextStyle(
                      fontSize: 12.5,
                      color: _hover && !disabled
                          ? AnalisisTheme.text
                          : AnalisisTheme.text2,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
