import 'package:flutter/material.dart';
import '../../../models/registro_rutina_data.dart';
import '../../../services/api_service.dart';
import '../../../theme/app_theme.dart';
import '../../../theme/dash_colors.dart';
import 'registro_nivel_dialog_parts.dart';

/// Abre el diálogo para subir o bajar el nivel de un deportista y ver su historial.
Future<String?> showRegistroNivelDialog(
  BuildContext context,
  DeportistaNivelResumen atleta,
) {
  return showDialog<String>(
    context: context,
    barrierColor: DashColors.modalOverlay,
    builder: (_) => _RegistroNivelDialog(atleta: atleta),
  );
}

class _RegistroNivelDialog extends StatefulWidget {
  final DeportistaNivelResumen atleta;
  const _RegistroNivelDialog({required this.atleta});

  @override
  State<_RegistroNivelDialog> createState() => _RegistroNivelDialogState();
}

class _RegistroNivelDialogState extends State<_RegistroNivelDialog> {
  DeportistaNivelDetalle? _det;
  late String _nuevo = widget.atleta.avance.siguiente ?? widget.atleta.nivel;
  late final TextEditingController _motivo = TextEditingController(
    text: widget.atleta.avance.sugerencia != null
        ? 'Cumplió los criterios de nivel: rutinas revisadas, calificación y cumplimiento.'
        : '',
  );
  String _error = '';
  bool _guardando = false;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  @override
  void dispose() {
    _motivo.dispose();
    super.dispose();
  }

  Future<void> _cargar() async {
    try {
      final d = await ApiService().nivelDeDeportistaEntrenador(
        widget.atleta.id,
      );
      if (mounted) setState(() => _det = d);
    } on ApiException catch (e) {
      if (!mounted || e.isUnauthorized) return;
      setState(() => _error = e.message);
    } catch (_) {}
  }

  bool get _sube =>
      kNivelesOrden.indexOf(_nuevo) >
      kNivelesOrden.indexOf(widget.atleta.nivel);

  bool get _baja =>
      kNivelesOrden.indexOf(_nuevo) <
      kNivelesOrden.indexOf(widget.atleta.nivel);

  Future<void> _guardar() async {
    if (_guardando) return;
    if (_nuevo == widget.atleta.nivel) {
      setState(() => _error = 'Elige un nivel distinto al actual.');
      return;
    }
    if (_baja && _motivo.text.trim().length < 3) {
      setState(() => _error = 'Para bajar el nivel escribe el motivo.');
      return;
    }
    setState(() {
      _guardando = true;
      _error = '';
    });
    try {
      await ApiService().cambiarNivelDeportistaEntrenador(
        widget.atleta.id,
        nivel: _nuevo,
        motivo: _motivo.text.trim().isEmpty ? null : _motivo.text.trim(),
      );
      if (!mounted) return;
      Navigator.of(context).pop(
        '${widget.atleta.nombre} ahora es ${nombreNivelRegistro(_nuevo)}. Recibió un aviso.',
      );
    } on ApiException catch (e) {
      if (!mounted || e.isUnauthorized) return;
      setState(() {
        _guardando = false;
        _error = e.message;
      });
      showAppToast(context, e.message, type: 'error');
    } catch (_) {
      if (!mounted) return;
      const msg = 'No se pudo actualizar el nivel.';
      setState(() {
        _guardando = false;
        _error = msg;
      });
      showAppToast(context, msg, type: 'error');
    }
  }

  @override
  Widget build(BuildContext context) {
    final a = widget.atleta;
    final btnTxt = _sube
        ? 'Subir de nivel'
        : _baja
            ? 'Bajar de nivel'
            : 'Cambiar nivel';

    return Dialog(
      backgroundColor: DashColors.cardDark,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(22),
        side: const BorderSide(color: DashColors.coachBorder),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 600, maxHeight: 680),
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
                          'Nivel actual: ${nombreNivelRegistro(a.nivel)}',
                          style: const TextStyle(
                            fontSize: 12.5,
                            color: DashColors.textMuted,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          'Nivel de ${a.nombreCompleto}',
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
                        margin: const EdgeInsets.only(bottom: 12),
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
                    if (a.avance.sugerencia != null)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        margin: const EdgeInsets.only(bottom: 14),
                        decoration: BoxDecoration(
                          color: DashColors.green.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: DashColors.green.withValues(alpha: 0.35),
                          ),
                        ),
                        child: Text(
                          'Cumple los criterios para subir a ${nombreNivelRegistro(a.avance.siguiente)}. La decisión es tuya.',
                          style: const TextStyle(
                            color: DashColors.successBadgeText,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (final n in kNivelesOrden)
                          RegistroNivelPeldano(
                            nivel: n,
                            actual: a.nivel,
                            seleccionado: _nuevo,
                            sube: _sube,
                            onTap: () => setState(() => _nuevo = n),
                          ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'MOTIVO ${_baja ? '(OBLIGATORIO AL BAJAR)' : '(RECOMENDADO)'}',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.8,
                        color: DashColors.textMuted,
                      ),
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _motivo,
                      maxLines: 3,
                      maxLength: 500,
                      style: const TextStyle(
                        color: DashColors.text,
                        fontSize: 13,
                      ),
                      decoration: const InputDecoration(
                        hintText: 'Qué viste para tomar esta decisión…',
                        counterText: '',
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'El deportista lo verá junto al aviso y en su historial.',
                      style: TextStyle(
                        fontSize: 11.5,
                        color: DashColors.textMuted,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Historial de niveles',
                      style: TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w700,
                        color: DashColors.text,
                      ),
                    ),
                    const SizedBox(height: 8),
                    RegistroNivelHistorialList(detalle: _det),
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
                      onPressed:
                          (_guardando || _nuevo == a.nivel) ? null : _guardar,
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
                          : Text(btnTxt),
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
