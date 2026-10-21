/// Preferencias de notificaciones y apariencia.
class PreferencesData {
  const PreferencesData({
    required this.sessionReminder,
    required this.analysisCompleted,
    required this.newContent,
    required this.language,
    required this.units,
  });

  final bool sessionReminder;
  final bool analysisCompleted;
  final bool newContent;
  final String language;
  final String units;

  static const languages = ['Español'];
  static const unitSystems = ['Métrico (kg, m)'];
}
