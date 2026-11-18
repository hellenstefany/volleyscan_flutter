const kExercises = <String, List<String>>{
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

const kAthletes = [
  'Juan García',
  'María López',
  'Carlos Ruiz',
  'Sofía Mendez',
  'Andrés Mora',
  'Todo el equipo',
];

const kDurations = ['30 min', '45 min', '60 min', '90 min', '2 hrs'];

class Preset {
  final String emoji, name, type, desc, dur;
  final int intensity;
  final List<String> exs;
  const Preset(
    this.emoji,
    this.name,
    this.type,
    this.desc,
    this.dur,
    this.intensity,
    this.exs,
  );
}

const kPresets = [
  Preset(
    '⚡',
    'Saque Explosivo',
    'Técnico',
    'Dominio del saque flotante y de potencia.',
    '60 min',
    8,
    ['Saque flotante', 'Saque potencia', 'Recepción pasiva'],
  ),
  Preset(
    '💪',
    'Fuerza & Salto',
    'Físico',
    'Circuito de potencia para el salto vertical.',
    '90 min',
    9,
    ['Saltos de cajón', 'Sentadillas', 'Drop jump'],
  ),
  Preset(
    '🧠',
    'Juego Táctico 6-2',
    'Táctico',
    'Sistema 6-2 con rotaciones.',
    '60 min',
    6,
    ['Sistema 6-2', 'Rotación posicional', 'Contraataque'],
  ),
  Preset(
    '🔥',
    'HIIT Voleibol',
    'Potencia',
    'Alta intensidad intervalada.',
    '45 min',
    10,
    ['Sprint 20m', 'Remate con carga', 'Drop jump'],
  ),
  Preset(
    '🧘',
    'Regeneración',
    'Recuperación',
    'Post-partido, recuperación muscular.',
    '30 min',
    3,
    ['Foam roller', 'Estiramientos activos'],
  ),
];

class Routine {
  final String id, name, athlete, type, hour, dur, notes, date;
  final int intensity;
  final List<String> exs;
  final bool done;
  const Routine({
    required this.id,
    required this.name,
    required this.athlete,
    required this.type,
    required this.hour,
    required this.dur,
    required this.intensity,
    required this.exs,
    required this.notes,
    required this.date,
    required this.done,
  });

  Routine copyWith({bool? done}) => Routine(
    id: id,
    name: name,
    athlete: athlete,
    type: type,
    hour: hour,
    dur: dur,
    intensity: intensity,
    exs: exs,
    notes: notes,
    date: date,
    done: done ?? this.done,
  );
}

String isoDate(DateTime d) =>
    '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
String daysAgoIso(int n) => isoDate(DateTime.now().subtract(Duration(days: n)));

/// Rutinas de ejemplo (fechas relativas a hoy).
List<Routine> sampleRoutines() => [
  Routine(
    id: 'a1',
    name: 'Saque Explosivo Matutino',
    athlete: 'Juan García',
    type: 'Técnico',
    hour: '08:00',
    dur: '60 min',
    intensity: 8,
    exs: const ['Saque flotante', 'Saque potencia'],
    notes: 'Posición del pie derecho.',
    date: daysAgoIso(0),
    done: false,
  ),
  Routine(
    id: 'a2',
    name: 'Fuerza & Explosividad',
    athlete: 'María López',
    type: 'Físico',
    hour: '10:00',
    dur: '90 min',
    intensity: 9,
    exs: const ['Saltos de cajón', 'Sentadillas'],
    notes: '',
    date: daysAgoIso(1),
    done: true,
  ),
  Routine(
    id: 'a3',
    name: 'Juego Táctico 6-2',
    athlete: 'Todo el equipo',
    type: 'Táctico',
    hour: '16:00',
    dur: '60 min',
    intensity: 6,
    exs: const ['Sistema 6-2', 'Contraataque'],
    notes: 'Llevar pizarrón.',
    date: daysAgoIso(1),
    done: false,
  ),
  Routine(
    id: 'a4',
    name: 'Regeneración Post-Partido',
    athlete: 'Carlos Ruiz',
    type: 'Recuperación',
    hour: '07:00',
    dur: '30 min',
    intensity: 3,
    exs: const ['Foam roller'],
    notes: '',
    date: daysAgoIso(2),
    done: true,
  ),
];
