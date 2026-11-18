import 'package:flutter/material.dart';
import '../../../models/my_level_data.dart';
import '../../../models/my_teams_data.dart';
import '../../../theme/app_theme.dart';
import '../../../theme/dash_colors.dart';

/// Tarjeta "Lo que observó tu entrenador" con estrellas y comentarios.
class LevelReviewsCard extends StatelessWidget {
  final List<LevelReviewItem> reviews;

  const LevelReviewsCard({super.key, required this.reviews});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppGradients.coachCardBg,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: DashColors.coachBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Lo que observó tu entrenador',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 16.5,
              fontWeight: FontWeight.w700,
              color: DashColors.text,
            ),
          ),
          const SizedBox(height: 14),
          if (reviews.isEmpty)
            const Text(
              'Todavía no hay rutinas revisadas. Completa tus rutinas: tu entrenador las revisará y dejará su comentario aquí.',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 13.5,
                height: 1.45,
                color: DashColors.muted,
              ),
            )
          else
            ...reviews.asMap().entries.map((entry) {
              final isLast = entry.key == reviews.length - 1;
              final r = entry.value;
              final meta =
                  '${formatTeamShortDate(r.fecha)}${r.entrenador != null ? ' · ${r.entrenador}' : ''}';

              return Container(
                padding: EdgeInsets.only(bottom: isLast ? 0 : 12),
                margin: EdgeInsets.only(bottom: isLast ? 0 : 12),
                decoration: isLast
                    ? null
                    : const BoxDecoration(
                        border: Border(
                          bottom: BorderSide(color: DashColors.coachBorder),
                        ),
                      ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            r.rutina,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: DashColors.text,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        _StarRating(value: r.calificacion),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      meta,
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 12,
                        color: DashColors.muted,
                      ),
                    ),
                    if (r.comentario != null) ...[
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.only(left: 10),
                        decoration: const BoxDecoration(
                          border: Border(
                            left: BorderSide(
                              color: DashColors.coachBorder,
                              width: 2,
                            ),
                          ),
                        ),
                        child: Text(
                          '“${r.comentario}”',
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 13,
                            fontStyle: FontStyle.italic,
                            height: 1.4,
                            color: DashColors.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }
}

class _StarRating extends StatelessWidget {
  final int value;

  const _StarRating({required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (i) {
        final filled = (i + 1) <= value;
        return Icon(
          filled ? Icons.star_rounded : Icons.star_outline_rounded,
          size: 17,
          color: filled ? DashColors.amber : DashColors.text3,
        );
      }),
    );
  }
}

/// Tarjeta "Historial de niveles" con línea de tiempo de cambios.
class LevelHistoryCard extends StatelessWidget {
  final List<LevelHistoryItem> history;

  const LevelHistoryCard({super.key, required this.history});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppGradients.coachCardBg,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: DashColors.coachBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Historial de niveles',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 16.5,
              fontWeight: FontWeight.w700,
              color: DashColors.text,
            ),
          ),
          const SizedBox(height: 14),
          if (history.isEmpty)
            const Text(
              'Aún no has cambiado de nivel. Cuando suceda, quedará registrado aquí.',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 13.5,
                height: 1.45,
                color: DashColors.muted,
              ),
            )
          else
            ...history.asMap().entries.map((entry) {
              final isLast = entry.key == history.length - 1;
              final h = entry.value;
              final meta =
                  '${formatTeamShortDate(h.fecha)}${h.entrenador != null ? ' · ${h.entrenador}' : ''}';

              return Padding(
                padding: EdgeInsets.only(bottom: isLast ? 0 : 14),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: (h.sube ? DashColors.green : DashColors.orange)
                            .withValues(alpha: 0.18),
                      ),
                      child: Icon(
                        h.sube
                            ? Icons.arrow_upward_rounded
                            : Icons.arrow_downward_rounded,
                        size: 15,
                        color: h.sube
                            ? DashColors.badgeRecepcionText
                            : DashColors.warningText,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${formatLevelName(h.anterior)} → ${formatLevelName(h.nuevo)}',
                            style: const TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: DashColors.text,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            meta,
                            style: const TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 12,
                              color: DashColors.muted,
                            ),
                          ),
                          if (h.motivo != null) ...[
                            const SizedBox(height: 4),
                            Text(
                              h.motivo!,
                              style: const TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 13,
                                height: 1.4,
                                color: DashColors.textSecondary,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }
}
