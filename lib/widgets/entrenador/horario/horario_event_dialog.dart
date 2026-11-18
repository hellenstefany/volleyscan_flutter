import 'package:flutter/material.dart';
import 'horario_colors.dart';
import 'horario_common_widgets.dart';
import 'horario_model.dart';

/// Modal para crear / editar / eliminar un evento.
class EventDialog extends StatefulWidget {
  final Ev? editing;
  final DateTime initFecha;
  final TimeOfDay initIni, initFin;
  const EventDialog({
    super.key,
    required this.editing,
    required this.initFecha,
    required this.initIni,
    required this.initFin,
  });

  @override
  State<EventDialog> createState() => _EventDialogState();
}

class _EventDialogState extends State<EventDialog> {
  late final TextEditingController _title = TextEditingController(
    text: widget.editing?.title ?? '',
  );
  late final TextEditingController _place = TextEditingController(
    text: widget.editing?.place ?? '',
  );
  late final TextEditingController _notes = TextEditingController(
    text: widget.editing?.notes ?? '',
  );
  late String _type = widget.editing?.type ?? 'Entrenamiento';
  late DateTime _fecha = widget.initFecha;
  late TimeOfDay _ini = widget.initIni;
  late TimeOfDay _fin = widget.initFin;
  String? _error;

  @override
  void dispose() {
    _title.dispose();
    _place.dispose();
    _notes.dispose();
    super.dispose();
  }

  Future<void> _pickFecha() async {
    final d = await showDatePicker(
      context: context,
      initialDate: _fecha,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (d != null) setState(() => _fecha = d);
  }

  Future<void> _pickHora(bool inicio) async {
    final t = await showTimePicker(
      context: context,
      initialTime: inicio ? _ini : _fin,
      builder: (ctx, child) => MediaQuery(
        data: MediaQuery.of(ctx).copyWith(alwaysUse24HourFormat: true),
        child: child!,
      ),
    );
    if (t != null) setState(() => inicio ? _ini = t : _fin = t);
  }

  void _save() {
    if (_title.text.trim().isEmpty) {
      setState(() => _error = 'El nombre es obligatorio');
      return;
    }
    final start = DateTime(
      _fecha.year,
      _fecha.month,
      _fecha.day,
      _ini.hour,
      _ini.minute,
    );
    final end = DateTime(
      _fecha.year,
      _fecha.month,
      _fecha.day,
      _fin.hour,
      _fin.minute,
    );
    if (!end.isAfter(start)) {
      setState(() => _error = 'La hora fin debe ser posterior');
      return;
    }
    Navigator.pop(
      context,
      EvDialogResult(
        ev: Ev(
          id: widget.editing?.id ?? DateTime.now().millisecondsSinceEpoch,
          title: _title.text.trim(),
          type: _type,
          place: _place.text.trim(),
          notes: _notes.text.trim(),
          start: start,
          end: end,
        ),
      ),
    );
  }

  // ── helpers de UI ──
  OutlineInputBorder _ob(Color c) => OutlineInputBorder(
    borderRadius: BorderRadius.circular(9),
    borderSide: BorderSide(color: c),
  );

  InputDecoration _deco(String hint) => InputDecoration(
    isDense: true,
    filled: true,
    fillColor: HC.card3,
    hintText: hint,
    hintStyle: const TextStyle(color: HC.t3, fontSize: 13),
    contentPadding: const EdgeInsets.symmetric(horizontal: 11, vertical: 11),
    border: _ob(HC.border2),
    enabledBorder: _ob(HC.border2),
    focusedBorder: _ob(HC.blue),
  );

  Widget _field(String label, Widget child) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label.toUpperCase(),
        style: const TextStyle(
          fontSize: 10.5,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.7,
          color: HC.t2,
        ),
      ),
      const SizedBox(height: 5),
      child,
    ],
  );

  Widget _pickerBox(String text, VoidCallback onTap) => InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(9),
    child: Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 12),
      decoration: BoxDecoration(
        color: HC.card3,
        borderRadius: BorderRadius.circular(9),
        border: Border.all(color: HC.border2),
      ),
      child: Text(text, style: const TextStyle(fontSize: 13, color: HC.t1)),
    ),
  );

  @override
  Widget build(BuildContext context) {
    final editing = widget.editing != null;
    const red = Color(0xFFF87171);
    const redDark = Color(0xFFDC2626);

    return Dialog(
      backgroundColor: HC.card2,
      insetPadding: const EdgeInsets.all(20),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: const BorderSide(color: HC.border2),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(26),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Icon(
                    editing ? Icons.edit : Icons.event_available,
                    size: 16,
                    color: HC.t1,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      editing ? 'Editar evento' : 'Nuevo evento',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: HC.t1,
                      ),
                    ),
                  ),
                  CloseBtn(onTap: () => Navigator.pop(context)),
                ],
              ),
              const SizedBox(height: 20),
              _field(
                'Nombre del evento',
                TextField(
                  controller: _title,
                  style: const TextStyle(color: HC.t1, fontSize: 13),
                  decoration: _deco('Ej. Entrenamiento técnico'),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: _field(
                      'Tipo',
                      DropdownButtonFormField<String>(
                        value: _type,
                        isExpanded: true,
                        dropdownColor: HC.card3,
                        style: const TextStyle(color: HC.t1, fontSize: 13),
                        decoration: _deco(''),
                        items: [
                          for (final t in kTipos)
                            DropdownMenuItem(value: t, child: Text(t)),
                        ],
                        onChanged: (v) => setState(() => _type = v ?? _type),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _field(
                      'Lugar',
                      TextField(
                        controller: _place,
                        style: const TextStyle(color: HC.t1, fontSize: 13),
                        decoration: _deco('Cancha 1…'),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _field('Fecha', _pickerBox(fmtDate(_fecha), _pickFecha)),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _field(
                      'Hora inicio',
                      _pickerBox(fmtTod(_ini), () => _pickHora(true)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _field(
                      'Hora fin',
                      _pickerBox(fmtTod(_fin), () => _pickHora(false)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _field(
                'Notas',
                TextField(
                  controller: _notes,
                  maxLines: 2,
                  style: const TextStyle(color: HC.t1, fontSize: 13),
                  decoration: _deco('Detalles adicionales…'),
                ),
              ),
              if (_error != null) ...[
                const SizedBox(height: 12),
                Text(_error!, style: const TextStyle(fontSize: 12, color: red)),
              ],
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.only(top: 16),
                decoration: const BoxDecoration(
                  border: Border(top: BorderSide(color: HC.border)),
                ),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  alignment: WrapAlignment.end,
                  children: [
                    if (editing)
                      OutlinedButton.icon(
                        onPressed: () => Navigator.pop(
                          context,
                          const EvDialogResult(delete: true),
                        ),
                        icon: const Icon(Icons.delete_outline, size: 15),
                        label: const Text('Eliminar'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: red,
                          backgroundColor: redDark.withValues(alpha: 0.08),
                          side: BorderSide(
                            color: redDark.withValues(alpha: 0.3),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(9),
                          ),
                        ),
                      ),
                    OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: HC.t2,
                        side: const BorderSide(color: HC.border2),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 14,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(9),
                        ),
                      ),
                      child: const Text('Cancelar'),
                    ),
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: _save,
                        borderRadius: BorderRadius.circular(9),
                        child: Ink(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 22,
                            vertical: 14,
                          ),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [HC.purpleG1, HC.purpleG2],
                            ),
                            borderRadius: BorderRadius.circular(9),
                          ),
                          child: const Text(
                            'Guardar',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
