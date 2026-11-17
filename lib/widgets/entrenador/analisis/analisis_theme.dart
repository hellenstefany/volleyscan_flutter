import 'package:flutter/material.dart';

/// Colores, gradientes, estilos y textos fijos de la pantalla de análisis IA.
abstract final class AnalisisTheme {
  // ── Colores ──
  static const bgPrimary = Color(0xFF0A0C14);
  static const accent = Color(0xFF7C5CFC);
  static const accentHover = Color(0xFF947CFF);
  static const blue = Color(0xFF4F9DFC);
  static const textPrimary = Color(0xFFF0F3FF);
  static const textSecondary = Color(0xFF9AA1B9);
  static const textMuted = Color(0xFF6A6F8A);
  static const line = Color(0xFF252A3C);
  static const lineStrong = Color(0xFF343B57);
  static const success = Color(0xFF10B981);
  static const surfaceTop = Color(0xFF181C2B);
  static const surfaceBottom = Color(0xFF141723);

  // ── Gradientes ──
  static const aiGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [accent, blue],
  );

  static const surfaceGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [surfaceTop, surfaceBottom],
  );

  // ── Tipografía ──
  static const mono = TextStyle(fontFamily: 'monospace');

  // ── Datos ──
  static const perfilDeportista = [
    ('Posición', 'Armador'),
    ('Nivel', 'Intermedio'),
    ('Objetivo', 'Mejorar salto'),
  ];

  static const welcome =
      """¡Hola! 👋 Soy tu entrenador personal de voleibol basado en IA.

Puedo ayudarte con:
✅ Rutinas de entrenamiento personalizadas
✅ Análisis técnico por posición
✅ Recomendaciones para mejorar rendimiento
✅ Respuesta a dudas tácticas

¿En qué puedo ayudarte hoy? 🏐""";

  static const sugerencias = [
    ('01', 'Rutina de salto'),
    ('02', 'Mejorar recepción'),
    ('03', 'Plan semanal'),
    ('04', 'Errores en remate'),
  ];

  static const maxCaracteres = 600;
}
