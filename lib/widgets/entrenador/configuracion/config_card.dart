import 'package:flutter/material.dart';

import 'config_theme.dart';

class ConfigCard extends StatelessWidget {
  final String? title;
  final Color titleColor;
  final Color borderColor;
  final List<Widget> children;

  const ConfigCard({
    super.key,
    this.title,
    this.titleColor = ConfigTheme.text,
    this.borderColor = ConfigTheme.border,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: ConfigTheme.panel2,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null) ...[
            Text(
              title!,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
                color: titleColor,
              ),
            ),
            const SizedBox(height: 14),
          ],
          ...children,
        ],
      ),
    );
  }
}
