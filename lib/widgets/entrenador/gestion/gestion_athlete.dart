int _toInt(dynamic value, [int fallback = 0]) {
  if (value == null) return fallback;
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value.toString()) ?? fallback;
}

int? _toNullableInt(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is num) return value.round();
  return int.tryParse(value.toString());
}

double? _toNullableDouble(dynamic value) {
  if (value == null) return null;
  if (value is double) return value;
  if (value is num) return value.toDouble();
  return double.tryParse(value.toString());
}

String _toStr(dynamic value, [String fallback = '']) {
  if (value == null) return fallback;
  return value.toString().trim();
}

String? _toNullableStr(dynamic value) {
  if (value == null) return null;
  final s = value.toString().trim();
  return s.isEmpty ? null : s;
}

List<double>? _toRango(dynamic value) {
  if (value is List && value.length >= 2) {
    final a = _toNullableDouble(value[0]);
    final b = _toNullableDouble(value[1]);
    if (a != null && b != null) return [a, b];
  }
  return null;
}

/// Resumen de práctica con IA de un deportista (`ia` dentro de `_atleta(f)` en `vinculos/repositorio.py`).
class DeportistaIaResumen {
  final int sesiones;
  final int? promedio;
  final int? mejor;
  final String? ultimaSesion;
  final int sinRevisar;

  const DeportistaIaResumen({
    required this.sesiones,
    this.promedio,
    this.mejor,
    this.ultimaSesion,
    this.sinRevisar = 0,
  });

  factory DeportistaIaResumen.fromJson(Map<String, dynamic> json) {
    return DeportistaIaResumen(
      sesiones: _toInt(json['sesiones']),
      promedio: _toNullableInt(json['promedio']),
      mejor: _toNullableInt(json['mejor']),
      ultimaSesion: _toNullableStr(json['ultimaSesion']),
      sinRevisar: _toInt(json['sinRevisar']),
    );
  }
}

/// Deportista vinculado o con solicitud pendiente (`GET /api/ia/vinculos/deportistas`,
/// `GET /api/ia/vinculos/solicitudes-recibidas` y `GET /api/ia/vinculos/deportistas/<id>`).
class EntrenadorDeportista {
  final int id;
  final String nombre;
  final String apellido;
  final String email;
  final String? fotoUrl;
  final String? nivel;
  final String? posicion;
  final double? pesoKg;
  final double? estaturaM;
  final String? fechaNac;
  final int? edad;
  final bool activo;
  final int vinculoId;
  final String? solicitadoEn;
  final String? desde;
  final DeportistaIaResumen? ia;

  const EntrenadorDeportista({
    required this.id,
    required this.nombre,
    required this.apellido,
    required this.email,
    this.fotoUrl,
    this.nivel,
    this.posicion,
    this.pesoKg,
    this.estaturaM,
    this.fechaNac,
    this.edad,
    this.activo = true,
    required this.vinculoId,
    this.solicitadoEn,
    this.desde,
    this.ia,
  });

  factory EntrenadorDeportista.fromJson(Map<String, dynamic> json) {
    final rawIa = json['ia'];
    return EntrenadorDeportista(
      id: _toInt(json['id']),
      nombre: _toStr(json['nombre']),
      apellido: _toStr(json['apellido']),
      email: _toStr(json['email']),
      fotoUrl: _toNullableStr(json['fotoUrl'] ?? json['foto_url']),
      nivel: _toNullableStr(json['nivel']),
      posicion: _toNullableStr(json['posicion']),
      pesoKg: _toNullableDouble(json['pesoKg'] ?? json['peso']),
      estaturaM: _toNullableDouble(json['estaturaM'] ?? json['estatura']),
      fechaNac: _toNullableStr(json['fechaNac'] ?? json['fecha_nac']),
      edad: _toNullableInt(json['edad']),
      activo: json['activo'] is bool ? json['activo'] as bool : true,
      vinculoId: _toInt(json['vinculoId'] ?? json['vinculo_id']),
      solicitadoEn: _toNullableStr(json['solicitadoEn']),
      desde: _toNullableStr(json['desde']),
      ia: rawIa is Map
          ? DeportistaIaResumen.fromJson(Map<String, dynamic>.from(rawIa))
          : null,
    );
  }

  String get nombreCompleto {
    final full = [nombre.trim(), apellido.trim()]
        .where((s) => s.isNotEmpty)
        .join(' ');
    return full.isNotEmpty ? full : 'Deportista';
  }

  String get iniciales {
    final n = nombre.trim().isNotEmpty ? nombre.trim()[0] : '';
    final a = apellido.trim().isNotEmpty ? apellido.trim()[0] : '';
    final ini = '$n$a'.toUpperCase();
    return ini.isNotEmpty ? ini : 'DP';
  }
}

/// Resumen de una sesión de análisis de IA (`GET /api/ia/vinculos/deportistas/<id>/sesiones`).
class DeportistaSesionResumen {
  final int id;
  final String tecnica;
  final int? puntuacion;
  final int totalRepeticiones;
  final int repeticionesValidas;
  final int? mejorPuntuacion;
  final int? duracionSeg;
  final String? nivel;
  final String? creadoEn;
  final bool revisadoPorEntrenador;
  final String? fechaRevision;

  const DeportistaSesionResumen({
    required this.id,
    required this.tecnica,
    this.puntuacion,
    required this.totalRepeticiones,
    required this.repeticionesValidas,
    this.mejorPuntuacion,
    this.duracionSeg,
    this.nivel,
    this.creadoEn,
    this.revisadoPorEntrenador = false,
    this.fechaRevision,
  });

  factory DeportistaSesionResumen.fromJson(Map<String, dynamic> json) {
    return DeportistaSesionResumen(
      id: _toInt(json['id']),
      tecnica: _toStr(json['tecnica'], 'remate'),
      puntuacion: _toNullableInt(json['puntuacion']),
      totalRepeticiones: _toInt(json['totalRepeticiones']),
      repeticionesValidas: _toInt(json['repeticionesValidas']),
      mejorPuntuacion: _toNullableInt(json['mejorPuntuacion']),
      duracionSeg: _toNullableInt(json['duracionSeg']),
      nivel: _toNullableStr(json['nivel']),
      creadoEn: _toNullableStr(json['creadoEn']),
      revisadoPorEntrenador: json['revisadoPorEntrenador'] == true,
      fechaRevision: _toNullableStr(json['fechaRevision']),
    );
  }

  bool get evaluada => repeticionesValidas > 0 && puntuacion != null;
}

class DeportistaErrorDetectado {
  final String medidaId;
  final String? nombre;
  final String? severidad;
  final int ocurrencias;
  final String? mensaje;
  final String? porQue;
  final String? ejercicio;
  final double? valorPromedio;
  final List<double>? ideal;

  const DeportistaErrorDetectado({
    required this.medidaId,
    this.nombre,
    this.severidad,
    required this.ocurrencias,
    this.mensaje,
    this.porQue,
    this.ejercicio,
    this.valorPromedio,
    this.ideal,
  });

  factory DeportistaErrorDetectado.fromJson(Map<String, dynamic> json) {
    return DeportistaErrorDetectado(
      medidaId: _toStr(json['medidaId'] ?? json['tipo_error']),
      nombre: _toNullableStr(json['nombre']),
      severidad: _toNullableStr(json['severidad']),
      ocurrencias: _toInt(json['ocurrencias'], 1),
      mensaje: _toNullableStr(json['mensaje'] ?? json['descripcion']),
      porQue: _toNullableStr(json['porQue']),
      ejercicio: _toNullableStr(json['ejercicio']),
      valorPromedio: _toNullableDouble(json['valorPromedio']),
      ideal: _toRango(json['ideal']),
    );
  }
}

class DeportistaPuntoMedida {
  final String? medidaId;
  final String nombre;
  final String? unidad;
  final bool aprobado;
  final double? valorPromedio;
  final double? anguloGrados;
  final List<double>? ideal;

  const DeportistaPuntoMedida({
    this.medidaId,
    required this.nombre,
    this.unidad,
    required this.aprobado,
    this.valorPromedio,
    this.anguloGrados,
    this.ideal,
  });

  factory DeportistaPuntoMedida.fromJson(Map<String, dynamic> json) {
    return DeportistaPuntoMedida(
      medidaId: _toNullableStr(json['medidaId']),
      nombre: _toStr(json['nombre']),
      unidad: _toNullableStr(json['unidad']),
      aprobado: json['aprobado'] == true,
      valorPromedio: _toNullableDouble(json['valorPromedio']),
      anguloGrados: _toNullableDouble(json['anguloGrados']),
      ideal: _toRango(json['ideal']),
    );
  }

  double? get valor => valorPromedio ?? anguloGrados;
}

class DeportistaMedidaRepeticion {
  final String id;
  final String nombre;
  final double? valor;
  final String? unidad;
  final String? estado;
  final List<double>? ideal;

  const DeportistaMedidaRepeticion({
    required this.id,
    required this.nombre,
    this.valor,
    this.unidad,
    this.estado,
    this.ideal,
  });

  factory DeportistaMedidaRepeticion.fromJson(Map<String, dynamic> json) {
    return DeportistaMedidaRepeticion(
      id: _toStr(json['id']),
      nombre: _toStr(json['nombre']),
      valor: _toNullableDouble(json['valor']),
      unidad: _toNullableStr(json['unidad']),
      estado: _toNullableStr(json['estado']),
      ideal: _toRango(json['ideal']),
    );
  }
}

class DeportistaRepeticion {
  final int numero;
  final bool valida;
  final int? puntuacion;
  final String? brazo;
  final String? motivo;
  final String? confianza;
  final int? fpsMedio;
  final String? principalMensaje;
  final List<String> fortalezas;
  final List<DeportistaMedidaRepeticion> medidas;

  const DeportistaRepeticion({
    required this.numero,
    required this.valida,
    this.puntuacion,
    this.brazo,
    this.motivo,
    this.confianza,
    this.fpsMedio,
    this.principalMensaje,
    this.fortalezas = const [],
    this.medidas = const [],
  });

  factory DeportistaRepeticion.fromJson(Map<String, dynamic> json) {
    final rec = json['recomendaciones'];
    String? principalMsg;
    List<String> forts = const [];
    if (rec is Map) {
      final p = rec['principal'];
      if (p is Map && p['mensaje'] != null) {
        principalMsg = p['mensaje'].toString();
      }
      final rawF = rec['fortalezas'];
      final rawE = rec['errores'];
      if (rawF is List && (rawE is! List || rawE.isEmpty)) {
        forts = rawF.map((e) => e.toString()).take(3).toList();
      }
    }
    final rawMedidas = json['medidas'];
    return DeportistaRepeticion(
      numero: _toInt(json['numero'], 1),
      valida: json['valida'] == true,
      puntuacion: _toNullableInt(json['puntuacion']),
      brazo: _toNullableStr(json['brazo']),
      motivo: _toNullableStr(json['motivo']),
      confianza: _toNullableStr(json['confianza']),
      fpsMedio: _toNullableInt(json['fpsMedio']),
      principalMensaje: principalMsg,
      fortalezas: forts,
      medidas: rawMedidas is List
          ? rawMedidas
              .whereType<Map>()
              .map(
                (m) => DeportistaMedidaRepeticion.fromJson(
                  Map<String, dynamic>.from(m),
                ),
              )
              .toList()
          : const [],
    );
  }
}

/// Detalle completo de una sesión de análisis (`GET /api/ia/vinculos/deportistas/<id>/sesiones/<sid>`).
class DeportistaSesionDetalle extends DeportistaSesionResumen {
  final List<DeportistaErrorDetectado> errores;
  final List<String> fortalezas;
  final List<DeportistaPuntoMedida> puntos;
  final List<DeportistaRepeticion> repeticiones;

  const DeportistaSesionDetalle({
    required super.id,
    required super.tecnica,
    super.puntuacion,
    required super.totalRepeticiones,
    required super.repeticionesValidas,
    super.mejorPuntuacion,
    super.duracionSeg,
    super.nivel,
    super.creadoEn,
    super.revisadoPorEntrenador,
    super.fechaRevision,
    this.errores = const [],
    this.fortalezas = const [],
    this.puntos = const [],
    this.repeticiones = const [],
  });

  factory DeportistaSesionDetalle.fromJson(Map<String, dynamic> json) {
    final base = DeportistaSesionResumen.fromJson(json);
    final rawErrores = json['errores'];
    final rawFortalezas = json['fortalezas'];
    final rawPuntos = json['puntos'];
    final rawReps = json['repeticiones'];
    return DeportistaSesionDetalle(
      id: base.id,
      tecnica: base.tecnica,
      puntuacion: base.puntuacion,
      totalRepeticiones: base.totalRepeticiones,
      repeticionesValidas: base.repeticionesValidas,
      mejorPuntuacion: base.mejorPuntuacion,
      duracionSeg: base.duracionSeg,
      nivel: base.nivel,
      creadoEn: base.creadoEn,
      revisadoPorEntrenador: base.revisadoPorEntrenador,
      fechaRevision: base.fechaRevision,
      errores: rawErrores is List
          ? rawErrores
              .whereType<Map>()
              .map(
                (e) => DeportistaErrorDetectado.fromJson(
                  Map<String, dynamic>.from(e),
                ),
              )
              .toList()
          : const [],
      fortalezas: rawFortalezas is List
          ? rawFortalezas.map((e) => e.toString()).toList()
          : const [],
      puntos: rawPuntos is List
          ? rawPuntos
              .whereType<Map>()
              .map(
                (p) => DeportistaPuntoMedida.fromJson(
                  Map<String, dynamic>.from(p),
                ),
              )
              .toList()
          : const [],
      repeticiones: rawReps is List
          ? rawReps
              .whereType<Map>()
              .map(
                (r) => DeportistaRepeticion.fromJson(
                  Map<String, dynamic>.from(r),
                ),
              )
              .toList()
          : const [],
    );
  }
}

const List<(String value, String label)> kDeportistaPosiciones = [
  ('todas', 'Todas'),
  ('armador', 'Armador'),
  ('punta', 'Punta'),
  ('central', 'Central'),
  ('opuesto', 'Opuesto'),
  ('libero', 'Líbero'),
];

const Map<String, String> kNombrePosicion = {
  'armador': 'Armador',
  'punta': 'Punta',
  'central': 'Central',
  'opuesto': 'Opuesto',
  'libero': 'Líbero',
};

const Map<String, String> kNombreNivel = {
  'principiante': 'Principiante',
  'intermedio': 'Intermedio',
  'avanzado': 'Avanzado',
  'profesional': 'Profesional',
};

String sinTildesDeportista(String text) {
  return text
      .toLowerCase()
      .replaceAll('á', 'a')
      .replaceAll('é', 'e')
      .replaceAll('í', 'i')
      .replaceAll('ó', 'o')
      .replaceAll('ú', 'u')
      .replaceAll('ü', 'u');
}

const List<String> _mesesCortos = [
  'ene',
  'feb',
  'mar',
  'abr',
  'may',
  'jun',
  'jul',
  'ago',
  'sep',
  'oct',
  'nov',
  'dic',
];

String formatFechaCortaDeportista(String? iso, {bool includeYear = true}) {
  if (iso == null || iso.trim().isEmpty) return '—';
  final dt = DateTime.tryParse(iso.trim())?.toLocal();
  if (dt == null) return '—';
  final m = _mesesCortos[(dt.month - 1).clamp(0, 11)];
  return includeYear ? '${dt.day} $m ${dt.year}' : '${dt.day} $m';
}

String formatFechaHoraDeportista(String? iso) {
  if (iso == null || iso.trim().isEmpty) return 'Fecha no disponible';
  final dt = DateTime.tryParse(iso.trim())?.toLocal();
  if (dt == null) return 'Fecha no disponible';
  final m = _mesesCortos[(dt.month - 1).clamp(0, 11)];
  final hh = dt.hour.toString().padLeft(2, '0');
  final mm = dt.minute.toString().padLeft(2, '0');
  return '${dt.day} $m ${dt.year}, $hh:$mm';
}

String? formatDuracionSeg(int? seg) {
  if (seg == null || seg <= 0) return null;
  final m = seg ~/ 60;
  final s = seg % 60;
  return m > 0 ? '$m min $s s' : '$s s';
}
