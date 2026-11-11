import 'package:flutter/material.dart';
import '../theme/vs_colors.dart';
import 'section_head.dart';

enum _PlanStyle { outline, gold, cyan }

class PlansSection extends StatelessWidget {
  const PlansSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        SectionHead(
          title: 'Elige tu plan',
          subtitle: 'Planes diseñados para atletas individuales y clubes.',
        ),
        _Plan(
          name: 'Novato',
          desc: 'Perfecto para comenzar.',
          price: 'Gratis',
          suffix: '',
          features: [
            '5 análisis por mes',
            'Detección básica',
            'Historial',
            'Soporte',
          ],
          btn: 'Comenzar Gratis',
          style: _PlanStyle.outline,
        ),
        _Plan(
          name: 'Atleta Profesional',
          desc: 'Para atletas serios.',
          price: r'$19.99',
          suffix: '/ mes',
          features: [
            'Análisis ilimitados',
            'IA avanzada',
            'Comparación con pros',
            'Retroalimentación personalizada',
          ],
          btn: 'Elegir Plan',
          style: _PlanStyle.gold,
          featured: true,
        ),
        _Plan(
          name: 'Club',
          desc: 'Ideal para equipos.',
          price: r'$49.99',
          suffix: '/ mes',
          features: [
            'Hasta 30 atletas',
            'Panel entrenador',
            'Estadísticas',
            'Soporte dedicado',
          ],
          btn: 'Contactar',
          style: _PlanStyle.cyan,
        ),
      ],
    );
  }
}

class _Plan extends StatelessWidget {
  final String name, desc, price, suffix, btn;
  final List<String> features;
  final _PlanStyle style;
  final bool featured;

  const _Plan({
    required this.name,
    required this.desc,
    required this.price,
    required this.suffix,
    required this.features,
    required this.btn,
    required this.style,
    this.featured = false,
  });

  @override
  Widget build(BuildContext context) {
    Color bg = Colors.transparent, fg = VS.slate200, border = VS.lineStrong;
    if (style == _PlanStyle.gold) {
      bg = VS.gold;
      fg = Colors.black;
      border = Colors.transparent;
    } else if (style == _PlanStyle.cyan) {
      fg = VS.cyan;
      border = const Color(0x4D22D3EE);
    }

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
      decoration: BoxDecoration(
        color: featured ? const Color(0xF20F172A) : VS.panel,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: featured ? VS.lineStrong : VS.line),
        boxShadow: featured
            ? const [
                BoxShadow(
                  color: Color(0x4D000000),
                  blurRadius: 40,
                  offset: Offset(0, 20),
                ),
              ]
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (featured)
            Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
              decoration: BoxDecoration(
                color: const Color(0x14FFD700),
                borderRadius: BorderRadius.circular(99),
                border: Border.all(color: const Color(0x4DFFD700)),
              ),
              child: const Text(
                'Más popular',
                style: TextStyle(
                  fontFamily: VS.font,
                  color: VS.gold,
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          Text(
            name,
            style: const TextStyle(
              fontFamily: VS.font,
              color: Colors.white,
              fontSize: 17.5,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            desc,
            style: const TextStyle(
              fontFamily: VS.font,
              color: VS.muted,
              fontSize: 13.5,
            ),
          ),
          const SizedBox(height: 16),
          Text.rich(
            TextSpan(
              children: [
                TextSpan(text: price),
                if (suffix.isNotEmpty)
                  TextSpan(
                    text: ' $suffix',
                    style: const TextStyle(
                      color: VS.muted,
                      fontSize: 13.5,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
              ],
            ),
            style: TextStyle(
              fontFamily: VS.font,
              color: featured ? VS.gold : Colors.white,
              fontSize: 34,
              letterSpacing: -0.7,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 16),
          for (final f in features)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Container(
                    width: 18,
                    height: 18,
                    alignment: Alignment.center,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0x1A22C55E),
                    ),
                    child: const Text(
                      '✓',
                      style: TextStyle(
                        color: VS.green,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      f,
                      style: const TextStyle(
                        fontFamily: VS.font,
                        color: VS.slate300,
                        fontSize: 13.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () => Navigator.pushNamed(context, '/registro'),
              style: OutlinedButton.styleFrom(
                backgroundColor: bg,
                foregroundColor: fg,
                side: BorderSide(color: border),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(
                btn,
                style: const TextStyle(
                  fontFamily: VS.font,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
