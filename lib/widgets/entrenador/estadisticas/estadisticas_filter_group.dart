import 'package:flutter/material.dart';

import 'estadisticas_theme.dart';

class EstadisticasFilterGroup extends StatelessWidget {
  final String label;
  final double width;
  final Widget child;
  const EstadisticasFilterGroup({
    super.key,
    required this.label,
    required this.width,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              color: EstadisticasTheme.muted,
              letterSpacing: 1,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 5),
          child,
        ],
      ),
    );
  }
}
