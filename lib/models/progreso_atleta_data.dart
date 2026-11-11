/// Modelos de respuesta para `GET /api/ia/progreso?tz=...`.
/// Respetan todos los `null` devueltos por el backend (`promedio`, `mejor`, `ultima`,
/// `variacion`, `siguiente`, `entrenador`, `detalle`) sin inventar valores por defecto.
class ProgresoAtletaResponse {
  final String? generadoEn;
  final ProgresoRacha racha;
  final List<ProgresoDiaSemana> semana;
  final List<ProgresoSemanaItem> semanas;
  final ProgresoAnalisis analisis;
  final ProgresoRutinas rutinas;
  final List<ProgresoLogro> logros;
  final ProgresoEntrenador? entrenador;
  final List<ProgresoEventoReciente> reciente;

  const ProgresoAtletaResponse({
    required this.generadoEn,
    required this.racha,
    required this.semana,
    required this.semanas,
    required this.analisis,
    required this.rutinas,
    required this.logros,
    required this.entrenador,
    required this.reciente,
  });

  factory ProgresoAtletaResponse.fromJson(Map<String, dynamic> json) {
    final rachaMap = json['racha'];
    final analisisMap = json['analisis'];
    final rutinasMap = json['rutinas'];
    final entrenadorMap = json['entrenador'];

    return ProgresoAtletaResponse(
      generadoEn: json['generadoEn']?.toString(),
      racha: rachaMap is Map
          ? ProgresoRacha.fromJson(Map<String, dynamic>.from(rachaMap))
          : const ProgresoRacha(actual: 0, mejor: 0, activoHoy: false),
      semana: _parseMapList(json['semana'], ProgresoDiaSemana.fromJson),
      semanas: _parseMapList(json['semanas'], ProgresoSemanaItem.fromJson),
      analisis: analisisMap is Map
          ? ProgresoAnalisis.fromJson(Map<String, dynamic>.from(analisisMap))
          : const ProgresoAnalisis(
              sesiones: 0,
              promedio: null,
              mejor: null,
              ultima: null,
              variacion: null,
              evolucion: [],
              porTecnica: [],
            ),
      rutinas: rutinasMap is Map
          ? ProgresoRutinas.fromJson(Map<String, dynamic>.from(rutinasMap))
          : const ProgresoRutinas(
              asignadas: 0,
              completadas: 0,
              pendientes: 0,
              ejerciciosTotal: 0,
              ejerciciosHechos: 0,
              porcentaje: 0,
              siguiente: null,
            ),
      logros: _parseMapList(json['logros'], ProgresoLogro.fromJson),
      entrenador: entrenadorMap is Map
          ? ProgresoEntrenador.fromJson(
              Map<String, dynamic>.from(entrenadorMap),
            )
          : null,
      reciente: _parseMapList(
        json['reciente'],
        ProgresoEventoReciente.fromJson,
      ),
    );
  }
}

class ProgresoRacha {
  final int actual;
  final int mejor;
  final bool activoHoy;

  const ProgresoRacha({
    required this.actual,
    required this.mejor,
    required this.activoHoy,
  });

  factory ProgresoRacha.fromJson(Map<String, dynamic> json) {
    return ProgresoRacha(
      actual: _toInt(json['actual']) ?? 0,
      mejor: _toInt(json['mejor']) ?? 0,
      activoHoy: json['activoHoy'] == true,
    );
  }
}

class ProgresoDiaSemana {
  final String fecha;
  final String dia;
  final int sesiones;
  final int ejercicios;
  final bool activo;
  final bool hoy;
  final bool futuro;

  const ProgresoDiaSemana({
    required this.fecha,
    required this.dia,
    required this.sesiones,
    required this.ejercicios,
    required this.activo,
    required this.hoy,
    required this.futuro,
  });

  factory ProgresoDiaSemana.fromJson(Map<String, dynamic> json) {
    return ProgresoDiaSemana(
      fecha: (json['fecha'] ?? '').toString(),
      dia: (json['dia'] ?? '').toString(),
      sesiones: _toInt(json['sesiones']) ?? 0,
      ejercicios: _toInt(json['ejercicios']) ?? 0,
      activo: json['activo'] == true,
      hoy: json['hoy'] == true,
      futuro: json['futuro'] == true,
    );
  }
}

class ProgresoSemanaItem {
  final String semana;
  final int sesiones;
  final int ejercicios;

  const ProgresoSemanaItem({
    required this.semana,
    required this.sesiones,
    required this.ejercicios,
  });

  factory ProgresoSemanaItem.fromJson(Map<String, dynamic> json) {
    return ProgresoSemanaItem(
      semana: (json['semana'] ?? '').toString(),
      sesiones: _toInt(json['sesiones']) ?? 0,
      ejercicios: _toInt(json['ejercicios']) ?? 0,
    );
  }
}

class ProgresoAnalisis {
  final int sesiones;
  final int? promedio;
  final int? mejor;
  final int? ultima;
  final int? variacion;
  final List<ProgresoPuntoEvolucion> evolucion;
  final List<ProgresoPorTecnica> porTecnica;

  const ProgresoAnalisis({
    required this.sesiones,
    required this.promedio,
    required this.mejor,
    required this.ultima,
    required this.variacion,
    required this.evolucion,
    required this.porTecnica,
  });

  factory ProgresoAnalisis.fromJson(Map<String, dynamic> json) {
    return ProgresoAnalisis(
      sesiones: _toInt(json['sesiones']) ?? 0,
      promedio: _toInt(json['promedio']),
      mejor: _toInt(json['mejor']),
      ultima: _toInt(json['ultima']),
      variacion: _toInt(json['variacion']),
      evolucion: _parseMapList(
        json['evolucion'],
        ProgresoPuntoEvolucion.fromJson,
      ),
      porTecnica: _parseMapList(
        json['porTecnica'],
        ProgresoPorTecnica.fromJson,
      ),
    );
  }
}

class ProgresoPuntoEvolucion {
  final String? creadoEn;
  final double puntuacion;
  final String tecnica;

  const ProgresoPuntoEvolucion({
    required this.creadoEn,
    required this.puntuacion,
    required this.tecnica,
  });

  factory ProgresoPuntoEvolucion.fromJson(Map<String, dynamic> json) {
    return ProgresoPuntoEvolucion(
      creadoEn: json['creadoEn']?.toString(),
      puntuacion: double.tryParse((json['puntuacion'] ?? '').toString()) ?? 0,
      tecnica: (json['tecnica'] ?? '').toString(),
    );
  }
}

class ProgresoPorTecnica {
  final String tecnica;
  final int sesiones;
  final int? promedio;
  final int? mejor;

  const ProgresoPorTecnica({
    required this.tecnica,
    required this.sesiones,
    required this.promedio,
    required this.mejor,
  });

  factory ProgresoPorTecnica.fromJson(Map<String, dynamic> json) {
    return ProgresoPorTecnica(
      tecnica: (json['tecnica'] ?? '').toString(),
      sesiones: _toInt(json['sesiones']) ?? 0,
      promedio: _toInt(json['promedio']),
      mejor: _toInt(json['mejor']),
    );
  }
}

class ProgresoRutinas {
  final int asignadas;
  final int completadas;
  final int pendientes;
  final int ejerciciosTotal;
  final int ejerciciosHechos;
  final int porcentaje;
  final ProgresoSiguienteRutina? siguiente;

  const ProgresoRutinas({
    required this.asignadas,
    required this.completadas,
    required this.pendientes,
    required this.ejerciciosTotal,
    required this.ejerciciosHechos,
    required this.porcentaje,
    required this.siguiente,
  });

  factory ProgresoRutinas.fromJson(Map<String, dynamic> json) {
    final sig = json['siguiente'];
    return ProgresoRutinas(
      asignadas: _toInt(json['asignadas']) ?? 0,
      completadas: _toInt(json['completadas']) ?? 0,
      pendientes: _toInt(json['pendientes']) ?? 0,
      ejerciciosTotal: _toInt(json['ejerciciosTotal']) ?? 0,
      ejerciciosHechos: _toInt(json['ejerciciosHechos']) ?? 0,
      porcentaje: _toInt(json['porcentaje']) ?? 0,
      siguiente: sig is Map
          ? ProgresoSiguienteRutina.fromJson(Map<String, dynamic>.from(sig))
          : null,
    );
  }
}

class ProgresoSiguienteRutina {
  final int? id;
  final String nombre;
  final String? fecha;
  final int total;
  final int hechos;
  final bool vencida;

  const ProgresoSiguienteRutina({
    required this.id,
    required this.nombre,
    required this.fecha,
    required this.total,
    required this.hechos,
    required this.vencida,
  });

  factory ProgresoSiguienteRutina.fromJson(Map<String, dynamic> json) {
    return ProgresoSiguienteRutina(
      id: _toInt(json['id']),
      nombre: (json['nombre'] ?? '').toString(),
      fecha: json['fecha']?.toString(),
      total: _toInt(json['total']) ?? 0,
      hechos: _toInt(json['hechos']) ?? 0,
      vencida: json['vencida'] == true,
    );
  }
}

class ProgresoLogro {
  final String id;
  final String titulo;
  final String detalle;
  final int valor;
  final int meta;
  final bool conseguido;

  const ProgresoLogro({
    required this.id,
    required this.titulo,
    required this.detalle,
    required this.valor,
    required this.meta,
    required this.conseguido,
  });

  factory ProgresoLogro.fromJson(Map<String, dynamic> json) {
    return ProgresoLogro(
      id: (json['id'] ?? '').toString(),
      titulo: (json['titulo'] ?? '').toString(),
      detalle: (json['detalle'] ?? '').toString(),
      valor: _toInt(json['valor']) ?? 0,
      meta: _toInt(json['meta']) ?? 1,
      conseguido: json['conseguido'] == true,
    );
  }
}

class ProgresoEntrenador {
  final String estado;
  final String nombre;

  const ProgresoEntrenador({
    required this.estado,
    required this.nombre,
  });

  factory ProgresoEntrenador.fromJson(Map<String, dynamic> json) {
    return ProgresoEntrenador(
      estado: (json['estado'] ?? '').toString(),
      nombre: (json['nombre'] ?? '').toString(),
    );
  }
}

class ProgresoEventoReciente {
  final String tipo;
  final String titulo;
  final String? detalle;
  final String? creadoEn;

  const ProgresoEventoReciente({
    required this.tipo,
    required this.titulo,
    required this.detalle,
    required this.creadoEn,
  });

  factory ProgresoEventoReciente.fromJson(Map<String, dynamic> json) {
    final det = json['detalle']?.toString().trim();
    return ProgresoEventoReciente(
      tipo: (json['tipo'] ?? '').toString(),
      titulo: (json['titulo'] ?? '').toString(),
      detalle: (det != null && det.isNotEmpty) ? det : null,
      creadoEn: json['creadoEn']?.toString(),
    );
  }
}

List<T> _parseMapList<T>(
  dynamic raw,
  T Function(Map<String, dynamic>) builder,
) {
  if (raw is! List) return const [];
  return raw
      .whereType<Map>()
      .map((e) => builder(Map<String, dynamic>.from(e)))
      .toList();
}

int? _toInt(dynamic v) {
  if (v == null) return null;
  if (v is int) return v;
  if (v is num) return v.round();
  return int.tryParse(v.toString());
}
