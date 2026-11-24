import 'package:flutter/material.dart';

import '../../../services/api_service.dart';
import '../../../theme/app_theme.dart';
import '../../../theme/dash_colors.dart';
import '../equipos/equipos_common_widgets.dart';
import 'horario_colors.dart';
import 'horario_controls.dart';
import 'horario_model.dart';

export 'horario_controls.dart';

/// Modal para pasar lista de asistencia y observaciones (`GET | PUT /api/ia/horario/<id>/asistencia`).
class HorarioAttendanceDialog extends StatefulWidget {
  final int eventoId;
  const HorarioAttendanceDialog({super.key, required this.eventoId});

  @override
  State<HorarioAttendanceDialog> createState() => _HorarioAttendanceDialogState();
}

class _HorarioAttendanceDialogState extends State<HorarioAttendanceDialog> {
  CoachAttendanceResponse? _asis;
  bool _cargando = true, _guardando = false;
  String _error = '';
  final Map<int, String?> _estados = {};
  final Map<int, TextEditingController> _obsCtrls = {};
  final Map<int, bool> _visibles = {};
  final Set<int> _notasAbiertas = {};

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  @override
  void dispose() {
    for (final c in _obsCtrls.values) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _cargar() async {
    setState(() {
      _cargando = true;
      _error = '';
    });
    try {
      final res = await ApiService().obtenerAsistenciaHorario(widget.eventoId);
      if (!mounted) return;
      for (final d in res.deportistas) {
        _estados[d.id] = d.estado;
        _obsCtrls.putIfAbsent(d.id, () => TextEditingController(text: d.observacion)).text = d.observacion;
        _visibles[d.id] = d.observacionVisible;
        if (d.observacion.isNotEmpty) _notasAbiertas.add(d.id);
      }
      setState(() {
        _asis = res;
        _cargando = false;
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.message;
        _cargando = false;
      });
      showAppToast(context, e.message, type: 'error');
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _error = 'No se pudo cargar la lista de asistencia.';
        _cargando = false;
      });
    }
  }

  List<CoachAttendanceAthlete> get _cambios {
    final asis = _asis;
    if (asis == null) return const [];
    return asis.deportistas.where((d) {
      final est = _estados[d.id];
      final obs = (_obsCtrls[d.id]?.text ?? '').trim();
      final vis = obs.isNotEmpty ? (_visibles[d.id] == true) : false;
      return est != d.estado || obs != d.observacion.trim() || vis != d.observacionVisible;
    }).toList();
  }

  Future<void> _cerrar() async {
    if (_cambios.isNotEmpty) {
      final salir = await showEquipoConfirmDialog(context, title: 'Cambios sin guardar', message: 'Tienes cambios sin guardar. ¿Salir de todos modos?', confirmLabel: 'Salir');
      if (!salir || !mounted) return;
    }
    if (mounted) Navigator.pop(context, false);
  }

  Future<void> _guardar() async {
    final cambios = _cambios;
    if (_guardando || cambios.isEmpty) return;
    setState(() {
      _guardando = true;
      _error = '';
    });
    try {
      final registros = [
        for (final d in cambios)
          {'deportistaId': d.id, 'estado': _estados[d.id], 'observacion': (_obsCtrls[d.id]?.text ?? '').trim(), 'observacionVisible': _visibles[d.id] == true},
      ];
      await ApiService().guardarAsistenciaHorario(widget.eventoId, registros);
      if (!mounted) return;
      showAppToast(context, 'Asistencia guardada');
      Navigator.pop(context, true);
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _guardando = false;
        _error = e.message;
      });
      showAppToast(context, e.message, type: 'error');
    } catch (_) {
      if (!mounted) return;
      const msg = 'No se pudo guardar la asistencia.';
      setState(() {
        _guardando = false;
        _error = msg;
      });
      showAppToast(context, msg, type: 'error');
    }
  }

  @override
  Widget build(BuildContext context) {
    final asis = _asis;
    final cambios = _cambios;
    return Dialog(
      backgroundColor: HC.card2,
      insetPadding: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18), side: const BorderSide(color: HC.border2)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 740, maxHeight: 680),
        child: Padding(
          padding: const EdgeInsets.all(22),
          child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Row(children: [
              const Icon(Icons.fact_check_outlined, size: 17, color: HC.t1),
              const SizedBox(width: 8),
              Expanded(child: Text(asis != null ? 'Asistencia · ${asis.evento.titulo}' : 'Asistencia', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: HC.t1))),
              CloseBtn(onTap: _cerrar),
            ]),
            const SizedBox(height: 12),
            if (_cargando)
              const Padding(padding: EdgeInsets.all(24), child: Text('Cargando lista…', style: TextStyle(color: HC.t2)))
            else if (asis == null)
              HorarioStatusBanner(loading: false, error: _error, onRetry: _cargar)
            else ...[
              Text(
                '${asis.evento.fecha.split('-').reversed.join('/')} · ${asis.evento.horaInicio} – ${asis.evento.horaFin}${asis.evento.paraQuien.isNotEmpty ? ' · ${asis.evento.paraQuien}' : ''}',
                style: const TextStyle(fontSize: 12.2, color: HC.t2),
              ),
              const SizedBox(height: 10),
              if (!asis.puedePasarLista)
                const Padding(padding: EdgeInsets.only(bottom: 10), child: Text('Solo puedes pasar lista de eventos que ya llegaron.', style: TextStyle(fontSize: 12.5, color: DashColors.warningText))),
              if (_error.isNotEmpty) HorarioStatusBanner(loading: false, error: _error, onRetry: _cargar),
              _buildResumen(asis),
              const SizedBox(height: 10),
              Flexible(
                child: asis.deportistas.isEmpty
                    ? const Center(child: Text('Este evento no tiene deportistas todavía.', style: TextStyle(color: HC.t3, fontSize: 13)))
                    : ListView.separated(
                        shrinkWrap: true,
                        itemCount: asis.deportistas.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 8),
                        itemBuilder: (_, i) => _buildRow(asis.deportistas[i], asis.puedePasarLista),
                      ),
              ),
              const SizedBox(height: 14),
              Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                EquipoSecButton(label: 'Cerrar', mini: true, enabled: !_guardando, onTap: _cerrar),
                const SizedBox(width: 8),
                EquipoPrimButton(
                  label: _guardando ? 'Guardando…' : (cambios.isNotEmpty ? 'Guardar (${cambios.length})' : 'Guardar'),
                  mini: true,
                  enabled: !_guardando && cambios.isNotEmpty,
                  onTap: _guardar,
                ),
              ]),
            ],
          ]),
        ),
      ),
    );
  }

  Widget _buildResumen(CoachAttendanceResponse asis) {
    int countOf(String? e) => asis.deportistas.where((d) => _estados[d.id] == e).length;
    return Wrap(spacing: 6, runSpacing: 6, crossAxisAlignment: WrapCrossAlignment.center, children: [
      for (final o in kAsistenciaOpciones)
        EquipoChip(
          text: '${o.$2} · ${countOf(o.$1)}',
          tone: switch (o.$1) { 'presente' => EquipoChipTone.verde, 'tarde' => EquipoChipTone.naranja, 'justificado' => EquipoChipTone.azul, _ => EquipoChipTone.gris },
        ),
      EquipoChip(text: 'Sin marcar · ${countOf(null)}'),
      if (asis.puedePasarLista && asis.deportistas.isNotEmpty)
        EquipoSecButton(
          label: 'Marcar a todos presentes',
          mini: true,
          onTap: () => setState(() {
            for (final d in asis.deportistas) {
              if (d.activo) _estados[d.id] = 'presente';
            }
          }),
        ),
    ]);
  }

  Widget _buildRow(CoachAttendanceAthlete d, bool puede) {
    final est = _estados[d.id];
    final ctrl = _obsCtrls[d.id]!;
    final notaOpen = _notasAbiertas.contains(d.id) || ctrl.text.isNotEmpty;
    final sub = d.activo
        ? [d.posicion, if (d.numeroCamiseta != null) 'N.º ${d.numeroCamiseta}'].whereType<String>().where((s) => s.isNotEmpty).join(' · ')
        : 'Ya no está en este evento';

    return Opacity(
      opacity: d.activo ? 1.0 : 0.7,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
        decoration: BoxDecoration(color: HC.card3, borderRadius: BorderRadius.circular(12), border: Border.all(color: HC.border)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Wrap(alignment: WrapAlignment.spaceBetween, crossAxisAlignment: WrapCrossAlignment.center, spacing: 10, runSpacing: 8, children: [
            Row(mainAxisSize: MainAxisSize.min, children: [
              EquipoAvatar(fotoUrl: d.fotoUrl, iniciales: inicialesDeNombre(d.nombreCompleto), size: 32),
              const SizedBox(width: 10),
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(d.nombreCompleto, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: HC.t1)),
                if (sub.isNotEmpty) Text(sub, style: const TextStyle(fontSize: 10.5, color: HC.t3)),
              ]),
            ]),
            Wrap(spacing: 4, runSpacing: 4, children: [
              for (final o in kAsistenciaOpciones)
                _stateBtn(o.$1, o.$2, est == o.$1, puede ? () => setState(() => _estados[d.id] = est == o.$1 ? null : o.$1) : null),
              InkWell(
                onTap: () => setState(() => _notasAbiertas.contains(d.id) ? _notasAbiertas.remove(d.id) : _notasAbiertas.add(d.id)),
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(8), border: Border.all(color: notaOpen ? HC.purple2 : HC.border2)),
                  child: Icon(Icons.chat_bubble_outline_rounded, size: 13, color: notaOpen ? HC.purple2 : HC.t2),
                ),
              ),
            ]),
          ]),
          if (notaOpen) ...[
            const SizedBox(height: 8),
            TextField(
              controller: ctrl,
              maxLines: 2,
              maxLength: 1000,
              onChanged: (_) => setState(() {}),
              style: const TextStyle(fontSize: 12.5, color: HC.t1),
              decoration: InputDecoration(
                counterText: '',
                hintText: 'Observación sobre este deportista en este evento…',
                hintStyle: const TextStyle(fontSize: 12, color: HC.t3),
                filled: true,
                fillColor: HC.card,
                isDense: true,
                contentPadding: const EdgeInsets.all(10),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: HC.border2)),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: HC.blue)),
              ),
            ),
            const SizedBox(height: 4),
            InkWell(
              onTap: () => setState(() => _visibles[d.id] = !(_visibles[d.id] == true)),
              child: Row(children: [
                SizedBox(width: 20, height: 20, child: Checkbox(value: _visibles[d.id] == true, onChanged: (v) => setState(() => _visibles[d.id] = v == true))),
                const SizedBox(width: 8),
                Expanded(child: Text('Visible para el deportista ${_visibles[d.id] == true ? '(le llegará un aviso)' : '(solo tú la ves)'}', style: const TextStyle(fontSize: 11.5, color: HC.t2))),
              ]),
            ),
          ],
        ]),
      ),
    );
  }

  Widget _stateBtn(String key, String label, bool on, VoidCallback? onTap) {
    final c = switch (key) { 'presente' => HC.green, 'tarde' => HC.amber, 'ausente' => HC.red, _ => HC.blue };
    return Opacity(
      opacity: onTap != null ? 1.0 : 0.4,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
          decoration: BoxDecoration(color: on ? c.withValues(alpha: 0.2) : Colors.transparent, borderRadius: BorderRadius.circular(8), border: Border.all(color: on ? c : HC.border2)),
          child: Text(label, style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: on ? c : HC.t2)),
        ),
      ),
    );
  }
}
