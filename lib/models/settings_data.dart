import 'package:flutter/material.dart';

class SettingsData {
  // General
  final String units;
  final String language;
  final String theme;
  final String videoQuality;
  final bool autoSaveVideos;

  // Privacidad rápida
  final String analysisVisibility;
  final bool allowComments;
  final bool shareProgress;

  // Análisis
  final bool poseDetection;
  final bool errorAlerts;
  final bool autoAnalysis;
  final String sensitivity;

  // Notificaciones
  final bool pushNotifications;
  final bool trainingReminder;
  final bool weeklySummary;
  final bool achievements;
  final TimeOfDay reminderTime;

  // Privacidad (sección)
  final String profileVisibility;
  final bool shareDataForAi;
  final bool usageAnalytics;

  const SettingsData({
    required this.units,
    required this.language,
    required this.theme,
    required this.videoQuality,
    required this.autoSaveVideos,
    required this.analysisVisibility,
    required this.allowComments,
    required this.shareProgress,
    required this.poseDetection,
    required this.errorAlerts,
    required this.autoAnalysis,
    required this.sensitivity,
    required this.pushNotifications,
    required this.trainingReminder,
    required this.weeklySummary,
    required this.achievements,
    required this.reminderTime,
    required this.profileVisibility,
    required this.shareDataForAi,
    required this.usageAnalytics,
  });

  static const unitOptions = ['Métrico (kg, cm)', 'Imperial (lb, ft)'];
  static const languageOptions = ['Español', 'English', 'Portugues'];
  static const themeOptions = ['Oscuro', 'Claro', 'Automático'];
  static const qualityOptions = ['Baja', 'Media', 'Alta', 'Auto'];
  static const visibilityOptions = [
    'Solo yo',
    'Mi entrenador',
    'Todos',
    'Mi equipo',
  ];
  static const sensitivityOptions = [
    'Baja(solo errores críticos)',
    'Media (recomendado)',
    'Alta(más errores detectados)',
  ];
  static const profileVisibilityOptions = [
    'Privado',
    'Solo entrenador',
    'Público',
  ];

  static const defaults = SettingsData(
    units: 'Métrico (kg, cm)',
    language: 'Español',
    theme: 'Oscuro',
    videoQuality: 'Alta',
    autoSaveVideos: true,
    analysisVisibility: 'Solo yo',
    allowComments: false,
    shareProgress: true,
    poseDetection: true,
    errorAlerts: true,
    autoAnalysis: false,
    sensitivity: 'Media (recomendado)',
    pushNotifications: true,
    trainingReminder: true,
    weeklySummary: false,
    achievements: true,
    reminderTime: TimeOfDay(hour: 8, minute: 0),
    profileVisibility: 'Privado',
    shareDataForAi: true,
    usageAnalytics: false,
  );

  SettingsData copyWith({
    String? units,
    String? language,
    String? theme,
    String? videoQuality,
    bool? autoSaveVideos,
    String? analysisVisibility,
    bool? allowComments,
    bool? shareProgress,
    bool? poseDetection,
    bool? errorAlerts,
    bool? autoAnalysis,
    String? sensitivity,
    bool? pushNotifications,
    bool? trainingReminder,
    bool? weeklySummary,
    bool? achievements,
    TimeOfDay? reminderTime,
    String? profileVisibility,
    bool? shareDataForAi,
    bool? usageAnalytics,
  }) => SettingsData(
    units: units ?? this.units,
    language: language ?? this.language,
    theme: theme ?? this.theme,
    videoQuality: videoQuality ?? this.videoQuality,
    autoSaveVideos: autoSaveVideos ?? this.autoSaveVideos,
    analysisVisibility: analysisVisibility ?? this.analysisVisibility,
    allowComments: allowComments ?? this.allowComments,
    shareProgress: shareProgress ?? this.shareProgress,
    poseDetection: poseDetection ?? this.poseDetection,
    errorAlerts: errorAlerts ?? this.errorAlerts,
    autoAnalysis: autoAnalysis ?? this.autoAnalysis,
    sensitivity: sensitivity ?? this.sensitivity,
    pushNotifications: pushNotifications ?? this.pushNotifications,
    trainingReminder: trainingReminder ?? this.trainingReminder,
    weeklySummary: weeklySummary ?? this.weeklySummary,
    achievements: achievements ?? this.achievements,
    reminderTime: reminderTime ?? this.reminderTime,
    profileVisibility: profileVisibility ?? this.profileVisibility,
    shareDataForAi: shareDataForAi ?? this.shareDataForAi,
    usageAnalytics: usageAnalytics ?? this.usageAnalytics,
  );
}
