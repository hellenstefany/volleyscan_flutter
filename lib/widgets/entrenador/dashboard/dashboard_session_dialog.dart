import 'package:flutter/material.dart';

import 'dashboard_models.dart';
import 'dashboard_theme.dart';

/// Diálogo "Nueva sesión". Devuelve el tipo de sesión elegido (o null si se cancela).
class DashboardSessionDialog extends StatefulWidget {
  const DashboardSessionDialog({super.key});

  @override
  State<DashboardSessionDialog> createState() => _DashboardSessionDialogState();
}

class _DashboardSessionDialogState extends State<DashboardSessionDialog> {
  String _type = dashboardSessionTypes.first;
  DateTime _date = DateTime.now();
  TimeOfDay _time = const TimeOfDay(hour: 10, minute: 0);
  final _durationCtrl = TextEditingController(text: '90');
  final _notesCtrl = TextEditingController();

  @override
  void dispose() {
    _durationCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  String get _dateText =>
      '${_date.day.toString().padLeft(2, '0')}/${_date.month.toString().padLeft(2, '0')}/${_date.year}';

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

  InputDecoration get _inputDeco => InputDecoration(
    isDense: true,
    filled: true,
    fillColor: DashboardTheme.bgSecondary,
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
    onTap: onTap,
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
                    onTap: () => Navigator.pop(context),
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
              _label('Tipo de sesión'),
              DropdownButtonFormField<String>(
                initialValue: _type,
                isExpanded: true,
                dropdownColor: DashboardTheme.bgCard,
                style: const TextStyle(
                  fontSize: 14,
                  color: DashboardTheme.textPrimary,
                ),
                decoration: _inputDeco,
                items: dashboardSessionTypes
                    .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                    .toList(),
                onChanged: (v) {
                  if (v != null) setState(() => _type = v);
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
                        _tapField(_dateText, _pickDate),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _label('Hora'),
                        _tapField(_time.format(context), _pickTime),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _label('Duración (minutos)'),
              TextField(
                controller: _durationCtrl,
                keyboardType: TextInputType.number,
                style: const TextStyle(
                  fontSize: 14,
                  color: DashboardTheme.textPrimary,
                ),
                cursorColor: DashboardTheme.blue,
                decoration: _inputDeco,
              ),
              const SizedBox(height: 16),
              _label('Notas'),
              TextField(
                controller: _notesCtrl,
                style: const TextStyle(
                  fontSize: 14,
                  color: DashboardTheme.textPrimary,
                ),
                cursorColor: DashboardTheme.blue,
                decoration: _inputDeco,
              ),
              const SizedBox(height: 22),
              Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
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
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context, _type),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [
                              DashboardTheme.blue,
                              DashboardTheme.purple,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: DashboardTheme.blue.withOpacity(0.3),
                              blurRadius: 15,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Text(
                          'Crear sesión',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
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
