import 'package:flutter/material.dart';

class FrequentError {
  final String name;
  final int percent;
  const FrequentError(this.name, this.percent);
}

class TechniquePerformance {
  final String name;
  final int percent;
  final Color color;
  const TechniquePerformance(this.name, this.percent, this.color);
}

class ProgressData {
  final int averageScore; // 0-100
  final int totalImprovement; // porcentaje
  final int analysesCount;
  final String trainingTime;
  final List<double> evolution; // puntos de la gráfica de línea
  final List<FrequentError> errors;
  final List<TechniquePerformance> techniques;

  const ProgressData({
    required this.averageScore,
    required this.totalImprovement,
    required this.analysesCount,
    required this.trainingTime,
    required this.evolution,
    required this.errors,
    required this.techniques,
  });

  /// Datos de ejemplo. Reemplázalos por la respuesta de tu API.
  static const sample = ProgressData(
    averageScore: 82,
    totalImprovement: 15,
    analysesCount: 24,
    trainingTime: '12h 30m',
    evolution: [70, 74, 72, 79, 77, 82, 84],
    errors: [
      FrequentError('Contacto anticipado', 35),
      FrequentError('Código bajo', 26),
      FrequentError('Salto no vertical', 20),
      FrequentError('Rotación del hombro', 10),
    ],
    techniques: [
      TechniquePerformance('Remate', 86, Color(0xFF22C55E)),
      TechniquePerformance('Saque', 75, Color(0xFFF97316)),
      TechniquePerformance('Recepción', 70, Color(0xFFEAB308)),
      TechniquePerformance('Bloqueo', 66, Color(0xFF3B82F6)),
    ],
  );
}
