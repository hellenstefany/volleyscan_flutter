import 'package:flutter/material.dart';

import 'analisis_theme.dart';

class AnalisisHeader extends StatelessWidget {
  final bool narrow;
  final bool hasMessages;
  final VoidCallback? onReset;

  const AnalisisHeader({
    super.key,
    required this.narrow,
    this.hasMessages = false,
    this.onReset,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(narrow ? 64 : 28, 20, narrow ? 16 : 28, 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Chat IA',
            style: TextStyle(
              fontSize: 16.8,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.2,
              color: AnalisisTheme.text,
            ),
          ),
          if (hasMessages && onReset != null)
            TextButton.icon(
              onPressed: onReset,
              icon: const Icon(
                Icons.add_comment_outlined,
                size: 15,
                color: AnalisisTheme.text2,
              ),
              label: const Text(
                'Nueva consulta',
                style: TextStyle(
                  fontSize: 12.2,
                  fontWeight: FontWeight.w600,
                  color: AnalisisTheme.text2,
                ),
              ),
              style: TextButton.styleFrom(
                backgroundColor: AnalisisTheme.surface,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(999),
                  side: const BorderSide(color: AnalisisTheme.lineStrong),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
