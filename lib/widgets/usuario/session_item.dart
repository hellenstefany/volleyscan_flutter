import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../models/session_data.dart';
import '../../theme/routine_colors.dart';

const _green = Color(0xFF22C55E);
const _orange = Color(0xFFF97316);

class SessionItem extends StatelessWidget {
  final SessionData session;
  final VoidCallback onTap;

  const SessionItem({super.key, required this.session, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final s = session;
    final labelColor = s.isGood ? _green : _orange;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: RoutineColors.cardDark,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: RoutineColors.border),
        ),
        child: Row(
          children: [
            _thumb(),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    s.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(top: 1),
                        child: Icon(
                          Icons.calendar_today_rounded,
                          size: 12,
                          color: RoutineColors.textMuted,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          s.date,
                          style: const TextStyle(
                            color: RoutineColors.textMuted,
                            fontSize: 12,
                            height: 1.3,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    s.duration,
                    style: const TextStyle(
                      color: Color(0xFFCBD5E1),
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 44,
                  height: 44,
                  child: CustomPaint(
                    painter: _ScoreRingPainter(score: s.score, color: s.color),
                  ),
                ),
                const SizedBox(height: 4),
                Text.rich(
                  TextSpan(
                    text: '${s.score}',
                    style: TextStyle(
                      color: labelColor,
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                    ),
                    children: [
                      TextSpan(
                        text: '/100',
                        style: TextStyle(
                          color: labelColor,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(width: 6),
            Container(
              width: 30,
              height: 30,
              decoration: const BoxDecoration(
                color: RoutineColors.trackGrey,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.chevron_right_rounded,
                size: 20,
                color: RoutineColors.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _thumb() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: SizedBox(
        width: 64,
        height: 64,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.network(
              session.imageUrl,
              fit: BoxFit.cover,
              loadingBuilder: (_, child, progress) =>
                  progress == null ? child : _placeholder(),
              errorBuilder: (_, __, ___) => _placeholder(),
            ),
            Container(
              color: Colors.black.withOpacity(0.3),
              child: const Icon(
                Icons.play_arrow_rounded,
                color: Colors.white,
                size: 26,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _placeholder() => Container(color: const Color(0xFF0F172A));
}

/// Aro de puntuación: fondo gris y arco de color según el puntaje.
class _ScoreRingPainter extends CustomPainter {
  final int score;
  final Color color;

  _ScoreRingPainter({required this.score, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    const radius = 16.0;
    const stroke = 4.0;

    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = const Color(0xFF1E293B)
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke,
    );

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      2 * math.pi * score / 100,
      false,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(covariant _ScoreRingPainter old) =>
      old.score != score || old.color != color;
}
