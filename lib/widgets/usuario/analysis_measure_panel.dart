import 'package:flutter/material.dart';
import '../../models/analysis_data.dart';
import '../../theme/routine_colors.dart';

const _currentColor = Color(0xFF3B82F6);
const _rangeColor = Color(0xFF1E3A8A);

/// Panel "Medición en vivo".
class AnalysisMeasurePanel extends StatelessWidget {
  final AnalysisData data;
  final VoidCallback onResetRanges;

  const AnalysisMeasurePanel({
    super.key,
    required this.data,
    required this.onResetRanges,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: RoutineColors.cardDark,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: RoutineColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Medición en vivo',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 12),
          for (final j in data.joints) _JointRow(joint: j),
          _TrunkRow(trunk: data.trunk),
          const SizedBox(height: 14),
          Row(
            children: [
              _legend(_currentColor, 'Actual'),
              const SizedBox(width: 18),
              _legend(_rangeColor, 'Rango de la sesión'),
            ],
          ),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: onResetRanges,
            child: Text(
              'Reiniciar rangos',
              style: TextStyle(
                color: Colors.white.withOpacity(0.35),
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _legend(Color color, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 20,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          text,
          style: const TextStyle(color: RoutineColors.textMuted, fontSize: 13),
        ),
      ],
    );
  }
}

class _RowShell extends StatelessWidget {
  final Widget child;
  const _RowShell({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: Colors.white.withOpacity(0.07))),
      ),
      child: child,
    );
  }
}

const _labelStyle = TextStyle(
  color: RoutineColors.textMuted,
  fontSize: 11,
  fontWeight: FontWeight.w700,
  letterSpacing: 1.2,
);

String _fmt(double? v) => v == null ? '—' : '${v.round()}°';

class _JointRow extends StatelessWidget {
  final JointMeasure joint;
  const _JointRow({required this.joint});

  @override
  Widget build(BuildContext context) {
    return _RowShell(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 70,
            child: Text(
              joint.name,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Expanded(
            child: _Side(label: 'IZQ', reading: joint.left),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _Side(label: 'DER', reading: joint.right),
          ),
        ],
      ),
    );
  }
}

class _Side extends StatelessWidget {
  final String label;
  final AngleReading reading;
  const _Side({required this.label, required this.reading});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: _labelStyle),
            Text(_fmt(reading.current), style: _labelStyle),
          ],
        ),
        const SizedBox(height: 8),
        AngleBar(reading: reading, maxValue: 180),
      ],
    );
  }
}

class _TrunkRow extends StatelessWidget {
  final AngleReading trunk;
  const _TrunkRow({required this.trunk});

  @override
  Widget build(BuildContext context) {
    return _RowShell(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(
            width: 70,
            child: Text(
              'Tronco',
              style: TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'INCLINACIÓN · 0° = ERGUIDO',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: _labelStyle,
                      ),
                    ),
                    Text(_fmt(trunk.current), style: _labelStyle),
                  ],
                ),
                const SizedBox(height: 8),
                AngleBar(reading: trunk, maxValue: 90, showCenterTick: false),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Barra con marca actual y rango de la sesión.
class AngleBar extends StatelessWidget {
  final AngleReading reading;
  final double maxValue;
  final bool showCenterTick;

  const AngleBar({
    super.key,
    required this.reading,
    required this.maxValue,
    this.showCenterTick = true,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 8,
      width: double.infinity,
      child: CustomPaint(
        painter: _BarPainter(reading, maxValue, showCenterTick),
      ),
    );
  }
}

class _BarPainter extends CustomPainter {
  final AngleReading r;
  final double maxValue;
  final bool showCenterTick;

  _BarPainter(this.r, this.maxValue, this.showCenterTick);

  double _x(double v, double w) =>
      (v / maxValue).clamp(0.0, 1.0).toDouble() * w;

  @override
  void paint(Canvas canvas, Size size) {
    final radius = Radius.circular(size.height / 2);
    final track = RRect.fromRectAndRadius(Offset.zero & size, radius);

    canvas.drawRRect(track, Paint()..color = const Color(0xFF0A1022));
    canvas.drawRRect(
      track,
      Paint()
        ..color = Colors.white.withOpacity(0.1)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );

    if (r.min != null && r.max != null) {
      final x1 = _x(r.min!, size.width);
      var x2 = _x(r.max!, size.width);
      if (x2 - x1 < 4) x2 = x1 + 4;
      canvas.drawRRect(
        RRect.fromLTRBR(x1, 0, x2, size.height, radius),
        Paint()..color = _rangeColor,
      );
    }

    if (showCenterTick) {
      canvas.drawLine(
        Offset(size.width / 2, 0),
        Offset(size.width / 2, size.height),
        Paint()
          ..color = Colors.white.withOpacity(0.25)
          ..strokeWidth = 1,
      );
    }

    if (r.current != null) {
      final x = _x(r.current!, size.width);
      canvas.drawRRect(
        RRect.fromLTRBR(
          x - 1.5,
          0,
          x + 1.5,
          size.height,
          const Radius.circular(2),
        ),
        Paint()..color = _currentColor,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _BarPainter old) => true;
}
