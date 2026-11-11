import 'package:flutter/material.dart';
import '../theme/vs_colors.dart';
import 'section_head.dart';

class FeaturesSection extends StatelessWidget {
  const FeaturesSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHead(
          title: 'Tecnología de alto rendimiento',
          subtitle: 'Inteligencia artificial aplicada al análisis biomecánico.',
        ),
        _Tile(
          icon: Icons.accessibility_new,
          iconColor: VS.cyan,
          title: 'Mapeo esquelético avanzado',
          desc: 'Rastreo en tiempo real de 33 puntos articulares.',
          visual: const SizedBox(
            width: 150,
            height: 112,
            child: CustomPaint(painter: _SkeletonPainter()),
          ),
        ),
        _Tile(
          icon: Icons.bar_chart_rounded,
          iconColor: VS.gold,
          title: 'Comparación profesional',
          desc: 'Compara métricas con atletas profesionales.',
          visual: const _Bars(),
        ),
        _Tile(
          icon: Icons.adjust,
          iconColor: VS.cyan,
          title: 'Retroalimentación estratégica',
          desc: 'Consejos personalizados generados por IA.',
          visual: const _Chat(),
        ),
        _Tile(
          icon: Icons.bolt,
          iconColor: VS.gold,
          title: 'Análisis en tiempo real',
          desc: 'Procesamiento instantáneo de video.',
          visual: const _Meter(),
        ),
      ],
    );
  }
}

class _Tile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title, desc;
  final Widget visual;
  const _Tile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.desc,
    required this.visual,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(26),
      decoration: BoxDecoration(
        color: VS.panel,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: VS.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0x08FFFFFF),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: VS.lineStrong),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(height: 14),
          Text(
            title,
            style: const TextStyle(
              fontFamily: VS.font,
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            desc,
            style: const TextStyle(
              fontFamily: VS.font,
              color: VS.muted,
              fontSize: 14,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 22),
          Center(child: visual),
        ],
      ),
    );
  }
}

class _Bars extends StatelessWidget {
  const _Bars();
  @override
  Widget build(BuildContext context) {
    const data = [
      ['Codo', 82.0, 94.0],
      ['Salto', 64.0, 88.0],
      ['Caída', 76.0, 85.0],
    ];
    Widget bar(double f, Color c) => FractionallySizedBox(
      widthFactor: f / 100,
      child: Container(
        height: 10,
        decoration: BoxDecoration(
          color: c,
          borderRadius: BorderRadius.circular(99),
        ),
      ),
    );
    return Column(
      children: [
        for (final d in data)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              children: [
                SizedBox(
                  width: 48,
                  child: Text(
                    d[0] as String,
                    style: const TextStyle(
                      fontFamily: VS.font,
                      color: VS.muted,
                      fontSize: 12.5,
                    ),
                  ),
                ),
                Expanded(
                  child: Stack(
                    children: [
                      Container(
                        height: 10,
                        decoration: BoxDecoration(
                          color: const Color(0x1494A3B8),
                          borderRadius: BorderRadius.circular(99),
                        ),
                      ),
                      bar(d[2] as double, const Color(0x40FFD700)),
                      bar(d[1] as double, VS.cyan),
                    ],
                  ),
                ),
              ],
            ),
          ),
        const Row(
          children: [
            _Dot(VS.cyan),
            SizedBox(width: 6),
            Text(
              'Tú',
              style: TextStyle(
                fontFamily: VS.font,
                color: VS.faint,
                fontSize: 12,
              ),
            ),
            SizedBox(width: 16),
            _Dot(Color(0x80FFD700)),
            SizedBox(width: 6),
            Text(
              'Referencia',
              style: TextStyle(
                fontFamily: VS.font,
                color: VS.faint,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _Dot extends StatelessWidget {
  final Color c;
  const _Dot(this.c);
  @override
  Widget build(BuildContext context) => Container(
    width: 8,
    height: 8,
    decoration: BoxDecoration(shape: BoxShape.circle, color: c),
  );
}

class _Chat extends StatelessWidget {
  const _Chat();

  Widget _bubble(String t, {bool right = false}) => Align(
    alignment: right ? Alignment.centerRight : Alignment.centerLeft,
    child: Container(
      margin: EdgeInsets.only(bottom: 8, left: right ? 20 : 0),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: right ? const Color(0x0A22D3EE) : const Color(0x05FFFFFF),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: right ? const Color(0x3322D3EE) : VS.line),
      ),
      child: Text(
        t,
        style: const TextStyle(
          fontFamily: VS.font,
          color: VS.slate300,
          fontSize: 13.5,
          height: 1.5,
        ),
      ),
    ),
  );

  @override
  Widget build(BuildContext context) => Column(
    children: [
      _bubble(
        'Estira por completo el brazo en el golpeo: pega arriba, con el codo extendido.',
      ),
      _bubble(
        'Carga las rodillas hasta unos 110° antes de saltar.',
        right: true,
      ),
    ],
  );
}

class _Meter extends StatelessWidget {
  const _Meter();
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        SizedBox(
          height: 100,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              for (var i = 0; i < 14; i++)
                Container(
                  width: 6,
                  height: (40 + (i * 15) % 60).toDouble(),
                  margin: const EdgeInsets.only(right: 4),
                  decoration: BoxDecoration(
                    color: VS.muted.withOpacity(.4),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
            ],
          ),
        ),
        const Text.rich(
          TextSpan(
            children: [
              TextSpan(text: 'hasta '),
              TextSpan(
                text: '60',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 21,
                  fontWeight: FontWeight.w700,
                ),
              ),
              TextSpan(text: ' fps'),
            ],
          ),
          style: TextStyle(fontFamily: VS.font, color: VS.muted, fontSize: 13),
        ),
      ],
    );
  }
}

/// Esqueleto (viewBox 200x150 del SVG original)
class _SkeletonPainter extends CustomPainter {
  const _SkeletonPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final sx = size.width / 200, sy = size.height / 150;
    Offset p(num x, num y) => Offset(x * sx, y * sy);

    final bone = Paint()
      ..color = VS.muted.withOpacity(.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    void poly(List<List<num>> pts) {
      final path = Path()
        ..moveTo(p(pts[0][0], pts[0][1]).dx, p(pts[0][0], pts[0][1]).dy);
      for (final q in pts.skip(1)) {
        path.lineTo(p(q[0], q[1]).dx, p(q[0], q[1]).dy);
      }
      canvas.drawPath(path, bone);
    }

    poly([
      [100, 30],
      [100, 78],
    ]);
    poly([
      [100, 46],
      [76, 54],
      [64, 80],
    ]);
    poly([
      [100, 46],
      [124, 54],
      [136, 76],
    ]);
    poly([
      [100, 78],
      [88, 104],
      [82, 134],
    ]);
    poly([
      [100, 78],
      [112, 104],
      [118, 134],
    ]);
    canvas.drawCircle(p(100, 16), 7 * sx, bone);

    final joint = Paint()..color = VS.cyan;
    const joints = [
      [100, 22],
      [100, 44],
      [76, 54],
      [124, 54],
      [64, 80],
      [136, 76],
      [100, 78],
      [88, 104],
      [112, 104],
      [82, 134],
      [118, 134],
    ];
    for (final j in joints) {
      canvas.drawCircle(p(j[0], j[1]), 3 * sx, joint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}
