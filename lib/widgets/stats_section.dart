import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'common/section_title.dart';
import 'common/tag.dart';

class StatsSection extends StatelessWidget {
  const StatsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionTitle(
          'Resultados que Hablan',
          'Mejoras significativas en atletas profesionales',
          trailing: Tag('LIVE DATA', AppColors.cyan),
        ),
        const SizedBox(height: 14),
        const Row(
          children: [
            Expanded(
              child: _StatCard('38%+', 'Mejora Promedio',
                  'En salto y potencia de remate', AppColors.gold),
            ),
            SizedBox(width: 12),
            Expanded(
              child: _StatCard('120+', 'Atletas Analizados',
                  'Clubes de 1ª división', AppColors.cyan),
            ),
          ],
        ),
        const SizedBox(height: 12),
        const Row(
          children: [
            Expanded(
              child: _StatCard('95%', 'Satisfacción', 'Índice en entrenadores',
                  AppColors.gold),
            ),
            SizedBox(width: 12),
            Expanded(
              child: _StatCard('10000+', 'Sesiones Procesadas',
                  'Clips de video analizados', AppColors.cyan),
            ),
          ],
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String value, label, sub;
  final Color color;

  const _StatCard(this.value, this.label, this.sub, this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 26,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            sub,
            style: const TextStyle(color: AppColors.muted, fontSize: 10),
          ),
        ],
      ),
    );
  }
}
