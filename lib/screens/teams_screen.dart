import 'package:flutter/material.dart';
import '../models/my_teams_data.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';
import '../theme/dash_colors.dart';
import '../widgets/usuario/drawer/menu_button.dart';
import '../widgets/usuario/entrenador/coach_directory_section.dart';
import '../widgets/usuario/entrenador/coach_status_widgets.dart';
import '../widgets/usuario/equipos/team_card.dart';
import '../widgets/usuario/equipos/team_invitations_section.dart';
import '../widgets/usuario/equipos/teams_header_and_states.dart';

/// Pantalla "Mis equipos" (`/usuario/equipos`) replicando
/// `VolleyScan_Next/src/app/usuario/equipos/page.jsx` y `equipos.module.css`.
class TeamsScreen extends StatefulWidget {
  const TeamsScreen({super.key});

  @override
  State<TeamsScreen> createState() => _TeamsScreenState();
}

enum _ScreenState { loading, error, ready }

class _TeamsScreenState extends State<TeamsScreen> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  _ScreenState _estado = _ScreenState.loading;
  String _error = '';
  String _aviso = '';
  List<MyTeam> _equipos = const <MyTeam>[];
  List<TeamInvitation> _recibidas = const <TeamInvitation>[];
  bool _ocupado = false;

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  Future<void> _cargarDatos({bool silent = false}) async {
    if (!silent && mounted) {
      setState(() {
        _estado = _ScreenState.loading;
        _error = '';
      });
    }

    try {
      final equiposFuture = ApiService().misEquipos();
      final invitacionesFuture = ApiService()
          .misInvitaciones()
          .catchError((_) => const <TeamInvitation>[]);

      final results = await Future.wait<dynamic>([
        equiposFuture,
        invitacionesFuture,
      ]);
      if (!mounted) return;
      setState(() {
        _equipos = results[0] as List<MyTeam>;
        _recibidas = results[1] as List<TeamInvitation>;
        _error = '';
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

  Future<void> _responderInvitacion(
    TeamInvitation inv,
    String accion,
  ) async {
    if (_ocupado) return;
    final esAceptar = accion == 'aceptar';
    final confirmed = await showCoachConfirmModal(
      context,
      title: esAceptar ? '¿Aceptar invitación?' : '¿Rechazar invitación?',
      message: esAceptar
          ? '¿Quieres unirte al equipo «${inv.equipo.nombre}»?'
          : '¿Seguro que deseas rechazar la invitación a «${inv.equipo.nombre}»?',
      confirmLabel: esAceptar ? 'Aceptar' : 'Rechazar',
      isDanger: !esAceptar,
    );
    if (!confirmed || !mounted) return;

    setState(() {
      _ocupado = true;
      _error = '';
      _aviso = '';
    });

    try {
      await ApiService().responderInvitacion(inv.id, accion);
      final msg = esAceptar
          ? 'Ya eres parte de «${inv.equipo.nombre}».'
          : 'Invitación rechazada.';
      if (!mounted) return;
      setState(() => _aviso = msg);
      showAppToast(context, msg, type: esAceptar ? 'success' : 'info');
      try {
        await ApiService().contadorAvisos(todas: true);
      } catch (_) {}
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _error = e.message);
      showAppToast(context, e.message, type: 'error');
    } catch (_) {
      if (!mounted) return;
      const msg = 'Ocurrió un error inesperado.';
      setState(() => _error = msg);
      showAppToast(context, msg, type: 'error');
    } finally {
      if (mounted) {
        setState(() => _ocupado = false);
        await _cargarDatos(silent: true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: DashColors.bg,
      drawer: const UserDrawer(selectedId: 'equipos'),
      body: DecoratedBox(
        decoration: const BoxDecoration(gradient: AppGradients.userPanelBg),
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              TeamsTopBar(
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
                        constraints: const BoxConstraints(maxWidth: 1100),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const TeamsPageHeader(),
                            if (_error.isNotEmpty)
                              CoachAlertBanner(message: _error),
                            if (_aviso.isNotEmpty)
                              TeamsSuccessBanner(message: _aviso),
                            TeamInvitationsSection(
                              invitations: _recibidas,
                              busy: _ocupado,
                              onRespond: _responderInvitacion,
                            ),
                            if (_estado == _ScreenState.loading)
                              const Padding(
                                padding: EdgeInsets.symmetric(vertical: 20),
                                child: Text(
                                  'Cargando tus equipos…',
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 14,
                                    color: DashColors.muted,
                                  ),
                                ),
                              )
                            else if (_estado == _ScreenState.error)
                              TeamsErrorRetry(onRetry: _cargarDatos)
                            else if (_equipos.isEmpty)
                              const TeamsEmptyState()
                            else
                              _TeamsGridSection(teams: _equipos),
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
}

class _TeamsGridSection extends StatelessWidget {
  final List<MyTeam> teams;

  const _TeamsGridSection({required this.teams});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Mis equipos',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: DashColors.text,
          ),
        ),
        const SizedBox(height: 12),
        LayoutBuilder(
          builder: (context, constraints) {
            final twoCols = constraints.maxWidth >= 680;
            if (!twoCols) {
              return Column(
                children: teams
                    .map(
                      (team) => Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: TeamCard(team: team),
                      ),
                    )
                    .toList(),
              );
            }

            final itemWidth = (constraints.maxWidth - 16) / 2;
            return Wrap(
              spacing: 16,
              runSpacing: 16,
              children: teams
                  .map(
                    (team) => SizedBox(
                      width: itemWidth,
                      child: TeamCard(team: team),
                    ),
                  )
                  .toList(),
            );
          },
        ),
      ],
    );
  }
}
