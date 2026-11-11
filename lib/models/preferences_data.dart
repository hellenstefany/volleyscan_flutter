/// Modelo tipado para la sección Preferencias (`GET | PUT /api/usuario/configuracion/`).
class PreferencesData {
  const PreferencesData({
    required this.notifSesion,
    required this.notifAnalisis,
    required this.notifContenido,
    required this.idioma,
    required this.unidadMedida,
  });

  final bool notifSesion;
  final bool notifAnalisis;
  final bool notifContenido;
  final String idioma; // 'es' | 'en' | 'pt'
  final String unidadMedida; // 'metric' | 'imperial'

  /// Choices exactos de `Configuracion.idioma` en el backend (`panel_entrenador/models.py`).
  static const Map<String, String> idiomaLabels = {
    'es': 'Español',
    'en': 'English',
    'pt': 'Português',
  };

  /// Choices exactos de `Configuracion.unidad_medida` en el backend (`panel_entrenador/models.py`).
  static const Map<String, String> unidadLabels = {
    'metric': 'Métrico (kg, m)',
    'imperial': 'Imperial (lb, ft)',
  };

  static const defaults = PreferencesData(
    notifSesion: true,
    notifAnalisis: true,
    notifContenido: false,
    idioma: 'es',
    unidadMedida: 'metric',
  );

  factory PreferencesData.fromJson(Map<String, dynamic> json) {
    final rawIdioma = (json['idioma'] ?? 'es').toString().trim().toLowerCase();
    final rawUnidad =
        (json['unidad_medida'] ?? 'metric').toString().trim().toLowerCase();
    return PreferencesData(
      notifSesion: json['notif_sesion'] is bool ? json['notif_sesion'] : true,
      notifAnalisis:
          json['notif_analisis'] is bool ? json['notif_analisis'] : true,
      notifContenido:
          json['notif_contenido'] is bool ? json['notif_contenido'] : false,
      idioma: idiomaLabels.containsKey(rawIdioma) ? rawIdioma : 'es',
      unidadMedida:
          unidadLabels.containsKey(rawUnidad) ? rawUnidad : 'metric',
    );
  }

  Map<String, dynamic> toJson() => {
        'notif_sesion': notifSesion,
        'notif_analisis': notifAnalisis,
        'notif_contenido': notifContenido,
        'idioma': idioma,
        'unidad_medida': unidadMedida,
      };
}
