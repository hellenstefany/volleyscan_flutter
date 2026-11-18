import 'package:flutter/material.dart';
import 'rutinas_colors.dart';
import 'rutinas_common_widgets.dart';
import 'rutinas_model.dart';

/// Tarjeta de una rutina registrada.
class RoutineCard extends StatelessWidget {
  final Routine r;
  final VoidCallback onToggleDone, onEdit, onDelete;
  const RoutineCard({
    super.key,
    required this.r,
    required this.onToggleDone,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final col = kTypeColors[r.type] ?? RtC.accent;
    return Container(
      decoration: rtBox(RtC.card, 14),
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
                        r.type,
                        style: TextStyle(
                          fontSize: 11,
                          letterSpacing: 1,
                          color: col,
                        ),
                      ),
                    ),
                    r.done
                        ? const Text(
                            '✔ Completada',
                            style: TextStyle(fontSize: 11, color: RtC.accent5),
                          )
                        : Text(
                            r.date,
                            style: const TextStyle(
                              fontSize: 11,
                              color: RtC.muted,
                            ),
                          ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  r.name,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1,
                    color: RtC.text,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '👤 ${r.athlete}',
                  style: const TextStyle(fontSize: 12, color: RtC.muted),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 14,
                  runSpacing: 4,
                  children: [
                    Text(
                      '⏰ ${r.hour}',
                      style: const TextStyle(fontSize: 12, color: RtC.muted),
                    ),
                    Text(
                      '⏱ ${r.dur}',
                      style: const TextStyle(fontSize: 12, color: RtC.muted),
                    ),
                    Text(
                      '⚡ ${r.intensity}/10',
                      style: const TextStyle(fontSize: 12, color: RtC.muted),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 5,
                  runSpacing: 5,
                  children: [
                    for (final e in r.exs.take(4)) RtMiniTag(e, big: true),
                    if (r.exs.length > 4)
                      RtMiniTag('+${r.exs.length - 4}', big: true),
                  ],
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
                            style: TextStyle(fontSize: 10, color: RtC.muted),
                          ),
                          const SizedBox(height: 3),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(99),
                            child: LinearProgressIndicator(
                              value: r.intensity / 10,
                              minHeight: 4,
                              backgroundColor: Colors.white12,
                              valueColor: AlwaysStoppedAnimation(
                                rtIntensityColor(r.intensity),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    RtActBtn('✔', RtC.accent5, onToggleDone),
                    const SizedBox(width: 6),
                    RtActBtn('✏️', RtC.accent2, onEdit),
                    const SizedBox(width: 6),
                    RtActBtn('🗑', RtC.accent3, onDelete),
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
