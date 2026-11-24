import 'equipo.dart';
import 'my_matches_data.dart';

/// Modelos de la pantalla "Partidos" del Panel de Entrenador
/// (`/panel_entrenador/partidos`), alineados con
/// `Backend_VolleyScan/vinculos/partidos.py` y `VolleyScan_Next`.
const List<({String k, String t, String ayuda})> kPartidoCamposStat = [
  (k: 'ataquesExitosos', t: 'Ataques +', ayuda: 'Ataques que terminaron en punto'),
  (k: 'ataquesFallidos', t: 'Ataques −', ayuda: 'Ataques fallados o bloqueados'),
  (k: 'bloqueos', t: 'Bloqueos', ayuda: 'Bloqueos que suman punto'),
  (k: 'saquesExitosos', t: 'Aces', ayuda: 'Saques directos a punto'),
  (k: 'saquesFallidos', t: 'Saque ✗', ayuda: 'Errores de saque'),
  (k: 'recepcionesExitosas', t: 'Recep. +', ayuda: 'Recepciones buenas'),
  (k: 'recepcionesFalladas', t: 'Recep. −', ayuda: 'Recepciones falladas'),
  (k: 'erroresNoForzados', t: 'Errores', ayuda: 'Errores no forzados'),
];

class CoachMatchesSummary {
  final int jugados, ganados, perdidos, setsGanados, setsPerdidos;
  final int? porcentajeVictorias;

  const CoachMatchesSummary({
    this.jugados = 0,
    this.ganados = 0,
    this.perdidos = 0,
    this.setsGanados = 0,
    this.setsPerdidos = 0,
    this.porcentajeVictorias,
  });

  factory CoachMatchesSummary.fromJson(Map<String, dynamic> j) =>
      CoachMatchesSummary(
        jugados: _toInt(j['jugados']) ?? 0,
        ganados: _toInt(j['ganados']) ?? 0,
        perdidos: _toInt(j['perdidos']) ?? 0,
        setsGanados: _toInt(j['setsGanados']) ?? 0,
        setsPerdidos: _toInt(j['setsPerdidos']) ?? 0,
        porcentajeVictorias: _toInt(j['porcentajeVictorias']),
      );
}

class CoachMatchListItem {
  final int id, equipoId, setsGanados, setsPerdidos, jugadores, puntosEquipo;
  final int? horarioId;
  final String equipo, rival, fecha, resultado;
  final String? ubicacion;

  const CoachMatchListItem({
    required this.id,
    required this.equipoId,
    required this.equipo,
    this.horarioId,
    required this.rival,
    required this.fecha,
    required this.setsGanados,
    required this.setsPerdidos,
    required this.resultado,
    this.ubicacion,
    this.jugadores = 0,
    this.puntosEquipo = 0,
  });

  bool get esVictoria => resultado == 'victoria';

  factory CoachMatchListItem.fromJson(Map<String, dynamic> j) =>
      CoachMatchListItem(
        id: _toInt(j['id']) ?? 0,
        equipoId: _toInt(j['equipoId']) ?? 0,
        equipo: (j['equipo'] ?? '').toString().trim(),
        horarioId: _toInt(j['horarioId']),
        rival: (j['rival'] ?? '').toString().trim(),
        fecha: (j['fecha'] ?? '').toString().trim(),
        setsGanados: _toInt(j['setsGanados']) ?? 0,
        setsPerdidos: _toInt(j['setsPerdidos']) ?? 0,
        resultado: (j['resultado'] ?? 'derrota').toString().trim(),
        ubicacion: _optionalText(j['ubicacion']),
        jugadores: _toInt(j['jugadores']) ?? 0,
        puntosEquipo: _toInt(j['puntosEquipo']) ?? 0,
      );
}

class CoachMatchesListResponse {
  final List<CoachMatchListItem> partidos;
  final CoachMatchesSummary resumen;

  const CoachMatchesListResponse({
    this.partidos = const <CoachMatchListItem>[],
    this.resumen = const CoachMatchesSummary(),
  });

  factory CoachMatchesListResponse.fromJson(Map<String, dynamic> j) {
    final rawP = j['partidos'];
    final rawR = j['resumen'];
    return CoachMatchesListResponse(
      partidos: rawP is List
          ? rawP
              .whereType<Map>()
              .map((m) => CoachMatchListItem.fromJson(Map<String, dynamic>.from(m)))
              .toList()
          : const <CoachMatchListItem>[],
      resumen: rawR is Map
          ? CoachMatchesSummary.fromJson(Map<String, dynamic>.from(rawR))
          : const CoachMatchesSummary(),
    );
  }
}

class CoachMatchPlayerStat {
  final int deportistaId;
  final String nombre, apellido;
  final String? fotoUrl, posicion, observacion;
  final int? numeroCamiseta;
  final MatchStats stats;

  const CoachMatchPlayerStat({
    required this.deportistaId,
    required this.nombre,
    required this.apellido,
    this.fotoUrl,
    this.posicion,
    this.numeroCamiseta,
    this.observacion,
    required this.stats,
  });

  String get nombreCompleto =>
      [nombre.trim(), apellido.trim()].where((s) => s.isNotEmpty).join(' ');
  String get iniciales => buildEquipoInitials(nombre, apellido);

  factory CoachMatchPlayerStat.fromJson(Map<String, dynamic> j) =>
      CoachMatchPlayerStat(
        deportistaId: _toInt(j['deportistaId']) ?? 0,
        nombre: (j['nombre'] ?? '').toString().trim(),
        apellido: (j['apellido'] ?? '').toString().trim(),
        fotoUrl: _optionalText(j['fotoUrl']),
        posicion: _optionalText(j['posicion']),
        numeroCamiseta: _toInt(j['numeroCamiseta']),
        observacion: _optionalText(j['observacion']),
        stats: MatchStats.fromJson(j),
      );
}

class CoachMatchDetail {
  final int id, equipoId, setsGanados, setsPerdidos;
  final int? horarioId;
  final String equipo, rival, fecha, resultado;
  final String? ubicacion, notas;
  final List<CoachMatchPlayerStat> jugadores;
  final MatchStats totales;

  const CoachMatchDetail({
    required this.id,
    required this.equipoId,
    required this.equipo,
    this.horarioId,
    required this.rival,
    required this.fecha,
    required this.setsGanados,
    required this.setsPerdidos,
    required this.resultado,
    this.ubicacion,
    this.notas,
    this.jugadores = const <CoachMatchPlayerStat>[],
    this.totales = const MatchStats(),
  });

  bool get esVictoria => resultado == 'victoria';

  factory CoachMatchDetail.fromJson(Map<String, dynamic> j) {
    final rawJ = j['jugadores'];
    final rawT = j['totales'];
    return CoachMatchDetail(
      id: _toInt(j['id']) ?? 0,
      equipoId: _toInt(j['equipoId']) ?? 0,
      equipo: (j['equipo'] ?? '').toString().trim(),
      horarioId: _toInt(j['horarioId']),
      rival: (j['rival'] ?? '').toString().trim(),
      fecha: (j['fecha'] ?? '').toString().trim(),
      setsGanados: _toInt(j['setsGanados']) ?? 0,
      setsPerdidos: _toInt(j['setsPerdidos']) ?? 0,
      resultado: (j['resultado'] ?? 'derrota').toString().trim(),
      ubicacion: _optionalText(j['ubicacion']),
      notas: _optionalText(j['notas']),
      jugadores: rawJ is List
          ? rawJ
              .whereType<Map>()
              .map((m) => CoachMatchPlayerStat.fromJson(Map<String, dynamic>.from(m)))
              .toList()
          : const <CoachMatchPlayerStat>[],
      totales: rawT is Map
          ? MatchStats.fromJson(Map<String, dynamic>.from(rawT))
          : const MatchStats(),
    );
  }
}

class CoachMatchTemplateEvent {
  final int id;
  final String titulo, fecha;
  final String? ubicacion;

  const CoachMatchTemplateEvent({
    required this.id,
    required this.titulo,
    required this.fecha,
    this.ubicacion,
  });

  factory CoachMatchTemplateEvent.fromJson(Map<String, dynamic> j) =>
      CoachMatchTemplateEvent(
        id: _toInt(j['id']) ?? 0,
        titulo: (j['titulo'] ?? '').toString().trim(),
        fecha: (j['fecha'] ?? '').toString().trim(),
        ubicacion: _optionalText(j['ubicacion']),
      );
}

class CoachMatchTemplate {
  final int equipoId;
  final String equipoNombre;
  final List<EquipoDeportista> jugadores;
  final List<CoachMatchTemplateEvent> eventos;

  const CoachMatchTemplate({
    required this.equipoId,
    required this.equipoNombre,
    this.jugadores = const <EquipoDeportista>[],
    this.eventos = const <CoachMatchTemplateEvent>[],
  });

  factory CoachMatchTemplate.fromJson(Map<String, dynamic> j) {
    final rawEq = j['equipo'];
    final rawJug = j['jugadores'];
    final rawEv = j['eventos'];
    return CoachMatchTemplate(
      equipoId: rawEq is Map ? (_toInt(rawEq['id']) ?? 0) : 0,
      equipoNombre: rawEq is Map ? (rawEq['nombre'] ?? '').toString().trim() : '',
      jugadores: rawJug is List
          ? rawJug
              .whereType<Map>()
              .map((m) => EquipoDeportista.fromJson(Map<String, dynamic>.from(m)))
              .toList()
          : const <EquipoDeportista>[],
      eventos: rawEv is List
          ? rawEv
              .whereType<Map>()
              .map((m) => CoachMatchTemplateEvent.fromJson(Map<String, dynamic>.from(m)))
              .toList()
          : const <CoachMatchTemplateEvent>[],
    );
  }
}

int? _toInt(dynamic v) =>
    v == null ? null : (v is num ? v.toInt() : int.tryParse(v.toString()));

String? _optionalText(dynamic v) {
  final s = v?.toString().trim();
  return (s == null || s.isEmpty) ? null : s;
}

const _mesesCortoPartido = <String>[
  'ene', 'feb', 'mar', 'abr', 'may', 'jun',
  'jul', 'ago', 'sep', 'oct', 'nov', 'dic',
];

String formatPartidoFecha(String iso) {
  final p = iso.split('-');
  if (p.length != 3) return iso.isEmpty ? '—' : iso;
  final y = int.tryParse(p[0]), m = int.tryParse(p[1]), d = int.tryParse(p[2]);
  if (y == null || m == null || d == null || m < 1 || m > 12) return iso;
  return '$d ${_mesesCortoPartido[m - 1]} $y';
}
