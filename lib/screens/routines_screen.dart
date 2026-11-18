import 'package:flutter/material.dart';
import '../models/routine_data.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';
import '../theme/dash_colors.dart';
import '../utils/bottom_nav_router.dart';
import '../widgets/usuario/drawer/menu_button.dart';
import '../widgets/usuario/rutinas/routine_exercises_panel.dart';
import '../widgets/usuario/rutinas/routine_hero_card.dart';
import '../widgets/usuario/rutinas/routine_summary_card.dart';
import '../widgets/usuario/rutinas/routines_header_and_picker.dart';
import '../widgets/usuario/shared/dashboard_bottom_nav.dart';

/// Pantalla "Mis rutinas" (`/usuario/rutinas`) replicando
/// `VolleyScan_Next/src/app/usuario/rutinas/page.jsx` y `rutinas.module.css`.
class RoutinesScreen extends StatefulWidget {
  const RoutinesScreen({super.key});

  @override
  State<RoutinesScreen> createState() => _RoutinesScreenState();
}

class _RoutinesScreenState extends State<RoutinesScreen> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _nextExerciseKey = GlobalKey();

  bool _loadingList = true;
  String? _listError;
  List<RoutineSummary> _routines = const <RoutineSummary>[];
  int? _selectedId;

  bool _loadingDetail = false;
  String? _detailError;
  RoutineDetail? _detail;
  int? _savingExerciseId;

  @override
  void initState() {
    super.initState();
    _cargarLista();
  }

  Future<void> _cargarLista({bool silent = false}) async {
    if (!silent && mounted) {
      setState(() {
        _loadingList = true;
        _listError = null;
      });
    }
    try {
      final list = await ApiService().listarRutinas();
      if (!mounted) return;
      final nextId = list.any((r) => r.id == _selectedId)
          ? _selectedId
          : (list.isNotEmpty ? list.first.id : null);

      setState(() {
        _routines = list;
        _selectedId = nextId;
        _loadingList = false;
        _listError = null;
        if (nextId == null) _detail = null;
      });

      if (nextId != null) {
        await _cargarDetalle(nextId, silent: silent);
      }
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _loadingList = false;
        _listError = e.message;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loadingList = false;
        _listError = 'No se pudieron cargar tus rutinas.';
      });
    }
  }

  Future<void> _cargarDetalle(int rutinaId, {bool silent = false}) async {
    if (!silent && mounted) {
      setState(() {
        _loadingDetail = true;
        _detailError = null;
      });
    }
    try {
      final detail = await ApiService().detalleRutina(rutinaId);
      if (!mounted || _selectedId != rutinaId) return;
      setState(() {
        _detail = detail;
        _loadingDetail = false;
        _detailError = null;
      });
    } on ApiException catch (e) {
      if (!mounted || _selectedId != rutinaId) return;
      setState(() {
        _loadingDetail = false;
        _detailError = e.message;
      });
    } catch (_) {
      if (!mounted || _selectedId != rutinaId) return;
      setState(() {
        _loadingDetail = false;
        _detailError = 'No se pudo cargar la rutina.';
      });
    }
  }

  void _seleccionarRutina(int id) {
    if (_selectedId == id) return;
    setState(() => _selectedId = id);
    _cargarDetalle(id);
  }

  Future<void> _toggleEjercicio(
    RoutineExerciseItem exercise,
    bool completado,
  ) async {
    final current = _detail;
    if (current == null || _savingExerciseId != null) return;

    final prevDetail = current;
    final prevList = _routines;

    final optimisticList = current.ejercicios
        .map((e) => e.id == exercise.id ? e.copyWith(completado: completado) : e)
        .toList();
    final doneCount = optimisticList.where((e) => e.completado).length;
    final totalCount = optimisticList.length;
    final pct = totalCount > 0 ? ((doneCount * 100) / totalCount).round() : 0;

    setState(() {
      _savingExerciseId = exercise.id;
      _detail = current.copyWith(
        ejercicios: optimisticList,
        progreso: RoutineProgress(
          total: totalCount,
          completados: doneCount,
          porcentaje: pct,
        ),
      );
      _routines = _routines
          .map(
            (r) => r.id == current.id
                ? r.copyWith(totalEjercicios: totalCount, completados: doneCount)
                : r,
          )
          .toList();
    });

    try {
      final res = await ApiService().completarEjercicio(
        rutinaId: current.id,
        ejercicioId: exercise.id,
        completado: completado,
      );
      if (!mounted) return;
      setState(() {
        _detail = current.copyWith(
          progreso: res.progreso,
          ejercicios: current.ejercicios
              .map((e) => e.id == res.ejercicio.id ? res.ejercicio : e)
              .toList(),
        );
        _routines = _routines
            .map(
              (r) => r.id == current.id
                  ? r.copyWith(
                      totalEjercicios: res.progreso.total,
                      completados: res.progreso.completados,
                    )
                  : r,
            )
            .toList();
      });
      if (res.ejercicio.completado != completado) {
        showAppToast(
          context,
          'Este ejercicio no se puede desmarcar.',
          type: 'info',
        );
      }
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _detail = prevDetail;
        _routines = prevList;
      });
      showAppToast(context, e.message, type: 'error');
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _detail = prevDetail;
        _routines = prevList;
      });
      showAppToast(
        context,
        'No se pudo guardar. Inténtalo de nuevo.',
        type: 'error',
      );
    } finally {
      if (mounted) setState(() => _savingExerciseId = null);
    }
  }

  void _irAlSiguiente() {
    final ctx = _nextExerciseKey.currentContext;
    if (ctx == null) return;
    Scrollable.ensureVisible(
      ctx,
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOutCubic,
      alignment: 0.35,
    );
  }

  @override
  Widget build(BuildContext context) {
    final detail = _detail;
    RoutineExerciseItem? nextExercise;
    if (detail != null) {
      for (final e in detail.ejercicios) {
        if (!e.completado) {
          nextExercise = e;
          break;
        }
      }
    }

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: DashColors.bg,
      drawer: const UserDrawer(selectedId: 'rutinas'),
      bottomNavigationBar: DashboardBottomNav(
        currentIndex: 1,
        onTap: (i) => goToTab(context, i, current: 1),
      ),
      body: DecoratedBox(
        decoration: const BoxDecoration(gradient: AppGradients.userPanelBg),
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              RoutinesTopBar(
                onOpenDrawer: () => _scaffoldKey.currentState?.openDrawer(),
              ),
              Expanded(
                child: RefreshIndicator(
                  color: DashColors.blueLight,
                  backgroundColor: DashColors.card,
                  onRefresh: () => _cargarLista(silent: true),
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(16, 20, 16, 48),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 1120),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            RoutinesPageHeader(routineCount: _routines.length),
                            if (_loadingList)
                              const Padding(
                                padding: EdgeInsets.symmetric(vertical: 28),
                                child: Center(
                                  child: CircularProgressIndicator(
                                    color: DashColors.blueLight,
                                  ),
                                ),
                              )
                            else if (_listError != null)
                              RoutinesErrorBox(
                                title: 'No se pudieron cargar tus rutinas',
                                subtitle: _listError!,
                                onRetry: _cargarLista,
                              )
                            else if (_routines.isEmpty)
                              const RoutinesEmptyState()
                            else ...[
                              RoutinePickerStrip(
                                routines: _routines,
                                selectedId: _selectedId ?? _routines.first.id,
                                onSelect: _seleccionarRutina,
                              ),
                              if (_loadingDetail)
                                const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 28),
                                  child: Center(
                                    child: CircularProgressIndicator(
                                      color: DashColors.blueLight,
                                    ),
                                  ),
                                )
                              else if (_detailError != null || detail == null)
                                RoutinesErrorBox(
                                  title: 'No se pudo cargar la rutina',
                                  subtitle: _detailError ??
                                      'Revisa tu conexión e inténtalo de nuevo.',
                                  onRetry: () {
                                    final id = _selectedId ?? _routines.first.id;
                                    _cargarDetalle(id);
                                  },
                                )
                              else ...[
                                RoutineHeroCard(routine: detail),
                                if (detail.progreso.isComplete)
                                  RoutineCompletedBanner(
                                    total: detail.progreso.total,
                                  ),
                                _RoutineBodyLayout(
                                  detail: detail,
                                  savingExerciseId: _savingExerciseId,
                                  nextExerciseId: nextExercise?.id,
                                  nextExerciseKey: _nextExerciseKey,
                                  onToggle: _toggleEjercicio,
                                  onJumpToNext: _irAlSiguiente,
                                ),
                              ],
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

class _RoutineBodyLayout extends StatelessWidget {
  final RoutineDetail detail;
  final int? savingExerciseId;
  final int? nextExerciseId;
  final GlobalKey nextExerciseKey;
  final void Function(RoutineExerciseItem, bool) onToggle;
  final VoidCallback onJumpToNext;

  const _RoutineBodyLayout({
    required this.detail,
    required this.savingExerciseId,
    required this.nextExerciseId,
    required this.nextExerciseKey,
    required this.onToggle,
    required this.onJumpToNext,
  });

  @override
  Widget build(BuildContext context) {
    final exercisesPanel = RoutineExercisesPanel(
      exercises: detail.ejercicios,
      progress: detail.progreso,
      savingExerciseId: savingExerciseId,
      nextExerciseId: nextExerciseId,
      nextExerciseKey: nextExerciseKey,
      onToggle: onToggle,
    );
    final summaryCard = RoutineSummaryCard(
      routine: detail,
      hasNext: nextExerciseId != null,
      onJumpToNext: onJumpToNext,
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 860) {
          return Column(
            children: [
              exercisesPanel,
              const SizedBox(height: 16),
              summaryCard,
            ],
          );
        }
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: exercisesPanel),
            const SizedBox(width: 20),
            SizedBox(width: 300, child: summaryCard),
          ],
        );
      },
    );
  }
}
