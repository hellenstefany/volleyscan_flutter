import 'package:flutter/material.dart';

import '../../../services/api_service.dart';
import '../../../theme/app_theme.dart';
import 'dashboard_models.dart';
import 'dashboard_theme.dart';

/// Modal "Nueva Sesión" conectado a `POST /api/panel/horarios` (`saveSession` en `page.jsx`).
/// Devuelve el título de la sesión creada si se guardó, o `null` si se cancela.
class DashboardSessionDialog extends StatefulWidget {
  const DashboardSessionDialog({super.key});

  @override
  State<DashboardSessionDialog> createState() => _DashboardSessionDialogState();
}

class _DashboardSessionDialogState extends State<DashboardSessionDialog> {
  final _titleCtrl = TextEditingController(text: 'Entrenamiento general');
  String _tipo = dashboardTipoEventoOptions.first.$1;
  DateTime _date = DateTime.now();
  TimeOfDay _time = const TimeOfDay(hour: 10, minute: 0);
  final _durationCtrl = TextEditingController(text: '90');
  final _ubicacionCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  bool _saving = false;

  @override
  void dispose() {
    _titleCtrl.dispose();
    _durationCtrl.dispose();
    _ubicacionCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  String get _fechaIso =>
      '${_date.year}-${_date.month.toString().padLeft(2, '0')}-${_date.day.toString().padLeft(2, '0')}';

  String get _horaInicioIso =>
      '${_time.hour.toString().padLeft(2, '0')}:${_time.minute.toString().padLeft(2, '0')}';

  Future<void> _pickDate() async {
    final d = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (d != null) setState(() => _date = d);
  }

  Future<void> _pickTime() async {
    final t = await showTimePicker(context: context, initialTime: _time);
    if (t != null) setState(() => _time = t);
  }

  Future<void> _saveSession() async {
    if (_saving) return;
    final title = _titleCtrl.text.trim();
    if (title.isEmpty) {
      showAppToast(context, 'Por favor ingresa un título', type: 'error');
      return;
    }

    final durMin = int.tryParse(_durationCtrl.text.trim()) ?? 60;
    final totalMin = _time.hour * 60 + _time.minute + (durMin > 0 ? durMin : 60);
    final horaFin =
        '${((totalMin ~/ 60) % 24).toString().padLeft(2, '0')}:${(totalMin % 60).toString().padLeft(2, '0')}';

    setState(() => _saving = true);
    try {
      await ApiService().crearHorarioEntrenador(
        titulo: title,
        tipoEvento: _tipo,
        fecha: _fechaIso,
        horaInicio: _horaInicioIso,
        horaFin: horaFin,
        ubicacion: _ubicacionCtrl.text,
        notas: _notesCtrl.text,
        estado: 'programado',
      );
      if (!mounted) return;
      Navigator.of(context).pop(title);
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
      showAppToast(context, e.message, type: 'error');
    } catch (_) {
      if (!mounted) return;
      setState(() => _saving = false);
      showAppToast(
        context,
        'Error al guardar la sesión en el servidor',
        type: 'error',
      );
    }
  }

  InputDecoration _inputDeco({String? hint}) => InputDecoration(
    isDense: true,
    filled: true,
    fillColor: DashboardTheme.bgSecondary,
    hintText: hint,
    hintStyle: const TextStyle(fontSize: 13, color: DashboardTheme.textMuted),
    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: DashboardTheme.border),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: DashboardTheme.blue),
    ),
  );

  Widget _label(String t) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Text(
      t.toUpperCase(),
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.6,
        color: DashboardTheme.textSecondary,
      ),
    ),
  );

  Widget _tapField(String text, VoidCallback onTap) => InkWell(
    borderRadius: BorderRadius.circular(10),
    onTap: _saving ? null : onTap,
    child: Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: DashboardTheme.bgSecondary,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: DashboardTheme.border),
      ),
      child: Text(
        text,
        style: const TextStyle(fontSize: 14, color: DashboardTheme.textPrimary),
      ),
    ),
  );

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: DashboardTheme.bgCard,
      insetPadding: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: const BorderSide(color: DashboardTheme.border),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Nueva Sesión',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: DashboardTheme.textPrimary,
                    ),
                  ),
                  InkWell(
                    borderRadius: BorderRadius.circular(8),
                    onTap: _saving
                        ? null
                        : () => Navigator.of(context).maybePop(),
                    child: Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: DashboardTheme.border),
                      ),
                      child: const Icon(
                        Icons.close,
                        size: 16,
                        color: DashboardTheme.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 22),
              _label('Título de la sesión'),
              TextField(
                controller: _titleCtrl,
                enabled: !_saving,
                style: const TextStyle(
                  fontSize: 14,
                  color: DashboardTheme.textPrimary,
                ),
                cursorColor: DashboardTheme.blue,
                decoration: _inputDeco(hint: 'Ej. Entrenamiento de recepción'),
              ),
              const SizedBox(height: 16),
              _label('Tipo de evento'),
              DropdownButtonFormField<String>(
                initialValue: _tipo,
                isExpanded: true,
                dropdownColor: DashboardTheme.bgCard,
                style: const TextStyle(
                  fontSize: 14,
                  color: DashboardTheme.textPrimary,
                ),
                decoration: _inputDeco(),
                items: dashboardTipoEventoOptions
                    .map(
                      (opt) => DropdownMenuItem(
                        value: opt.$1,
                        child: Text(opt.$2),
                      ),
                    )
                    .toList(),
                onChanged: _saving
                    ? null
                    : (v) {
                        if (v != null) setState(() => _tipo = v);
                      },
              ),
              const SizedBox(height: 16),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _label('Fecha'),
                        _tapField(_fechaIso, _pickDate),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _label('Hora de inicio'),
                        _tapField(_horaInicioIso, _pickTime),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _label('Duración (minutos)'),
                        TextField(
                          controller: _durationCtrl,
                          enabled: !_saving,
                          keyboardType: TextInputType.number,
                          style: const TextStyle(
                            fontSize: 14,
                            color: DashboardTheme.textPrimary,
                          ),
                          cursorColor: DashboardTheme.blue,
                          decoration: _inputDeco(),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _label('Ubicación'),
                        TextField(
                          controller: _ubicacionCtrl,
                          enabled: !_saving,
                          style: const TextStyle(
                            fontSize: 14,
                            color: DashboardTheme.textPrimary,
                          ),
                          cursorColor: DashboardTheme.blue,
                          decoration: _inputDeco(hint: 'Cancha principal'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _label('Notas'),
              TextField(
                controller: _notesCtrl,
                enabled: !_saving,
                style: const TextStyle(
                  fontSize: 14,
                  color: DashboardTheme.textPrimary,
                ),
                cursorColor: DashboardTheme.blue,
                decoration: _inputDeco(),
              ),
              const SizedBox(height: 22),
              Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: OutlinedButton(
                      onPressed: _saving
                          ? null
                          : () => Navigator.of(context).maybePop(),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: DashboardTheme.textSecondary,
                        side: const BorderSide(color: DashboardTheme.border),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        'Cancelar',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    flex: 2,
                    child: Opacity(
                      opacity: _saving ? 0.7 : 1,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(10),
                        onTap: _saving ? null : _saveSession,
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            gradient: AppGradients.sidebarLogoIcon,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color: DashboardTheme.blue.withValues(
                                  alpha: 0.3,
                                ),
                                blurRadius: 15,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Text(
                            _saving ? 'Guardando…' : 'Crear sesión',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
