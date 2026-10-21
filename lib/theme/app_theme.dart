import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Colores tomados del CSS de la página web de VolleyScan.
class AppColors {
  static const bg = Color(0xFF050814);
  static const card = Color(0x0AFFFFFF); // rgba(255,255,255,.04)
  static const border = Color(0x14FFFFFF); // rgba(255,255,255,.08)
  static const cyan = Color(0xFF22D3EE);
  static const gold = Color(0xFFFFD700);
  static const goldDeep = Color(0xFFF59E0B);
  static const blue = Color(0xFF6366F1);
  static const indigoSoft = Color(0xFF818CF8);
  static const orange = Color(0xFFFF7A3D);
  static const teal = Color(0xFF2DD4BF);
  static const green = Color(0xFF22C55E);
  static const muted = Color(0xFF94A3B8);
  static const footerText = Color(0xFF64748B);
  static const navBg = Color(0xFF050814);
}

class AppGradients {
  static const background = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF0B0F1A), Color(0xFF111A3A), Color(0xFF050814)],
  );
  static const primary = LinearGradient(
    colors: [AppColors.blue, AppColors.cyan],
  );
  static const goldBtn = LinearGradient(
    colors: [AppColors.gold, AppColors.goldDeep],
  );
}

ThemeData buildTheme() {
  final base = ThemeData.dark();
  return base.copyWith(
    scaffoldBackgroundColor: AppColors.bg,
    textTheme: GoogleFonts.poppinsTextTheme(base.textTheme),
  );
}
