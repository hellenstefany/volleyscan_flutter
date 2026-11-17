import 'package:flutter/material.dart';

import 'config_theme.dart';

class ConfigFieldRow extends StatelessWidget {
  final String name;
  final String? desc;
  final Widget? trailing;
  final bool last;
  final bool small;

  const ConfigFieldRow({
    super.key,
    required this.name,
    this.desc,
    this.trailing,
    this.last = false,
    this.small = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        border: last
            ? null
            : const Border(bottom: BorderSide(color: ConfigTheme.border)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(
                    fontSize: small ? 12 : 13.5,
                    fontWeight: FontWeight.w500,
                    color: ConfigTheme.text,
                  ),
                ),
                if (desc != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    desc!,
                    style: const TextStyle(
                      fontSize: 12,
                      color: ConfigTheme.muted,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (trailing != null) ...[const SizedBox(width: 12), trailing!],
        ],
      ),
    );
  }
}
