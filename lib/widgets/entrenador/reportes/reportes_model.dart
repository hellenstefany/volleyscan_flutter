import 'package:flutter/material.dart';
import 'reportes_colors.dart';

class Dep {
  final int perf, asis, ses, errores, ejercicios;
  final List<double> spark;
  const Dep(
    this.perf,
    this.asis,
    this.ses,
    this.errores,
    this.ejercicios,
    this.spark,
  );
}

const kData = <String, Dep>{
  'Juan Pérez': Dep(85, 92, 24, 8, 47, [60, 65, 70, 68, 78, 82, 85]),
  'María González': Dep(78, 88, 20, 12, 38, [55, 58, 62, 65, 70, 75, 78]),
  'Carlos Ramírez': Dep(91, 96, 30, 4, 60, [75, 80, 82, 85, 88, 90, 91]),
  'Sofía Ortega': Dep(62, 70, 12, 20, 25, [45, 48, 50, 55, 57, 60, 62]),
  'Andrés López': Dep(80, 90, 22, 9, 44, [60, 65, 68, 72, 75, 78, 80]),
};

const kRecs = <String, List<String>>{
  'Juan Pérez': [
    'Aumentar series de bloqueo',
    'Reforzar recepción en diagonal',
    'Trabajar posición de ataque Z4',
  ],
  'María González': [
    'Mejorar velocidad de reacción',
    'Consolidar defensa de pipe',
    'Ejercicios de salto vertical',
  ],
  'Carlos Ramírez': [
    'Mantener rutina de fuerza',
    'Explorar variantes de saque float',
    'Liderazgo en sistema 6-2',
  ],
  'Sofía Ortega': [
    'Recuperar consistencia en asistencia',
    'Repasar fundamentos de armado',
    'Sesiones de confianza mental',
  ],
  'Andrés López': [
    'Mejorar recepción en zona 1',
    'Trabajar coordinación con armadora',
    'Fortalecer tren superior',
  ],
};

const kTiposReporte = ['Individual', 'Grupal', 'Por fechas'];

String fmtDisp(DateTime d) =>
    '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

/// Tarjetas de estadísticas según los checks marcados: (valor, etiqueta, color).
List<(String, String, Color)> buildStats(Dep d, Map<String, bool> checks) => [
  if (checks['Rendimiento']!) ('${d.perf}%', 'Rendimiento promedio', RC.green),
  if (checks['Asistencia']!) ('${d.asis}%', 'Asistencia', RC.blue2),
  if (checks['Ejercicios']!)
    ('${d.ejercicios}', 'Ejercicios completados', RC.purple2),
  if (checks['Errores']!) ('${d.errores}', 'Errores registrados', RC.red),
];
