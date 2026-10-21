import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'common/section_title.dart';
import 'common/tag.dart';

class FeaturesSection extends StatelessWidget {
  const FeaturesSection({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionTitle(
          'Tecnología de Alto Rendimiento',
          'Inteligencia artificial aplicada al análisis biomecánico.',
        ),
        SizedBox(height: 14),
        _FeatureCard(
          icon: Icons.bolt,
          title: 'Mapeo Esquelético Avanzado',
          desc:
              'Rastreo cinemático en tiempo real con precisión milimétrica de articulaciones.',
          tag: '33 PUNTOS',
          color: AppColors.cyan,
          tagColor: AppColors.cyan,
        ),
        SizedBox(height: 12),
        _FeatureCard(
          icon: Icons.bar_chart_rounded,
          title: 'Comparación Profesional',
          desc:
              'Compara tus ángulos de batida y suspensión con jugadores olímpicos.',
          tag: 'BENCHMARK',
          color: AppColors.gold,
          tagColor: AppColors.goldDeep,
        ),
        SizedBox(height: 12),
        _FeatureCard(
          icon: Icons.track_changes,
          title: 'Retroalimentación Estratégica',
          desc:
              'Consejos personalizados y correcciones posturales generados por IA.',
          tag: 'IA COACH',
          color: AppColors.cyan,
          tagColor: AppColors.indigoSoft,
        ),
        SizedBox(height: 12),
        _FeatureCard(
          icon: Icons.flash_on,
          title: 'Análisis en Tiempo Real',
          desc:
              'Procesamiento instantáneo de video sin necesidad de sensores externos.',
          tag: '0.4s LATENCIA',
          color: AppColors.orange,
          tagColor: AppColors.orange,
        ),
      ],
    );
  }
}

class _FeatureCard extends StatelessWidget {
  final IconData icon;
  final String title, desc, tag;
  final Color color, tagColor;

  const _FeatureCard({
    required this.icon,
    required this.title,
    required this.desc,
    required this.tag,
    required this.color,
    required this.tagColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: color.withValues(alpha: 0.4)),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Text(
                          title,
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Tag(tag, tagColor),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  desc,
                  style: const TextStyle(
                    color: AppColors.muted,
                    fontSize: 12,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
