import 'package:flutter/material.dart';
import '../../../models/registro_rutina_data.dart';
import '../../../theme/dash_colors.dart';
import 'registro_rutinas_common.dart';

/// Cuerpo del diálogo de revisión: chips, objetivo, lista de ejercicios y formulario.
class RegistroRevisionBody extends StatelessWidget {
  final RegistroRutinaItem d;
  final int calificacion;
  final TextEditingController comentarioCtrl;
  final TextEditingController notaCtrl;
  final ValueChanged<int> onCalificacion;

  const RegistroRevisionBody({
    super.key,
    required this.d,
    required this.calificacion,
    required this.comentarioCtrl,
    required this.notaCtrl,
    required this.onCalificacion,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: [
            if (d.tipo != null) RegChip(d.tipo!),
            RegChipNivel(nivel: d.nivel),
            if (d.intensidad != null) RegChip('Intensidad ${d.intensidad}/10'),
            if (d.aTiempo == true)
              RegChip(
                'Completada a tiempo',
                bg: DashColors.green.withValues(alpha: 0.15),
                fg: DashColors.successBadgeText,
              ),
            if (d.aTiempo == false && d.diasRetraso != null)
              RegChip(
                '${d.diasRetraso} ${d.diasRetraso == 1 ? 'día' : 'días'} después de lo programado',
                bg: DashColors.orange.withValues(alpha: 0.15),
                fg: DashColors.warningText,
              ),
          ],
        ),
        if (d.objetivo != null) ...[
          const SizedBox(height: 12),
          Text.rich(
            TextSpan(
              children: [
                const TextSpan(
                  text: 'Objetivo: ',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: DashColors.text,
                  ),
                ),
                TextSpan(text: d.objetivo!),
              ],
            ),
            style: const TextStyle(
              fontSize: 13.5,
              color: DashColors.textSecondary,
            ),
          ),
        ],
        const SizedBox(height: 14),
        for (final ej in d.listaEjercicios)
          Container(
            margin: const EdgeInsets.only(bottom: 6),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
            decoration: BoxDecoration(
              color: DashColors.coachCard2,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: DashColors.coachBorder),
            ),
            child: Row(
              children: [
                Container(
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: DashColors.green.withValues(alpha: 0.18),
                  ),
                  child: const Icon(
                    Icons.check,
                    size: 13,
                    color: DashColors.badgeRecepcionText,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    ej.nombre,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: DashColors.text,
                      fontWeight: FontWeight.w600,
                      fontSize: 13.5,
                    ),
                  ),
                ),
                Text(
                  '${ej.series}×${ej.repeticiones}',
                  style: const TextStyle(
                    color: DashColors.accent2,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  regFormatFechaHora(ej.completadoEn),
                  style: const TextStyle(
                    color: DashColors.textMuted,
                    fontSize: 11.5,
                  ),
                ),
              ],
            ),
          ),
        const SizedBox(height: 16),
        const Text(
          '¿Cómo la hizo?',
          style: TextStyle(
            fontSize: 14.5,
            fontWeight: FontWeight.w700,
            color: DashColors.text,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            RegEstrellas(
              valor: calificacion,
              size: 28,
              onCambiar: onCalificacion,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                calificacion > 0
                    ? (kEtiquetaCalificacion[calificacion] ?? '')
                    : 'Elige una calificación',
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  color: DashColors.text,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        const Text(
          'COMENTARIO PARA EL DEPORTISTA',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.8,
            color: DashColors.textMuted,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: comentarioCtrl,
          maxLines: 3,
          maxLength: 1000,
          style: const TextStyle(color: DashColors.text, fontSize: 13),
          decoration: const InputDecoration(
            hintText:
                'Ej: Buen ritmo. Sube más la altura del brazo en el saque.',
            counterText: '',
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Lo verá en «Mi nivel» y recibirá un aviso.',
          style: TextStyle(fontSize: 11.5, color: DashColors.textMuted),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: DashColors.coachPurple.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: DashColors.coachPurple.withValues(alpha: 0.28),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(
                    Icons.lock_outline,
                    size: 14,
                    color: DashColors.infoBadgeText,
                  ),
                  SizedBox(width: 6),
                  Text(
                    'NOTA PRIVADA',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.8,
                      color: DashColors.infoBadgeText,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              TextField(
                controller: notaCtrl,
                maxLines: 2,
                maxLength: 1000,
                style: const TextStyle(color: DashColors.text, fontSize: 13),
                decoration: const InputDecoration(
                  hintText: 'Solo tú la ves. Útil para decidir su nivel.',
                  counterText: '',
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
