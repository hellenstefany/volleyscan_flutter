import 'coach_link_data.dart';

/// Entrenador asignado a un equipo del deportista (`/api/ia/mis-equipos`).
class TeamCoach {
  final CoachPerson coach;
  final bool esPropietario;

  const TeamCoach({
    required this.coach,
    this.esPropietario = false,
  });

  factory TeamCoach.fromJson(Map<String, dynamic> json) {
    return TeamCoach(
      coach: CoachPerson.fromJson(json),
      esPropietario: json['esPropietario'] == true,
    );
  }
}

/// Equipo al que pertenece el deportista (`/api/ia/mis-equipos`).
class MyTeam {
  final int id;
  final String nombre;
  final String? categoria;
  final String? temporada;
  final String? posicion;
  final int? numeroCamiseta;
  final String? desde;
  final int integrantes;
  final List<TeamCoach> entrenadores;

  const MyTeam({
    required this.id,
    required this.nombre,
    this.categoria,
    this.temporada,
    this.posicion,
    this.numeroCamiseta,
    this.desde,
    this.integrantes = 0,
    this.entrenadores = const <TeamCoach>[],
  });

  factory MyTeam.fromJson(Map<String, dynamic> json) {
    final rawCoaches = json['entrenadores'];
    final coaches = rawCoaches is List
        ? rawCoaches
            .whereType<Map>()
            .map((e) => TeamCoach.fromJson(Map<String, dynamic>.from(e)))
            .toList()
        : const <TeamCoach>[];

    return MyTeam(
      id: _toInt(json['id']) ?? 0,
      nombre: (json['nombre'] ?? '').toString().trim(),
      categoria: _optionalText(json['categoria']),
      temporada: _optionalText(json['temporada']),
      posicion: _optionalText(json['posicion']),
      numeroCamiseta: _toInt(json['numeroCamiseta']),
      desde: _optionalText(json['desde']),
      integrantes: _toInt(json['integrantes']) ?? 0,
      entrenadores: coaches,
    );
  }
}

/// Resumen del equipo dentro de una invitación (`/api/ia/invitaciones/mias`).
class InvitedTeamInfo {
  final int id;
  final String nombre;
  final String? categoria;
  final String? temporada;

  const InvitedTeamInfo({
    required this.id,
    required this.nombre,
    this.categoria,
    this.temporada,
  });

  factory InvitedTeamInfo.fromJson(Map<String, dynamic> json) {
    return InvitedTeamInfo(
      id: _toInt(json['id']) ?? 0,
      nombre: (json['nombre'] ?? '').toString().trim(),
      categoria: _optionalText(json['categoria']),
      temporada: _optionalText(json['temporada']),
    );
  }
}

/// Invitación pendiente recibida por el deportista (`/api/ia/invitaciones/mias`).
class TeamInvitation {
  final int id;
  final String tipo;
  final InvitedTeamInfo equipo;
  final String invitadoPor;
  final String? creadaEn;
  final String? venceEn;

  const TeamInvitation({
    required this.id,
    required this.tipo,
    required this.equipo,
    required this.invitadoPor,
    this.creadaEn,
    this.venceEn,
  });

  factory TeamInvitation.fromJson(Map<String, dynamic> json) {
    final rawEquipo = json['equipo'];
    return TeamInvitation(
      id: _toInt(json['id']) ?? 0,
      tipo: (json['tipo'] ?? '').toString().trim(),
      equipo: rawEquipo is Map
          ? InvitedTeamInfo.fromJson(Map<String, dynamic>.from(rawEquipo))
          : const InvitedTeamInfo(id: 0, nombre: ''),
      invitadoPor: (json['invitadoPor'] ?? '').toString().trim(),
      creadaEn: _optionalText(json['creadaEn']),
      venceEn: _optionalText(json['venceEn']),
    );
  }
}

/// Respuesta de aceptar o rechazar una invitación (`/api/ia/invitaciones/<id>/<accion>`).
class InvitationActionResult {
  final String estado;
  final int equipoId;
  final String equipo;
  final String tipo;

  const InvitationActionResult({
    required this.estado,
    required this.equipoId,
    required this.equipo,
    required this.tipo,
  });

  factory InvitationActionResult.fromJson(Map<String, dynamic> json) {
    return InvitationActionResult(
      estado: (json['estado'] ?? '').toString().trim(),
      equipoId: _toInt(json['equipoId']) ?? 0,
      equipo: (json['equipo'] ?? '').toString().trim(),
      tipo: (json['tipo'] ?? '').toString().trim(),
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

const _mesesCortosEs = <String>[
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

/// Replica `Intl.DateTimeFormat("es-CO", { day: "numeric", month: "short", year: "numeric" })`.
String formatTeamShortDate(String? iso) {
  if (iso == null || iso.trim().isEmpty) return '—';
  final parsed = DateTime.tryParse(iso.trim());
  if (parsed == null) return '—';
  final local = parsed.toLocal();
  final mes = _mesesCortosEs[local.month - 1];
  return '${local.day} $mes ${local.year}';
}
