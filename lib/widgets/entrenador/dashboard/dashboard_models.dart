import 'package:flutter/material.dart';

import 'dashboard_theme.dart';

// ── Modelos ──

class DashboardPlayerData {
  final String name;
  final int pct;
  final Color color;
  final String initials;
  final Color bg;
  const DashboardPlayerData(
    this.name,
    this.pct,
    this.color,
    this.initials,
    this.bg,
  );
}

class DashboardActivity {
  final String name;
  final String action;
  final String time;
  final String initials;
  final Color bg;
  final bool icon;
  const DashboardActivity(
    this.name,
    this.action,
    this.time,
    this.initials,
    this.bg, {
    this.icon = false,
  });
}

class DashboardKpi {
  final Color color;
  final String icon;
  final String label;
  final int value;
  final String suffix;
  final String? sub;
  final String? delta;

  const DashboardKpi(
    this.color,
    this.icon,
    this.label,
    this.value,
    this.suffix, {
    this.sub,
    this.delta,
  });
}

// ── Datos ──

const dashboardPlayers = [
  DashboardPlayerData(
    'Juan Pérez',
    85,
    DashboardTheme.blue,
    'JP',
    Color(0xFF1E3A8A),
  ),
  DashboardPlayerData(
    'María González',
    78,
    Color(0xFFEF4444),
    'MG',
    Color(0xFF7F1D1D),
  ),
  DashboardPlayerData(
    'Carlos Ramírez',
    72,
    DashboardTheme.blue,
    'CR',
    Color(0xFF1E40AF),
  ),
  DashboardPlayerData(
    'Sofía Ortega',
    68,
    DashboardTheme.green,
    'SO',
    Color(0xFF14532D),
  ),
  DashboardPlayerData(
    'Andrés López',
    65,
    DashboardTheme.green,
    'AL',
    Color(0xFF166534),
  ),
];

const dashboardInitialActivities = [
  DashboardActivity(
    'Juan Pérez',
    'Completó entrenamiento',
    'Hoy, 10:30 AM',
    'JP',
    Color(0xFF1E3A8A),
  ),
  DashboardActivity(
    'María González',
    'Error técnico detectado',
    'Hoy, 09:15 AM',
    'MG',
    Color(0xFF7F1D1D),
  ),
  DashboardActivity(
    'Carlos Ramírez',
    'Mejora en saque',
    'Ayer, 07:45 PM',
    'CR',
    Color(0xFF1E40AF),
  ),
  DashboardActivity(
    'Nueva sesión',
    'Entrenamiento de defensa',
    'Ayer, 06:30 PM',
    '📹',
    Color(0xFF312E81),
    icon: true,
  ),
];

const dashboardChartLabels = ['14 Abr', '21 Abr', '28 Abr', '5 May', '12 May'];

const dashboardChartValues = [48.0, 55.0, 62.0, 68.0, 78.0];

const dashboardDateOptions = [
  '12 - 18 Mayo, 2025',
  '5 - 11 Mayo, 2025',
  '28 Abr - 4 Mayo, 2025',
  'Abril 2025',
  'Mayo 2025',
];

const dashboardSessionTypes = [
  'Entrenamiento general',
  'Entrenamiento de defensa',
  'Entrenamiento de ataque',
  'Entrenamiento de saque',
  'Partido amistoso',
  'Análisis táctico',
];
