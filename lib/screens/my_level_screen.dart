import 'package:flutter/material.dart';
import '../models/my_level_data.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';
import '../theme/dash_colors.dart';
import '../widgets/usuario/drawer/menu_button.dart';
import '../widgets/usuario/entrenador/coach_status_widgets.dart';
import '../widgets/usuario/mi_nivel/level_header_and_hero.dart';
import '../widgets/usuario/mi_nivel/level_progress_card.dart';
import '../widgets/usuario/mi_nivel/level_reviews_and_history.dart';

/// Pantalla "Mi nivel" (`/usuario/mi-nivel`) replicando
/// `VolleyScan_Next/src/app/usuario/mi-nivel/page.jsx` y `mi-nivel.module.css`.
class MyLevelScreen extends StatefulWidget {
  const MyLevelScreen({super.key});

  @override
  State<MyLevelScreen> createState() => _MyLevelScreenState();
}

enum _ScreenState { loading, error, ready }

class _MyLevelScreenState extends State<MyLevelScreen> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  _ScreenState _estado = _ScreenState.loading;
  String _error = '';
  MyLevelResponse _datos = const MyLevelResponse();

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
      final res = await ApiService().miNivel();
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
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: DashColors.bg,
      drawer: const UserDrawer(selectedId: 'mi_nivel'),
      body: DecoratedBox(
        decoration: const BoxDecoration(gradient: AppGradients.userPanelBg),
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              LevelTopBar(
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
                            const LevelPageHeader(),
                            if (_error.isNotEmpty)
                              CoachAlertBanner(message: _error),
                            if (_estado == _ScreenState.loading)
                              const Padding(
                                padding: EdgeInsets.symmetric(vertical: 20),
                                child: Text(
                                  'Cargando tu nivel…',
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 14,
                                    color: DashColors.muted,
                                  ),
                                ),
                              )
                            else if (_estado == _ScreenState.error)
                              LevelErrorRetry(onRetry: _cargar)
                            else ...[
                              LevelHeroCard(data: _datos),
                              LevelProgressCard(avance: _datos.avance),
                              _BottomCardsLayout(data: _datos),
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

class _BottomCardsLayout extends StatelessWidget {
  final MyLevelResponse data;

  const _BottomCardsLayout({required this.data});

  @override
  Widget build(BuildContext context) {
    final reviewsCard = LevelReviewsCard(reviews: data.revisiones);
    final historyCard = LevelHistoryCard(history: data.historial);

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 740) {
          return Column(
            children: [
              reviewsCard,
              const SizedBox(height: 16),
              historyCard,
            ],
          );
        }
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: reviewsCard),
            const SizedBox(width: 16),
            Expanded(child: historyCard),
          ],
        );
      },
    );
  }
}
