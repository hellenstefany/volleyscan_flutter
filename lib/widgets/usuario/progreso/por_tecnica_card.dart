import 'package:flutter/material.dart';
import '../../../models/progreso_atleta_data.dart';
import '../../../theme/app_theme.dart';
import '../../../theme/dash_colors.dart';
import '../dash_card.dart';
import 'progreso_shared.dart';

/// Tarjeta "Por técnica" (`Tecnicas` en `MiProgreso.jsx`).
class PorTecnicaCard extends StatelessWidget {
  final List<ProgresoPorTecnica> porTecnica;

  const PorTecnicaCard({super.key, required this.porTecnica});

  @override
  Widget build(BuildContext context) {
    return DashCard(
      padding: AppSpacing.dashCardPadding,
      borderRadius: AppRadii.panel,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const ProgresoCardHeader(title: 'Por técnica', tag: 'Promedio'),
          const SizedBox(height: AppSpacing.dashGap),
          if (porTecnica.isEmpty)
            const ProgresoEmptyBox(
              title: 'Sin datos todavía',
              subtitle:
                  'Tus promedios por técnica aparecerán tras tus primeras sesiones.',
            )
          else
            Column(
              children: [
                for (var i = 0; i < porTecnica.length; i++) ...[
                  if (i > 0) const SizedBox(height: 10),
                  _TecnicaRow(item: porTecnica[i]),
                ],
              ],
            ),
        ],
      ),
    );
  }
}

class _TecnicaRow extends StatelessWidget {
  final ProgresoPorTecnica item;

  const _TecnicaRow({required this.item});

  @override
  Widget build(BuildContext context) {
    final rawName = item.tecnica;
    final tecnica = rawName.isEmpty
        ? 'Técnica'
        : '${rawName[0].toUpperCase()}${rawName.substring(1)}';
    final promedio = item.promedio;
    final sesiones = item.sesiones;
    final factor = ((promedio ?? 0).clamp(0, 100)) / 100.0;

    return Row(
      children: [
        SizedBox(
          width: 78,
          child: Text(
            tecnica,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 12.5,
              color: DashColors.text1,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(99),
            child: Container(
              height: 8,
              color: Colors.white.withValues(alpha: 0.07),
              alignment: Alignment.centerLeft,
              child: FractionallySizedBox(
                widthFactor: factor,
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [DashColors.blueLight, DashColors.teal],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        RichText(
          text: TextSpan(
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 11.5,
              color: DashColors.textSecondary,
            ),
            children: [
              TextSpan(
                text: '${promedio ?? '—'}',
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              TextSpan(
                text: ' · $sesiones ${sesiones == 1 ? 'sesión' : 'sesiones'}',
              ),
            ],
          ),
        ),
      ],
    );
  }
}
