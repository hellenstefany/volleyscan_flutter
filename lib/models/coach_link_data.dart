/// Modelos de la pantalla "Mi entrenador" (`/usuario/entrenador`)
/// alineados con `VolleyScan_Next/src/app/usuario/entrenador/page.jsx`
/// y `Backend_VolleyScan/vinculos/repositorio.py`.
class CoachPerson {
  final int id;
  final String nombre;
  final String apellido;
  final String? fotoUrl;
  final int deportistas;

  const CoachPerson({
    required this.id,
    required this.nombre,
    required this.apellido,
    this.fotoUrl,
    this.deportistas = 0,
  });

  factory CoachPerson.fromJson(Map<String, dynamic> json) {
    final rawFoto = json['fotoUrl']?.toString().trim();
    return CoachPerson(
      id: _toInt(json['id']) ?? 0,
      nombre: (json['nombre'] ?? '').toString().trim(),
      apellido: (json['apellido'] ?? '').toString().trim(),
      fotoUrl: (rawFoto != null && rawFoto.isNotEmpty) ? rawFoto : null,
      deportistas: _toInt(json['deportistas']) ?? 0,
    );
  }

  String get fullName =>
      [nombre, apellido].where((s) => s.isNotEmpty).join(' ').trim();

  String get initials {
    final n = nombre.isNotEmpty ? nombre[0].toUpperCase() : '';
    final a = apellido.isNotEmpty ? apellido[0].toUpperCase() : '';
    final res = '$n$a';
    return res.isNotEmpty ? res : 'EN';
  }
}

class CoachBond {
  final int id;
  final String estado;
  final String? solicitadoEn;
  final String? respondidoEn;
  final CoachPerson entrenador;

  const CoachBond({
    required this.id,
    required this.estado,
    this.solicitadoEn,
    this.respondidoEn,
    required this.entrenador,
  });

  factory CoachBond.fromJson(Map<String, dynamic> json) {
    final rawEntrenador = json['entrenador'];
    return CoachBond(
      id: _toInt(json['id']) ?? 0,
      estado: (json['estado'] ?? '').toString().trim(),
      solicitadoEn: json['solicitadoEn']?.toString(),
      respondidoEn: json['respondidoEn']?.toString(),
      entrenador: rawEntrenador is Map
          ? CoachPerson.fromJson(Map<String, dynamic>.from(rawEntrenador))
          : const CoachPerson(id: 0, nombre: '', apellido: ''),
    );
  }

  bool get isAccepted => estado == 'aceptado';
  bool get isPending => estado == 'pendiente';
}

class MyCoachResponse {
  final CoachBond? vinculo;
  final CoachBond? ultimoRechazo;

  const MyCoachResponse({
    this.vinculo,
    this.ultimoRechazo,
  });

  factory MyCoachResponse.fromJson(Map<String, dynamic> json) {
    final rawVinculo = json['vinculo'];
    final rawRechazo = json['ultimoRechazo'];
    return MyCoachResponse(
      vinculo: rawVinculo is Map
          ? CoachBond.fromJson(Map<String, dynamic>.from(rawVinculo))
          : null,
      ultimoRechazo: rawRechazo is Map
          ? CoachBond.fromJson(Map<String, dynamic>.from(rawRechazo))
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

const _mesesEs = <String>[
  'enero',
  'febrero',
  'marzo',
  'abril',
  'mayo',
  'junio',
  'julio',
  'agosto',
  'septiembre',
  'octubre',
  'noviembre',
  'diciembre',
];

/// Replica `Intl.DateTimeFormat("es-CO", { day: "numeric", month: "long", year: "numeric" })`.
String formatCoachLongDate(String? iso) {
  if (iso == null || iso.trim().isEmpty) return '—';
  final parsed = DateTime.tryParse(iso.trim());
  if (parsed == null) return '—';
  final local = parsed.toLocal();
  final mes = _mesesEs[local.month - 1];
  return '${local.day} de $mes de ${local.year}';
}

/// Replica `sinTildes(t)` de `VolleyScan_Next/src/app/usuario/entrenador/page.jsx`.
String normalizeCoachSearch(String text) {
  const withAccents = 'áàäâãéèëêíìïîóòöôõúùüûñçÁÀÄÂÃÉÈËÊÍÌÏÎÓÒÖÔÕÚÙÜÛÑÇ';
  const withoutAccents = 'aaaaaeeeeiiiiooooouuuuncAAAAAEEEEIIIIOOOOOUUUUNC';
  final buf = StringBuffer();
  for (final codeUnit in text.runes) {
    final ch = String.fromCharCode(codeUnit);
    final idx = withAccents.indexOf(ch);
    buf.write(idx >= 0 ? withoutAccents[idx] : ch);
  }
  return buf.toString().toLowerCase().trim();
}
