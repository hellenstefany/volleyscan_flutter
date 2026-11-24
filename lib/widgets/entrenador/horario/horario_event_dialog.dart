import 'package:flutter/material.dart';

import '../../../models/equipo.dart';
import '../../../services/api_service.dart';
import '../../../theme/app_theme.dart';
import '../equipos/equipos_common_widgets.dart';
import '../gestion/gestion_athlete.dart';
import 'horario_colors.dart';
import 'horario_common_widgets.dart';
import 'horario_model.dart';
import 'horario_month_picker.dart';

enum EventDialogOutcome { saved, deleted, openAttendance }

/// Modal para crear, editar o eliminar un evento del horario (`/api/ia/horario...`).
class EventDialog extends StatefulWidget {
  final CoachScheduleEvent? editing;
  final DateTime initFecha;
  final TimeOfDay initIni, initFin;
  final List<Equipo> equipos;
  final List<EntrenadorDeportista> deportistas;

  const EventDialog({
    super.key,
    required this.editing,
    required this.initFecha,
    required this.initIni,
    required this.initFin,
    required this.equipos,
    required this.deportistas,
  });

  @override
  State<EventDialog> createState() => _EventDialogState();
}

class _EventDialogState extends State<EventDialog> {
  late final TextEditingController _title = TextEditingController(text: widget.editing?.titulo ?? '');
  late final TextEditingController _place = TextEditingController(text: widget.editing?.ubicacion ?? '');
  late final TextEditingController _notes = TextEditingController(text: widget.editing?.notas ?? '');

  late String _tipo = widget.editing?.tipo ?? 'entrenamiento';
  late String _estado = widget.editing?.estado ?? 'programado';
  late DateTime _fecha = widget.initFecha;
  late TimeOfDay _ini = widget.initIni;
  late TimeOfDay _fin = widget.initFin;
  late String _para;
  late List<CoachScheduleAthleteRef> _citados;
  bool _guardando = false;

  @override
  void initState() {
    super.initState();
    final ed = widget.editing;
    if (ed != null) {
      _para = ed.equipo != null ? 'equipo:${ed.equipo!.id}' : (ed.deportistas.isNotEmpty ? 'deportistas' : 'personal');
      _citados = List.of(ed.deportistas);
    } else {
      _para = widget.equipos.isNotEmpty ? 'equipo:${widget.equipos.first.id}' : 'personal';
      _citados = [];
    }
  }

  @override
  void dispose() {
    _title.dispose();
    _place.dispose();
    _notes.dispose();
    super.dispose();
  }

  List<(String, String)> get _paraOptions {
    final opts = <(String, String)>[for (final eq in widget.equipos) ('equipo:${eq.id}', eq.nombre)];
    if (widget.editing?.equipo != null && !opts.any((o) => o.$1 == 'equipo:${widget.editing!.equipo!.id}')) {
      opts.add(('equipo:${widget.editing!.equipo!.id}', widget.editing!.equipo!.nombre));
    }
    if (widget.deportistas.isNotEmpty || _citados.isNotEmpty) {
      opts.add(('deportistas', 'Deportistas elegidos (uno o varios)'));
    }
    opts.add(('personal', 'Solo para mí'));
    return opts;
  }

  String get _avisoPara {
    if (_para.startsWith('equipo:')) return 'Los deportistas del equipo verán este evento y recibirán un aviso.';
    if (_para == 'deportistas') {
      final n = _citados.length;
      if (n == 0) return 'Marca a quién quieres citar.';
      return n == 1 ? 'Solo ese deportista lo verá y recibirá un aviso.' : 'Solo los $n citados lo verán y cada uno recibirá un aviso.';
    }
    return 'Solo tú verás este evento.';
  }

  Future<void> _pickFecha() async {
    final d = await showDatePicker(context: context, initialDate: _fecha, firstDate: DateTime(2020), lastDate: DateTime(2100));
    if (d != null) setState(() => _fecha = d);
  }

  Future<void> _pickHora(bool inicio) async {
    final t = await showTimePicker(
      context: context,
      initialTime: inicio ? _ini : _fin,
      builder: (ctx, child) => MediaQuery(data: MediaQuery.of(ctx).copyWith(alwaysUse24HourFormat: true), child: child!),
    );
    if (t != null) setState(() => inicio ? _ini = t : _fin = t);
  }

  Future<void> _save() async {
    if (_guardando) return;
    final title = _title.text.trim();
    if (title.isEmpty) return showAppToast(context, 'El nombre es obligatorio', type: 'error');
    final horaI = fmtTod(_ini), horaF = fmtTod(_fin);
    if (horaF.compareTo(horaI) <= 0) return showAppToast(context, 'La hora fin debe ser posterior', type: 'error');
    if (_para == 'deportistas' && _citados.isEmpty) return showAppToast(context, 'Elige al menos un deportista', type: 'error');

    final cuerpo = <String, dynamic>{
      'titulo': title,
      'tipo': _tipo,
      'fecha': fmtDate(_fecha),
      'horaInicio': horaI,
      'horaFin': horaF,
      'ubicacion': _place.text.trim(),
      'notas': _notes.text.trim(),
      'estado': _estado,
      'equipoId': _para.startsWith('equipo:') ? int.tryParse(_para.split(':')[1]) : null,
      'deportistaIds': _para == 'deportistas' ? _citados.map((c) => c.id).toList() : const <int>[],
    };
    setState(() => _guardando = true);
    try {
      if (widget.editing != null) {
        await ApiService().editarEventoHorarioEntrenador(widget.editing!.id, cuerpo);
      } else {
        await ApiService().crearEventoHorarioEntrenador(cuerpo);
      }
      if (!mounted) return;
      showAppToast(context, widget.editing != null ? 'Evento actualizado' : 'Evento creado');
      Navigator.pop(context, EventDialogOutcome.saved);
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _guardando = false);
      showAppToast(context, e.message, type: 'error');
    } catch (_) {
      if (!mounted) return;
      setState(() => _guardando = false);
      showAppToast(context, 'No se pudo guardar el evento.', type: 'error');
    }
  }

  Future<void> _delete() async {
    final ed = widget.editing;
    if (_guardando || ed == null) return;
    final ok = await showEquipoConfirmDialog(
      context,
      title: 'Eliminar evento',
      message: '¿Eliminar este evento? Si es de un equipo o de un deportista, se les avisará.',
      confirmLabel: 'Eliminar',
    );
    if (!ok || !mounted) return;
    setState(() => _guardando = true);
    try {
      await ApiService().eliminarEventoHorarioEntrenador(ed.id);
      if (!mounted) return;
      showAppToast(context, 'Evento eliminado');
      Navigator.pop(context, EventDialogOutcome.deleted);
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _guardando = false);
      showAppToast(context, e.message, type: 'error');
    } catch (_) {
      if (!mounted) return;
      setState(() => _guardando = false);
      showAppToast(context, 'No se pudo eliminar el evento.', type: 'error');
    }
  }

  InputDecoration _deco(String hint) => InputDecoration(
        isDense: true,
        filled: true,
        fillColor: HC.card3,
        counterText: '',
        hintText: hint,
        hintStyle: const TextStyle(color: HC.t3, fontSize: 13),
        contentPadding: const EdgeInsets.symmetric(horizontal: 11, vertical: 10),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(9), borderSide: const BorderSide(color: HC.border2)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(9), borderSide: const BorderSide(color: HC.blue)),
      );

  Widget _field(String label, Widget child, {String? hint}) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label.toUpperCase(), style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, letterSpacing: 0.7, color: HC.t2)),
          const SizedBox(height: 5),
          child,
          if (hint != null) Padding(padding: const EdgeInsets.only(top: 4), child: Text(hint, style: const TextStyle(fontSize: 11, color: HC.t2))),
        ],
      );

  Widget _pickerBox(String text, VoidCallback onTap) => InkWell(
        onTap: _guardando ? null : onTap,
        borderRadius: BorderRadius.circular(9),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 11),
          decoration: BoxDecoration(color: HC.card3, borderRadius: BorderRadius.circular(9), border: Border.all(color: HC.border2)),
          child: Text(text, style: const TextStyle(fontSize: 13, color: HC.t1)),
        ),
      );

  Widget _dropdown(String value, List<(String, String)> items, ValueChanged<String?> onChanged) => DropdownButtonFormField<String>(
        initialValue: value,
        isExpanded: true,
        dropdownColor: HC.card3,
        style: const TextStyle(color: HC.t1, fontSize: 13),
        decoration: _deco(''),
        items: [for (final i in items) DropdownMenuItem(value: i.$1, child: Text(i.$2, overflow: TextOverflow.ellipsis))],
        onChanged: _guardando ? null : onChanged,
      );

  @override
  Widget build(BuildContext context) {
    final ed = widget.editing;
    final editing = ed != null;
    final opts = _paraOptions;
    if (!opts.any((o) => o.$1 == _para)) _para = opts.last.$1;

    return Dialog(
      backgroundColor: HC.card2,
      insetPadding: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18), side: const BorderSide(color: HC.border2)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 490),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Icon(editing ? Icons.edit : Icons.event_available, size: 16, color: HC.t1),
                  const SizedBox(width: 8),
                  Expanded(child: Text(editing ? 'Editar evento' : 'Nuevo evento', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: HC.t1))),
                  CloseBtn(onTap: () => Navigator.pop(context)),
                ],
              ),
              const SizedBox(height: 16),
              _field('Nombre del evento', TextField(controller: _title, maxLength: 150, style: const TextStyle(color: HC.t1, fontSize: 13), decoration: _deco('Ej. Entrenamiento técnico'))),
              const SizedBox(height: 12),
              _field('Para', _dropdown(_para, opts, (v) => setState(() => _para = v ?? _para)), hint: _avisoPara),
              if (_para == 'deportistas') ...[
                const SizedBox(height: 12),
                _field('Citar a ${_citados.length}', HorarioAthletesSelector(deportistas: widget.deportistas, citados: _citados, onChanged: (next) => setState(() => _citados = next))),
              ],
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(child: _field('Tipo', _dropdown(kHorarioTipos.any((t) => t.$1 == _tipo) ? _tipo : 'entrenamiento', kHorarioTipos, (v) => setState(() => _tipo = v ?? _tipo)))),
                  const SizedBox(width: 12),
                  Expanded(child: _field('Lugar', TextField(controller: _place, maxLength: 150, style: const TextStyle(color: HC.t1, fontSize: 13), decoration: _deco('Cancha 1…')))),
                ],
              ),
              const SizedBox(height: 12),
              _field('Fecha', _pickerBox(fmtDate(_fecha), _pickFecha)),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(child: _field('Hora inicio', _pickerBox(fmtTod(_ini), () => _pickHora(true)))),
                  const SizedBox(width: 12),
                  Expanded(child: _field('Hora fin', _pickerBox(fmtTod(_fin), () => _pickHora(false)))),
                ],
              ),
              if (editing) ...[
                const SizedBox(height: 12),
                _field('Estado', _dropdown(kHorarioEstados.any((e) => e.$1 == _estado) ? _estado : 'programado', kHorarioEstados, (v) => setState(() => _estado = v ?? _estado))),
              ],
              const SizedBox(height: 12),
              _field('Indicaciones', TextField(controller: _notes, maxLines: 3, maxLength: 2000, style: const TextStyle(color: HC.t1, fontSize: 13), decoration: _deco('Qué llevar, qué se va a trabajar, punto de encuentro… (los deportistas lo ven)'))),
              const SizedBox(height: 18),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                alignment: WrapAlignment.end,
                children: [
                  if (editing) EquipoDangerButton(label: 'Eliminar', mini: true, enabled: !_guardando, onTap: _delete),
                  if (editing && ed.conLista && _estado != 'cancelado')
                    EquipoSecButton(label: 'Asistencia', mini: true, enabled: !_guardando, onTap: () => Navigator.pop(context, EventDialogOutcome.openAttendance)),
                  EquipoSecButton(label: 'Cancelar', mini: true, enabled: !_guardando, onTap: () => Navigator.pop(context)),
                  EquipoPrimButton(label: _guardando ? 'Guardando…' : 'Guardar', mini: true, enabled: !_guardando, onTap: _save),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
