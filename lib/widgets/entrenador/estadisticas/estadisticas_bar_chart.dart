import 'package:flutter/material.dart';

import 'estadisticas_models.dart';
import 'estadisticas_no_data.dart';
import 'estadisticas_theme.dart';

/// Gráfica de barras: rendimiento promedio por deportista.
class EstadisticasBarChart extends StatelessWidget {
  final List<EstadisticasPlayer> players;
  const EstadisticasBarChart({super.key, required this.players});

  @override
  Widget build(BuildContext context) {
    const chartH = 110.0;
    if (players.isEmpty) return const EstadisticasNoData(icon: '📊');

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // Eje Y
        SizedBox(
          height: chartH,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: ['100%', '75%', '50%', '25%', '0%']
                .map(
                  (l) => Text(
                    l,
                    style: const TextStyle(
                      fontSize: 10,
                      color: EstadisticasTheme.muted,
                      height: 1,
                    ),
                  ),
                )
                .toList(),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: players.map((p) {
              final h = p.perf / 100 * chartH;
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 7),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${p.perf}%',
                        style: const TextStyle(
                          fontSize: 11,
                          color: EstadisticasTheme.muted,
                        ),
                      ),
                      const SizedBox(height: 6),
                      SizedBox(
                        height: chartH,
                        child: Align(
                          alignment: Alignment.bottomCenter,
                          child: Tooltip(
                            message: '${p.name}: ${p.perf}%',
                            child: Container(
                              height: h,
                              decoration: BoxDecoration(
                                borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(6),
                                  bottom: Radius.circular(2),
                                ),
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    p.gradient[0],
                                    p.gradient[1].withOpacity(0.7),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        p.name,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12,
                          color: EstadisticasTheme.muted,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}
