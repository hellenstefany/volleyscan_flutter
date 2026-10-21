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

  RoutineExercise copyWith({bool? completed}) => RoutineExercise(
    id: id,
    name: name,
    sets: sets,
    reps: reps,
    completed: completed ?? this.completed,
  );
}

class RoutineData {
  final String title;
  final String levelLabel; // INTERMEDIO
  final int levelIndex; // 1 = básico, 2 = intermedio, 3 = avanzado
  final String subtitle;
  final String weeklyGoal;
  final List<RoutineExercise> exercises;

  const RoutineData({
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

  RoutineData copyWith({List<RoutineExercise>? exercises}) => RoutineData(
    title: title,
    levelLabel: levelLabel,
    levelIndex: levelIndex,
    subtitle: subtitle,
    weeklyGoal: weeklyGoal,
    exercises: exercises ?? this.exercises,
  );

  /// Datos de ejemplo. Reemplázalos por la respuesta de tu API.
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
