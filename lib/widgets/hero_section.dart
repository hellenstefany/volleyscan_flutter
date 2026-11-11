import 'dart:async';
import 'package:flutter/material.dart';
import '../theme/vs_colors.dart';

class HeroSection extends StatelessWidget {
  const HeroSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 12),
        const Text(
          'Transforma tu rendimiento',
          style: TextStyle(
            fontFamily: VS.font,
            color: Colors.white,
            fontSize: 36,
            height: 1.1,
            letterSpacing: -0.9,
            fontWeight: FontWeight.w700,
          ),
        ),
        const Text(
          'en el voleibol con IA',
          style: TextStyle(
            fontFamily: VS.font,
            color: VS.cyan,
            fontSize: 36,
            height: 1.1,
            letterSpacing: -0.9,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 20),
        const Text(
          'Detecta errores técnicos, analiza movimientos y mejora el rendimiento deportivo con precisión profesional.',
          style: TextStyle(
            fontFamily: VS.font,
            color: VS.muted,
            fontSize: 15,
            height: 1.6,
          ),
        ),
        const SizedBox(height: 28),
        Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: () => Navigator.pushNamed(context, '/registro'),
            child: Ink(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                gradient: const LinearGradient(colors: [VS.indigo, VS.cyan]),
              ),
              child: const Center(
                child: Text(
                  'Crear Cuenta Gratis',
                  style: TextStyle(
                    fontFamily: VS.font,
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 32),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.only(top: 20),
          decoration: const BoxDecoration(
            border: Border(top: BorderSide(color: VS.line)),
          ),
          child: const Wrap(
            spacing: 28,
            runSpacing: 8,
            children: [
              _Fact('33', 'puntos articulares'),
              _Fact('3D', 'ángulos en vivo'),
              _Fact('0', 'videos subidos'),
            ],
          ),
        ),
        const SizedBox(height: 32),
        Center(
          child: Column(
            children: [
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: AspectRatio(
                  aspectRatio: 4 / 5,
                  child: Container(
                    decoration: BoxDecoration(
                      color: VS.deep,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: VS.lineStrong),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x66000000),
                          blurRadius: 50,
                          offset: Offset(0, 20),
                        ),
                      ],
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.asset(
                          'assets/images/image.jpg',
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => const Center(
                            child: Icon(
                              Icons.image_outlined,
                              color: VS.faint,
                              size: 48,
                            ),
                          ),
                        ),
                        const DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              stops: [0.6, 1],
                              colors: [Colors.transparent, Color(0xB304060D)],
                            ),
                          ),
                        ),
                        const _Corner(top: 12, left: 12),
                        const _Corner(top: 12, right: 12),
                        const _Corner(bottom: 12, left: 12),
                        const _Corner(bottom: 12, right: 12),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Vista ilustrativa del análisis',
                style: TextStyle(
                  fontFamily: VS.font,
                  color: VS.faint,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Fact extends StatelessWidget {
  final String n, label;
  const _Fact(this.n, this.label);
  @override
  Widget build(BuildContext context) => Text.rich(
    TextSpan(
      children: [
        TextSpan(
          text: '$n ',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 17.5,
            fontWeight: FontWeight.w600,
          ),
        ),
        TextSpan(text: label),
      ],
    ),
    style: const TextStyle(
      fontFamily: VS.font,
      color: VS.muted,
      fontSize: 13.5,
    ),
  );
}

class _Corner extends StatelessWidget {
  final double? top, left, right, bottom;
  const _Corner({this.top, this.left, this.right, this.bottom});
  @override
  Widget build(BuildContext context) {
    const side = BorderSide(color: VS.lineStrong, width: 2);
    return Positioned(
      top: top,
      left: left,
      right: right,
      bottom: bottom,
      child: Container(
        width: 20,
        height: 20,
        decoration: BoxDecoration(
          border: Border(
            top: top != null ? side : BorderSide.none,
            bottom: bottom != null ? side : BorderSide.none,
            left: left != null ? side : BorderSide.none,
            right: right != null ? side : BorderSide.none,
          ),
        ),
      ),
    );
  }
}

/// Cinta animada (la de "Biomecánica · 33 puntos articulares · ...").
/// Va como hijo de ancho completo (fuera del padding horizontal si quieres).
class TickerBar extends StatefulWidget {
  const TickerBar({super.key});
  @override
  State<TickerBar> createState() => _TickerBarState();
}

class _TickerBarState extends State<TickerBar> {
  static const _items = [
    'Biomecánica',
    '33 puntos articulares',
    'Tiempo real',
    'Corrección de gestos',
    'Historial de sesiones',
    'Panel de entrenador',
    'Análisis de remate',
  ];
  final _ctrl = ScrollController();
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(milliseconds: 16), (_) {
      if (_ctrl.hasClients) _ctrl.jumpTo(_ctrl.offset + 0.7);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 46,
      decoration: const BoxDecoration(
        color: Color(0x660A1020),
        border: Border.symmetric(horizontal: BorderSide(color: VS.line)),
      ),
      child: ListView.builder(
        controller: _ctrl,
        scrollDirection: Axis.horizontal,
        physics: const NeverScrollableScrollPhysics(),
        itemBuilder: (_, i) => Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Row(
              children: [
                Text(
                  _items[i % _items.length],
                  style: const TextStyle(
                    fontFamily: VS.font,
                    color: VS.muted,
                    fontSize: 13.5,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 28),
                const Text('·', style: TextStyle(color: VS.faint)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
