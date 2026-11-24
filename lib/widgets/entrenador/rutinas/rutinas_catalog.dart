import 'package:flutter/material.dart';
import '../../../theme/dash_colors.dart';

/// Catálogo y utilidades de la pantalla Rutinas del Entrenador,
/// alineados 1:1 con `VolleyScan_Next/src/app/panel_entrenador/rutinas/page.jsx`.
const kRutinaExercises = <String, List<String>>{
  'Técnico': [
    'Saque flotante',
    'Recepción pasiva',
    'Colocación',
    'Remate cruzado',
    'Bloqueo doble',
    'Defensa en W',
    'Saque potencia',
    'Pase de dedos',
  ],
  'Físico': [
    'Saltos de cajón',
    'Sentadillas',
    'Plancha lateral',
    'Sprint 20m',
    'Escaladores',
    'Flexiones explosivas',
    'Zancadas',
    'Banda elástica',
  ],
  'Táctico': [
    'Sistema 6-2',
    'Rotación posicional',
    'Contraataque',
    'Lectura del bloqueo',
    'Defensa zona',
    'Ataque en diagonal',
    'Finta de remate',
  ],
  'Potencia': [
    'Salto vertical',
    'Remate con carga',
    'Arranque',
    'Kettlebell swing',
    'Drop jump',
    'Banded sprint',
    'Cargada olímpica',
  ],
  'Resistencia': [
    'Carrera continua',
    'Circuito funcional',
    'Remo ergómetro',
    'Bicicleta HIIT',
    'Natación técnica',
    'Escalera de agilidad',
  ],
  'Recuperación': [
    'Foam roller',
    'Estiramientos activos',
    'Yoga deportivo',
    'Movilidad de hombro',
    'Crioterapia',
    'Respiración diafragmática',
  ],
  'Precompetencia': [
    'Activación neuromuscular',
    'Tiro libre',
    'Recepción simulada',
    'Formación táctica',
    'Calentamiento dinámico',
    'Visualización',
  ],
};

const kRutinaTypeColors = <String, Color>{
  'Técnico': DashColors.coachPurple,
  'Físico': DashColors.cyan,
  'Táctico': DashColors.amber,
  'Potencia': DashColors.red,
  'Resistencia': DashColors.greenTeal,
  'Recuperación': DashColors.orange,
  'Precompetencia': DashColors.purple,
};

const kRutinaDuraciones = <String, int>{
  '30 min': 30,
  '45 min': 45,
  '60 min': 60,
  '90 min': 90,
  '2 hrs': 120,
};

const kRutinaNiveles = <(String, String)>[
  ('principiante', 'Principiante'),
  ('intermedio', 'Intermedio'),
  ('avanzado', 'Avanzado'),
  ('profesional', 'Profesional'),
  ('todos', 'Todos los niveles'),
];

String rtNombreNivel(String v) {
  for (final n in kRutinaNiveles) {
    if (n.$1 == v) return n.$2;
  }
  return 'Intermedio';
}

String rtDurTexto(int min) {
  for (final e in kRutinaDuraciones.entries) {
    if (e.value == min) return e.key;
  }
  return min > 0 ? '$min min' : '—';
}

Color rtIntensityColor(int v) {
  if (v <= 3) return DashColors.greenTeal;
  if (v <= 6) return DashColors.amber;
  if (v <= 8) return DashColors.orange;
  return DashColors.red;
}

String rtIsoDate(DateTime d) =>
    '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

const _mesesCortos = <String>[
  'ene',
  'feb',
  'mar',
  'abr',
  'may',
  'jun',
  'jul',
  'ago',
  'sep',
  'oct',
  'nov',
  'dic',
];

String rtFechaCorta(String? iso) {
  if (iso == null || iso.trim().isEmpty) return 'Sin fecha';
  final parts = iso.trim().split('-');
  if (parts.length != 3) return iso;
  final m = int.tryParse(parts[1]);
  final d = int.tryParse(parts[2]);
  if (m == null || d == null || m < 1 || m > 12) return iso;
  return '$d ${_mesesCortos[m - 1]}';
}

/// Plantilla prediseñada de rutina.
class RutinaPreset {
  final String emoji;
  final String name;
  final String type;
  final String desc;
  final String dur;
  final int intensity;
  final List<String> exs;

  const RutinaPreset({
    required this.emoji,
    required this.name,
    required this.type,
    required this.desc,
    required this.dur,
    required this.intensity,
    required this.exs,
  });
}

const kRutinaPresets = <RutinaPreset>[
  RutinaPreset(
    emoji: '⚡',
    name: 'Saque Explosivo',
    type: 'Técnico',
    desc: 'Dominio del saque flotante y de potencia.',
    dur: '60 min',
    intensity: 8,
    exs: ['Saque flotante', 'Saque potencia', 'Recepción pasiva'],
  ),
  RutinaPreset(
    emoji: '💪',
    name: 'Fuerza & Salto',
    type: 'Físico',
    desc: 'Circuito de potencia para el salto vertical.',
    dur: '90 min',
    intensity: 9,
    exs: ['Saltos de cajón', 'Sentadillas', 'Drop jump'],
  ),
  RutinaPreset(
    emoji: '🧠',
    name: 'Juego Táctico 6-2',
    type: 'Táctico',
    desc: 'Sistema 6-2 con rotaciones.',
    dur: '60 min',
    intensity: 6,
    exs: ['Sistema 6-2', 'Rotación posicional', 'Contraataque'],
  ),
  RutinaPreset(
    emoji: '🔥',
    name: 'HIIT Voleibol',
    type: 'Potencia',
    desc: 'Alta intensidad intervalada.',
    dur: '45 min',
    intensity: 10,
    exs: ['Sprint 20m', 'Remate con carga', 'Drop jump'],
  ),
  RutinaPreset(
    emoji: '🧘',
    name: 'Regeneración',
    type: 'Recuperación',
    desc: 'Post-partido, recuperación muscular.',
    dur: '30 min',
    intensity: 3,
    exs: ['Foam roller', 'Estiramientos activos'],
  ),
];

/// Calcula el texto de resumen de la tarjeta "Atención" igual que en Next.
String rtResumenAtencion({
  required List<dynamic> visibles,
  required List<dynamic> enSemana,
  required String? atletaNombre,
  required String hoy,
}) {
  if (visibles.isEmpty) {
    return atletaNombre != null
        ? '$atletaNombre aún no tiene rutinas. Crea la primera con el formulario.'
        : 'Aún no has asignado rutinas. Crea la primera con el formulario.';
  }
  final vencidas = visibles
      .where(
        (r) =>
            !r.completada &&
            r.fechaProgramada != null &&
            (r.fechaProgramada as String).compareTo(hoy) < 0,
      )
      .toList();
  if (vencidas.isNotEmpty) {
    final quienes = {for (final r in vencidas) r.atleta.nombre as String}.toList();
    final lista = quienes.take(3).join(', ') +
        (quienes.length > 3 ? ' y ${quienes.length - 3} más' : '');
    return '${vencidas.length} rutina${vencidas.length > 1 ? 's' : ''} sin completar con fecha vencida ($lista).';
  }
  final hechasSemana = enSemana.where((r) => r.completada == true).length;
  return hechasSemana > 0
      ? 'Esta semana se completaron $hechasSemana rutina${hechasSemana > 1 ? 's' : ''}. Todo lo demás va al día.'
      : 'Todo va al día: no hay rutinas vencidas.';
}
