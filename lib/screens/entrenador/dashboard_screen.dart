import 'package:flutter/material.dart';

import 'package:volleyscan_mobile/widgets/entrenador/dashboard/dashboard_activity_list.dart';
import 'package:volleyscan_mobile/widgets/entrenador/dashboard/dashboard_chart.dart';
import 'package:volleyscan_mobile/widgets/entrenador/dashboard/dashboard_kpis.dart';
import 'package:volleyscan_mobile/widgets/entrenador/dashboard/dashboard_models.dart';
import 'package:volleyscan_mobile/widgets/entrenador/dashboard/dashboard_panel.dart';
import 'package:volleyscan_mobile/widgets/entrenador/dashboard/dashboard_players_list.dart';
import 'package:volleyscan_mobile/widgets/entrenador/dashboard/dashboard_session_dialog.dart';
import 'package:volleyscan_mobile/widgets/entrenador/dashboard/dashboard_theme.dart';
import 'package:volleyscan_mobile/widgets/entrenador/dashboard/dashboard_topbar.dart';

// Nota: se llama DashboardScreen para coincidir con el shell
// (que la importa con `as entrenador`).
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  List<DashboardActivity> _activities = List.of(dashboardInitialActivities);
  int _sessionCount = 15;
  String _dateLabel = 'Fechas';

  void _toast(String msg) {
    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        duration: const Duration(milliseconds: 2800),
        backgroundColor: DashboardTheme.bgCard,
        margin: const EdgeInsets.all(20),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: DashboardTheme.green),
        ),
        content: Row(
          children: [
            const Text(
              '✓',
              style: TextStyle(color: DashboardTheme.green, fontSize: 16),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                msg,
                style: const TextStyle(
                  color: DashboardTheme.textPrimary,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _nowLabel() {
    final now = DateTime.now();
    final h12 = now.hour % 12 == 0 ? 12 : now.hour % 12;
    final mm = now.minute.toString().padLeft(2, '0');
    final ampm = now.hour >= 12 ? 'PM' : 'AM';
    return 'Hoy, ${h12.toString().padLeft(2, '0')}:$mm $ampm';
  }

  Future<void> _openNewSession() async {
    final type = await showDialog<String>(
      context: context,
      barrierColor: Colors.black.withOpacity(0.7),
      builder: (_) => const DashboardSessionDialog(),
    );
    if (type == null) return;

    setState(() {
      _activities = [
        DashboardActivity(
          'Nueva sesión',
          type,
          _nowLabel(),
          '📹',
          const Color(0xFF312E81),
          icon: true,
        ),
        ..._activities.take(3),
      ];
      _sessionCount++;
    });

    _toast('Sesión "$type" creada exitosamente');
  }

  @override
  Widget build(BuildContext context) {
    // Se usa el ancho DISPONIBLE (no el de toda la ventana): así el título
    // deja espacio al botón del menú cuando el contenido se ve angosto.
    return LayoutBuilder(
      builder: (context, box) => _buildBody(box.maxWidth < 760),
    );
  }

  Widget _buildBody(bool narrow) {
    return Material(
      color: DashboardTheme.bgSecondary,
      child: Column(
        children: [
          DashboardTopbar(
            narrow: narrow,
            dateLabel: _dateLabel,
            onDateSelected: (d) {
              setState(() => _dateLabel = d);
              _toast('Período: $d');
            },
            onNewSession: _openNewSession,
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(narrow ? 16 : 28),
              child: LayoutBuilder(
                builder: (context, c) {
                  final w = c.maxWidth;
                  final threeCols = w >= 1000;

                  final chartPanel = DashboardPanel(
                    title: 'Rendimiento por semana',
                    child: DashboardChart(narrow: narrow),
                  );
                  final playersPanel = DashboardPanel(
                    title: 'Comparativa de jugadores',
                    child: DashboardPlayersList(
                      onPlayerTap: (p) =>
                          _toast('Ver estadísticas de ${p.name}'),
                    ),
                  );
                  final activityPanel = DashboardPanel(
                    title: 'Actividad reciente',
                    child: DashboardActivityList(activities: _activities),
                  );

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      DashboardKpis(width: w, sessionCount: _sessionCount),
                      SizedBox(height: narrow ? 16 : 22),
                      if (threeCols)
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(child: chartPanel),
                            const SizedBox(width: 16),
                            Expanded(child: playersPanel),
                            const SizedBox(width: 16),
                            Expanded(child: activityPanel),
                          ],
                        )
                      else ...[
                        chartPanel,
                        const SizedBox(height: 14),
                        playersPanel,
                        const SizedBox(height: 14),
                        activityPanel,
                      ],
                    ],
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
