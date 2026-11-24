import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../models/equipo.dart';
import '../../../models/my_matches_data.dart';
import '../../../models/schedule_data.dart';
import '../../../services/api_service.dart';
import '../../../theme/app_theme.dart';
import '../../../theme/dash_colors.dart';
import '../equipos/equipos_common_widgets.dart';
import 'partido_form_table.dart';

/// Modal para registrar o editar un partido (`POST | PUT /api/ia/partidos...`).
class PartidoFormDialog extends StatefulWidget {
  final List<Equipo> equipos;
  final CoachMatchDetail? inicial;

  const PartidoFormDialog({super.key, required this.equipos, this.inicial});

  @override
  State<PartidoFormDialog> createState() => _PartidoFormDialogState();
}

class _PartidoFormDialogState extends State<PartidoFormDialog> {
  bool get _editando => widget.inicial != null;

  late int _equipoId = widget.inicial?.equipoId ??
      (widget.equipos.isNotEmpty ? widget.equipos.first.id : 0);
  late int? _horarioId = widget.inicial?.horarioId;
  late String _fecha = widget.inicial?.fecha ?? fechaIsoLocal(DateTime.now());
  late int _setsG = widget.inicial?.setsGanados ?? 3;
  late int _setsP = widget.inicial?.setsPerdidos ?? 0;

  late final _rivalCtrl = TextEditingController(text: widget.inicial?.rival ?? '');
  late final _lugarCtrl = TextEditingController(text: widget.inicial?.ubicacion ?? '');
  late final _notasCtrl = TextEditingController(text: widget.inicial?.notas ?? '');

  CoachMatchTemplate? _plantilla;
  final List<PartidoPlayerDraft> _roster = [];
  bool _cargando = true, _guardando = false;
  String _error = '';
  int _reqToken = 0;

  @override
  void initState() {
    super.initState();
    _cargarPlantilla();
  }

  @override
  void dispose() {
    _rivalCtrl.dispose();
    _lugarCtrl.dispose();
    _notasCtrl.dispose();
    for (final r in _roster) {
      r.obsCtrl.dispose();
    }
    super.dispose();
  }

  Future<void> _cargarPlantilla() async {
    if (_equipoId == 0) return;
    final token = ++_reqToken;
    setState(() {
      _cargando = true;
      _error = '';
    });
    try {
      final tpl = await ApiService().plantillaPartidoEntrenador(_equipoId);
      if (!mounted || token != _reqToken) return;
      for (final r in _roster) {
        r.obsCtrl.dispose();
      }
      _roster
        ..clear()
        ..addAll(buildPartidoRoster(tpl, widget.inicial));
      setState(() {
        _plantilla = tpl;
        _cargando = false;
      });
    } on ApiException catch (e) {
      if (!mounted || token != _reqToken) return;
      setState(() {
        _error = e.message;
        _cargando = false;
      });
    } catch (_) {
      if (!mounted || token != _reqToken) return;
      setState(() {
        _error = 'No se pudo cargar la plantilla del equipo.';
        _cargando = false;
      });
    }
  }

  void _elegirEvento(int? id) {
    setState(() {
      _horarioId = id;
      final ev = _plantilla?.eventos.where((e) => e.id == id).firstOrNull;
      if (ev == null) return;
      _fecha = ev.fecha;
      if (_lugarCtrl.text.trim().isEmpty && ev.ubicacion != null) {
        _lugarCtrl.text = ev.ubicacion!;
      }
      if (_rivalCtrl.text.trim().isEmpty) {
        final re = RegExp(r'^(vs\.?|contra)\s+', caseSensitive: false);
        _rivalCtrl.text = ev.titulo.replaceFirst(re, '');
      }
    });
  }

  Future<void> _pickFecha() async {
    final now = DateTime.now(), cur = DateTime.tryParse(_fecha) ?? now;
    final picked = await showDatePicker(
      context: context,
      initialDate: cur.isAfter(now) ? now : cur,
      firstDate: DateTime(2020),
      lastDate: now,
    );
    if (picked != null) setState(() => _fecha = fechaIsoLocal(picked));
  }

  Future<void> _guardar() async {
    if (_guardando || _cargando) return;
    final rival = _rivalCtrl.text.trim();
    if (rival.isEmpty) return _setErr('Escribe el nombre del rival.');
    if (_setsG == _setsP) return _setErr('El resultado no puede quedar empatado.');
    if (math.max(_setsG, _setsP) < 2) {
      return _setErr('Quien gana el partido necesita al menos 2 sets.');
    }

    final jugando = _roster.where((r) => r.juega).toList();
    final cuerpo = <String, dynamic>{
      'equipoId': _equipoId,
      'rival': rival,
      'fecha': _fecha,
      'setsGanados': _setsG,
      'setsPerdidos': _setsP,
      'ubicacion': _lugarCtrl.text.trim(),
      'notas': _notasCtrl.text.trim(),
      'horarioId': _horarioId,
      'jugadores': [for (final j in jugando) j.toPayload()],
    };

    setState(() {
      _guardando = true;
      _error = '';
    });
    try {
      if (_editando) {
        await ApiService().editarPartidoEntrenador(widget.inicial!.id, cuerpo);
      } else {
        await ApiService().crearPartidoEntrenador(cuerpo);
      }
      if (!mounted) return;
      final n = jugando.length;
      final msg = _editando
          ? 'Partido actualizado.'
          : (n > 0 ? 'Partido registrado. Avisamos a $n jugador${n == 1 ? '' : 'es'}.' : 'Partido registrado.');
      showAppToast(context, msg);
      Navigator.pop(context, msg);
    } on ApiException catch (e) {
      if (!mounted) return;
      _setErr(e.message, stopLoad: true);
    } catch (_) {
      if (!mounted) return;
      _setErr('No se pudo guardar el partido.', stopLoad: true);
    }
  }

  void _setErr(String msg, {bool stopLoad = false}) {
    setState(() {
      if (stopLoad) _guardando = false;
      _error = msg;
    });
    showAppToast(context, msg, type: 'error');
  }

  @override
  Widget build(BuildContext context) {
    final evs = _plantilla?.eventos ?? const <CoachMatchTemplateEvent>[];
    final iniHor = widget.inicial?.horarioId;
    final evOpts = <DropdownMenuItem<int?>>[
      const DropdownMenuItem<int?>(value: null, child: Text('Sin ligar a un evento')),
      if (iniHor != null && !evs.any((e) => e.id == iniHor))
        DropdownMenuItem<int?>(value: iniHor, child: const Text('Evento actual')),
      for (final e in evs)
        DropdownMenuItem<int?>(
          value: e.id,
          child: Text('${e.titulo} · ${formatPartidoFecha(e.fecha)}', overflow: TextOverflow.ellipsis),
        ),
    ];
    const barSide = BorderSide(color: DashColors.coachBorder);

    return Dialog(
      backgroundColor: DashColors.cardDark,
      insetPadding: const EdgeInsets.all(14),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24), side: barSide),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 980,
          maxHeight: math.min(760, MediaQuery.sizeOf(context).height * 0.9),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(22, 18, 18, 14),
              decoration: const BoxDecoration(border: Border(bottom: barSide)),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(_editando ? 'Editar partido' : 'Nuevo partido', style: const TextStyle(fontSize: 12.8, color: DashColors.textMuted)),
                        const SizedBox(height: 2),
                        Text(_editando ? 'vs ${widget.inicial!.rival}' : 'Registrar resultado y estadísticas', style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w700, color: DashColors.text1)),
                      ],
                    ),
                  ),
                  IconButton(onPressed: _guardando ? null : () => Navigator.pop(context), icon: const Icon(Icons.close_rounded, size: 18, color: DashColors.textMuted)),
                ],
              ),
            ),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(22, 16, 22, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (_error.isNotEmpty) EquipoAlertBanner(text: _error),
                    PartidoFormTopFields(
                      equipos: widget.equipos,
                      equipoId: _equipoId,
                      horarioId: _horarioId,
                      evOpts: evOpts,
                      rivalCtrl: _rivalCtrl,
                      lugarCtrl: _lugarCtrl,
                      fecha: _fecha,
                      setsG: _setsG,
                      setsP: _setsP,
                      editando: _editando,
                      guardando: _guardando,
                      onEquipoChanged: (v) {
                        setState(() {
                          _equipoId = v;
                          _horarioId = null;
                        });
                        _cargarPlantilla();
                      },
                      onEventoChanged: _elegirEvento,
                      onPickFecha: _pickFecha,
                      onSetsGChanged: (v) => setState(() => _setsG = v),
                      onSetsPChanged: (v) => setState(() => _setsP = v),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Marca a quienes jugaron y escribe sus cifras. Los puntos se calculan solos (ataques + bloqueos + aces). Cada jugador recibe un aviso y verá solo sus cifras y la observación que le dejes.',
                      style: TextStyle(fontSize: 12.6, color: DashColors.textMuted, height: 1.4),
                    ),
                    const SizedBox(height: 10),
                    if (_cargando)
                      const Padding(padding: EdgeInsets.symmetric(vertical: 20), child: Text('Cargando jugadores…', style: TextStyle(color: DashColors.textMuted)))
                    else if (_roster.isEmpty)
                      const EquipoAlertBanner(text: 'Este equipo no tiene deportistas activos. Puedes guardar solo el resultado.')
                    else
                      PartidoEditableStatsTable(roster: _roster, guardando: _guardando, onChanged: () => setState(() {})),
                    const SizedBox(height: 16),
                    partidoFieldLabel(
                      'Notas del entrenador (privadas)',
                      TextField(
                        controller: _notasCtrl,
                        maxLines: 3,
                        maxLength: 2000,
                        style: const TextStyle(color: DashColors.text1, fontSize: 13.5),
                        decoration: partidoInputDeco('Qué funcionó, qué corregir… Los deportistas no ven esto. Para decirle algo a un jugador usa su campo «Observación».'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(22, 14, 22, 18),
              decoration: const BoxDecoration(border: Border(top: barSide)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  EquipoSecButton(label: 'Cancelar', enabled: !_guardando, onTap: () => Navigator.pop(context)),
                  const SizedBox(width: 10),
                  EquipoPrimButton(label: _guardando ? 'Guardando…' : (_editando ? 'Guardar cambios' : 'Registrar partido'), enabled: !_guardando && !_cargando, onTap: _guardar),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
