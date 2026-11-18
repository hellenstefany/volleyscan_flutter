import 'package:flutter/material.dart';

/// Colores (de tu :root en Gestion.css)
class GC {
  static const bg = Color(0xFF080C18);
  static const card = Color(0xFF0E1525);
  static const card2 = Color(0xFF121D30);
  static const hover = Color(0xFF1A2540);
  static const border = Color(0x0FFFFFFF); // .06
  static const accent = Color(0xFF3B82F6);
  static const accent2 = Color(0xFF60A5FA);
  static const indigo = Color(0xFF818CF8);
  static const red = Color(0xFFEF4444);
  static const redSoft = Color(0xFFF87171);
  static const purple = Color(0xFF6D28D9);
  static const purple2 = Color(0xFF8B5CF6);
  static const green = Color(0xFF10B981);
  static const mint = Color(0xFF22D3A5);
  static const t1 = Color(0xFFEEF4FF);
  static const t2 = Color(0xFF7A90B8);
  static const t3 = Color(0xFF374A6E);
}

const avatarColors = [
  Color(0xFF3B82F6),
  Color(0xFF7C3AED),
  Color(0xFF06B6D4),
  Color(0xFFF59E0B),
  Color(0xFF22D3A5),
  Color(0xFFF43F5E),
  Color(0xFF8B5CF6),
  Color(0xFF10B981),
];
Color colorFor(int id) => avatarColors[(id - 1) % avatarColors.length];
