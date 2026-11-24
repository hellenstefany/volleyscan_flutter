export 'partido_entrenador_data.dart';

/// Modelos de la pantalla "Mis partidos" (`/usuario/partidos`) alineados con
/// `VolleyScan_Next/src/app/usuario/partidos/page.jsx` y
/// `Backend_VolleyScan/vinculos/partidos.py`.
class MatchStats {
  final int saquesExitosos;
  final int saquesFallidos;
  final int ataquesExitosos;
  final int ataquesFallidos;
  final int bloqueos;
  final int recepcionesExitosas;
  final int recepcionesFalladas;
  final int erroresNoForzados;
  final int puntosTotales;
  final int? minutosJugados;
  final int? efectividadSaque;
  final int? efectividadAtaque;
  final int? efectividadRecepcion;

  const MatchStats({
    this.saquesExitosos = 0,
    this.saquesFallidos = 0,
    this.ataquesExitosos = 0,
    this.ataquesFallidos = 0,
    this.bloqueos = 0,
    this.recepcionesExitosas = 0,
    this.recepcionesFalladas = 0,
    this.erroresNoForzados = 0,
    this.puntosTotales = 0,
    this.minutosJugados,
    this.efectividadSaque,
    this.efectividadAtaque,
    this.efectividadRecepcion,
  });

  factory MatchStats.fromJson(Map<String, dynamic> json) {
    return MatchStats(
      saquesExitosos: _toInt(json['saquesExitosos']) ?? 0,
      saquesFallidos: _toInt(json['saquesFallidos']) ?? 0,
      ataquesExitosos: _toInt(json['ataquesExitosos']) ?? 0,
      ataquesFallidos: _toInt(json['ataquesFallidos']) ?? 0,
      bloqueos: _toInt(json['bloqueos']) ?? 0,
      recepcionesExitosas: _toInt(json['recepcionesExitosas']) ?? 0,
      recepcionesFalladas: _toInt(json['recepcionesFalladas']) ?? 0,
      erroresNoForzados: _toInt(json['erroresNoForzados']) ?? 0,
      puntosTotales: _toInt(json['puntosTotales']) ?? 0,
      minutosJugados: _toInt(json['minutosJugados']),
      efectividadSaque: _toInt(json['efectividadSaque']),
      efectividadAtaque: _toInt(json['efectividadAtaque']),
      efectividadRecepcion: _toInt(json['efectividadRecepcion']),
    );
  }

  int statByKey(String key) => switch (key) {
        'ataquesExitosos' => ataquesExitosos,
        'ataquesFallidos' => ataquesFallidos,
        'bloqueos' => bloqueos,
        'saquesExitosos' => saquesExitosos,
        'saquesFallidos' => saquesFallidos,
        'recepcionesExitosas' => recepcionesExitosas,
        'recepcionesFalladas' => recepcionesFalladas,
        'erroresNoForzados' => erroresNoForzados,
        _ => 0,
      };
}

class MatchAccumulated {
  final int partidos;
  final MatchStats stats;

  const MatchAccumulated({required this.partidos, required this.stats});

  factory MatchAccumulated.fromJson(Map<String, dynamic> json) {
    return MatchAccumulated(
      partidos: _toInt(json['partidos']) ?? 0,
      stats: MatchStats.fromJson(json),
    );
  }
}

class AthleteMatch {
  final int id;
  final int equipoId;
  final String equipo;
  final int? horarioId;
  final String rival;
  final String fecha;
  final int setsGanados;
  final int setsPerdidos;
  final String resultado;
  final String? ubicacion;
  final MatchStats misCifras;
  final String? miObservacion;

  const AthleteMatch({
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
    required this.misCifras,
    this.miObservacion,
  });

  factory AthleteMatch.fromJson(Map<String, dynamic> json) {
    final rawStats = json['misCifras'];
    return AthleteMatch(
      id: _toInt(json['id']) ?? 0,
      equipoId: _toInt(json['equipoId']) ?? 0,
      equipo: (json['equipo'] ?? '').toString().trim(),
      horarioId: _toInt(json['horarioId']),
      rival: (json['rival'] ?? '').toString().trim(),
      fecha: (json['fecha'] ?? '').toString().trim(),
      setsGanados: _toInt(json['setsGanados']) ?? 0,
      setsPerdidos: _toInt(json['setsPerdidos']) ?? 0,
      resultado: (json['resultado'] ?? 'derrota').toString().trim(),
      ubicacion: _optionalText(json['ubicacion']),
      misCifras: rawStats is Map
          ? MatchStats.fromJson(Map<String, dynamic>.from(rawStats))
          : const MatchStats(),
      miObservacion: _optionalText(json['miObservacion']),
    );
  }

  bool get isVictory => resultado == 'victoria';
}

class MyMatchesResponse {
  final List<AthleteMatch> partidos;
  final MatchAccumulated? acumulado;

  const MyMatchesResponse({
    this.partidos = const <AthleteMatch>[],
    this.acumulado,
  });

  factory MyMatchesResponse.fromJson(Map<String, dynamic> json) {
    final rawList = json['partidos'];
    final list = rawList is List
        ? rawList
            .whereType<Map>()
            .map((e) => AthleteMatch.fromJson(Map<String, dynamic>.from(e)))
            .toList()
        : const <AthleteMatch>[];
    final rawAcum = json['acumulado'];
    return MyMatchesResponse(
      partidos: list,
      acumulado: rawAcum is Map
          ? MatchAccumulated.fromJson(Map<String, dynamic>.from(rawAcum))
          : null,
    );
  }
}

int? _toInt(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value.toString());
}

String? _optionalText(dynamic value) {
  final text = value?.toString().trim();
  return (text == null || text.isEmpty) ? null : text;
}

String formatPercentOrDash(int? value) => value == null ? '—' : '$value%';
