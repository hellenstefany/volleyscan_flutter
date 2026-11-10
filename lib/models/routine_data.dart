class RoutineExercise {
  final String id;
  final String name;
  final int sets;
  final int reps;
  final bool completed;

  const RoutineExercise({
    required this.id,
    required this.name,
    required this.sets,
    required this.reps,
    this.completed = false,
  });

  String get description => '$sets series x $reps repeticiones';

  factory RoutineExercise.fromApi(Map<String, dynamic> j) => RoutineExercise(
    id: j['id'].toString(),
    name: j['nombre'] ?? '',
    sets: (j['series'] ?? 3) as int,
    reps: (j['repeticiones'] ?? 10) as int,
    completed: j['completado'] == true,
  );

  RoutineExercise copyWith({bool? completed}) => RoutineExercise(
    id: id,
    name: name,
    sets: sets,
    reps: reps,
    completed: completed ?? this.completed,
  );
}

class RoutineData {
  final int id;
  final String title;
  final String levelLabel;
  final int levelIndex; // 1 = básico, 2 = intermedio, 3 = avanzado
  final String subtitle;
  final String weeklyGoal;
  final List<RoutineExercise> exercises;

  const RoutineData({
    this.id = 0,
    required this.title,
    required this.levelLabel,
    required this.levelIndex,
    required this.subtitle,
    required this.weeklyGoal,
    required this.exercises,
  });

  int get completedCount => exercises.where((e) => e.completed).length;

  double get progress =>
      exercises.isEmpty ? 0 : completedCount / exercises.length;

  factory RoutineData.fromApi(Map<String, dynamic> j) {
    final nivel = (j['nivel'] ?? 'intermedio').toString();
    const indices = {'principiante': 1, 'intermedio': 2, 'avanzado': 3};
    return RoutineData(
      id: j['id'] as int,
      title: j['nombre'] ?? 'Rutina',
      levelLabel: nivel.toUpperCase(),
      levelIndex: indices[nivel] ?? 2,
      subtitle: j['descripcion'] ?? '',
      weeklyGoal: j['objetivo'] ?? '',
      exercises: ((j['ejercicios'] ?? []) as List)
          .map((e) => RoutineExercise.fromApi(Map<String, dynamic>.from(e)))
          .toList(),
    );
  }

  RoutineData copyWith({List<RoutineExercise>? exercises}) => RoutineData(
    id: id,
    title: title,
    levelLabel: levelLabel,
    levelIndex: levelIndex,
    subtitle: subtitle,
    weeklyGoal: weeklyGoal,
    exercises: exercises ?? this.exercises,
  );

  static const sample = RoutineData(
    title: 'Rutina personalizada',
    levelLabel: 'INTERMEDIO',
    levelIndex: 2,
    subtitle: 'Rutina recomendada por la IA para ti.',
    weeklyGoal: 'Mejorar técnica de remate y recepción',
    exercises: [
      RoutineExercise(id: '1', name: 'Remate por zona 4', sets: 4, reps: 8),
      RoutineExercise(id: '2', name: 'Recepción alta', sets: 4, reps: 10),
      RoutineExercise(
        id: '3',
        name: 'Pase largo a objetivo',
        sets: 3,
        reps: 12,
      ),
    ],
  );
}
