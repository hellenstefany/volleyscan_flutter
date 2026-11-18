import 'package:flutter/material.dart';

import 'estadisticas_theme.dart';

// ── Modelos ──

class EstadisticasPlayer {
  final String name;
  final int perf;
  final int attendance;
  final Color color;
  final List<Color> gradient;
  const EstadisticasPlayer(
    this.name,
    this.perf,
    this.attendance,
    this.color,
    this.gradient,
  );
}

class EstadisticasSeries {
  final String name;
  final Color color;
  final List<int> values;
  const EstadisticasSeries(this.name, this.color, this.values);
}

class EstadisticasItem {
  final String name;
  final int pct;
  final Color color;
  const EstadisticasItem(this.name, this.pct, this.color);
}

// ── Datos ──

const estadisticasPlayers = [
  EstadisticasPlayer('Juan', 88, 92, EstadisticasTheme.accent, [
    Color(0xFF7C5CFC),
    Color(0xFFA488FF),
  ]),
  EstadisticasPlayer('María', 82, 92, EstadisticasTheme.accent4, [
    Color(0xFFF7B731),
    Color(0xFFFFD470),
  ]),
  EstadisticasPlayer('Carlos', 74, 92, EstadisticasTheme.accent5, [
    Color(0xFF26DE81),
    Color(0xFF5EF5A0),
  ]),
  EstadisticasPlayer('Sofía', 65, 92, EstadisticasTheme.accent2, [
    Color(0xFF00D4FF),
    Color(0xFF7EEEFF),
  ]),
  EstadisticasPlayer('Andrés', 60, 92, EstadisticasTheme.accent3, [
    Color(0xFFFF6B6B),
    Color(0xFFFF9F9F),
  ]),
];

const estadisticasDates = ['4 May', '7 May', '10 May', '13 May', '16 May'];

const estadisticasEvolution = [
  EstadisticasSeries('Juan', EstadisticasTheme.accent, [72, 80, 78, 85, 90]),
  EstadisticasSeries('María', EstadisticasTheme.accent4, [65, 70, 68, 72, 69]),
  EstadisticasSeries('Carlos', EstadisticasTheme.accent5, [55, 62, 60, 58, 65]),
];

const estadisticasExercisesAll = [
  EstadisticasItem('Saque', 35, EstadisticasTheme.accent),
  EstadisticasItem('Recepción', 25, EstadisticasTheme.accent2),
  EstadisticasItem('Remate', 20, EstadisticasTheme.accent4),
  EstadisticasItem('Bloqueo', 20, EstadisticasTheme.accent3),
];

const estadisticasExerciseOverrides = {
  'Juan': [
    EstadisticasItem('Saque', 50, EstadisticasTheme.accent),
    EstadisticasItem('Remate', 30, EstadisticasTheme.accent4),
    EstadisticasItem('Recepción', 20, EstadisticasTheme.accent2),
  ],
  'María': [
    EstadisticasItem('Recepción', 45, EstadisticasTheme.accent2),
    EstadisticasItem('Bloqueo', 35, EstadisticasTheme.accent3),
    EstadisticasItem('Saque', 20, EstadisticasTheme.accent),
  ],
  'Carlos': [
    EstadisticasItem('Remate', 40, EstadisticasTheme.accent4),
    EstadisticasItem('Bloqueo', 35, EstadisticasTheme.accent3),
    EstadisticasItem('Saque', 25, EstadisticasTheme.accent),
  ],
};

const estadisticasErrors = [
  EstadisticasItem('Postura incorrecta', 32, EstadisticasTheme.accent3),
  EstadisticasItem('Brazo bajo en saque', 28, EstadisticasTheme.accent3),
  EstadisticasItem('Piernas semiflexionadas', 20, EstadisticasTheme.accent4),
  EstadisticasItem('Falta de coordinación', 20, EstadisticasTheme.accent4),
];

const estadisticasErrorOffsets = {
  'Juan': 5,
  'María': -3,
  'Carlos': 2,
  'Sofía': -5,
  'Andrés': 8,
};
