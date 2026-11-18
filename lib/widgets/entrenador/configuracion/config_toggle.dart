import 'package:flutter/material.dart';

import 'config_data.dart';
import 'config_theme.dart';

class ConfigToggle extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;
  const ConfigToggle({super.key, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: 42,
        height: 24,
        padding: const EdgeInsets.all(3),
        alignment: value ? Alignment.centerRight : Alignment.centerLeft,
        decoration: BoxDecoration(
          color: value
              ? ConfigTheme.accent
              : Colors.white.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(99),
        ),
        child: Container(
          width: 18,
          height: 18,
          decoration: const BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }
}

/// Toggle ligado a una clave del mapa de valores de configuración.
class ConfigValueToggle extends StatelessWidget {
  final Map<String, dynamic> values;
  final String id;
  final ConfigSetter onSet;
  const ConfigValueToggle({
    super.key,
    required this.values,
    required this.id,
    required this.onSet,
  });

  @override
  Widget build(BuildContext context) {
    return ConfigToggle(
      value: values[id] as bool,
      onChanged: (x) => onSet(id, x),
    );
  }
}
