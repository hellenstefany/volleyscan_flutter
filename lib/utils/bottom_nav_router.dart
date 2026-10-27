import 'package:flutter/material.dart';
import '../screens/analysis_screen.dart';
import '../screens/dashboard_screen.dart';
import '../screens/history_screen.dart';
import '../screens/profile_screen.dart';
import '../screens/routines_screen.dart';

/// Navegación de la barra inferior desde las pantallas de los accesos
/// directos (Rutinas, Scan IA, Historial, Perfil).
///
/// Índices: 0 Inicio, 1 Rutinas, 2 Scan IA, 3 Historial, 4 Perfil.
///
/// - Inicio vuelve al panel y limpia el historial de pantallas.
/// - Las demás pestañas REEMPLAZAN la pantalla actual, así la flecha de
///   volver siempre regresa al panel y no se acumulan pantallas.
void goToTab(
  BuildContext context,
  int index, {
  required int current,
  String userName = 'Agustin',
}) {
  if (index == current) return;

  if (index == 0) {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => DashboardScreen(userName: userName)),
      (route) => false,
    );
    return;
  }

  final Widget page;
  switch (index) {
    case 1:
      page = const RoutinesScreen();
      break;
    case 2:
      page = const AnalysisScreen();
      break;
    case 3:
      page = const HistoryScreen();
      break;
    default:
      page = ProfileScreen(userName: userName);
  }

  Navigator.of(
    context,
  ).pushReplacement(MaterialPageRoute(builder: (_) => page));
}
