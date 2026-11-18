import 'package:flutter/material.dart';
import '../models/notification_data.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';
import '../theme/dash_colors.dart';
import '../widgets/usuario/drawer/menu_button.dart';
import '../widgets/usuario/entrenador/coach_directory_section.dart';
import '../widgets/usuario/notificaciones/notification_filters.dart';
import '../widgets/usuario/notificaciones/notification_item.dart';
import '../widgets/usuario/notificaciones/recommendation_card.dart';
import 'analysis_screen.dart';
import 'coach_screen.dart';
import 'history_screen.dart';
import 'matches_screen.dart';
import 'my_level_screen.dart';
import 'progress_screen.dart';
import 'routines_screen.dart';
import 'schedule_screen.dart';
import 'teams_screen.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

enum _ScreenState { loading, error, ready }

class _NotificationsScreenState extends State<NotificationsScreen> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  _ScreenState _estado = _ScreenState.loading;
  String _error = '';
  List<AppNotification> _notifications = const <AppNotification>[];
  String _filter = 'all';
  Set<int> _dismissing = {};
  bool _busy = false;

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
      final res = await ApiService().listarAvisos(limite: 100, todas: true);
      if (!mounted) return;
      setState(() {
        _notifications = res.avisos;
        _estado = _ScreenState.ready;
        _error = '';
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
        _error = 'No se pudieron cargar las notificaciones.';
        if (!silent) _estado = _ScreenState.error;
      });
    }
  }

  List<AppNotification> get _filtered {
    if (_filter == 'all') return _notifications;
    if (_filter == 'unread') {
      return _notifications.where((n) => n.unread).toList();
    }
    return _notifications.where((n) => n.rawType == _filter).toList();
  }

  int get _unreadCount => _notifications.where((n) => n.unread).length;

  Future<void> _markAsRead(int id, {bool showToast = true}) async {
    final idx = _notifications.indexWhere((n) => n.id == id);
    if (idx < 0 || !_notifications[idx].unread || _busy) return;

    final prev = _notifications;
    setState(() {
      _busy = true;
      _notifications = _notifications
          .map((x) => x.id == id ? x.copyWith(unread: false) : x)
          .toList();
    });
    try {
      await ApiService().marcarAvisoLeida(id, todas: true);
      if (mounted && showToast) {
        showAppToast(context, 'Notificación marcada como leída.', type: 'info');
      }
    } on ApiException catch (e) {
      if (mounted) {
        setState(() => _notifications = prev);
        showAppToast(context, e.message, type: 'error');
      }
    } catch (_) {
      if (mounted) {
        setState(() => _notifications = prev);
        showAppToast(
          context,
          'No se pudo marcar como leída.',
          type: 'error',
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _openNotification(AppNotification notif) {
    if (notif.unread) _markAsRead(notif.id, showToast: false);
    final link = notif.link;
    if (link == null || link.isEmpty) return;

    final Widget? page = _resolveUserRoute(link);
    if (page == null) {
      showAppToast(context, 'Próximamente disponible', type: 'info');
      return;
    }
    Navigator.push(context, MaterialPageRoute(builder: (_) => page));
  }

  Widget? _resolveUserRoute(String link) {
    if (link.startsWith('/usuario/rutinas')) return const RoutinesScreen();
    if (link.startsWith('/usuario/analisis')) return const AnalysisScreen();
    if (link.startsWith('/usuario/entrenador')) return const CoachScreen();
    if (link.startsWith('/usuario/equipos')) return const TeamsScreen();
    if (link.startsWith('/usuario/horario')) return const ScheduleScreen();
    if (link.startsWith('/usuario/partidos')) return const MatchesScreen();
    if (link.startsWith('/usuario/mi-nivel')) return const MyLevelScreen();
    if (link.startsWith('/usuario/progreso')) return const ProgressScreen();
    if (link.startsWith('/usuario/historial')) return const HistoryScreen();
    return null;
  }

  Future<void> _dismiss(int id) async {
    if (_busy) return;
    final confirmed = await showCoachConfirmModal(
      context,
      title: '¿Eliminar notificación?',
      message: 'Esta notificación se eliminará de tu lista.',
      confirmLabel: 'Eliminar',
      isDanger: true,
    );
    if (!confirmed || !mounted) return;

    setState(() => _busy = true);
    try {
      await ApiService().eliminarAviso(id);
    } on ApiException catch (e) {
      if (e.statusCode != 404) {
        if (mounted) {
          setState(() => _busy = false);
          showAppToast(context, e.message, type: 'error');
        }
        return;
      }
    } catch (_) {
      if (mounted) {
        setState(() => _busy = false);
        showAppToast(context, 'No se pudo eliminar.', type: 'error');
      }
      return;
    }

    if (!mounted) return;
    setState(() => _dismissing = {..._dismissing, id});
    await Future.delayed(const Duration(milliseconds: 300));
    if (!mounted) return;
    setState(() {
      _notifications = _notifications.where((n) => n.id != id).toList();
      _dismissing = _dismissing.where((d) => d != id).toSet();
      _busy = false;
    });
  }

  Future<void> _markAllRead() async {
    if (_busy) return;
    final count = _unreadCount;
    if (count == 0) {
      showAppToast(context, 'No hay notificaciones sin leer.', type: 'info');
      return;
    }

    final prev = _notifications;
    setState(() {
      _busy = true;
      _notifications =
          _notifications.map((n) => n.copyWith(unread: false)).toList();
    });
    try {
      await ApiService().marcarTodosLosAvisosLeidos(todas: true);
      if (mounted) {
        final plural = count > 1;
        showAppToast(
          context,
          '✓ $count notificación${plural ? 'es' : ''} marcada${plural ? 's' : ''} como leída${plural ? 's' : ''}.',
        );
      }
    } on ApiException catch (e) {
      if (mounted) {
        setState(() => _notifications = prev);
        showAppToast(context, e.message, type: 'error');
      }
    } catch (_) {
      if (mounted) {
        setState(() => _notifications = prev);
        showAppToast(
          context,
          'No se pudieron marcar como leídas.',
          type: 'error',
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _clearAll() async {
    if (_busy) return;
    if (_notifications.isEmpty) {
      showAppToast(context, 'No hay notificaciones que limpiar.', type: 'info');
      return;
    }
    final confirmed = await showCoachConfirmModal(
      context,
      title: '¿Limpiar notificaciones?',
      message: 'Se eliminarán todas tus notificaciones de forma permanente.',
      confirmLabel: 'Limpiar todo',
      isDanger: true,
    );
    if (!confirmed || !mounted) return;

    setState(() => _busy = true);
    try {
      await ApiService().eliminarTodosLosAvisos(todas: true);
    } on ApiException catch (e) {
      if (mounted) {
        setState(() => _busy = false);
        showAppToast(context, e.message, type: 'error');
      }
      return;
    } catch (_) {
      if (mounted) {
        setState(() => _busy = false);
        showAppToast(context, 'No se pudieron eliminar.', type: 'error');
      }
      return;
    }

    if (!mounted) return;
    setState(() => _dismissing = _notifications.map((n) => n.id).toSet());
    await Future.delayed(const Duration(milliseconds: 300));
    if (!mounted) return;
    setState(() {
      _notifications = const <AppNotification>[];
      _dismissing = {};
      _busy = false;
    });
    showAppToast(context, 'Todas las notificaciones eliminadas.');
  }

  void _openRecommendation(Recommendation rec) {
    final Widget page = rec.target == RecommendationTarget.analysis
        ? const AnalysisScreen()
        : const RoutinesScreen();
    Navigator.push(context, MaterialPageRoute(builder: (_) => page));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: DashColors.bg,
      drawer: const UserDrawer(selectedId: 'notificaciones'),
      body: DecoratedBox(
        decoration: const BoxDecoration(gradient: AppGradients.userPanelBg),
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              _topBar(),
              Expanded(
                child: RefreshIndicator(
                  color: DashColors.blueLight,
                  backgroundColor: DashColors.card,
                  onRefresh: () => _cargar(silent: true),
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(16, 20, 16, 36),
                    child: Column(
                      children: [
                        _buildNotificationsPanel(),
                        const SizedBox(height: 16),
                        _buildRecommendationsPanel(),
                      ],
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

  Widget _topBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: DashColors.border)),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => _scaffoldKey.currentState?.openDrawer(),
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: DashColors.card,
                borderRadius: BorderRadius.circular(AppRadii.panel),
                border: Border.all(color: DashColors.border),
              ),
              child: const Icon(
                Icons.menu_rounded,
                size: 22,
                color: DashColors.textPrimary,
              ),
            ),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Text(
              'Notificaciones y Feedback',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 19,
                fontWeight: FontWeight.w700,
                color: DashColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationsPanel() {
    final filtered = _filtered;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: DashColors.cardDark,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: DashColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'Notificaciones',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  color: DashColors.textPrimary,
                  fontSize: 19,
                  fontWeight: FontWeight.w800,
                ),
              ),
              if (_unreadCount > 0) ...[
                const SizedBox(width: 10),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 9, vertical: 2),
                  decoration: BoxDecoration(
                    color: DashColors.orange,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '$_unreadCount',
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      color: DashColors.textPrimary,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 4),
          Wrap(
            spacing: 4,
            children: [
              TextButton.icon(
                onPressed: _busy ? null : _markAllRead,
                icon: const Icon(Icons.done_all_rounded, size: 17),
                label: const Text('Marcar todas como leídas'),
                style: TextButton.styleFrom(
                  foregroundColor: DashColors.muted,
                  textStyle: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              TextButton.icon(
                onPressed: _busy ? null : _clearAll,
                icon: const Icon(Icons.delete_outline_rounded, size: 17),
                label: const Text('Limpiar'),
                style: TextButton.styleFrom(
                  foregroundColor: DashColors.muted,
                  textStyle: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          NotificationFilters(
            selected: _filter,
            onSelect: (v) => setState(() => _filter = v),
          ),
          const SizedBox(height: 16),
          if (_estado == _ScreenState.loading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 28),
              child: Center(
                child: CircularProgressIndicator(color: DashColors.blueLight),
              ),
            )
          else if (_estado == _ScreenState.error)
            _errorState()
          else if (filtered.isEmpty)
            _emptyState()
          else
            for (final n in filtered)
              NotificationItem(
                key: ValueKey(n.id),
                notification: n,
                dismissing: _dismissing.contains(n.id),
                busy: _busy,
                onTap: () => _openNotification(n),
                onMarkRead: () => _markAsRead(n.id),
                onDelete: () => _dismiss(n.id),
              ),
        ],
      ),
    );
  }

  Widget _errorState() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 28),
      child: Center(
        child: Column(
          children: [
            const Icon(
              Icons.notifications_off_outlined,
              size: 40,
              color: DashColors.muted,
            ),
            const SizedBox(height: 10),
            Text(
              _error.isNotEmpty
                  ? _error
                  : 'No se pudieron cargar las notificaciones.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'Poppins',
                color: DashColors.muted,
                fontSize: 13.5,
              ),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: _cargar,
              icon: const Icon(Icons.refresh_rounded, size: 17),
              label: const Text('Reintentar'),
              style: OutlinedButton.styleFrom(
                foregroundColor: DashColors.textSecondary,
                side: const BorderSide(color: DashColors.coachBorder),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _emptyState() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 34),
      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.notifications_off_outlined,
              size: 40,
              color: DashColors.muted,
            ),
            SizedBox(height: 12),
            Text(
              'No hay notificaciones aquí.',
              style: TextStyle(
                fontFamily: 'Poppins',
                color: DashColors.muted,
                fontSize: 13.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecommendationsPanel() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: DashColors.cardDark,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: DashColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Recomendaciones para ti',
            style: TextStyle(
              fontFamily: 'Poppins',
              color: DashColors.textPrimary,
              fontSize: 17.5,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 14),
          for (final rec in NotificationsData.recommendations)
            RecommendationCard(
              recommendation: rec,
              onTap: () => _openRecommendation(rec),
            ),
        ],
      ),
    );
  }
}
