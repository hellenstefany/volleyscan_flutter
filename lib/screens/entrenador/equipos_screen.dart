import 'package:flutter/material.dart';

import '../../models/equipo.dart';
import '../../models/my_teams_data.dart';
import '../../services/api_service.dart';
import '../../theme/app_theme.dart';
import '../../theme/dash_colors.dart';
import '../../widgets/entrenador/equipos/equipo_detail_view.dart';
import '../../widgets/entrenador/equipos/equipos_common_widgets.dart';
import '../../widgets/entrenador/equipos/equipos_list_widgets.dart';

enum _EstadoLista { cargando, error, listo }

/// Pantalla "Equipos" del Panel de Entrenador (`/panel_entrenador/equipos` y `/panel_entrenador/equipos/[id]`).
class EquiposScreen extends StatefulWidget {
  const EquiposScreen({super.key});

  @override
  State<EquiposScreen> createState() => _EquiposScreenState();
}

class _EquiposScreenState extends State<EquiposScreen> {
  final _scrollCtrl = ScrollController();

  _EstadoLista _estado = _EstadoLista.cargando;
  String _error = '';
  String _aviso = '';
  List<Equipo> _equipos = const <Equipo>[];
  List<TeamInvitation> _recibidas = const <TeamInvitation>[];
  bool _abierto = false;
  bool _ocupado = false;

  int? _detalleEquipoId;
  double _savedScrollOffset = 0;

  final _nombreCtrl = TextEditingController();
  final _categoriaCtrl = TextEditingController();
  final _temporadaCtrl = TextEditingController(
    text: '${DateTime.now().year}',
  );

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  @override
  void dispose() {
    _scrollCtrl.dispose();
    _nombreCtrl.dispose();
    _categoriaCtrl.dispose();
    _temporadaCtrl.dispose();
    super.dispose();
  }

  Future<void> _cargar({bool silent = false}) async {
    if (!silent && mounted) {
      setState(() {
        _estado = _EstadoLista.cargando;
        _error = '';
      });
    }
    try {
      final equiposFuture = ApiService().listarEquiposEntrenador();
      final invFuture = ApiService()
          .misInvitaciones()
          .catchError((_) => const <TeamInvitation>[]);

      final equipos = await equiposFuture;
      final recibidas = await invFuture;
      if (!mounted) return;
      setState(() {
        _equipos = equipos;
        _recibidas = recibidas;
        _error = '';
        _estado = _EstadoLista.listo;
      });
    } on ApiException catch (e) {
      if (!mounted || e.isUnauthorized) return;
      final msg = e.message.isNotEmpty
          ? e.message
          : 'No se pudieron cargar los equipos.';
      setState(() {
        _error = msg;
        _estado = _EstadoLista.error;
      });
      if (silent) showAppToast(context, msg, type: 'error');
    } catch (_) {
      if (!mounted) return;
      const msg = 'No se pudieron cargar los equipos.';
      setState(() {
        _error = msg;
        _estado = _EstadoLista.error;
      });
      if (silent) showAppToast(context, msg, type: 'error');
    }
  }

  Future<void> _crear() async {
    if (_ocupado || _nombreCtrl.text.trim().length < 2) return;
    setState(() {
      _ocupado = true;
      _error = '';
      _aviso = '';
    });
    try {
      final nuevoId = await ApiService().crearEquipoEntrenador(
        nombre: _nombreCtrl.text,
        categoria: _categoriaCtrl.text,
        temporada: _temporadaCtrl.text,
      );
      if (!mounted) return;
      final nombreCreado = _nombreCtrl.text.trim();
      _nombreCtrl.clear();
      _categoriaCtrl.clear();
      _temporadaCtrl.text = '${DateTime.now().year}';
      setState(() {
        _ocupado = false;
        _abierto = false;
      });
      showAppToast(context, 'Equipo «$nombreCreado» creado.');
      if (nuevoId > 0) {
        _abrirEquipo(nuevoId);
      } else {
        await _cargar(silent: true);
      }
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _ocupado = false;
        _error = e.message;
      });
      showAppToast(context, e.message, type: 'error');
    } catch (_) {
      if (!mounted) return;
      const msg = 'No se pudo crear el equipo.';
      setState(() {
        _ocupado = false;
        _error = msg;
      });
      showAppToast(context, msg, type: 'error');
    }
  }

  Future<void> _responder(TeamInvitation inv, String accion) async {
    if (_ocupado) return;
    if (accion == 'rechazar') {
      final ok = await showEquipoConfirmDialog(
        context,
        title: 'Rechazar invitación',
        message:
            '¿Rechazar la invitación de ${inv.invitadoPor} para «${inv.equipo.nombre}»?',
        confirmLabel: 'Rechazar',
      );
      if (!ok || !mounted) return;
    }
    setState(() {
      _ocupado = true;
      _error = '';
      _aviso = '';
    });
    try {
      await ApiService().responderInvitacion(inv.id, accion);
      if (!mounted) return;
      final msg = accion == 'aceptar'
          ? 'Ahora eres entrenador de «${inv.equipo.nombre}».'
          : 'Invitación rechazada.';
      setState(() {
        _ocupado = false;
        _aviso = msg;
      });
      showAppToast(context, msg);
      await _cargar(silent: true);
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _ocupado = false;
        _error = e.message;
      });
      showAppToast(context, e.message, type: 'error');
      await _cargar(silent: true);
    } catch (_) {
      if (!mounted) return;
      const msg = 'No se pudo procesar la invitación.';
      setState(() {
        _ocupado = false;
        _error = msg;
      });
      showAppToast(context, msg, type: 'error');
      await _cargar(silent: true);
    }
  }

  void _abrirEquipo(int equipoId) {
    if (_scrollCtrl.hasClients) {
      _savedScrollOffset = _scrollCtrl.offset;
    }
    setState(() => _detalleEquipoId = equipoId);
  }

  Future<void> _volverDeDetalle() async {
    setState(() => _detalleEquipoId = null);
    await _cargar(silent: true);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollCtrl.hasClients) {
        final max = _scrollCtrl.position.maxScrollExtent;
        _scrollCtrl.jumpTo(_savedScrollOffset.clamp(0.0, max));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final narrow = MediaQuery.of(context).size.width < 900;

    return Material(
      color: DashColors.bg,
      child: RefreshIndicator(
        color: DashColors.blueLight,
        backgroundColor: DashColors.cardDark,
        onRefresh: () => _cargar(silent: true),
        child: SingleChildScrollView(
          controller: _detalleEquipoId == null ? _scrollCtrl : null,
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.fromLTRB(
            narrow ? 14 : 20,
            narrow ? 64 : 28,
            narrow ? 14 : 20,
            90,
          ),
          child: Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1240),
              child: _detalleEquipoId != null
                  ? EquipoDetailView(
                      key: ValueKey('equipo-det-$_detalleEquipoId'),
                      equipoId: _detalleEquipoId!,
                      onBack: _volverDeDetalle,
                    )
                  : _buildListado(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildListado() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        EquiposListHeader(
          formOpen: _abierto,
          onToggleForm: () => setState(() => _abierto = !_abierto),
        ),
        if (_error.isNotEmpty)
          EquipoAlertBanner(
            text: _error,
            isError: true,
            onRetry: _estado == _EstadoLista.error ? () => _cargar() : null,
          ),
        if (_aviso.isNotEmpty)
          EquipoAlertBanner(text: _aviso, isError: false),
        if (_abierto)
          EquipoFormPanel(
            nombreCtrl: _nombreCtrl,
            categoriaCtrl: _categoriaCtrl,
            temporadaCtrl: _temporadaCtrl,
            submitLabel: 'Crear equipo',
            loadingLabel: 'Creando…',
            busy: _ocupado,
            onSubmit: _crear,
          ),
        EquiposReceivedInvitations(
          invitaciones: _recibidas,
          busy: _ocupado,
          onResponder: _responder,
        ),
        if (_estado == _EstadoLista.cargando)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: Text(
              'Cargando equipos…',
              style: TextStyle(fontSize: 14, color: DashColors.textMuted),
            ),
          )
        else if (_estado == _EstadoLista.listo && _equipos.isEmpty)
          const EquiposEmptyState()
        else if (_equipos.isNotEmpty)
          EquiposGrid(
            equipos: _equipos,
            onOpenEquipo: (e) => _abrirEquipo(e.id),
          ),
      ],
    );
  }
}
