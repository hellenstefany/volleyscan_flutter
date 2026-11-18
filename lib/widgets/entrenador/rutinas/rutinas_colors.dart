import 'package:flutter/material.dart';

/// Colores (de tu :root en Rutinas.css)
class RtC {
  static const bg = Color(0xFF0D0F1A); // --bg
  static const card = Color(0xFF181C30); // --panel2
  static const card2 = Color(0xFF1E2238); // --panel3
  static const border = Color(0x12FFFFFF); // --border
  static const text = Color(0xFFE8EAF6); // --text
  static const muted = Color(0xFF7A7F9A); // --muted
  static const muted2 = Color(0xFF4A4F6A); // --muted2
  static const accent = Color(0xFF7C5CFC); // --accent
  static const accent2 = Color(0xFF00D4FF); // --accent2
  static const accent3 = Color(0xFFFF6B6B); // --accent3
  static const accent4 = Color(0xFFF7B731); // --accent4
  static const accent5 = Color(0xFF26DE81); // --accent5
  static const orange = Color(0xFFFF9F43); // --accent6
}

const kTypeColors = <String, Color>{
  'Técnico': Color(0xFF7C5CFC),
  'Físico': Color(0xFF00D4FF),
  'Táctico': Color(0xFFF7B731),
  'Potencia': Color(0xFFFF6B6B),
  'Resistencia': Color(0xFF26DE81),
  'Recuperación': Color(0xFFFF9F43),
  'Precompetencia': Color(0xFFE056FD),
};

/// Color según la intensidad (1–10).
Color rtIntensityColor(int v) => v <= 3
    ? RtC.accent5
    : v <= 6
    ? RtC.accent4
    : v <= 8
    ? RtC.orange
    : RtC.accent3;
