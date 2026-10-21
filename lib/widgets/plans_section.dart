import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'common/section_title.dart';

class PlansSection extends StatelessWidget {
  const PlansSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionTitle(
          'Elige tu Plan',
          'Planes para atletas independientes y clubes.',
          trailing: GestureDetector(
            onTap: () {},
            child: const Padding(
              padding: EdgeInsets.only(top: 2),
              child: Text(
                'Ver todos',
                style: TextStyle(
                  color: AppColors.cyan,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 22),
        const _ProPlanCard(),
        const SizedBox(height: 14),
        const IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: _MiniPlan(
                  name: 'Novato',
                  price: 'Gratis',
                  desc: '5 análisis/mes básicos',
                  button: 'Comenzar',
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: _MiniPlan(
                  name: 'Club / Team',
                  price: r'$49.99',
                  priceSuffix: '/m',
                  desc: 'Hasta 30 atletas y panel',
                  button: 'Contactar',
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ProPlanCard extends StatelessWidget {
  const _ProPlanCard();

  static const _benefits = [
    'Análisis ilimitados con IA',
    'IA avanzada y tracking 3D de muñeca/hombro',
    'Comparación directa con profesionales',
    'Retroalimentación táctica personalizada',
  ];

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(18, 26, 18, 18),
          decoration: BoxDecoration(
            color: AppColors.gold.withValues(alpha: 0.04),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.gold.withValues(alpha: 0.5)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Atleta Profesional',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Para atletas serios de alto rendimiento.',
                          style:
                              TextStyle(color: AppColors.muted, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        r'$19.99',
                        style: TextStyle(
                          color: AppColors.gold,
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          height: 1.1,
                        ),
                      ),
                      Text(
                        '/ mes',
                        style: TextStyle(color: AppColors.muted, fontSize: 11),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              for (final b in _benefits)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(top: 1),
                        child: Icon(Icons.check_circle_outline,
                            size: 16, color: AppColors.teal),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          b,
                          style: const TextStyle(
                            fontSize: 12.5,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 6),
              Container(
                height: 48,
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: AppGradients.goldBtn,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () {},
                    child: const Center(
                      child: Text(
                        'ELEGIR PLAN PRO',
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.w800,
                          fontSize: 13,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        Positioned(
          top: -11,
          left: 16,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFF2A2410),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.gold.withValues(alpha: 0.6)),
            ),
            child: const Text(
              '★ MÁS POPULAR',
              style: TextStyle(
                color: AppColors.gold,
                fontSize: 10,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.3,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _MiniPlan extends StatelessWidget {
  final String name, price, desc, button;
  final String? priceSuffix;

  const _MiniPlan({
    required this.name,
    required this.price,
    required this.desc,
    required this.button,
    this.priceSuffix,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            name,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text.rich(
            TextSpan(
              text: price,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
              children: [
                if (priceSuffix != null)
                  TextSpan(
                    text: priceSuffix,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w400,
                      color: AppColors.muted,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            desc,
            style: const TextStyle(color: AppColors.muted, fontSize: 10.5),
          ),
          const Spacer(),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 36,
            child: OutlinedButton(
              onPressed: () {},
              style: OutlinedButton.styleFrom(
                backgroundColor: const Color(0xFF131B3A),
                foregroundColor: Colors.white,
                padding: EdgeInsets.zero,
                side: const BorderSide(color: Color(0x33FFFFFF)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(
                button,
                style: const TextStyle(
                  fontSize: 12,
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
