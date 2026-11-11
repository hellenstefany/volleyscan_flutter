import 'package:flutter/material.dart';

/// Colores del panel de usuario y variables globales de VolleyScan_Next (globals.css).
class DashColors {
  DashColors._();

  // Fondos principales (globals.css)
  static const bg = Color(0xFF0B0F1A); // --bg-base / --bg-deep
  static const surface = Color(0xFF131929); // --bg-surface / --bg-sidebar
  static const card = Color(0xFF1A2235); // --bg-card
  static const cardDark = Color(0xFF111827); // --bg-card (deep)
  static const card2 = Color(0xFF161E2E); // --bg-card2
  static const cardHover = Color(0xFF222D46); // --bg-card-hover
  static const hover = Color(0xFF1E2A3D); // --bg-hover

  // Textos (globals.css)
  static const textPrimary = Color(0xFFFFFFFF); // --text-primary
  static const text1 = Color(0xFFF1F5F9); // --text-1
  static const textSecondary = Color(0xFFCBD5E1); // --text-secondary
  static const textMuted = Color(0xFF94A3B8); // --text-muted / --text-2
  static const text3 = Color(0xFF475569); // --text-3

  // Acentos (globals.css)
  static const blue = Color(0xFF2563EB);
  static const blueLight = Color(0xFF3B82F6); // --accent-blue / --accent
  static const accent2 = Color(0xFF60A5FA); // --accent2
  static const blueGlow = Color(0x333B82F6); // --accent-blue-glow
  static const sky = Color(0xFF38BDF8);
  static const cyan = Color(0xFF22D3EE);
  static const green = Color(0xFF22C55E); // --accent-green
  static const greenGlow = Color(0x3322C55E); // --accent-green-glow
  static const greenTeal = Color(0xFF22D3A5); // --green
  static const greenStrong = Color(0xFF059669);
  static const purple = Color(0xFFA855F7); // --accent-purple
  static const orange = Color(0xFFF97316); // --accent-orange
  static const red = Color(0xFFEF4444); // --red

  // Bordes (globals.css)
  static Color get border => const Color(0x14FFFFFF); // rgba(255, 255, 255, .08)
  static Color get borderSubtle => const Color(0x0FFFFFFF); // rgba(255, 255, 255, .06)
  static Color get border2 => const Color(0x1AFFFFFF); // rgba(255, 255, 255, .10)
  static Color get muted => textMuted;
}

