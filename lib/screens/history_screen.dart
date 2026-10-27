import 'package:flutter/material.dart';
import '../utils/bottom_nav_router.dart';
import '../widgets/usuario/dashboard_bottom_nav.dart';
import '../models/session_data.dart';
import '../theme/routine_colors.dart';
import '../widgets/usuario/session_filter_dropdown.dart';
import '../widgets/usuario/session_item.dart';
import '../widgets/usuario/menu_button.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  // TODO: cargar las sesiones reales del usuario.
  final List<SessionData> _sessions = SessionsData.sessions;
  String _filter = 'all';

  List<SessionData> get _filtered => _filter == 'all'
      ? _sessions
      : _sessions.where((s) => s.technique == _filter).toList();

  void _openSession(SessionData session) {
    // TODO: abrir el detalle / video de la sesión.
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filtered;

    return Scaffold(
      backgroundColor: RoutineColors.background,
      appBar: AppBar(
        backgroundColor: RoutineColors.background,
        elevation: 0,
        automaticallyImplyLeading: false,
        leading: const MenuButton(),
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Historial de Sesiones',
          style: TextStyle(fontWeight: FontWeight.w800, color: Colors.white),
        ),
      ),
      drawer: const UserDrawer(selectedId: 'historial'),
      bottomNavigationBar: DashboardBottomNav(
        currentIndex: 3,
        onTap: (i) => goToTab(context, i, current: 3),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Container(
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
                Wrap(
                  alignment: WrapAlignment.spaceBetween,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  runSpacing: 12,
                  children: [
                    const Text(
                      'Historial de sesiones',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SessionFilterDropdown(
                      selected: _filter,
                      onChanged: (v) => setState(() => _filter = v),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                if (filtered.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 32),
                    child: Center(
                      child: Text(
                        'No hay sesiones para esta técnica.',
                        style: TextStyle(
                          color: RoutineColors.textMuted,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  )
                else
                  for (final s in filtered)
                    SessionItem(
                      key: ValueKey(s.id),
                      session: s,
                      onTap: () => _openSession(s),
                    ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
