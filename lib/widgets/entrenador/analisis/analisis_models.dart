import 'package:flutter/material.dart';

/// Mensaje del chat (`coach == true` cuando responde VolleyScan AI).
class ChatMsg {
  final bool coach;
  final String texto;
  final String hora;

  const ChatMsg(this.coach, this.texto, this.hora);
}

/// Tarjeta rápida de la pantalla de bienvenida en Chat IA.
class WelcomeCardData {
  final IconData icono;
  final String titulo;
  final String texto;
  final String pregunta;

  const WelcomeCardData({
    required this.icono,
    required this.titulo,
    required this.texto,
    required this.pregunta,
  });
}

/// Constantes de contenido compartidas con `VolleyScan_Next/panel_entrenador/analisis/page.jsx`.
abstract final class AnalisisConfig {
  static const int maxCaracteres = 600;

  static const List<(String glifo, String texto)> sugerencias = [
    ('01', 'Rutina de salto'),
    ('02', 'Mejorar recepción'),
    ('03', 'Plan semanal'),
    ('04', 'Errores en remate'),
  ];

  static const List<WelcomeCardData> tarjetas = [
    WelcomeCardData(
      icono: Icons.bolt_rounded,
      titulo: 'Rutina de salto',
      texto: 'Ejercicios de fuerza y pliometría para ganar altura.',
      pregunta: 'Rutina de salto',
    ),
    WelcomeCardData(
      icono: Icons.track_changes_rounded,
      titulo: 'Análisis técnico',
      texto:
          'Detecta errores en remate y recepción, con pasos para corregirlos.',
      pregunta: 'Errores en remate y recepción',
    ),
    WelcomeCardData(
      icono: Icons.calendar_today_rounded,
      titulo: 'Plan semanal',
      texto: 'Organiza la carga, el descanso y los partidos de tu semana.',
      pregunta: 'Plan semanal',
    ),
  ];
}

String horaActual() {
  final n = DateTime.now();
  return '${n.hour.toString().padLeft(2, '0')}:${n.minute.toString().padLeft(2, '0')}';
}
