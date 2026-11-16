import 'package:flutter/material.dart';
import '../models/coach_link_data.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';
import '../theme/dash_colors.dart';
import '../widgets/usuario/entrenador/coach_directory_section.dart';
import '../widgets/usuario/entrenador/coach_status_widgets.dart';
import '../widgets/usuario/drawer/menu_button.dart';

/// Pantalla "Mi entrenador" (`/usuario/entrenador`) replicando
/// `VolleyScan_Next/src/app/usuario/entrenador/page.jsx` y `entrenador.module.css`.
class CoachScreen extends StatefulWidget {
  const CoachScreen({super.key});

  @override
  State<CoachScreen> createState() => _CoachScreenState();
}

enum _ScreenState { loading, error, ready }

class _CoachScreenState extends State<CoachScreen> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _searchCtrl = TextEditingController();

  _ScreenState _estado = _ScreenState.loading;
  String _error = '';
  MyCoachResponse _mio = const MyCoachResponse();
  List<CoachPerson> _entrenadores = const <CoachPerson>[];
  String _query = '';
  bool _ocupado = false;

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _cargarDatos({bool silent = false}) async {
    if (!silent && mounted) {
      setState(() {
        _estado = _ScreenState.loading;
        _error = '';
      });
    }
    try {
      final results = await Future.wait<dynamic>([
        ApiService().miEntrenador(),
        ApiService().listarEntrenadores(),
      ]);
      if (!mounted) return;
      setState(() {
        _mio = results[0] as MyCoachResponse;
        _entrenadores = results[1] as List<CoachPerson>;
        _estado = _ScreenState.ready;
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.message;
        if (!silent) _estado = _ScreenState.error;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _error = 'Ocurrió un error inesperado.';
        if (!silent) _estado = _ScreenState.error;
      });
    }
  }

  List<CoachPerson> get _visibles {
    final norm = normalizeCoachSearch(_query);
    if (norm.isEmpty) return _entrenadores;
    return _entrenadores
        .where((p) => normalizeCoachSearch(p.fullName).contains(norm))
        .toList();
  }

  Future<void> _elegirEntrenador(CoachPerson coach) async {
    if (_ocupado) return;
    final confirmed = await showCoachConfirmModal(
      context,
      title: '¿Elegir como entrenador?',
      message:
          '¿Enviar solicitud a ${coach.fullName}? Cuando la acepte, podrá ver tu perfil y tu práctica con la IA.',
      confirmLabel: 'Sí',
    );
    if (!confirmed || !mounted) return;

    setState(() {
      _ocupado = true;
      _error = '';
    });
    try {
      await ApiService().solicitarEntrenador(coach.id);
      if (mounted) {
        showAppToast(context, '✓ Solicitud enviada a ${coach.fullName}.');
      }
    } on ApiException catch (e) {
      if (mounted) {
        setState(() => _error = e.message);
        showAppToast(context, e.message, type: 'error');
      }
    } catch (_) {
      if (mounted) {
        const msg = 'Ocurrió un error inesperado.';
        setState(() => _error = msg);
        showAppToast(context, msg, type: 'error');
      }
    } finally {
      if (mounted) {
        setState(() => _ocupado = false);
        await _cargarDatos(silent: true);
      }
    }
  }

  Future<void> _cancelarOSalir(CoachBond vinculo) async {
    if (_ocupado) return;
    final accepted = vinculo.isAccepted;
    final confirmed = await showCoachConfirmModal(
      context,
      title: accepted ? '¿Dejar a tu entrenador?' : '¿Cancelar la solicitud?',
      message: accepted
          ? 'Dejarás de entrenar con ${vinculo.entrenador.fullName} y podrás elegir a otro entrenador.'
          : 'Se cancelará la solicitud enviada a ${vinculo.entrenador.fullName}.',
      confirmLabel: 'Sí',
      isDanger: true,
    );
    if (!confirmed || !mounted) return;

    setState(() {
      _ocupado = true;
      _error = '';
    });
    try {
      await ApiService().cancelarOSalirEntrenador();
      if (mounted) {
        showAppToast(
          context,
          accepted ? 'Vínculo finalizado.' : 'Solicitud cancelada.',
          type: 'info',
        );
      }
    } on ApiException catch (e) {
      if (mounted) {
        setState(() => _error = e.message);
        showAppToast(context, e.message, type: 'error');
      }
    } catch (_) {
      if (mounted) {
        const msg = 'Ocurrió un error inesperado.';
        setState(() => _error = msg);
        showAppToast(context, msg, type: 'error');
      }
    } finally {
      if (mounted) {
        setState(() => _ocupado = false);
        await _cargarDatos(silent: true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final v = _mio.vinculo;
    final rechazo = _mio.ultimoRechazo;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: DashColors.bg,
      drawer: const UserDrawer(selectedId: 'entrenador'),
      body: DecoratedBox(
        decoration: const BoxDecoration(gradient: AppGradients.userPanelBg),
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              CoachScreenHeader(
                onOpenDrawer: () => _scaffoldKey.currentState?.openDrawer(),
              ),
              Expanded(
                child: RefreshIndicator(
                  color: DashColors.blueLight,
                  backgroundColor: DashColors.card,
                  onRefresh: () => _cargarDatos(silent: true),
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(16, 20, 16, 48),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 1040),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _pageHeader(),
                            if (_error.isNotEmpty)
                              CoachAlertBanner(message: _error),
                            if (_estado == _ScreenState.loading)
                              const Padding(
                                padding: EdgeInsets.symmetric(vertical: 20),
                                child: Text(
                                  'Cargando…',
                                  style: TextStyle(fontFamily: 'Poppins', fontSize: 14, color: DashColors.muted),
                                ),
                              )
                            else if (_estado == _ScreenState.error)
                              OutlinedButton(
                                onPressed: _cargarDatos,
                                style: OutlinedButton.styleFrom(
                                  backgroundColor: DashColors.cardDark,
                                  foregroundColor: DashColors.textSecondary,
                                  side: const BorderSide(color: DashColors.coachBorder),
                                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 11),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadii.btn)),
                                ),
                                child: const Text(
                                  'Reintentar',
                                  style: TextStyle(fontFamily: 'Poppins', fontSize: 13.5, fontWeight: FontWeight.w600),
                                ),
                              )
                            else if (v != null)
                              CoachBondStatusCard(
                                vinculo: v,
                                busy: _ocupado,
                                onActionPressed: () => _cancelarOSalir(v),
                              )
                            else ...[
                              if (rechazo != null)
                                CoachAlertBanner(
                                  message:
                                      '${rechazo.entrenador.fullName} no aceptó tu solicitud. Puedes elegir a otro entrenador.',
                                ),
                              CoachDirectorySection(
                                allCoaches: _entrenadores,
                                visibleCoaches: _visibles,
                                searchController: _searchCtrl,
                                onSearchChanged: (val) => setState(() => _query = val),
                                busy: _ocupado,
                                onSelectCoach: _elegirEntrenador,
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _pageHeader() {
    return const Padding(
      padding: EdgeInsets.only(bottom: 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'PERFIL DE ATLETA',
            style: TextStyle(fontFamily: 'Poppins', fontSize: 11.5, fontWeight: FontWeight.w700, letterSpacing: 1.5, color: DashColors.accent2),
          ),
          SizedBox(height: 4),
          Text(
            'Mi entrenador',
            style: TextStyle(fontFamily: 'Poppins', fontSize: 28, fontWeight: FontWeight.w800, letterSpacing: -0.5, color: DashColors.text),
          ),
          SizedBox(height: 4),
          Text(
            'Elige a tu entrenador. Cuando acepte tu solicitud, podrá ver tu perfil y tu práctica con la IA.',
            style: TextStyle(fontFamily: 'Poppins', fontSize: 14, height: 1.45, color: DashColors.muted),
          ),
        ],
      ),
    );
  }
}
