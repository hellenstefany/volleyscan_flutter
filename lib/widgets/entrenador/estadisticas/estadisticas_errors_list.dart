import 'package:flutter/material.dart';

import 'estadisticas_models.dart';
import 'estadisticas_theme.dart';

/// Lista de errores comunes. [offset] ajusta los porcentajes según el deportista.
class EstadisticasErrorsList extends StatelessWidget {
  final int offset;
  const EstadisticasErrorsList({super.key, required this.offset});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: estadisticasErrors.map((e) {
        final pct = (e.pct + offset).clamp(5, 99);
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Text(
                      e.name,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12,
                        color: EstadisticasTheme.text,
                      ),
                    ),
                  ),
                  Text(
                    '$pct%',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: EstadisticasTheme.text,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              ClipRRect(
                borderRadius: BorderRadius.circular(99),
                child: Container(
                  height: 5,
                  color: Colors.white.withOpacity(0.07),
                  alignment: Alignment.centerLeft,
                  child: FractionallySizedBox(
                    widthFactor: pct / 100,
                    child: Container(color: e.color),
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
