import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../models/rutina_entrenador_data.dart';
import '../../../theme/dash_colors.dart';
import 'rutinas_catalog.dart';
import 'rutinas_common_widgets.dart';

/// Tarjeta "Progreso semanal" con anillos por tipo calculados desde `enSemana`.
class RutinasProgressCard extends StatelessWidget {
  final List<RutinaEntrenador> enSemana;

  const RutinasProgressCard({super.key, required this.enSemana});

  (int count, int pct) _anillo(String tipo) {
    final rs = enSemana.where((r) => r.tipo == tipo).toList();
    final total = rs.fold<int>(0, (acc, r) => acc + r.progreso.total);
    final hechos = rs.fold<int>(0, (acc, r) => acc + r.progreso.completados);
    final pct = total > 0 ? ((hechos * 100) / total).round() : 0;
    return (rs.length, pct);
  }

  @override
  Widget build(BuildContext context) {
    const tipos = ['Técnico', 'Físico', 'Táctico', 'Recuperación'];
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: rtBox(DashColors.card, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const RtCardTitle(icon: '📊', title: 'Progreso semanal'),
          Center(
            child: Wrap(
              alignment: WrapAlignment.center,
              spacing: 20,
              runSpacing: 12,
              children: [
                for (final tipo in tipos)
                  Builder(
                    builder: (_) {
                      final (n, pct) = _anillo(tipo);
                      final color =
                          kRutinaTypeColors[tipo] ?? DashColors.coachPurple;
                      return Opacity(
                        opacity: n > 0 ? 1.0 : 0.45,
                        child: Tooltip(
                          message: n > 0
                              ? '$n rutina${n > 1 ? 's' : ''} esta semana'
                              : 'Sin rutinas esta semana',
                          child: Column(
                            children: [
                              SizedBox(
                                width: 70,
                                height: 70,
                                child: CustomPaint(
                                  painter: _RingPainter(pct / 100, color),
                                  child: Center(
                                    child: Text(
                                      '$pct%',
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700,
                                        color: color,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                tipo,
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: DashColors.textMuted,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  final double value;
  final Color color;

  _RingPainter(this.value, this.color);

  @override
  void paint(Canvas canvas, Size size) {
    const sw = 7.0;
    final rect = (Offset.zero & size).deflate(sw / 2 + 3);
    canvas.drawArc(
      rect,
      0,
      math.pi * 2,
      false,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.06)
        ..style = PaintingStyle.stroke
        ..strokeWidth = sw,
    );
    canvas.drawArc(
      rect,
      -math.pi / 2,
      math.pi * 2 * value.clamp(0.0, 1.0),
      false,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = sw
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(covariant _RingPainter o) =>
      o.value != value || o.color != color;
}
