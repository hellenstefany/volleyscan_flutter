import 'package:flutter/material.dart';
import '../screens/ai_history_screen.dart';
import '../screens/analysis_screen.dart';
import '../screens/content_screen.dart';
import '../screens/dashboard_screen.dart';
import '../screens/history_screen.dart';
import '../screens/notifications_screen.dart';
import '../screens/profile_screen.dart';
import '../screens/progress_screen.dart';
import '../screens/routines_screen.dart';
import '../screens/settings_screen.dart';
import '../theme/app_theme.dart';

void goToMenuItem(
  BuildContext context,
  String id, {
  required String current,
  String userName = '',
}) {
  final isCurrent = (id == current) ||
      (id == 'dashboard' && current == 'panel') ||
      (id == 'panel' && current == 'dashboard') ||
      (id == 'analisis' && current == 'analisis_ia') ||
      (id == 'analisis_ia' && current == 'analisis') ||
      (id == 'histtrial' && current == 'historial_ia') ||
      (id == 'historial_ia' && current == 'histtrial');

  if (isCurrent) return;

  final nav = Navigator.of(context);

  void replace(Widget screen) =>
      nav.pushReplacement(MaterialPageRoute(builder: (_) => screen));

  switch (id) {
    case 'dashboard':
    case 'panel':
      nav.pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => DashboardScreen(userName: userName)),
        (route) => false,
      );
      break;
    case 'perfil':
      replace(ProfileScreen(userName: userName));
      break;
    case 'entrenador':
      showAppToast(
        context,
        'Próximamente disponible: Mi entrenador',
        type: 'info',
      );
      break;
    case 'equipos':
      showAppToast(
        context,
        'Próximamente disponible: Mis equipos',
        type: 'info',
      );
      break;
    case 'horario':
      showAppToast(
        context,
        'Próximamente disponible: Horario',
        type: 'info',
      );
      break;
    case 'partidos':
      showAppToast(
        context,
        'Próximamente disponible: Mis partidos',
        type: 'info',
      );
      break;
    case 'rutinas':
      replace(const RoutinesScreen());
      break;
    case 'mi_nivel':
      showAppToast(
        context,
        'Próximamente disponible: Mi nivel',
        type: 'info',
      );
      break;
    case 'historial':
      replace(const HistoryScreen());
      break;
    case 'contenido':
      replace(const ContentScreen());
      break;
    case 'progreso':
      replace(const ProgressScreen());
      break;
    case 'analisis':
    case 'analisis_ia':
      replace(const AnalysisScreen());
      break;
    case 'histtrial':
    case 'historial_ia':
      replace(const AiHistoryScreen());
      break;
    case 'notificaciones':
      replace(const NotificationsScreen());
      break;
    case 'configuracion':
      replace(const SettingsScreen());
      break;
  }
}
