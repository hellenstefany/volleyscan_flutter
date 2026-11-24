import 'package:flutter/material.dart';
import '../../../models/rutina_entrenador_data.dart';
import '../../../theme/dash_colors.dart';
import 'rutinas_catalog.dart';
import 'rutinas_common_widgets.dart';

/// Tarjeta de una rutina asignada por el entrenador.
class RoutineCard extends StatelessWidget {
  final RutinaEntrenador r;
  final String today;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const RoutineCard({
    super.key,
    required this.r,
    required this.today,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final col = kRutinaTypeColors[r.tipo] ?? DashColors.coachPurple;
    final vencida = !r.completada &&
        r.fechaProgramada != null &&
        r.fechaProgramada!.compareTo(today) < 0;
    final comp = r.progreso.completados;
    final tot = r.progreso.total;
    final pct = r.progreso.porcentaje;

    return Container(
      decoration: rtBox(DashColors.card, 14),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 3,
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [col, Colors.transparent]),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: col.withValues(alpha: 0.09),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: col.withValues(alpha: 0.25)),
                      ),
                      child: Text(
                        r.tipo,
                        style: TextStyle(
                          fontSize: 11,
                          letterSpacing: 1,
                          color: col,
                        ),
                      ),
                    ),
                    if (r.completada)
                      const Text(
                        '✔ Completada',
                        style: TextStyle(
                          fontSize: 11,
                          color: DashColors.greenTeal,
                        ),
                      )
                    else
                      Text(
                        '${vencida ? 'Vencida · ' : ''}${rtFechaCorta(r.fechaProgramada)}',
                        style: TextStyle(
                          fontSize: 11,
                          color: vencida
                              ? DashColors.red
                              : DashColors.textMuted,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  r.nombre,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1,
                    color: DashColors.text,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '👤 ${r.atleta.nombreCompleto}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: DashColors.textMuted,
                  ),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 14,
                  runSpacing: 4,
                  children: [
                    Text(
                      '⏰ ${r.horaInicio ?? '—'}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: DashColors.textMuted,
                      ),
                    ),
                    Text(
                      '⏱ ${rtDurTexto(r.duracionMin)}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: DashColors.textMuted,
                      ),
                    ),
                    Text(
                      '⚡ ${r.intensidad}/10',
                      style: const TextStyle(
                        fontSize: 12,
                        color: DashColors.textMuted,
                      ),
                    ),
                    Text(
                      '🎚 ${rtNombreNivel(r.nivel)}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: DashColors.textMuted,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 5,
                  runSpacing: 5,
                  children: [
                    for (final e in r.ejercicios.take(4))
                      RtMiniTag(
                        '${e.completado ? '✔ ' : ''}${e.nombre}',
                        big: true,
                        done: e.completado,
                      ),
                    if (r.ejercicios.length > 4)
                      RtMiniTag('+${r.ejercicios.length - 4}', big: true),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  'Avance del deportista · $comp/$tot',
                  style: const TextStyle(
                    fontSize: 10,
                    color: DashColors.textMuted,
                  ),
                ),
                const SizedBox(height: 4),
                ClipRRect(
                  borderRadius: BorderRadius.circular(99),
                  child: LinearProgressIndicator(
                    value: (pct / 100).clamp(0.0, 1.0),
                    minHeight: 5,
                    backgroundColor: Colors.white.withValues(alpha: 0.06),
                    valueColor: const AlwaysStoppedAnimation(
                      DashColors.greenTeal,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Intensidad',
                            style: TextStyle(
                              fontSize: 10,
                              color: DashColors.textMuted,
                            ),
                          ),
                          const SizedBox(height: 3),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(99),
                            child: LinearProgressIndicator(
                              value: (r.intensidad / 10).clamp(0.0, 1.0),
                              minHeight: 4,
                              backgroundColor: Colors.white12,
                              valueColor: AlwaysStoppedAnimation(
                                rtIntensityColor(r.intensidad),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    RtActBtn(
                      '✏️',
                      DashColors.cyan,
                      onEdit,
                      disabled: comp > 0,
                      tooltip: comp > 0
                          ? 'Con avance: no se puede editar'
                          : 'Editar',
                    ),
                    const SizedBox(width: 6),
                    RtActBtn(
                      '🗑',
                      DashColors.red,
                      onDelete,
                      tooltip: 'Eliminar',
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
