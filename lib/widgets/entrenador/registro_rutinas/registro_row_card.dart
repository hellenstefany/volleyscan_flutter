import 'package:flutter/material.dart';
import '../../../models/registro_rutina_data.dart';
import '../../../theme/app_theme.dart';
import '../../../theme/dash_colors.dart';
import 'registro_rutinas_common.dart';

/// Tarjeta de una rutina completada en la pestaña "Registro".
class RegistroRowCard extends StatelessWidget {
  final RegistroRutinaItem item;
  final VoidCallback onRevisar;

  const RegistroRowCard({
    super.key,
    required this.item,
    required this.onRevisar,
  });

  @override
  Widget build(BuildContext context) {
    final rev = item.revision;
    final stripeColor = rev != null ? DashColors.green : DashColors.orange;

    return Container(
      decoration: BoxDecoration(
        gradient: AppGradients.coachCardBg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: DashColors.coachBorder),
      ),
      clipBehavior: Clip.antiAlias,
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(width: 4, color: stripeColor),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        RegAvatar(
                          fotoUrl: item.atleta.fotoUrl,
                          iniciales: item.atleta.iniciales,
                          size: 46,
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Wrap(
                                spacing: 8,
                                runSpacing: 4,
                                crossAxisAlignment: WrapCrossAlignment.center,
                                children: [
                                  Text(
                                    item.atleta.nombreCompleto,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: DashColors.textMuted,
                                    ),
                                  ),
                                  RegChipNivel(nivel: item.atleta.nivel),
                                ],
                              ),
                              const SizedBox(height: 3),
                              Text(
                                item.nombre,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: DashColors.text,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Wrap(
                                spacing: 6,
                                runSpacing: 6,
                                crossAxisAlignment: WrapCrossAlignment.center,
                                children: [
                                  if (item.tipo != null) RegChip(item.tipo!),
                                  RegChip(
                                    item.nivel == 'todos'
                                        ? 'Rutina para todos los niveles'
                                        : 'Rutina de nivel ${nombreNivelRegistro(item.nivel).toLowerCase()}',
                                    bg: Colors.transparent,
                                    fg: DashColors.textMuted,
                                    border: DashColors.coachBorder,
                                  ),
                                  RegChip('${item.ejercicios} ejercicios'),
                                  if (item.aTiempo == true)
                                    RegChip(
                                      'A tiempo',
                                      bg: DashColors.green.withValues(alpha: 0.15),
                                      fg: DashColors.successBadgeText,
                                    ),
                                  if (item.aTiempo == false &&
                                      item.diasRetraso != null)
                                    RegChip(
                                      '${item.diasRetraso} ${item.diasRetraso == 1 ? 'día' : 'días'} tarde',
                                      bg: DashColors.orange.withValues(alpha: 0.15),
                                      fg: DashColors.warningText,
                                    ),
                                  Text(
                                    'Completada ${regFormatFechaHora(item.completadaEn)}',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: DashColors.textMuted,
                                    ),
                                  ),
                                ],
                              ),
                              if (rev?.comentario != null) ...[
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
                                    '“${rev!.comentario!}”',
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontStyle: FontStyle.italic,
                                      color: DashColors.textSecondary,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        if (rev != null) ...[
                          RegEstrellas(valor: rev.calificacion, size: 17),
                          const SizedBox(width: 12),
                          OutlinedButton(
                            onPressed: onRevisar,
                            style: OutlinedButton.styleFrom(
                              foregroundColor: DashColors.textSecondary,
                              side: const BorderSide(
                                color: DashColors.coachBorder,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: const Text('Editar revisión'),
                          ),
                        ] else
                          Container(
                            decoration: BoxDecoration(
                              gradient: AppGradients.coachPrimaryBtn,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: ElevatedButton(
                              onPressed: onRevisar,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Text('Revisar'),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
