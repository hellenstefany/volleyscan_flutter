import 'package:flutter/material.dart';
import '../../../models/registro_rutina_data.dart';
import '../../../services/api_service.dart';
import '../../../theme/app_theme.dart';
import '../../../theme/dash_colors.dart';
import 'registro_revision_body.dart';
import 'registro_rutinas_common.dart';

/// Abre el diálogo de revisión de una rutina completada.
/// Devuelve el mensaje de éxito si se guardó, o `null` si se canceló.
Future<String?> showRegistroRevisionDialog(
  BuildContext context,
  int rutinaId,
) {
  return showDialog<String>(
    context: context,
    barrierColor: DashColors.modalOverlay,
    builder: (_) => _RegistroRevisionDialog(rutinaId: rutinaId),
  );
}

class _RegistroRevisionDialog extends StatefulWidget {
  final int rutinaId;
  const _RegistroRevisionDialog({required this.rutinaId});

  @override
  State<_RegistroRevisionDialog> createState() =>
      _RegistroRevisionDialogState();
}

class _RegistroRevisionDialogState extends State<_RegistroRevisionDialog> {
  RegistroRutinaItem? _detalle;
  String _error = '';
  int _cal = 0;
  final _comentario = TextEditingController();
  final _nota = TextEditingController();
  bool _guardando = false;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  @override
  void dispose() {
    _comentario.dispose();
    _nota.dispose();
    super.dispose();
  }

  Future<void> _cargar() async {
    try {
      final d = await ApiService().detalleRegistroRutinaEntrenador(
        widget.rutinaId,
      );
      if (!mounted) return;
      setState(() {
        _detalle = d;
        _cal = d.revision?.calificacion ?? 0;
        _comentario.text = d.revision?.comentario ?? '';
        _nota.text = d.revision?.notaPrivada ?? '';
      });
    } on ApiException catch (e) {
      if (!mounted || e.isUnauthorized) return;
      setState(() => _error = e.message);
    } catch (_) {
      if (!mounted) return;
      setState(() => _error = 'No se pudo cargar la rutina.');
    }
  }

  Future<void> _guardar() async {
    if (_guardando || _detalle == null) return;
    if (_cal == 0) {
      setState(() => _error = 'Elige una calificación de 1 a 5 estrellas.');
      return;
    }
    setState(() {
      _guardando = true;
      _error = '';
    });
    try {
      await ApiService().revisarRutinaEntrenador(
        widget.rutinaId,
        calificacion: _cal,
        comentario:
            _comentario.text.trim().isEmpty ? null : _comentario.text.trim(),
        notaPrivada: _nota.text.trim().isEmpty ? null : _nota.text.trim(),
      );
      if (!mounted) return;
      final msg = _detalle?.revision != null
          ? 'Revisión actualizada.'
          : 'Rutina revisada. El deportista recibió un aviso.';
      Navigator.of(context).pop(msg);
    } on ApiException catch (e) {
      if (!mounted || e.isUnauthorized) return;
      setState(() {
        _guardando = false;
        _error = e.message;
      });
      showAppToast(context, e.message, type: 'error');
    } catch (_) {
      if (!mounted) return;
      const msg = 'No se pudo guardar la revisión.';
      setState(() {
        _guardando = false;
        _error = msg;
      });
      showAppToast(context, msg, type: 'error');
    }
  }

  @override
  Widget build(BuildContext context) {
    final d = _detalle;
    return Dialog(
      backgroundColor: DashColors.cardDark,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(22),
        side: const BorderSide(color: DashColors.coachBorder),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 680, maxHeight: 720),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 12, 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          d != null
                              ? '${d.atleta.nombreCompleto} · completada ${regFormatFechaHora(d.completadaEn)}'
                              : 'Cargando…',
                          style: const TextStyle(
                            fontSize: 12.5,
                            color: DashColors.textMuted,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          d != null ? d.nombre : 'Rutina',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: DashColors.text,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed:
                        _guardando ? null : () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close, color: DashColors.textMuted),
                  ),
                ],
              ),
            ),
            const Divider(color: DashColors.coachBorder, height: 1),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_error.isNotEmpty)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        margin: const EdgeInsets.only(bottom: 14),
                        decoration: BoxDecoration(
                          color: DashColors.orange.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: DashColors.orange.withValues(alpha: 0.4),
                          ),
                        ),
                        child: Text(
                          _error,
                          style: const TextStyle(color: DashColors.warningText),
                        ),
                      ),
                    if (d == null && _error.isEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 28),
                        child: Center(
                          child: CircularProgressIndicator(
                            color: DashColors.blueLight,
                          ),
                        ),
                      ),
                    if (d != null)
                      RegistroRevisionBody(
                        d: d,
                        calificacion: _cal,
                        comentarioCtrl: _comentario,
                        notaCtrl: _nota,
                        onCalificacion: (v) => setState(() => _cal = v),
                      ),
                  ],
                ),
              ),
            ),
            const Divider(color: DashColors.coachBorder, height: 1),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed:
                        _guardando ? null : () => Navigator.of(context).pop(),
                    child: const Text(
                      'Cancelar',
                      style: TextStyle(color: DashColors.textSecondary),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Container(
                    decoration: BoxDecoration(
                      gradient: AppGradients.coachPrimaryBtn,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ElevatedButton(
                      onPressed: (d == null || _guardando) ? null : _guardar,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _guardando
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Text(
                              d?.revision != null
                                  ? 'Guardar cambios'
                                  : 'Guardar revisión',
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
