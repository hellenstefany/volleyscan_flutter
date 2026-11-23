import 'package:flutter/material.dart';

import '../../../models/equipo.dart';
import '../../../services/api_service.dart';
import '../../../theme/app_theme.dart';
import '../../../theme/dash_colors.dart';
import '../gestion/gestion_athlete_detail.dart';
import 'equipo_invite_section.dart';
import 'equipo_members_sections.dart';
import 'equipos_common_widgets.dart';
import 'equipos_list_widgets.dart';

class EquipoDetailView extends StatefulWidget {
  final int equipoId;
  final VoidCallback onBack;

  const EquipoDetailView({super.key, required this.equipoId, required this.onBack});

  @override
  State<EquipoDetailView> createState() => _EquipoDetailViewState();
}

class _EquipoDetailViewState extends State<EquipoDetailView> {
  String _estado = 'cargando'; // 'cargando' | 'noexiste' | 'error' | 'listo'
  EquipoDetalle? _equipo;
  String _error = '', _aviso = '', _tipoInv = 'deportista';
  final _emailInvCtrl = TextEditingController();
  EquipoInvitacionCreada? _resultadoInv;

  bool _editando = false, _ocupado = false;
  final _nombreCtrl = TextEditingController();
  final _catCtrl = TextEditingController();
  final _tempCtrl = TextEditingController();
  int? _busyAtletaId, _fichaAtletaId;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  @override
  void dispose() {
    _emailInvCtrl.dispose();
    _nombreCtrl.dispose();
    _catCtrl.dispose();
    _tempCtrl.dispose();
    super.dispose();
  }

  Future<void> _cargar({bool silent = false}) async {
    if (!silent && mounted) setState(() => _estado = 'cargando');
    try {
      final det = await ApiService().detalleEquipoEntrenador(widget.equipoId);
      if (!mounted) return;
      setState(() {
        _equipo = det;
        _estado = 'listo';
      });
    } on ApiException catch (e) {
      if (!mounted || e.isUnauthorized) return;
      setState(() {
        _error = e.message;
        _estado = e.statusCode == 404 ? 'noexiste' : 'error';
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _error = 'No se pudo cargar el equipo.';
        _estado = 'error';
      });
    }
  }

  void _fallo(String msg) {
    if (!mounted) return;
    setState(() {
      _aviso = '';
      _error = msg;
    });
    showAppToast(context, msg, type: 'error');
  }

  Future<void> _tras([String? msg]) async {
    if (!mounted) return;
    setState(() {
      _error = '';
      if (msg != null && msg.isNotEmpty) _aviso = msg;
    });
    if (msg != null && msg.isNotEmpty) showAppToast(context, msg);
    await _cargar(silent: true);
  }

  Future<void> _runBusy(Future<void> Function() action, [String fallback = 'Ocurrió un error inesperado.']) async {
    if (_ocupado) return;
    setState(() {
      _ocupado = true;
      _error = '';
      _aviso = '';
    });
    try {
      await action();
    } on ApiException catch (e) {
      _fallo(e.message);
    } catch (_) {
      _fallo(fallback);
    } finally {
      if (mounted) setState(() => _ocupado = false);
    }
  }

  Future<void> _enviarInvitacion() async {
    final email = _emailInvCtrl.text.trim();
    if (email.isEmpty) return;
    await _runBusy(() async {
      final res = await ApiService().invitarMiembroEquipo(widget.equipoId, tipo: _tipoInv, email: email);
      if (!mounted) return;
      _emailInvCtrl.clear();
      setState(() => _resultadoInv = res);
      showAppToast(
        context,
        res.emailEnviado ? 'Invitación enviada a ${res.email}' : 'Invitación creada. Copia el enlace para compartirlo.',
        type: res.emailEnviado ? 'success' : 'info',
      );
      await _cargar(silent: true);
    }, 'No se pudo enviar la invitación.');
  }

  Future<void> _reenviar(EquipoInvitacionPendiente inv) => _runBusy(() async {
        final res = await ApiService().reenviarInvitacionEquipo(widget.equipoId, inv.id);
        if (!mounted) return;
        setState(() => _resultadoInv = res);
        showAppToast(context, 'Invitación reenviada a ${res.email}');
        await _cargar(silent: true);
      }, 'No se pudo reenviar la invitación.');

  Future<void> _revocar(EquipoInvitacionPendiente inv) async {
    if (_ocupado) return;
    final ok = await showEquipoConfirmDialog(context, title: 'Cancelar invitación', message: '¿Cancelar la invitación a ${inv.email}?', confirmLabel: 'Cancelar invitación');
    if (!ok || !mounted) return;
    await _runBusy(() async {
      await ApiService().revocarInvitacionEquipo(widget.equipoId, inv.id);
      await _tras('Invitación cancelada.');
    }, 'No se pudo cancelar la invitación.');
  }

  Future<void> _guardarDeportista(EquipoDeportista d, String pos, int? num) async {
    if (_busyAtletaId != null) return;
    setState(() => _busyAtletaId = d.id);
    try {
      await ApiService().editarDeportistaEquipo(widget.equipoId, d.id, posicion: pos, numeroCamiseta: num);
      await _tras('Datos de ${d.nombre} actualizados.');
    } on ApiException catch (e) {
      _fallo(e.message);
    } catch (_) {
      _fallo('No se pudo actualizar al deportista.');
    } finally {
      if (mounted) setState(() => _busyAtletaId = null);
    }
  }

  Future<void> _quitarDeportista(EquipoDeportista d) async {
    if (_busyAtletaId != null || _ocupado) return;
    final ok = await showEquipoConfirmDialog(context, title: 'Sacar deportista', message: '¿Sacar a ${d.nombreCompleto} del equipo?', confirmLabel: 'Sacar');
    if (!ok || !mounted) return;
    setState(() => _busyAtletaId = d.id);
    try {
      await ApiService().quitarDeportistaEquipo(widget.equipoId, d.id);
      await _tras('${d.nombre} salió del equipo.');
    } on ApiException catch (e) {
      _fallo(e.message);
    } catch (_) {
      _fallo('No se pudo sacar al deportista.');
    } finally {
      if (mounted) setState(() => _busyAtletaId = null);
    }
  }

  Future<void> _quitarCoach(EquipoEntrenador c) async {
    if (_ocupado) return;
    final salir = c.soyYo;
    final ok = await showEquipoConfirmDialog(
      context,
      title: salir ? 'Salir del equipo' : 'Quitar entrenador',
      message: salir ? '¿Salir de este equipo? Dejarás de ver a sus deportistas.' : '¿Quitar a ${c.nombre} del equipo?',
      confirmLabel: salir ? 'Salir' : 'Quitar',
    );
    if (!ok || !mounted) return;
    await _runBusy(() async {
      await ApiService().quitarEntrenadorEquipo(widget.equipoId, c.id);
      if (!mounted) return;
      if (salir) {
        showAppToast(context, 'Saliste del equipo.');
        widget.onBack();
        return;
      }
      await _tras('${c.nombre} ya no es entrenador del equipo.');
    }, 'No se pudo quitar al entrenador.');
  }

  Future<void> _guardarEdicion() => _runBusy(() async {
        await ApiService().editarEquipoEntrenador(widget.equipoId, nombre: _nombreCtrl.text, categoria: _catCtrl.text, temporada: _tempCtrl.text);
        if (mounted) setState(() => _editando = false);
        await _tras('Equipo actualizado.');
      }, 'No se pudo actualizar el equipo.');

  Future<void> _archivar() async {
    final eq = _equipo;
    if (eq == null || _ocupado) return;
    final ok = await showEquipoConfirmDialog(
      context,
      title: 'Archivar equipo',
      message: '¿Archivar «${eq.nombre}»? Sus deportistas saldrán del equipo y se cancelarán las invitaciones pendientes.',
      confirmLabel: 'Archivar equipo',
    );
    if (!ok || !mounted) return;
    await _runBusy(() async {
      await ApiService().archivarEquipoEntrenador(widget.equipoId);
      if (!mounted) return;
      showAppToast(context, 'Equipo «${eq.nombre}» archivado.');
      widget.onBack();
    }, 'No se pudo archivar el equipo.');
  }

  @override
  Widget build(BuildContext context) {
    if (_fichaAtletaId != null) {
      return DeportistaFichaView(atletaId: _fichaAtletaId!, onBack: () => setState(() => _fichaAtletaId = null));
    }
    if (_estado == 'cargando') {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 28),
        child: Text('Cargando equipo…', style: TextStyle(fontSize: 14, color: DashColors.textMuted)),
      );
    }
    if (_estado != 'listo' || _equipo == null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _volverBtn(),
          EquipoAlertBanner(
            text: _estado == 'noexiste' ? 'Este equipo no existe o no formas parte de él.' : _error,
            onRetry: _estado == 'error' ? _cargar : null,
          ),
        ],
      );
    }
    final eq = _equipo!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _volverBtn(),
        _buildHeader(eq),
        if (_error.isNotEmpty) EquipoAlertBanner(text: _error, isError: true),
        if (_aviso.isNotEmpty) EquipoAlertBanner(text: _aviso, isError: false),
        if (_editando)
          EquipoFormPanel(
            nombreCtrl: _nombreCtrl,
            categoriaCtrl: _catCtrl,
            temporadaCtrl: _tempCtrl,
            submitLabel: 'Guardar',
            loadingLabel: 'Guardando…',
            busy: _ocupado,
            isEdit: true,
            onSubmit: _guardarEdicion,
          ),
        EquipoInvitePanel(
          tipo: _tipoInv,
          onTipoChanged: (t) => setState(() => _tipoInv = t),
          emailCtrl: _emailInvCtrl,
          busy: _ocupado,
          onSubmit: _enviarInvitacion,
          resultado: _resultadoInv,
        ),
        EquipoDeportistasSection(
          deportistas: eq.deportistas,
          busyAtletaId: _busyAtletaId,
          onGuardarDeportista: _guardarDeportista,
          onAbrirFicha: (d) => setState(() => _fichaAtletaId = d.id),
          onQuitarDeportista: _quitarDeportista,
        ),
        EquipoEntrenadoresAndInvitaciones(
          equipo: eq,
          busy: _ocupado,
          onQuitarCoach: _quitarCoach,
          onReenviar: _reenviar,
          onRevocar: _revocar,
        ),
      ],
    );
  }

  Widget _volverBtn() => Align(
        alignment: Alignment.centerLeft,
        child: InkWell(
          onTap: widget.onBack,
          borderRadius: BorderRadius.circular(8),
          child: const Padding(
            padding: EdgeInsets.symmetric(vertical: 6),
            child: Text('← Equipos', style: TextStyle(fontSize: 13.8, color: DashColors.textMuted)),
          ),
        ),
      );

  Widget _buildHeader(EquipoDetalle eq) {
    return Padding(
      padding: const EdgeInsets.only(top: 4, bottom: 24),
      child: Wrap(
        alignment: WrapAlignment.spaceBetween,
        crossAxisAlignment: WrapCrossAlignment.end,
        spacing: 16,
        runSpacing: 14,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                eq.esPropietario ? 'ERES EL PROPIETARIO' : 'ERES CO-ENTRENADOR',
                style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, letterSpacing: 1.5, color: DashColors.accent2),
              ),
              const SizedBox(height: 4),
              Text(eq.nombre, style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w800, color: DashColors.text1)),
              const SizedBox(height: 10),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  if (eq.categoria != null) EquipoChip(text: eq.categoria!, tone: EquipoChipTone.azul),
                  if (eq.temporada != null) EquipoChip(text: 'Temporada ${eq.temporada}'),
                  EquipoChip(text: '${eq.deportistas.length} deportistas'),
                  EquipoChip(text: '${eq.entrenadores.length} entrenadores'),
                ],
              ),
            ],
          ),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              EquipoSecButton(
                label: _editando ? 'Cancelar' : 'Editar',
                enabled: !_ocupado,
                onTap: () => setState(() {
                  _nombreCtrl.text = eq.nombre;
                  _catCtrl.text = eq.categoria ?? '';
                  _tempCtrl.text = eq.temporada ?? '';
                  _editando = !_editando;
                }),
              ),
              if (eq.esPropietario)
                EquipoDangerButton(label: 'Archivar equipo', enabled: !_ocupado, onTap: _archivar),
            ],
          ),
        ],
      ),
    );
  }
}
