import 'package:flutter/material.dart';

import 'config_theme.dart';

class ConfigSelect extends StatelessWidget {
  final String value;
  final List<String> options;
  final ValueChanged<String> onChanged;
  final double width;

  const ConfigSelect({
    super.key,
    required this.value,
    required this.options,
    required this.onChanged,
    this.width = 170,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: 38,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: ConfigTheme.panel2,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: ConfigTheme.border),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          dropdownColor: const Color(0xFF1A1E30),
          icon: const Icon(
            Icons.keyboard_arrow_down,
            size: 18,
            color: ConfigTheme.muted,
          ),
          style: const TextStyle(color: ConfigTheme.text, fontSize: 13),
          items: options
              .map((o) => DropdownMenuItem(value: o, child: Text(o)))
              .toList(),
          onChanged: (x) {
            if (x != null) onChanged(x);
          },
        ),
      ),
    );
  }
}
