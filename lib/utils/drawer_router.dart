import 'package:flutter/material.dart';
import '../screens/dashboard_screen.dart';
import '../screens/profile_screen.dart';
import '../screens/routines_screen.dart';
import '../screens/progress_screen.dart';
import '../screens/settings_screen.dart';
import '../screens/analysis_screen.dart';
import '../screens/ai_history_screen.dart';
import '../screens/notifications_screen.dart';
import '../screens/history_screen.dart';
import '../screens/content_screen.dart';

void goToMenuItem(
  BuildContext context,
  String id, {
  required String current,
  String userName = 'Agustin',
}) {
  final nav = Navigator.of(context);

  if (id == current) {
    nav.pop(); // cierra el drawer
    return;
  }

  void replace(Widget screen) =>
      nav.pushReplacement(MaterialPageRoute(builder: (_) => screen));

  switch (id) {
    case 'panel':
      nav.pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => DashboardScreen(userName: userName)),
        (route) => false,
      );
      break;
    case 'perfil':
      replace(ProfileScreen(userName: userName));
      break;
    case 'rutinas':
      replace(const RoutinesScreen());
      break;
    case 'progreso':
      replace(const ProgressScreen());
      break;
    case 'configuracion':
      replace(const SettingsScreen());
      break;
    case 'analisis_ia':
      replace(const AnalysisScreen());
      break;
    case 'historial_ia':
      replace(const AiHistoryScreen());
      break;
    case 'notificaciones':
      replace(const NotificationsScreen());
      break;
    case 'historial':
      replace(const HistoryScreen());
      break;
    case 'contenido':
      replace(const ContentScreen());
      break;
  }
}
