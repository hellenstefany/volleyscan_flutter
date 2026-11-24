/// Modelos de la pantalla "Estadísticas" del Panel de Entrenador
/// (`/panel_entrenador/estadisticas`), alineados con
/// `Backend_VolleyScan/vinculos/estadisticas.py` y `VolleyScan_Next`.
library;

const List<({int dias, String corto, String largo})> kEstadisticasPeriodos = [
  (dias: 7, corto: '7 días', largo: 'los últimos 7 días'),
  (dias: 30, corto: '30 días', largo: 'los últimos 30 días'),
  (dias: 90, corto: '90 días', largo: 'los últimos 90 días'),
  (dias: 180, corto: '6 meses', largo: 'los últimos 6 meses'),
];

const Map<String, String> kEstadisticasTecnicas = {
  'remate': 'Remate',
  'saque': 'Saque',
  'recepcion': 'Recepción',
  'bloqueo': 'Bloqueo',
  'pase': 'Pase',
};

const Map<String, String> kEstadisticasSeveridad = {'leve': 'Leve', 'moderado': 'Moderado', 'grave': 'Grave'};
const Map<String, String> kEstadisticasEstados = {'activo': 'Activo', 'inactivo': 'Inactivo', 'sin_datos': 'Sin datos'};

class CoachStatsTeamRef {
  final int id;
  final String nombre;
  const CoachStatsTeamRef({required this.id, required this.nombre});

  factory CoachStatsTeamRef.fromJson(Map<String, dynamic> j) =>
      CoachStatsTeamRef(id: _toInt(j['id']) ?? 0, nombre: (j['nombre'] ?? '').toString().trim());
}

class CoachStatsPeriod {
  final int dias;
  final String desde, hasta, previoDesde;
  const CoachStatsPeriod({required this.dias, required this.desde, required this.hasta, required this.previoDesde});

  factory CoachStatsPeriod.fromJson(Map<String, dynamic> j) => CoachStatsPeriod(
        dias: _toInt(j['dias']) ?? 30,
        desde: (j['desde'] ?? '').toString().trim(),
        hasta: (j['hasta'] ?? '').toString().trim(),
        previoDesde: (j['previoDesde'] ?? '').toString().trim(),
      );
}

class CoachStatsKpis {
  final int deportistas, activos, analisis, analisisDelta;
  final int ejerciciosHechos, ejerciciosTotales, porRevisar;
  final int asistenciaPresentes, asistenciaAusencias, asistenciaJustificadas;
  final int? puntuacionMedia, puntuacionDelta, cumplimiento, cumplimientoDelta, asistencia, asistenciaDelta;

  const CoachStatsKpis({
    this.deportistas = 0,
    this.activos = 0,
    this.analisis = 0,
    this.analisisDelta = 0,
    this.puntuacionMedia,
    this.puntuacionDelta,
    this.cumplimiento,
    this.cumplimientoDelta,
    this.ejerciciosHechos = 0,
    this.ejerciciosTotales = 0,
    this.porRevisar = 0,
    this.asistencia,
    this.asistenciaDelta,
    this.asistenciaPresentes = 0,
    this.asistenciaAusencias = 0,
    this.asistenciaJustificadas = 0,
  });

  factory CoachStatsKpis.fromJson(Map<String, dynamic> j) => CoachStatsKpis(
        deportistas: _toInt(j['deportistas']) ?? 0,
        activos: _toInt(j['activos']) ?? 0,
        analisis: _toInt(j['analisis']) ?? 0,
        analisisDelta: _toInt(j['analisisDelta']) ?? 0,
        puntuacionMedia: _toInt(j['puntuacionMedia']),
        puntuacionDelta: _toInt(j['puntuacionDelta']),
        cumplimiento: _toInt(j['cumplimiento']),
        cumplimientoDelta: _toInt(j['cumplimientoDelta']),
        ejerciciosHechos: _toInt(j['ejerciciosHechos']) ?? 0,
        ejerciciosTotales: _toInt(j['ejerciciosTotales']) ?? 0,
        porRevisar: _toInt(j['porRevisar']) ?? 0,
        asistencia: _toInt(j['asistencia']),
        asistenciaDelta: _toInt(j['asistenciaDelta']),
        asistenciaPresentes: _toInt(j['asistenciaPresentes']) ?? 0,
        asistenciaAusencias: _toInt(j['asistenciaAusencias']) ?? 0,
        asistenciaJustificadas: _toInt(j['asistenciaJustificadas']) ?? 0,
      );
}

class CoachStatsPoint {
  final String desde, hasta;
  final int sesiones;
  final int? promedio;
  const CoachStatsPoint({required this.desde, required this.hasta, this.sesiones = 0, this.promedio});

  factory CoachStatsPoint.fromJson(Map<String, dynamic> j) => CoachStatsPoint(
        desde: (j['desde'] ?? '').toString().trim(),
        hasta: (j['hasta'] ?? '').toString().trim(),
        sesiones: _toInt(j['sesiones']) ?? 0,
        promedio: _toInt(j['promedio']),
      );
}

class CoachStatsTechnique {
  final String tecnica;
  final int sesiones;
  final int? promedio, delta, mejor;
  const CoachStatsTechnique({required this.tecnica, this.sesiones = 0, this.promedio, this.delta, this.mejor});

  String get label => kEstadisticasTecnicas[tecnica] ?? tecnica;

  factory CoachStatsTechnique.fromJson(Map<String, dynamic> j) => CoachStatsTechnique(
        tecnica: (j['tecnica'] ?? '').toString().trim(),
        sesiones: _toInt(j['sesiones']) ?? 0,
        promedio: _toInt(j['promedio']),
        delta: _toInt(j['delta']),
        mejor: _toInt(j['mejor']),
      );
}

class CoachStatsRankingItem {
  final int id, sesiones, ejerciciosHechos, ejerciciosTotales;
  final int asistio, falto, justificadas, eventosConLista, porRevisar;
  final String nombre, apellido, estado;
  final String? fotoUrl, posicion, nivel, ultimaActividad;
  final int? promedio, mejor, delta, cumplimiento, asistencia, diasSinActividad;

  const CoachStatsRankingItem({
    required this.id,
    required this.nombre,
    required this.apellido,
    this.fotoUrl,
    this.posicion,
    this.nivel,
    this.sesiones = 0,
    this.promedio,
    this.mejor,
    this.delta,
    this.cumplimiento,
    this.ejerciciosHechos = 0,
    this.ejerciciosTotales = 0,
    this.asistencia,
    this.asistio = 0,
    this.falto = 0,
    this.justificadas = 0,
    this.eventosConLista = 0,
    this.ultimaActividad,
    this.diasSinActividad,
    this.estado = 'sin_datos',
    this.porRevisar = 0,
  });

  String get nombreCompleto => [nombre.trim(), apellido.trim()].where((s) => s.isNotEmpty).join(' ');
  String get iniciales {
    final c1 = nombre.trim().isNotEmpty ? nombre.trim()[0] : '';
    final c2 = apellido.trim().isNotEmpty ? apellido.trim()[0] : '';
    return ('$c1$c2').isNotEmpty ? '$c1$c2'.toUpperCase() : '?';
  }

  factory CoachStatsRankingItem.fromJson(Map<String, dynamic> j) => CoachStatsRankingItem(
        id: _toInt(j['id']) ?? 0,
        nombre: (j['nombre'] ?? '').toString().trim(),
        apellido: (j['apellido'] ?? '').toString().trim(),
        fotoUrl: _optionalText(j['fotoUrl']),
        posicion: _optionalText(j['posicion']),
        nivel: _optionalText(j['nivel']),
        sesiones: _toInt(j['sesiones']) ?? 0,
        promedio: _toInt(j['promedio']),
        mejor: _toInt(j['mejor']),
        delta: _toInt(j['delta']),
        cumplimiento: _toInt(j['cumplimiento']),
        ejerciciosHechos: _toInt(j['ejerciciosHechos']) ?? 0,
        ejerciciosTotales: _toInt(j['ejerciciosTotales']) ?? 0,
        asistencia: _toInt(j['asistencia']),
        asistio: _toInt(j['asistio']) ?? 0,
        falto: _toInt(j['falto']) ?? 0,
        justificadas: _toInt(j['justificadas']) ?? 0,
        eventosConLista: _toInt(j['eventosConLista']) ?? 0,
        ultimaActividad: _optionalText(j['ultimaActividad']),
        diasSinActividad: _toInt(j['diasSinActividad']),
        estado: (j['estado'] ?? 'sin_datos').toString().trim(),
        porRevisar: _toInt(j['porRevisar']) ?? 0,
      );
}

class CoachStatsErrorItem {
  final String nombre, severidad;
  final int sesiones, atletas, ocurrencias;
  final double? impacto;

  const CoachStatsErrorItem({required this.nombre, this.severidad = 'leve', this.sesiones = 0, this.atletas = 0, this.ocurrencias = 0, this.impacto});

  factory CoachStatsErrorItem.fromJson(Map<String, dynamic> j) => CoachStatsErrorItem(
        nombre: (j['nombre'] ?? '').toString().trim(),
        severidad: (j['severidad'] ?? 'leve').toString().trim(),
        sesiones: _toInt(j['sesiones']) ?? 0,
        atletas: _toInt(j['atletas']) ?? 0,
        ocurrencias: _toInt(j['ocurrencias']) ?? 0,
        impacto: j['impacto'] is num ? (j['impacto'] as num).toDouble() : null,
      );
}

class CoachStatsAlertItem {
  final String tipo, nombre;
  final int atletaId;
  final int? dias, delta, faltas, de, porcentaje, cantidad;

  const CoachStatsAlertItem({required this.tipo, required this.atletaId, required this.nombre, this.dias, this.delta, this.faltas, this.de, this.porcentaje, this.cantidad});

  int get orden => switch (tipo) {
        'baja' || 'inasistencia' => 0,
        'inactivo' || 'asistencia_baja' => 1,
        'sin_actividad' => 2,
        'por_revisar' => 3,
        _ => 4,
      };

  String get descripcion => switch (tipo) {
        'baja' => '$nombre bajó ${(delta ?? 0).abs()} puntos de promedio',
        'inactivo' => '$nombre lleva ${dias ?? 0} días sin actividad',
        'sin_actividad' => '$nombre aún no tiene actividad',
        'por_revisar' => '$nombre tiene ${cantidad ?? 0} análisis sin revisar',
        'inasistencia' => '$nombre faltó a ${faltas ?? 0} de sus últimos ${de ?? 0} eventos',
        'asistencia_baja' => '$nombre asiste solo al ${porcentaje ?? 0}% de los eventos',
        'sin_rutina' => '$nombre no tiene rutinas pendientes',
        _ => nombre,
      };

  factory CoachStatsAlertItem.fromJson(Map<String, dynamic> j) => CoachStatsAlertItem(
        tipo: (j['tipo'] ?? '').toString().trim(),
        atletaId: _toInt(j['atletaId']) ?? 0,
        nombre: (j['nombre'] ?? '').toString().trim(),
        dias: _toInt(j['dias']),
        delta: _toInt(j['delta']),
        faltas: _toInt(j['faltas']),
        de: _toInt(j['de']),
        porcentaje: _toInt(j['porcentaje']),
        cantidad: _toInt(j['cantidad']),
      );
}

class CoachStatsResponse {
  final CoachStatsPeriod periodo;
  final CoachStatsTeamRef? equipo;
  final List<CoachStatsTeamRef> equipos;
  final String generado;
  final CoachStatsKpis kpis;
  final List<CoachStatsPoint> evolucion;
  final List<CoachStatsTechnique> porTecnica;
  final List<CoachStatsRankingItem> ranking;
  final List<CoachStatsErrorItem> erroresFrecuentes;
  final List<CoachStatsAlertItem> alertas;

  const CoachStatsResponse({
    required this.periodo,
    this.equipo,
    this.equipos = const <CoachStatsTeamRef>[],
    this.generado = '',
    this.kpis = const CoachStatsKpis(),
    this.evolucion = const <CoachStatsPoint>[],
    this.porTecnica = const <CoachStatsTechnique>[],
    this.ranking = const <CoachStatsRankingItem>[],
    this.erroresFrecuentes = const <CoachStatsErrorItem>[],
    this.alertas = const <CoachStatsAlertItem>[],
  });

  factory CoachStatsResponse.fromJson(Map<String, dynamic> j) => CoachStatsResponse(
        periodo: j['periodo'] is Map ? CoachStatsPeriod.fromJson(Map<String, dynamic>.from(j['periodo'] as Map)) : const CoachStatsPeriod(dias: 30, desde: '', hasta: '', previoDesde: ''),
        equipo: j['equipo'] is Map ? CoachStatsTeamRef.fromJson(Map<String, dynamic>.from(j['equipo'] as Map)) : null,
        equipos: _mapList(j['equipos'], CoachStatsTeamRef.fromJson),
        generado: (j['generado'] ?? '').toString().trim(),
        kpis: j['kpis'] is Map ? CoachStatsKpis.fromJson(Map<String, dynamic>.from(j['kpis'] as Map)) : const CoachStatsKpis(),
        evolucion: _mapList(j['evolucion'], CoachStatsPoint.fromJson),
        porTecnica: _mapList(j['porTecnica'], CoachStatsTechnique.fromJson),
        ranking: _mapList(j['ranking'], CoachStatsRankingItem.fromJson),
        erroresFrecuentes: _mapList(j['erroresFrecuentes'], CoachStatsErrorItem.fromJson),
        alertas: _mapList(j['alertas'], CoachStatsAlertItem.fromJson),
      );
}

List<T> _mapList<T>(dynamic raw, T Function(Map<String, dynamic>) fn) =>
    raw is List ? raw.whereType<Map>().map((m) => fn(Map<String, dynamic>.from(m))).toList() : <T>[];

int? _toInt(dynamic v) => v == null ? null : (v is num ? v.toInt() : int.tryParse(v.toString()));
String? _optionalText(dynamic v) {
  final s = v?.toString().trim();
  return (s == null || s.isEmpty) ? null : s;
}

const _mesesCortoStats = <String>['ene', 'feb', 'mar', 'abr', 'may', 'jun', 'jul', 'ago', 'sep', 'oct', 'nov', 'dic'];

String formatStatsShortDate(String iso) {
  final p = iso.split('-');
  if (p.length != 3) return iso.isEmpty ? '—' : iso;
  final m = int.tryParse(p[1]), d = int.tryParse(p[2]);
  if (m == null || d == null || m < 1 || m > 12) return iso;
  return '$d ${_mesesCortoStats[m - 1]}';
}
