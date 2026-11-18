import 'package:flutter/material.dart';

import 'config_theme.dart';

class ConfigSectionHeader extends StatelessWidget {
  final String title;
  final String desc;
  const ConfigSectionHeader(this.title, this.desc, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: ConfigTheme.text,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            desc,
            style: const TextStyle(fontSize: 13, color: ConfigTheme.muted),
          ),
        ],
      ),
    );
  }
}
