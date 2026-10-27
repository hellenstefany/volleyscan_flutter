import 'package:flutter/material.dart';

class SessionData {
  final int id;
  final String technique; // remate, saque, recepcion, bloqueo
  final String name;
  final String date;
  final int score; // 0-100
  final String duration;
  final String imageUrl;
  final Color color; // color del aro de puntuación

  const SessionData({
    required this.id,
    required this.technique,
    required this.name,
    required this.date,
    required this.score,
    required this.duration,
    required this.imageUrl,
    required this.color,
  });

  /// Verde si la puntuación es 80 o más, naranja si es menor.
  bool get isGood => score >= 80;
}

class SessionFilter {
  final String value;
  final String label;
  const SessionFilter(this.value, this.label);
}

class SessionsData {
  static const _green = Color(0xFF22C55E);
  static const _orange = Color(0xFFF97316);

  /// Datos de ejemplo. Reemplázalos por la respuesta de tu API.
  static const sessions = [
    SessionData(
      id: 1,
      technique: 'remate',
      name: 'Remate por zona 4',
      date: '18 Mayo 2025 · 10:30 a.m.',
      score: 85,
      duration: '00:45',
      imageUrl:
          'https://images.unsplash.com/photo-1612872087720-bb876e2e67d1?w=120&q=75',
      color: _green,
    ),
    SessionData(
      id: 2,
      technique: 'saque',
      name: 'Saque flotante',
      date: '17 Mayo 2025 · 08:15 a.m.',
      score: 78,
      duration: '00:40',
      imageUrl:
          'https://images.unsplash.com/photo-1547347298-4074fc3086f0?w=120&q=75',
      color: _green,
    ),
    SessionData(
      id: 3,
      technique: 'recepcion',
      name: 'Recepción y pase',
      date: '16 Mayo 2025 · 08:30 a.m.',
      score: 82,
      duration: '00:38',
      imageUrl:
          'https://images.unsplash.com/photo-1574629810360-7efbbe195018?w=120&q=75',
      color: _green,
    ),
    SessionData(
      id: 4,
      technique: 'bloqueo',
      name: 'Bloqueo frontal',
      date: '15 Mayo 2025 · 07:30 p.m.',
      score: 75,
      duration: '00:35',
      imageUrl:
          'https://images.unsplash.com/photo-1561014990-82a765a3e7e5?w=120&q=75',
      color: _orange,
    ),
  ];

  static const filters = [
    SessionFilter('all', 'Todas las técnicas'),
    SessionFilter('saque', 'Saque'),
    SessionFilter('recepcion', 'Recepción'),
    SessionFilter('bloqueo', 'Bloqueo'),
  ];
}
