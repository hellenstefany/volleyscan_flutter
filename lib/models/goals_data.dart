/// Objetivos de entrenamiento del usuario.
class GoalsData {
  const GoalsData({
    required this.mainGoal,
    required this.sessionsPerWeek,
    required this.minutesPerSession,
    required this.areas,
  });

  final String mainGoal;
  final int sessionsPerWeek;
  final int minutesPerSession;
  final List<String> areas;

  static const mainGoals = [
    'Mejorar técnica de remate',
    'Aumentar resistencia',
    'Mejorar velocidad de reacción',
    'Consistencia en recepción',
  ];

  static const areaOptions = ['Remate', 'Recepción', 'Saque'];

  static const minSessions = 1;
  static const maxSessions = 7;
  static const minMinutes = 15;
  static const maxMinutes = 120;
  static const minutesStep = 5;
}
