/// Modelos de la pantalla "Mi nivel" (`/usuario/mi-nivel`) alineados con
/// `VolleyScan_Next/src/app/usuario/mi-nivel/page.jsx` y
/// `Backend_VolleyScan/vinculos/registro_rutinas.py`.
class LevelCriterion {
  final String clave;
  final String titulo;
  final double? valor;
  final double meta;
  final String unidad;
  final bool cumple;

  const LevelCriterion({
    required this.clave,
    required this.titulo,
    this.valor,
    required this.meta,
    this.unidad = '',
    this.cumple = false,
  });

  factory LevelCriterion.fromJson(Map<String, dynamic> json) {
    return LevelCriterion(
      clave: (json['clave'] ?? '').toString().trim(),
      titulo: (json['titulo'] ?? '').toString().trim(),
      valor: _toDouble(json['valor']),
      meta: _toDouble(json['meta']) ?? 1.0,
      unidad: (json['unidad'] ?? '').toString(),
      cumple: json['cumple'] == true,
    );
  }

  /// Replica `Math.max(0, Math.min(100, Math.round(((c.valor ?? 0) / c.meta) * 100)))`.
  int get percent {
    if (meta <= 0) return 0;
    final raw = (((valor ?? 0) / meta) * 100).round();
    return raw.clamp(0, 100);
  }
}

class LevelAdvance {
  final String nivelActual;
  final String? siguiente;
  final List<LevelCriterion> criterios;
  final String? sugerencia;

  const LevelAdvance({
    required this.nivelActual,
    this.siguiente,
    this.criterios = const <LevelCriterion>[],
    this.sugerencia,
  });

  factory LevelAdvance.fromJson(Map<String, dynamic> json) {
    final rawCrit = json['criterios'];
    return LevelAdvance(
      nivelActual: (json['nivelActual'] ?? '').toString().trim().toLowerCase(),
      siguiente: _optionalText(json['siguiente'])?.toLowerCase(),
      criterios: rawCrit is List
          ? rawCrit
              .whereType<Map>()
              .map((e) => LevelCriterion.fromJson(Map<String, dynamic>.from(e)))
              .toList()
          : const <LevelCriterion>[],
      sugerencia: _optionalText(json['sugerencia']),
    );
  }
}

class LevelHistoryItem {
  final String anterior;
  final String nuevo;
  final bool sube;
  final String? motivo;
  final String? fecha;
  final String? entrenador;

  const LevelHistoryItem({
    required this.anterior,
    required this.nuevo,
    required this.sube,
    this.motivo,
    this.fecha,
    this.entrenador,
  });

  factory LevelHistoryItem.fromJson(Map<String, dynamic> json) {
    return LevelHistoryItem(
      anterior: (json['anterior'] ?? '').toString().trim().toLowerCase(),
      nuevo: (json['nuevo'] ?? '').toString().trim().toLowerCase(),
      sube: json['sube'] == true,
      motivo: _optionalText(json['motivo']),
      fecha: _optionalText(json['fecha']),
      entrenador: _optionalText(json['entrenador']),
    );
  }
}

class LevelReviewItem {
  final int id;
  final String rutina;
  final int calificacion;
  final String? comentario;
  final String? fecha;
  final String? entrenador;

  const LevelReviewItem({
    required this.id,
    required this.rutina,
    required this.calificacion,
    this.comentario,
    this.fecha,
    this.entrenador,
  });

  factory LevelReviewItem.fromJson(Map<String, dynamic> json) {
    return LevelReviewItem(
      id: _toInt(json['id']) ?? 0,
      rutina: (json['rutina'] ?? '').toString().trim(),
      calificacion: (_toInt(json['calificacion']) ?? 0).clamp(0, 5),
      comentario: _optionalText(json['comentario']),
      fecha: _optionalText(json['fecha']),
      entrenador: _optionalText(json['entrenador']),
    );
  }
}

class MyLevelResponse {
  final String nivel;
  final String? siguiente;
  final String? entrenador;
  final LevelAdvance? avance;
  final List<LevelHistoryItem> historial;
  final List<LevelReviewItem> revisiones;
  final int totalRevisadas;
  final double? calificacionPromedio;

  const MyLevelResponse({
    this.nivel = 'principiante',
    this.siguiente,
    this.entrenador,
    this.avance,
    this.historial = const <LevelHistoryItem>[],
    this.revisiones = const <LevelReviewItem>[],
    this.totalRevisadas = 0,
    this.calificacionPromedio,
  });

  factory MyLevelResponse.fromJson(Map<String, dynamic> json) {
    final rawAv = json['avance'];
    final rawHist = json['historial'];
    final rawRev = json['revisiones'];
    return MyLevelResponse(
      nivel: (json['nivel'] ?? 'principiante').toString().trim().toLowerCase(),
      siguiente: _optionalText(json['siguiente'])?.toLowerCase(),
      entrenador: _optionalText(json['entrenador']),
      avance: rawAv is Map
          ? LevelAdvance.fromJson(Map<String, dynamic>.from(rawAv))
          : null,
      historial: rawHist is List
          ? rawHist
              .whereType<Map>()
              .map(
                (e) => LevelHistoryItem.fromJson(Map<String, dynamic>.from(e)),
              )
              .toList()
          : const <LevelHistoryItem>[],
      revisiones: rawRev is List
          ? rawRev
              .whereType<Map>()
              .map(
                (e) => LevelReviewItem.fromJson(Map<String, dynamic>.from(e)),
              )
              .toList()
          : const <LevelReviewItem>[],
      totalRevisadas: _toInt(json['totalRevisadas']) ?? 0,
      calificacionPromedio: _toDouble(json['calificacionPromedio']),
    );
  }
}

const myLevelSteps = <String>[
  'principiante',
  'intermedio',
  'avanzado',
  'profesional',
];

String formatLevelName(String? nivel) {
  switch ((nivel ?? '').trim().toLowerCase()) {
    case 'principiante':
      return 'Principiante';
    case 'intermedio':
      return 'Intermedio';
    case 'avanzado':
      return 'Avanzado';
    case 'profesional':
      return 'Profesional';
    case 'todos':
      return 'Todos los niveles';
    default:
      return '—';
  }
}

String formatDecimalComma(double value) =>
    value.toStringAsFixed(1).replaceAll('.', ',');

int? _toInt(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value.toString());
}

double? _toDouble(dynamic value) {
  if (value == null) return null;
  if (value is double) return value;
  if (value is num) return value.toDouble();
  return double.tryParse(value.toString());
}

String? _optionalText(dynamic value) {
  final text = value?.toString().trim();
  return (text == null || text.isEmpty) ? null : text;
}
