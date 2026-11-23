/// Modelos del módulo "Equipos" del Panel de Entrenador (`/api/ia/equipos/...`).
///
/// Para las invitaciones recibidas por el entrenador (`GET /api/ia/invitaciones/mias`
/// y `POST /api/ia/invitaciones/<id>/<aceptar|rechazar>`) se reutilizan
/// `TeamInvitation`, `InvitedTeamInfo`, `InvitationActionResult` y
/// `formatTeamShortDate` de `lib/models/my_teams_data.dart`.
library;

const Map<String, String> kEquipoNivelesLabel = <String, String>{
  'principiante': 'Principiante',
  'intermedio': 'Intermedio',
  'avanzado': 'Avanzado',
  'profesional': 'Profesional',
};

String formatEquipoNivel(String? raw) {
  if (raw == null || raw.trim().isEmpty) return '—';
  final key = raw.trim().toLowerCase();
  return kEquipoNivelesLabel[key] ?? '—';
}

String buildEquipoInitials(String nombre, String apellido) {
  final n = nombre.trim();
  final a = apellido.trim();
  final c1 = n.isNotEmpty ? n[0] : '';
  final c2 = a.isNotEmpty ? a[0] : '';
  final res = '$c1$c2'.toUpperCase();
  if (res.isNotEmpty) return res;
  return '?';
}

/// Resumen de un equipo del entrenador (`GET /api/ia/equipos`).
class Equipo {
  final int id;
  final String nombre;
  final String? categoria;
  final String? temporada;
  final bool esPropietario;
  final int deportistas;
  final int entrenadores;
  final int invitacionesPendientes;
  final String? creadoEn;

  const Equipo({
    required this.id,
    required this.nombre,
    this.categoria,
    this.temporada,
    required this.esPropietario,
    required this.deportistas,
    required this.entrenadores,
    required this.invitacionesPendientes,
    this.creadoEn,
  });

  factory Equipo.fromJson(Map<String, dynamic> j) => Equipo(
        id: _entero(j['id']),
        nombre: (j['nombre'] ?? '').toString().trim(),
        categoria: _texto(j['categoria']),
        temporada: _texto(j['temporada']),
        esPropietario: j['esPropietario'] == true,
        deportistas: _entero(j['deportistas']),
        entrenadores: _entero(j['entrenadores']),
        invitacionesPendientes: _entero(j['invitacionesPendientes']),
        creadoEn: _texto(j['creadoEn']),
      );
}

/// Deportista integrante de un equipo (`detalle.deportistas` en `GET /api/ia/equipos/<id>`).
class EquipoDeportista {
  final int id;
  final String nombre;
  final String apellido;
  final String? fotoUrl;
  final String? nivel;
  final String? posicion;
  final int? numeroCamiseta;
  final String? desde;

  const EquipoDeportista({
    required this.id,
    required this.nombre,
    required this.apellido,
    this.fotoUrl,
    this.nivel,
    this.posicion,
    this.numeroCamiseta,
    this.desde,
  });

  String get nombreCompleto =>
      [nombre.trim(), apellido.trim()].where((s) => s.isNotEmpty).join(' ');

  String get iniciales => buildEquipoInitials(nombre, apellido);

  String get nivelTexto => formatEquipoNivel(nivel);

  factory EquipoDeportista.fromJson(Map<String, dynamic> j) => EquipoDeportista(
        id: _entero(j['id']),
        nombre: (j['nombre'] ?? '').toString().trim(),
        apellido: (j['apellido'] ?? '').toString().trim(),
        fotoUrl: _texto(j['fotoUrl'] ?? j['foto_url']),
        nivel: _texto(j['nivel']),
        posicion: _texto(j['posicion']),
        numeroCamiseta: _enteroOpcional(j['numeroCamiseta']),
        desde: _texto(j['desde']),
      );
}

/// Entrenador integrante de un equipo (`detalle.entrenadores` en `GET /api/ia/equipos/<id>`).
class EquipoEntrenador {
  final int id;
  final String nombre;
  final String apellido;
  final String email;
  final String? fotoUrl;
  final bool esPropietario;
  final bool soyYo;
  final String? desde;

  const EquipoEntrenador({
    required this.id,
    required this.nombre,
    required this.apellido,
    required this.email,
    this.fotoUrl,
    required this.esPropietario,
    required this.soyYo,
    this.desde,
  });

  String get nombreCompleto =>
      [nombre.trim(), apellido.trim()].where((s) => s.isNotEmpty).join(' ');

  String get iniciales => buildEquipoInitials(nombre, apellido);

  factory EquipoEntrenador.fromJson(Map<String, dynamic> j) => EquipoEntrenador(
        id: _entero(j['id']),
        nombre: (j['nombre'] ?? '').toString().trim(),
        apellido: (j['apellido'] ?? '').toString().trim(),
        email: (j['email'] ?? '').toString().trim(),
        fotoUrl: _texto(j['fotoUrl'] ?? j['foto_url']),
        esPropietario: j['esPropietario'] == true,
        soyYo: j['soyYo'] == true,
        desde: _texto(j['desde']),
      );
}

/// Invitación pendiente enviada desde el equipo (`detalle.invitaciones` en `GET /api/ia/equipos/<id>`).
class EquipoInvitacionPendiente {
  final int id;
  final String tipo; // 'deportista' | 'entrenador'
  final String email;
  final String? creadaEn;
  final String? venceEn;
  final bool vencida;
  final String invitadoPor;

  const EquipoInvitacionPendiente({
    required this.id,
    required this.tipo,
    required this.email,
    this.creadaEn,
    this.venceEn,
    required this.vencida,
    required this.invitadoPor,
  });

  factory EquipoInvitacionPendiente.fromJson(Map<String, dynamic> j) =>
      EquipoInvitacionPendiente(
        id: _entero(j['id']),
        tipo: (j['tipo'] ?? 'deportista').toString().trim(),
        email: (j['email'] ?? '').toString().trim(),
        creadaEn: _texto(j['creadaEn']),
        venceEn: _texto(j['venceEn']),
        vencida: j['vencida'] == true,
        invitadoPor: (j['invitadoPor'] ?? '').toString().trim(),
      );
}

/// Detalle completo de un equipo del entrenador (`GET /api/ia/equipos/<id>`).
class EquipoDetalle {
  final int id;
  final String nombre;
  final String? categoria;
  final String? temporada;
  final bool esPropietario;
  final List<EquipoDeportista> deportistas;
  final List<EquipoEntrenador> entrenadores;
  final List<EquipoInvitacionPendiente> invitaciones;

  const EquipoDetalle({
    required this.id,
    required this.nombre,
    this.categoria,
    this.temporada,
    required this.esPropietario,
    this.deportistas = const <EquipoDeportista>[],
    this.entrenadores = const <EquipoEntrenador>[],
    this.invitaciones = const <EquipoInvitacionPendiente>[],
  });

  factory EquipoDetalle.fromJson(Map<String, dynamic> j) {
    final rawDep = j['deportistas'];
    final rawCoach = j['entrenadores'];
    final rawInv = j['invitaciones'];

    return EquipoDetalle(
      id: _entero(j['id']),
      nombre: (j['nombre'] ?? '').toString().trim(),
      categoria: _texto(j['categoria']),
      temporada: _texto(j['temporada']),
      esPropietario: j['esPropietario'] == true,
      deportistas: rawDep is List
          ? rawDep
              .whereType<Map>()
              .map((m) =>
                  EquipoDeportista.fromJson(Map<String, dynamic>.from(m)))
              .toList()
          : const <EquipoDeportista>[],
      entrenadores: rawCoach is List
          ? rawCoach
              .whereType<Map>()
              .map((m) =>
                  EquipoEntrenador.fromJson(Map<String, dynamic>.from(m)))
              .toList()
          : const <EquipoEntrenador>[],
      invitaciones: rawInv is List
          ? rawInv
              .whereType<Map>()
              .map((m) => EquipoInvitacionPendiente.fromJson(
                    Map<String, dynamic>.from(m),
                  ))
              .toList()
          : const <EquipoInvitacionPendiente>[],
    );
  }
}

/// Respuesta al enviar o reenviar una invitación (`POST /api/ia/equipos/<id>/invitaciones`
/// y `POST /api/ia/equipos/<id>/invitaciones/<invId>/reenviar`).
class EquipoInvitacionCreada {
  final int id;
  final String email;
  final String tipo;
  final String enlace;
  final bool emailEnviado;
  final String? venceEn;

  const EquipoInvitacionCreada({
    required this.id,
    required this.email,
    required this.tipo,
    required this.enlace,
    required this.emailEnviado,
    this.venceEn,
  });

  factory EquipoInvitacionCreada.fromJson(Map<String, dynamic> j) =>
      EquipoInvitacionCreada(
        id: _entero(j['id']),
        email: (j['email'] ?? '').toString().trim(),
        tipo: (j['tipo'] ?? 'deportista').toString().trim(),
        enlace: (j['enlace'] ?? '').toString().trim(),
        emailEnviado: j['emailEnviado'] == true,
        venceEn: _texto(j['venceEn']),
      );
}

String? _texto(dynamic v) {
  final s = v?.toString().trim();
  return (s == null || s.isEmpty) ? null : s;
}

int _entero(dynamic v) => v is num ? v.toInt() : int.tryParse('$v') ?? 0;

int? _enteroOpcional(dynamic v) {
  if (v == null) return null;
  if (v is int) return v;
  if (v is num) return v.toInt();
  final s = v.toString().trim();
  if (s.isEmpty) return null;
  return int.tryParse(s);
}
