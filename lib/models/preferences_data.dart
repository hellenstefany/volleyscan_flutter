/// Modelo tipado para `GET | PUT /api/usuario/configuracion/` (11 campos de la tabla `configuracion`).
/// Reutilizado tanto en Perfil → Preferencias como en la pantalla Configuración.
class PreferencesData {
  const PreferencesData({
    required this.unidadMedida,
    required this.idioma,
    this.tema = 'dark',
    this.calidadVideo = 'alta',
    this.guardarVideos = true,
    required this.notifSesion,
    required this.notifAnalisis,
    required this.notifContenido,
    this.compartirProgreso = true,
    this.permitirComentarios = false,
    this.visibilidadAnalisis = 'solo',
  });

  final String unidadMedida; // 'metric' | 'imperial'
  final String idioma; // 'es' | 'en' | 'pt'
  final String tema; // 'dark' | 'light' | 'auto'
  final String calidadVideo; // 'baja' | 'media' | 'alta' | 'auto'
  final bool guardarVideos;
  final bool notifSesion;
  final bool notifAnalisis;
  final bool notifContenido;
  final bool compartirProgreso;
  final bool permitirComentarios;
  final String visibilidadAnalisis; // 'solo' | 'entrenador' | 'equipo' | 'todos'

  /// Choices de `Configuracion.idioma` en el backend (`panel_entrenador/models.py`).
  static const Map<String, String> idiomaLabels = {
    'es': 'Español',
    'en': 'English',
    'pt': 'Português',
  };

  /// Choices de `Configuracion.unidad_medida` en el backend y `SeccionGeneral.jsx`.
  static const Map<String, String> unidadLabels = {
    'metric': 'Métrico (kg, cm)',
    'imperial': 'Imperial (lb, ft)',
  };

  /// Choices de `Configuracion.tema` en el backend (`panel_entrenador/models.py`).
  static const Map<String, String> temaLabels = {
    'dark': 'Oscuro',
    'light': 'Claro',
    'auto': 'Automático',
  };

  /// Choices de `Configuracion.calidad_video` en `SeccionGeneral.jsx`.
  static const Map<String, String> calidadLabels = {
    'alta': 'Alta',
    'media': 'Media',
    'baja': 'Baja',
    'auto': 'Auto',
  };

  /// Choices de `Configuracion.visibilidad_analisis` en `ControlesConfig.jsx` (`VISIBILIDAD`).
  static const Map<String, String> visibilidadLabels = {
    'solo': 'Solo yo',
    'entrenador': 'Mi entrenador',
    'equipo': 'Mi equipo',
    'todos': 'Todos',
  };

  /// Valores de visualización iniciales solo mientras carga la pantalla.
  /// Nunca deben enviarse en un `PUT` si la carga desde el backend no se completó.
  static const defaults = PreferencesData(
    unidadMedida: 'metric',
    idioma: 'es',
    tema: 'dark',
    calidadVideo: 'alta',
    guardarVideos: true,
    notifSesion: true,
    notifAnalisis: true,
    notifContenido: false,
    compartirProgreso: true,
    permitirComentarios: false,
    visibilidadAnalisis: 'solo',
  );

  factory PreferencesData.fromJson(Map<String, dynamic> json) {
    final rawUnidad =
        (json['unidad_medida'] ?? 'metric').toString().trim().toLowerCase();
    final rawIdioma =
        (json['idioma'] ?? 'es').toString().trim().toLowerCase();
    final rawTema =
        (json['tema'] ?? 'dark').toString().trim().toLowerCase();
    final rawCalidad =
        (json['calidad_video'] ?? 'alta').toString().trim().toLowerCase();
    final rawVisibilidad =
        (json['visibilidad_analisis'] ?? 'solo').toString().trim().toLowerCase();

    return PreferencesData(
      unidadMedida:
          unidadLabels.containsKey(rawUnidad) ? rawUnidad : 'metric',
      idioma: idiomaLabels.containsKey(rawIdioma) ? rawIdioma : 'es',
      tema: temaLabels.containsKey(rawTema) ? rawTema : 'dark',
      calidadVideo:
          calidadLabels.containsKey(rawCalidad) ? rawCalidad : 'alta',
      guardarVideos:
          json['guardar_videos'] is bool ? json['guardar_videos'] as bool : true,
      notifSesion:
          json['notif_sesion'] is bool ? json['notif_sesion'] as bool : true,
      notifAnalisis:
          json['notif_analisis'] is bool ? json['notif_analisis'] as bool : true,
      notifContenido: json['notif_contenido'] is bool
          ? json['notif_contenido'] as bool
          : false,
      compartirProgreso: json['compartir_progreso'] is bool
          ? json['compartir_progreso'] as bool
          : true,
      permitirComentarios: json['permitir_comentarios'] is bool
          ? json['permitir_comentarios'] as bool
          : false,
      visibilidadAnalisis: visibilidadLabels.containsKey(rawVisibilidad)
          ? rawVisibilidad
          : 'solo',
    );
  }

  PreferencesData copyWith({
    String? unidadMedida,
    String? idioma,
    String? tema,
    String? calidadVideo,
    bool? guardarVideos,
    bool? notifSesion,
    bool? notifAnalisis,
    bool? notifContenido,
    bool? compartirProgreso,
    bool? permitirComentarios,
    String? visibilidadAnalisis,
  }) {
    return PreferencesData(
      unidadMedida: unidadMedida ?? this.unidadMedida,
      idioma: idioma ?? this.idioma,
      tema: tema ?? this.tema,
      calidadVideo: calidadVideo ?? this.calidadVideo,
      guardarVideos: guardarVideos ?? this.guardarVideos,
      notifSesion: notifSesion ?? this.notifSesion,
      notifAnalisis: notifAnalisis ?? this.notifAnalisis,
      notifContenido: notifContenido ?? this.notifContenido,
      compartirProgreso: compartirProgreso ?? this.compartirProgreso,
      permitirComentarios: permitirComentarios ?? this.permitirComentarios,
      visibilidadAnalisis: visibilidadAnalisis ?? this.visibilidadAnalisis,
    );
  }

  Map<String, dynamic> toJson() => {
        'unidad_medida': unidadMedida,
        'idioma': idioma,
        'tema': tema,
        'calidad_video': calidadVideo,
        'guardar_videos': guardarVideos,
        'notif_sesion': notifSesion,
        'notif_analisis': notifAnalisis,
        'notif_contenido': notifContenido,
        'compartir_progreso': compartirProgreso,
        'permitir_comentarios': permitirComentarios,
        'visibilidad_analisis': visibilidadAnalisis,
      };
}

/// Estado local para la pestaña "Análisis" (`SeccionAnalisis.jsx` en Next).
/// Estos 4 controles no existen en la base de datos y solo viven mientras la pantalla está abierta.
class LocalAnalysisSettings {
  const LocalAnalysisSettings({
    this.pose = true,
    this.alertas = true,
    this.automatico = false,
    this.sensibilidad = 'media',
  });

  final bool pose;
  final bool alertas;
  final bool automatico;
  final String sensibilidad; // 'alta' | 'media' | 'baja'

  static const Map<String, String> sensibilidadLabels = {
    'alta': 'Alta (más errores detectados)',
    'media': 'Media (recomendado)',
    'baja': 'Baja (solo errores críticos)',
  };

  static const defaults = LocalAnalysisSettings();

  LocalAnalysisSettings copyWith({
    bool? pose,
    bool? alertas,
    bool? automatico,
    String? sensibilidad,
  }) {
    return LocalAnalysisSettings(
      pose: pose ?? this.pose,
      alertas: alertas ?? this.alertas,
      automatico: automatico ?? this.automatico,
      sensibilidad: sensibilidad ?? this.sensibilidad,
    );
  }
}
