/// Modelos de respuesta para `GET /api/usuario/dashboard/` y `GET /api/ia/avisos/contador`.
/// Respetan todos los `null` devueltos por el backend sin inventar valores por defecto.
class DashboardResponse {
  final String? usuarioNombre;
  final DashboardProgreso progreso;
  final DashboardSesiones sesiones;
  final int? rachaDias;
  final DashboardUltimoAnalisis? ultimoAnalisis;
  final DashboardRutinaDia? rutinaDelDia;
  final int? notificacionesSinLeer;

  const DashboardResponse({
    required this.usuarioNombre,
    required this.progreso,
    required this.sesiones,
    required this.rachaDias,
    required this.ultimoAnalisis,
    required this.rutinaDelDia,
    required this.notificacionesSinLeer,
  });

  factory DashboardResponse.fromJson(Map<String, dynamic> json) {
    final usuarioMap = json['usuario'];
    final nombre = usuarioMap is Map
        ? usuarioMap['nombre']?.toString().trim()
        : null;

    final progMap = json['progreso'];
    final sesMap = json['sesiones'];
    final ultimoMap = json['ultimo_analisis'];
    final rutinaMap = json['rutina_del_dia'];

    return DashboardResponse(
      usuarioNombre: (nombre != null && nombre.isNotEmpty) ? nombre : null,
      progreso: progMap is Map
          ? DashboardProgreso.fromJson(Map<String, dynamic>.from(progMap))
          : const DashboardProgreso(
              valor: null,
              variacion: null,
              tendencia: [],
            ),
      sesiones: sesMap is Map
          ? DashboardSesiones.fromJson(Map<String, dynamic>.from(sesMap))
          : const DashboardSesiones(semana: null, variacion: null),
      rachaDias: _parseInt(json['racha_dias']),
      ultimoAnalisis: ultimoMap is Map
          ? DashboardUltimoAnalisis.fromJson(
              Map<String, dynamic>.from(ultimoMap),
            )
          : null,
      rutinaDelDia: rutinaMap is Map
          ? DashboardRutinaDia.fromJson(Map<String, dynamic>.from(rutinaMap))
          : null,
      notificacionesSinLeer: _parseInt(json['notificaciones_sin_leer']),
    );
  }
}

class DashboardProgreso {
  final int? valor;
  final num? variacion;
  final List<double> tendencia;

  const DashboardProgreso({
    required this.valor,
    required this.variacion,
    required this.tendencia,
  });

  factory DashboardProgreso.fromJson(Map<String, dynamic> json) {
    final rawTendencia = json['tendencia'];
    final list = rawTendencia is List
        ? rawTendencia
              .map((e) => double.tryParse(e.toString()))
              .whereType<double>()
              .toList()
        : const <double>[];

    return DashboardProgreso(
      valor: _parseInt(json['valor']),
      variacion: _parseNum(json['variacion']),
      tendencia: list,
    );
  }
}

class DashboardSesiones {
  final int? semana;
  final num? variacion;

  const DashboardSesiones({
    required this.semana,
    required this.variacion,
  });

  factory DashboardSesiones.fromJson(Map<String, dynamic> json) {
    return DashboardSesiones(
      semana: _parseInt(json['semana']),
      variacion: _parseNum(json['variacion']),
    );
  }
}

class DashboardUltimoAnalisis {
  final int? id;
  final String tecnica;
  final int? puntuacion;
  final String? miniaturaUrl;
  final String? creadoEn;

  const DashboardUltimoAnalisis({
    required this.id,
    required this.tecnica,
    required this.puntuacion,
    required this.miniaturaUrl,
    required this.creadoEn,
  });

  factory DashboardUltimoAnalisis.fromJson(Map<String, dynamic> json) {
    final rawMiniatura = json['miniatura_url']?.toString().trim();
    return DashboardUltimoAnalisis(
      id: _parseInt(json['id']),
      tecnica: (json['tecnica'] ?? '').toString(),
      puntuacion: _parseInt(json['puntuacion']),
      miniaturaUrl:
          (rawMiniatura != null && rawMiniatura.isNotEmpty) ? rawMiniatura : null,
      creadoEn: json['creado_en']?.toString(),
    );
  }
}

class DashboardRutinaDia {
  final int? id;
  final String nombre;
  final int? totalEjercicios;
  final int? completados;

  const DashboardRutinaDia({
    required this.id,
    required this.nombre,
    required this.totalEjercicios,
    required this.completados,
  });

  factory DashboardRutinaDia.fromJson(Map<String, dynamic> json) {
    return DashboardRutinaDia(
      id: _parseInt(json['id']),
      nombre: (json['nombre'] ?? '').toString(),
      totalEjercicios: _parseInt(json['total_ejercicios']),
      completados: _parseInt(json['completados']),
    );
  }
}

class AvisosContadorResponse {
  final int noLeidas;

  const AvisosContadorResponse({required this.noLeidas});

  factory AvisosContadorResponse.fromJson(Map<String, dynamic> json) {
    return AvisosContadorResponse(
      noLeidas: _parseInt(json['noLeidas']) ?? 0,
    );
  }
}

int? _parseInt(dynamic v) {
  if (v == null) return null;
  if (v is int) return v;
  if (v is num) return v.round();
  return int.tryParse(v.toString());
}

num? _parseNum(dynamic v) {
  if (v == null) return null;
  if (v is num) return v;
  return num.tryParse(v.toString());
}
