import 'package:flutter/material.dart';

/// Colores del panel de usuario (mismos tonos oscuros/cyan de VolleyScan).
class DashColors {
  DashColors._();

  static const bg = Color(0xFF0A0E1F);
  static const card = Color(0xFF0F1730);
  static const cardDark = Color(0xFF0A1022);

  static const blue = Color(0xFF2563EB);
  static const blueLight = Color(0xFF3B82F6);
  static const sky = Color(0xFF38BDF8);
  static const cyan = Color(0xFF22D3EE);
  static const green = Color(0xFF34D399);
  static const greenStrong = Color(0xFF059669);
  static const purple = Color(0xFF9333EA);
  static const orange = Color(0xFFF97316);

  static Color get border => Colors.white.withOpacity(0.07);
  static Color get muted => Colors.white.withOpacity(0.6);
}
