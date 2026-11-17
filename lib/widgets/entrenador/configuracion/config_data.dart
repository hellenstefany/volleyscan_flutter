import 'package:flutter/material.dart';

/// Función para mostrar un aviso (snackbar) desde las secciones.
typedef ConfigToast = void Function(String icon, String msg, [Color color]);

/// Callback para modificar un valor de configuración.
typedef ConfigSetter = void Function(String key, dynamic value);

/// (nombre, email, rol, color)
typedef ConfigMember = (String, String, String, Color);

class ConfigThemeOpt {
  final String id;
  final String name;
  final List<Color> colors;
  const ConfigThemeOpt(this.id, this.name, this.colors);
}

const configThemes = [
  ConfigThemeOpt('dark', 'Oscuro', [
    Color(0xFF0D0F1A),
    Color(0xFF131629),
    Color(0xFF7C5CFC),
  ]),
  ConfigThemeOpt('amoled', 'AMOLED', [
    Color(0xFF000000),
    Color(0xFF0A0A0A),
    Color(0xFF7C5CFC),
  ]),
  ConfigThemeOpt('navy', 'Navy', [
    Color(0xFF0F1923),
    Color(0xFF162032),
    Color(0xFF00D4FF),
  ]),
  ConfigThemeOpt('midnight', 'Midnight', [
    Color(0xFF12111A),
    Color(0xFF1A1828),
    Color(0xFFE056FD),
  ]),
];

const configAccentColors = [
  ('Violeta', Color(0xFF7C5CFC)),
  ('Cian', Color(0xFF00D4FF)),
  ('Verde', Color(0xFF26DE81)),
  ('Naranja', Color(0xFFFF9F43)),
  ('Rojo', Color(0xFFFF6B6B)),
  ('Rosa', Color(0xFFE056FD)),
];

const configNotifTypes = [
  'Nuevas rutinas asignadas',
  'Recordatorio de sesión (30 min antes)',
  'Reportes generados por IA',
  'Inasistencias de deportistas',
  'Actualizaciones del sistema',
  'Consejos de entrenamiento semanales',
];

const configNavItems = [
  ('General', 'General', Icons.tune_rounded),
  ('seguridad', 'Seguridad', Icons.lock_outline_rounded),
  ('tema', 'Tema', Icons.palette_outlined),
  ('notificaciones', 'Notificaciones', Icons.notifications_none_rounded),
  ('equipo', 'Equipo', Icons.groups_outlined),
  ('peligro', 'Eliminar', Icons.warning_amber_rounded),
];

const configMembers = <ConfigMember>[
  ('Agustín Luligo', 'agustin@volleyai.com', 'Admin', Color(0xFF7C5CFC)),
  ('Carla Ríos', 'carla@volleyai.com', 'Entrenador', Color(0xFF26DE81)),
  ('Pedro Gómez', 'pedro@volleyai.com', 'Analista', Color(0xFFF7B731)),
];

Map<String, dynamic> configDefaults() => {
  'unidad': 'Métrico (kg, cm)',
  'idioma': 'Español',
  'tema': 'Oscuro',
  'video': 'Baja',
  'autoVideo': true,
  'privacidad': 'Solo yo',
  'comentarios': false,
  'compartir': true,
  '2fa': false,
  '2faSms': true,
  'push': true,
  'email': true,
  'sms': false,
  for (final n in configNotifTypes) 'n:$n': true,
  'themeId': 'dark',
  'accent': 0xFF7C5CFC,
};
