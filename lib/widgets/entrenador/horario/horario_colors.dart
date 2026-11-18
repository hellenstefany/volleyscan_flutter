import 'package:flutter/material.dart';

/// Colores (de tu :root en Horario.css)
class HC {
  static const bg2 = Color(0xFF0C1220);
  static const card = Color(0xFF0E1525);
  static const card2 = Color(0xFF121D30);
  static const card3 = Color(0xFF172038);
  static const hover = Color(0xFF1A2540);
  static const border = Color(0x0FFFFFFF); // rgba(255,255,255,.06)
  static const border2 = Color(0x1CFFFFFF); // rgba(255,255,255,.11)
  static const blue = Color(0xFF3B82F6);
  static const blue2 = Color(0xFF60A5FA);
  static const purple = Color(0xFF6D28D9);
  static const purple2 = Color(0xFF8B5CF6);
  static const purpleG1 = Color(0xFF5B21B6);
  static const purpleG2 = Color(0xFF7C3AED);
  static const green = Color(0xFF10B981);
  static const t1 = Color(0xFFEEF4FF);
  static const t2 = Color(0xFF7A90B8);
  static const t3 = Color(0xFF374A6E);
}

// Colores por tipo de evento
Color evBg(String t) => switch (t) {
  'Entrenamiento' => const Color(0xFF1C3461),
  'Competencia' => const Color(0xFF4A1020),
  'Reunión' => const Color(0xFF1A2E1A),
  _ => const Color(0xFF2A1F40),
};

Color evBorder(String t) => switch (t) {
  'Entrenamiento' => HC.blue,
  'Competencia' => const Color(0xFFDC2626),
  'Reunión' => HC.green,
  _ => HC.purple2,
};

Color dotFg(String t) => switch (t) {
  'Entrenamiento' => HC.blue2,
  'Competencia' => const Color(0xFFF87171),
  'Reunión' => const Color(0xFF34D399),
  _ => HC.purple2,
};

IconData tipoIcon(String t) => switch (t) {
  'Competencia' => Icons.emoji_events,
  'Reunión' => Icons.groups,
  _ => Icons.sports_volleyball,
};
