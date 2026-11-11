import 'package:flutter/material.dart';
import '../../../models/progreso_atleta_data.dart';
import '../../../theme/app_theme.dart';
import '../../../theme/dash_colors.dart';
import '../dash_card.dart';
import 'progreso_shared.dart';

/// Tarjeta "Logros" (`Logros` en `MiProgreso.jsx`).
class LogrosCard extends StatelessWidget {
  final List<ProgresoLogro> logros;

  const LogrosCard({super.key, required this.logros});

  @override
  Widget build(BuildContext context) {
    final hechos = logros.where((l) => l.conseguido).length;

    return DashCard(
      padding: AppSpacing.dashCardPadding,
      borderRadius: AppRadii.panel,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ProgresoCardHeader(
            title: 'Logros',
            tag: '$hechos de ${logros.length}',
          ),
          const SizedBox(height: AppSpacing.dashGap),
          if (logros.isEmpty)
            const ProgresoEmptyBox(
              title: 'Sin logros disponibles',
              subtitle: 'Entrena y analiza tus sesiones para desbloquearlos.',
            )
          else
            Column(
              children: [
                for (var i = 0; i < logros.length; i += 2) ...[
                  if (i > 0) const SizedBox(height: 10),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: _LogroTile(logro: logros[i])),
                      const SizedBox(width: 10),
                      Expanded(
                        child: (i + 1 < logros.length)
                            ? _LogroTile(logro: logros[i + 1])
                            : const SizedBox.shrink(),
                      ),
                    ],
                  ),
                ],
              ],
            ),
        ],
      ),
    );
  }
}

class _LogroTile extends StatelessWidget {
  final ProgresoLogro logro;

  const _LogroTile({required this.logro});

  @override
  Widget build(BuildContext context) {
    final meta = logro.meta.clamp(1, 999999);
    final conseguido = logro.conseguido;
    final ratio = (logro.valor / meta).clamp(0.0, 1.0);
    final IconData icon = conseguido
        ? _logroIcon(logro.id)
        : Icons.lock_rounded;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: conseguido ? null : DashColors.surface,
        gradient: conseguido
            ? LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  DashColors.amber.withValues(alpha: 0.14),
                  DashColors.surface,
                ],
              )
            : null,
        borderRadius: BorderRadius.circular(AppRadii.btn),
        border: Border.all(
          color: conseguido
              ? DashColors.amber.withValues(alpha: 0.45)
              : DashColors.border,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: conseguido
                  ? DashColors.amber.withValues(alpha: 0.2)
                  : Colors.white.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(AppRadii.sm),
            ),
            alignment: Alignment.center,
            child: Icon(
              icon,
              size: 17,
              color: conseguido ? DashColors.amber : DashColors.textMuted,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            logro.titulo,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: conseguido ? Colors.white : DashColors.textSecondary,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            logro.detalle,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 11,
              height: 1.35,
              color: DashColors.textMuted,
            ),
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(99),
            child: Container(
              height: 5,
              color: Colors.white.withValues(alpha: 0.08),
              alignment: Alignment.centerLeft,
              child: FractionallySizedBox(
                widthFactor: ratio,
                child: Container(
                  color: conseguido ? DashColors.amber : DashColors.blueLight,
                ),
              ),
            ),
          ),
          const SizedBox(height: 5),
          Text(
            conseguido ? '¡Conseguido!' : '${logro.valor} / $meta',
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 10.5,
              color: DashColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }

  IconData _logroIcon(String id) {
    switch (id) {
      case 'primer-analisis':
        return Icons.photo_camera_rounded;
      case 'diez-analisis':
        return Icons.military_tech_rounded;
      case 'nota-80':
        return Icons.star_rounded;
      case 'racha-3':
        return Icons.local_fire_department_rounded;
      case 'racha-7':
        return Icons.bolt_rounded;
      case 'primera-rutina':
        return Icons.fitness_center_rounded;
      case 'cinco-rutinas':
        return Icons.emoji_events_rounded;
      case 'con-entrenador':
        return Icons.groups_rounded;
      default:
        return Icons.military_tech_rounded;
    }
  }
}
