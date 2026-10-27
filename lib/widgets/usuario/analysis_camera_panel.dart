import 'package:flutter/material.dart';
import '../../theme/routine_colors.dart';

/// Panel izquierdo: instrucciones para colocar la cámara (o vista previa).
class AnalysisCameraPanel extends StatelessWidget {
  final bool cameraOn;
  const AnalysisCameraPanel({super.key, required this.cameraOn});

  static const _tips = [
    'Cámara fija, de lado o en diagonal',
    'Cuerpo completo dentro del marco',
    'A 3 o 4 metros, con luz de frente',
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: RoutineColors.cardDark,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: RoutineColors.border),
      ),
      child: cameraOn ? _preview() : _instructions(),
    );
  }

  Widget _preview() {
    return const SizedBox(
      height: 320,
      child: Center(
        child: Text(
          // TODO: aquí va la vista previa de la cámara (paquete `camera`)
          // con el esqueleto de pose encima.
          'Cámara activa',
          style: TextStyle(color: RoutineColors.textMuted, fontSize: 16),
        ),
      ),
    );
  }

  Widget _instructions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Activa la cámara y colócate en el marco.',
          style: TextStyle(
            color: Colors.white,
            fontSize: 26,
            fontWeight: FontWeight.w800,
            height: 1.15,
          ),
        ),
        const SizedBox(height: 18),
        for (final t in _tips)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 22,
                  height: 22,
                  margin: const EdgeInsets.only(top: 1),
                  decoration: BoxDecoration(
                    color: RoutineColors.blue.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Container(
                      width: 10,
                      height: 10,
                      decoration: const BoxDecoration(
                        color: RoutineColors.blue,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    t,
                    style: const TextStyle(
                      color: Color(0xFFE2E8F0),
                      fontSize: 16,
                      height: 1.3,
                    ),
                  ),
                ),
              ],
            ),
          ),
        const SizedBox(height: 6),
        const Text(
          'El video se procesa en tu dispositivo y no se sube a ningún servidor.',
          style: TextStyle(
            color: RoutineColors.textMuted,
            fontSize: 14,
            height: 1.4,
          ),
        ),
        const SizedBox(height: 24),
        const Center(child: _StickFigureFrame()),
      ],
    );
  }
}

/// Recuadro punteado con una figura de palitos (guía de encuadre).
class _StickFigureFrame extends StatelessWidget {
  const _StickFigureFrame();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 140,
      height: 180,
      child: CustomPaint(painter: _FramePainter()),
    );
  }
}

class _FramePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Borde punteado
    final dash = Paint()
      ..color = Colors.white.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    final rrect = RRect.fromRectAndRadius(
      Offset.zero & size,
      const Radius.circular(10),
    );
    final path = Path()..addRRect(rrect);
    for (final metric in path.computeMetrics()) {
      var d = 0.0;
      while (d < metric.length) {
        canvas.drawPath(metric.extractPath(d, d + 5), dash);
        d += 9;
      }
    }

    // Figura
    final cx = size.width / 2;
    final body = Paint()
      ..color = const Color(0xFFD1D5DB)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5
      ..strokeCap = StrokeCap.round;
    final head = Paint()
      ..color = const Color(0xFF22C55E)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5;

    canvas.drawCircle(Offset(cx, 36), 12, head);
    canvas.drawLine(Offset(cx, 48), Offset(cx, 112), body); // torso
    canvas.drawLine(Offset(cx, 66), Offset(cx - 28, 86), body); // brazo izq
    canvas.drawLine(Offset(cx, 66), Offset(cx + 28, 86), body); // brazo der
    canvas.drawLine(Offset(cx, 112), Offset(cx - 16, 160), body); // pierna izq
    canvas.drawLine(Offset(cx, 112), Offset(cx + 16, 160), body); // pierna der
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}
