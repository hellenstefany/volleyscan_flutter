import 'package:flutter/material.dart';

class ContentVideo {
  final int id;
  final String cat; // saque, recepcion, bloqueo, pose, preparacion
  final String title;
  final String duration;
  final String imageUrl;
  final String desc;

  const ContentVideo({
    required this.id,
    required this.cat,
    required this.title,
    required this.duration,
    required this.imageUrl,
    required this.desc,
  });
}

class ContentTab {
  final String value;
  final String label;
  const ContentTab(this.value, this.label);
}

class ContentData {
  static const pageSize = 6;

  static const catLabel = {
    'saque': 'Saque',
    'recepcion': 'Recepción',
    'bloqueo': 'Bloqueo',
    'pose': 'Pose',
    'preparacion': 'Preparación física',
  };

  static const catColor = {
    'saque': Color(0xFF60A5FA),
    'recepcion': Color(0xFF22C55E),
    'bloqueo': Color(0xFFA855F7),
    'pose': Color(0xFFEAB308),
    'preparacion': Color(0xFF14B8A6),
  };

  static const tabs = [
    ContentTab('all', 'Todos'),
    ContentTab('saque', 'Saque'),
    ContentTab('recepcion', 'Recepción'),
    ContentTab('bloqueo', 'Bloqueo'),
    ContentTab('pose', 'Pose'),
    ContentTab('preparacion', 'Preparación física'),
  ];

  /// Datos de ejemplo. Reemplázalos por la respuesta de tu API.
  static const videos = [
    ContentVideo(
      id: 2,
      cat: 'saque',
      title: 'Errores comunes en el saque',
      duration: '6:30 min',
      imageUrl:
          'https://images.unsplash.com/photo-1547347298-4074fc3086f0?w=400&q=75',
      desc:
          'Análisis detallado de los 5 errores más frecuentes al sacar y cómo corregirlos con ejercicios específicos.',
    ),
    ContentVideo(
      id: 3,
      cat: 'recepcion',
      title: 'Mejora tu recepción',
      duration: '7:15 min',
      imageUrl:
          'https://images.unsplash.com/photo-1574629810360-7efbbe195018?w=400&q=75',
      desc:
          'Postura, lectura del rival y técnica de plataforma para una recepción consistente bajo presión.',
    ),
    ContentVideo(
      id: 4,
      cat: 'recepcion',
      title: 'Posición de manos en el pase',
      duration: '4:10 min',
      imageUrl:
          'https://images.unsplash.com/photo-1543347218-9c47e4b8d9b3?w=400&q=75',
      desc:
          'Guía práctica sobre la posición óptima de manos para el pase de dedos: errores, correcciones y ejercicios.',
    ),
    ContentVideo(
      id: 5,
      cat: 'bloqueo',
      title: 'Bloqueo efectivo',
      duration: '6:45 min',
      imageUrl:
          'https://images.unsplash.com/photo-1561014990-82a765a3e7e5?w=400&q=75',
      desc:
          'Timing, lectura del armador y técnica de manos para un bloqueo que genere puntos directos.',
    ),
    ContentVideo(
      id: 6,
      cat: 'preparacion',
      title: 'Entrenamiento de salto',
      duration: '5:00 días',
      imageUrl:
          'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?w=400&q=75',
      desc:
          'Plan de 5 días para aumentar tu altura de salto con ejercicios pliométricos y de fuerza específicos.',
    ),
    ContentVideo(
      id: 7,
      cat: 'pose',
      title: 'Postura base del voleibolista',
      duration: '3:50 min',
      imageUrl:
          'https://images.unsplash.com/photo-1599058917765-a780eda07a3e?w=400&q=75',
      desc:
          'La postura base es el fundamento de todo movimiento. Aprende la posición correcta para reaccionar más rápido.',
    ),
    ContentVideo(
      id: 8,
      cat: 'saque',
      title: 'Saque flotante con efecto',
      duration: '8:00 min',
      imageUrl:
          'https://images.unsplash.com/photo-1612872087720-bb876e2e67d1?w=400&q=75',
      desc:
          'Domina el saque flotante: grip, contacto y trayectoria para crear un balón imparable.',
    ),
    ContentVideo(
      id: 9,
      cat: 'preparacion',
      title: 'Resistencia para voleibol',
      duration: '10:20 min',
      imageUrl:
          'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?w=400&q=75',
      desc:
          'Circuito de alta intensidad diseñado para mejorar la resistencia específica de voleibolistas.',
    ),
    ContentVideo(
      id: 11,
      cat: 'bloqueo',
      title: 'Comunicación en el bloqueo',
      duration: '4:30 min',
      imageUrl:
          'https://images.unsplash.com/photo-1561014990-82a765a3e7e5?w=400&q=75',
      desc:
          'La coordinación entre centrales y puntas es clave. Aprende las señas y comunicación táctica en el bloqueo.',
    ),
    ContentVideo(
      id: 12,
      cat: 'pose',
      title: 'Análisis de postura con IA',
      duration: '6:10 min',
      imageUrl:
          'https://images.unsplash.com/photo-1599058917765-a780eda07a3e?w=400&q=75',
      desc:
          'Cómo interpretar los resultados del análisis de pose de VolleyScan y aplicarlos en tu entrenamiento.',
    ),
  ];
}
