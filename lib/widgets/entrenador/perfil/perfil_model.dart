int _toInt(dynamic value, [int fallback = 0]) {
  if (value == null) return fallback;
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value.toString()) ?? fallback;
}

String _toStr(dynamic value, [String fallback = '']) {
  if (value == null) return fallback;
  return value.toString().trim();
}

/// Modelo del perfil del entrenador (`GET` / `PATCH /api/panel/perfil`, `PerfilSerializer`).
class EntrenadorPerfilData {
  final int id;
  final String nombre;
  final String apellido;
  final String email;
  final String rol;
  final String? nivel;
  final String? posicion;
  final String? fotoUrl;
  final String telefono;
  final String club;
  final String experiencia;

  const EntrenadorPerfilData({
    required this.id,
    required this.nombre,
    required this.apellido,
    required this.email,
    required this.rol,
    this.nivel,
    this.posicion,
    this.fotoUrl,
    this.telefono = '',
    this.club = '',
    this.experiencia = '',
  });

  factory EntrenadorPerfilData.fromJson(Map<String, dynamic> json) {
    final rawNivel = _toStr(json['nivel'] ?? json['level']);
    final rawPos = _toStr(json['posicion']);
    final rawFoto = _toStr(json['foto_url']);
    return EntrenadorPerfilData(
      id: _toInt(json['id']),
      nombre: _toStr(json['nombre']),
      apellido: _toStr(json['apellido']),
      email: _toStr(json['email']),
      rol: _toStr(json['rol'], 'entrenador'),
      nivel: rawNivel.isNotEmpty ? rawNivel : null,
      posicion: rawPos.isNotEmpty ? rawPos : null,
      fotoUrl: rawFoto.isNotEmpty ? rawFoto : null,
      telefono: _toStr(json['telefono'] ?? json['phone']),
      club: _toStr(json['club']),
      experiencia: _toStr(json['experiencia'] ?? json['experience']),
    );
  }

  EntrenadorPerfilData copyWith({
    int? id,
    String? nombre,
    String? apellido,
    String? email,
    String? rol,
    String? nivel,
    String? posicion,
    String? fotoUrl,
    String? telefono,
    String? club,
    String? experiencia,
  }) {
    return EntrenadorPerfilData(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      apellido: apellido ?? this.apellido,
      email: email ?? this.email,
      rol: rol ?? this.rol,
      nivel: nivel ?? this.nivel,
      posicion: posicion ?? this.posicion,
      fotoUrl: fotoUrl ?? this.fotoUrl,
      telefono: telefono ?? this.telefono,
      club: club ?? this.club,
      experiencia: experiencia ?? this.experiencia,
    );
  }

  String get nombreCompleto {
    final full = [nombre.trim(), apellido.trim()]
        .where((s) => s.isNotEmpty)
        .join(' ');
    return full.isNotEmpty ? full : 'Entrenador';
  }

  String get iniciales => perfilInitials(nombreCompleto);

  String get nivelEtiqueta => formatCoachNivel(nivel);
}

/// Modelo para un logro en la sección "Logros recientes" (`achievements` en `page.jsx`).
class Achievement {
  final int id;
  final String icon;
  final String title;
  final String description;

  const Achievement({
    required this.id,
    required this.icon,
    required this.title,
    required this.description,
  });

  factory Achievement.fromJson(Map<String, dynamic> json) {
    return Achievement(
      id: _toInt(json['id'], DateTime.now().millisecondsSinceEpoch),
      icon: _toStr(json['icon'], '🏆'),
      title: _toStr(json['title']),
      description: _toStr(json['description']),
    );
  }
}

/// Choices reales de `Usuario.nivel` en `Backend_VolleyScan/panel_entrenador/models.py:24`
/// (`NIVELES_USUARIO = ("principiante", "intermedio", "avanzado", "profesional")`).
const List<(String value, String label)> kCoachNivelesOptions = [
  ('principiante', 'Principiante'),
  ('intermedio', 'Intermedio'),
  ('avanzado', 'Avanzado'),
  ('profesional', 'Profesional'),
];

String formatCoachNivel(String? raw) {
  final clean = (raw ?? '').trim();
  if (clean.isEmpty) return 'Sin nivel';
  for (final opt in kCoachNivelesOptions) {
    if (opt.$1 == clean.toLowerCase()) return opt.$2;
  }
  return clean;
}

/// Normaliza el valor actual de `nivel` para el `DropdownButtonFormField`
/// (si viene nulo o fuera de `NIVELES_USUARIO`, usa `'intermedio'`).
String normalizeCoachNivelValue(String? raw) {
  final clean = (raw ?? '').trim().toLowerCase();
  for (final opt in kCoachNivelesOptions) {
    if (opt.$1 == clean) return opt.$1;
  }
  return 'intermedio';
}

String perfilInitials(String fullName) {
  final parts = fullName
      .trim()
      .split(RegExp(r'\s+'))
      .where((s) => s.isNotEmpty)
      .toList();
  if (parts.isEmpty) return 'EN';
  return parts.map((s) => s[0]).take(2).join().toUpperCase();
}
