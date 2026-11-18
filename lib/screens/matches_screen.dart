import 'package:flutter/material.dart';
import '../models/my_matches_data.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';
import '../theme/dash_colors.dart';
import '../widgets/usuario/drawer/menu_button.dart';
import '../widgets/usuario/entrenador/coach_status_widgets.dart';
import '../widgets/usuario/partidos/match_card.dart';
import '../widgets/usuario/partidos/matches_accumulated_card.dart';
import '../widgets/usuario/partidos/matches_header_and_states.dart';

/// Pantalla "Mis partidos" (`/usuario/partidos`) replicando
/// `VolleyScan_Next/src/app/usuario/partidos/page.jsx` y `partidos.module.css`.
class MatchesScreen extends StatefulWidget {
  const MatchesScreen({super.key});

  @override
  State<MatchesScreen> createState() => _MatchesScreenState();
}

enum _ScreenState { loading, error, ready }

class _MatchesScreenState extends State<MatchesScreen> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  _ScreenState _estado = _ScreenState.loading;
  String _error = '';
  MyMatchesResponse _datos = const MyMatchesResponse();

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar({bool silent = false}) async {
    if (!silent && mounted) {
      setState(() {
        _estado = _ScreenState.loading;
        _error = '';
      });
    }

    try {
      final res = await ApiService().misPartidos();
      if (!mounted) return;
      setState(() {
        _datos = res;
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

  @override
  Widget build(BuildContext context) {
    final acumulado = _datos.acumulado;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: DashColors.bg,
      drawer: const UserDrawer(selectedId: 'partidos'),
      body: DecoratedBox(
        decoration: const BoxDecoration(gradient: AppGradients.userPanelBg),
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              MatchesTopBar(
                onOpenDrawer: () => _scaffoldKey.currentState?.openDrawer(),
              ),
              Expanded(
                child: RefreshIndicator(
                  color: DashColors.blueLight,
                  backgroundColor: DashColors.card,
                  onRefresh: () => _cargar(silent: true),
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(16, 20, 16, 48),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 1000),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const MatchesPageHeader(),
                            if (_error.isNotEmpty)
                              CoachAlertBanner(message: _error),
                            if (_estado == _ScreenState.loading)
                              const Padding(
                                padding: EdgeInsets.symmetric(vertical: 20),
                                child: Text(
                                  'Cargando tus partidos…',
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 14,
                                    color: DashColors.muted,
                                  ),
                                ),
                              )
                            else if (_estado == _ScreenState.error)
                              MatchesErrorRetry(onRetry: _cargar)
                            else if (acumulado == null)
                              const MatchesEmptyState()
                            else ...[
                              MatchesAccumulatedCard(accumulated: acumulado),
                              ..._datos.partidos.map(
                                (p) => MatchCard(match: p),
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
}
