/// Modelo tipado para `GET | PUT /api/usuario/perfil/`.
/// Respeta los `null` que devuelve el backend (`nivel`, `posicion`, `peso`, `estatura`, `fecha_nac`, `foto_url`).
class ProfileData {
  const ProfileData({
    this.id,
    required this.nombre,
    required this.apellido,
    required this.email,
    this.rol,
    this.nivel,
    this.posicion,
    this.peso,
    this.estatura,
    this.fechaNac,
    this.fotoUrl,
  });

  final int? id;
  final String nombre;
  final String apellido;
  final String email;
  final String? rol;
  final String? nivel;
  final String? posicion;
  final double? peso;
  final double? estatura;
  final String? fechaNac; // Formato YYYY-MM-DD o null
  final String? fotoUrl;

  /// Choices exactos de `NIVELES_USUARIO` en el backend (`panel_entrenador/models.py`).
  static const Map<String, String> nivelLabels = {
    'principiante': 'Principiante',
    'intermedio': 'Intermedio',
    'avanzado': 'Avanzado',
    'profesional': 'Profesional',
  };

  /// Choices exactos de `POSICIONES` en el backend (`panel_entrenador/models.py`).
  static const Map<String, String> posicionLabels = {
    '': 'Sin especificar',
    'opuesto': 'Opuesto',
    'armador': 'Armador',
    'central': 'Central',
    'punta': 'Punta receptor',
    'libero': 'Líbero',
  };

  String get fullName {
    final full = '${nombre.trim()} ${apellido.trim()}'.trim();
    return full.isEmpty ? 'Atleta' : full;
  }

  String get nivelLabel =>
      nivelLabels[(nivel ?? '').toLowerCase()] ?? 'Deportista';

  String get rolLabel {
    final r = (rol ?? '').toLowerCase();
    if (r == 'entrenador') return 'Entrenador';
    return 'Deportista';
  }

  factory ProfileData.fromJson(Map<String, dynamic> json) {
    double? parseNum(dynamic v) {
      if (v == null) return null;
      if (v is num) return v.toDouble();
      return double.tryParse(v.toString().trim().replaceAll(',', '.'));
    }

    String? cleanStr(dynamic v) {
      if (v == null) return null;
      final s = v.toString().trim();
      return s.isEmpty ? null : s;
    }

    return ProfileData(
      id: json['id'] is num
          ? (json['id'] as num).toInt()
          : int.tryParse('${json['id'] ?? ''}'),
      nombre: (json['nombre'] ?? '').toString().trim(),
      apellido: (json['apellido'] ?? '').toString().trim(),
      email: (json['email'] ?? '').toString().trim(),
      rol: cleanStr(json['rol']),
      nivel: cleanStr(json['nivel'])?.toLowerCase(),
      posicion: cleanStr(json['posicion'])?.toLowerCase(),
      peso: parseNum(json['peso']),
      estatura: parseNum(json['estatura']),
      fechaNac: cleanStr(json['fecha_nac']),
      fotoUrl: cleanStr(json['foto_url']),
    );
  }

  /// Devuelve únicamente los campos que cambiaron respecto a [original]
  /// para enviar en `PUT /api/usuario/perfil/`.
  Map<String, dynamic> diffFrom(ProfileData original) {
    final diff = <String, dynamic>{};
    if (nombre.trim() != original.nombre.trim()) {
      diff['nombre'] = nombre.trim();
    }
    if (apellido.trim() != original.apellido.trim()) {
      diff['apellido'] = apellido.trim();
    }
    if (email.trim().toLowerCase() != original.email.trim().toLowerCase()) {
      diff['email'] = email.trim().toLowerCase();
    }
    if ((nivel ?? '') != (original.nivel ?? '')) {
      diff['nivel'] = (nivel == null || nivel!.isEmpty) ? null : nivel;
    }
    if ((posicion ?? '') != (original.posicion ?? '')) {
      diff['posicion'] =
          (posicion == null || posicion!.isEmpty) ? null : posicion;
    }
    if (peso != original.peso) {
      diff['peso'] = peso;
    }
    if (estatura != original.estatura) {
      diff['estatura'] = estatura;
    }
    if ((fechaNac ?? '') != (original.fechaNac ?? '')) {
      diff['fecha_nac'] =
          (fechaNac == null || fechaNac!.isEmpty) ? null : fechaNac;
    }
    return diff;
  }

  ProfileData copyWith({
    int? id,
    String? nombre,
    String? apellido,
    String? email,
    String? rol,
    String? nivel,
    String? posicion,
    bool clearPosicion = false,
    double? peso,
    bool clearPeso = false,
    double? estatura,
    bool clearEstatura = false,
    String? fechaNac,
    bool clearFechaNac = false,
    String? fotoUrl,
    bool clearFotoUrl = false,
  }) {
    return ProfileData(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      apellido: apellido ?? this.apellido,
      email: email ?? this.email,
      rol: rol ?? this.rol,
      nivel: nivel ?? this.nivel,
      posicion: clearPosicion ? null : (posicion ?? this.posicion),
      peso: clearPeso ? null : (peso ?? this.peso),
      estatura: clearEstatura ? null : (estatura ?? this.estatura),
      fechaNac: clearFechaNac ? null : (fechaNac ?? this.fechaNac),
      fotoUrl: clearFotoUrl ? null : (fotoUrl ?? this.fotoUrl),
    );
  }
}
