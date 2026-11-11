import 'package:flutter/material.dart';

/// Paleta idéntica a style.css de la web (Next).
class VS {
  static const ink = Color(0xFF04060D);
  static const deep = Color(0xFF0A1020);
  static const panel = Color(0xD90C1224); // rgba(12,18,36,.85)
  static const line = Color(0x1F94A3B8); // .12
  static const lineStrong = Color(0x3D94A3B8); // .24
  static const text = Color(0xFFEAF0FF);
  static const muted = Color(0xFF94A3B8);
  static const faint = Color(0xFF64748B);
  static const cyan = Color(0xFF22D3EE);
  static const indigo = Color(0xFF6366F1);
  static const gold = Color(0xFFFFD700);
  static const green = Color(0xFF22C55E);
  static const slate200 = Color(0xFFE2E8F0);
  static const slate300 = Color(0xFFCBD5E1);

  /// Úsalo en main.dart como fondo global.
  static const bgGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF0B1023), Color(0xFF111A3A), Color(0xFF050814)],
  );

  static const font = 'Poppins';
}
