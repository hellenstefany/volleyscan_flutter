import 'package:flutter/material.dart';
import '../../../models/rutina_entrenador_data.dart';
import '../../../services/api_service.dart';
import '../../../theme/app_theme.dart';
import '../../../theme/dash_colors.dart';

/// Muestra el diálogo de confirmación para eliminar una rutina y ejecuta `DELETE`.
Future<bool> showRutinaDeleteDialog(
  BuildContext context,
  RutinaEntrenador r,
) async {
  var borrando = false;
  var eliminada = false;
  await showDialog<void>(
    context: context,
    barrierColor: DashColors.modalOverlay,
    builder: (dlgCtx) => StatefulBuilder(
      builder: (_, setDlgState) => RutinasDeleteDialog(
        rutina: r,
        borrando: borrando,
        onConfirm: () async {
          if (borrando) return;
          setDlgState(() => borrando = true);
          try {
            await ApiService().eliminarRutinaEntrenador(r.id);
            eliminada = true;
            if (dlgCtx.mounted) Navigator.of(dlgCtx).pop();
            if (context.mounted) showAppToast(context, '"${r.nombre}" eliminada');
          } on ApiException catch (e) {
            if (e.statusCode == 404) {
              eliminada = true;
              if (dlgCtx.mounted) Navigator.of(dlgCtx).pop();
              if (context.mounted) showAppToast(context, '"${r.nombre}" eliminada');
              return;
            }
            if (dlgCtx.mounted) setDlgState(() => borrando = false);
            if (context.mounted && !e.isUnauthorized) {
              showAppToast(context, e.message, type: 'error');
            }
          } catch (_) {
            if (dlgCtx.mounted) setDlgState(() => borrando = false);
            if (context.mounted) {
              showAppToast(context, 'No se pudo eliminar la rutina.', type: 'error');
            }
          }
        },
      ),
    ),
  );
  return eliminada;
}

/// Diálogo de confirmación para eliminar una rutina asignada.
class RutinasDeleteDialog extends StatelessWidget {
  final RutinaEntrenador rutina;
  final bool borrando;
  final VoidCallback onConfirm;

  const RutinasDeleteDialog({
    super.key,
    required this.rutina,
    required this.borrando,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    final comp = rutina.progreso.completados;
    final tot = rutina.progreso.total;
    final atleta = rutina.atleta.nombreCompleto;

    return AlertDialog(
      backgroundColor: DashColors.card,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: const BorderSide(color: DashColors.border),
      ),
      title: const Text(
        'ELIMINAR RUTINA',
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.5,
          color: DashColors.text,
        ),
      ),
      content: comp > 0
          ? Text.rich(
              TextSpan(
                style: const TextStyle(
                  fontSize: 14,
                  color: DashColors.textMuted,
                  height: 1.5,
                ),
                children: [
                  TextSpan(
                    text:
                        '«${rutina.nombre}» ya tiene $comp de $tot ejercicios completados por $atleta. Si la eliminas, ',
                  ),
                  const TextSpan(
                    text: 'se pierde ese avance',
                    style: TextStyle(
                      color: DashColors.red,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const TextSpan(text: '.'),
                ],
              ),
            )
          : Text(
              'Se eliminará «${rutina.nombre}» de la lista de $atleta.',
              style: const TextStyle(
                fontSize: 14,
                color: DashColors.textMuted,
                height: 1.5,
              ),
            ),
      actions: [
        TextButton(
          onPressed: borrando ? null : () => Navigator.of(context).pop(),
          child: const Text(
            'Cancelar',
            style: TextStyle(color: DashColors.textSecondary),
          ),
        ),
        ElevatedButton(
          onPressed: borrando ? null : onConfirm,
          style: ElevatedButton.styleFrom(
            backgroundColor: DashColors.red.withValues(alpha: 0.18),
            foregroundColor: DashColors.red,
            side: BorderSide(color: DashColors.red.withValues(alpha: 0.5)),
          ),
          child: borrando
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: DashColors.red,
                  ),
                )
              : const Text('Eliminar'),
        ),
      ],
    );
  }
}
