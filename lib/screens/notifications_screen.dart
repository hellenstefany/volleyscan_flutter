import 'package:flutter/material.dart';
import '../models/notification_data.dart';
import '../theme/routine_colors.dart';
import '../widgets/usuario/notification_filters.dart';
import '../widgets/usuario/notification_item.dart';
import '../widgets/usuario/recommendation_card.dart';
import 'analysis_screen.dart';
import 'routines_screen.dart';
import '../widgets/usuario/menu_button.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  // TODO: cargar las notificaciones reales del usuario.
  List<AppNotification> _notifications = List.of(NotificationsData.initial);
  String _filter = 'all';
  Set<int> _dismissing = {};

  // ── Toast ──
  void _toast(String message, {Color color = RoutineColors.blue}) {
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(
        SnackBar(
          content: Text(message, style: const TextStyle(color: Colors.white)),
          behavior: SnackBarBehavior.floating,
          backgroundColor: RoutineColors.card,
          duration: const Duration(seconds: 3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: color),
          ),
        ),
      );
  }

  // ── Filtrado ──
  List<AppNotification> get _filtered {
    if (_filter == 'all') return _notifications;
    if (_filter == 'unread') {
      return _notifications.where((n) => n.unread).toList();
    }
    return _notifications.where((n) => n.type.name == _filter).toList();
  }

  int get _unreadCount => _notifications.where((n) => n.unread).length;

  // ── Acciones ──
  void _markAsRead(int id) {
    final n = _notifications.firstWhere((n) => n.id == id);
    if (!n.unread) return;
    setState(() {
      _notifications = _notifications
          .map((x) => x.id == id ? x.copyWith(unread: false) : x)
          .toList();
    });
    _toast('Notificación marcada como leída.');
    // TODO: avisar al backend.
  }

  void _dismiss(int id) {
    setState(() => _dismissing = {..._dismissing, id});
    Future.delayed(const Duration(milliseconds: 320), () {
      if (!mounted) return;
      setState(() {
        _notifications = _notifications.where((n) => n.id != id).toList();
        _dismissing = _dismissing.where((d) => d != id).toSet();
      });
      // TODO: avisar al backend.
    });
  }

  void _markAllRead() {
    final count = _notifications.where((n) => n.unread).length;
    if (count == 0) {
      _toast('No hay notificaciones sin leer.');
      return;
    }
    setState(() {
      _notifications = _notifications
          .map((n) => n.copyWith(unread: false))
          .toList();
    });
    final plural = count > 1;
    _toast(
      '✓ $count notificación${plural ? 'es' : ''} '
      'marcada${plural ? 's' : ''} como leída${plural ? 's' : ''}.',
      color: const Color(0xFF22C55E),
    );
  }

  void _clearAll() {
    if (_notifications.isEmpty) {
      _toast('No hay notificaciones que limpiar.');
      return;
    }
    setState(() => _dismissing = _notifications.map((n) => n.id).toSet());
    Future.delayed(const Duration(milliseconds: 340), () {
      if (!mounted) return;
      setState(() {
        _notifications = [];
        _dismissing = {};
      });
      _toast(
        'Todas las notificaciones eliminadas.',
        color: const Color(0xFF22C55E),
      );
    });
  }

  void _openRecommendation(Recommendation rec) {
    final Widget page = rec.target == RecommendationTarget.analysis
        ? const AnalysisScreen()
        : const RoutinesScreen();
    Navigator.push(context, MaterialPageRoute(builder: (_) => page));
  }

  // ── UI ──
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: RoutineColors.background,
      appBar: AppBar(
        backgroundColor: RoutineColors.background,
        elevation: 0,
        automaticallyImplyLeading: false,
        leading: const MenuButton(),
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Notificaciones y Feedback',
          style: TextStyle(fontWeight: FontWeight.w800, color: Colors.white),
        ),
      ),
      drawer: const UserDrawer(
        selectedId: 'notificaiones',
      ), // cambia el id en cada archivo
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _buildNotificationsPanel(),
              const SizedBox(height: 16),
              _buildRecommendationsPanel(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationsPanel() {
    final filtered = _filtered;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: RoutineColors.card,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: RoutineColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'Notificaciones',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
              if (_unreadCount > 0) ...[
                const SizedBox(width: 10),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 9,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF97316),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '$_unreadCount',
                    style: const TextStyle(
                      color: Colors.white,
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
                onPressed: _markAllRead,
                icon: const Icon(Icons.done_all_rounded, size: 17),
                label: const Text('Marcar todas como leídas'),
                style: TextButton.styleFrom(
                  foregroundColor: RoutineColors.textMuted,
                  textStyle: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              TextButton.icon(
                onPressed: _clearAll,
                icon: const Icon(Icons.delete_outline_rounded, size: 17),
                label: const Text('Limpiar'),
                style: TextButton.styleFrom(
                  foregroundColor: RoutineColors.textMuted,
                  textStyle: const TextStyle(
                    fontSize: 13,
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
          if (filtered.isEmpty)
            _emptyState()
          else
            for (final n in filtered)
              NotificationItem(
                key: ValueKey(n.id),
                notification: n,
                dismissing: _dismissing.contains(n.id),
                onTap: () => _markAsRead(n.id),
                onMarkRead: () => _markAsRead(n.id),
                onDelete: () => _dismiss(n.id),
              ),
        ],
      ),
    );
  }

  Widget _emptyState() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 36),
      child: Center(
        child: Column(
          children: const [
            Icon(
              Icons.notifications_off_outlined,
              size: 42,
              color: RoutineColors.textMuted,
            ),
            SizedBox(height: 12),
            Text(
              'No hay notificaciones aquí.',
              style: TextStyle(color: RoutineColors.textMuted, fontSize: 14),
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
        color: RoutineColors.card,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: RoutineColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Recomendaciones para ti',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
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
