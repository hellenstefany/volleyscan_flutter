/// Un equipo del entrenador (respuesta de listarEquipos).
class Equipo {
  final String id;
  final String nombre;
  final String? categoria;
  final String? temporada;
  final bool esPropietario;
  final int deportistas;
  final int entrenadores;
  final int invitacionesPendientes;

  const Equipo({
    required this.id,
    required this.nombre,
    this.categoria,
    this.temporada,
    required this.esPropietario,
    required this.deportistas,
    required this.entrenadores,
    required this.invitacionesPendientes,
  });

  factory Equipo.fromJson(Map<String, dynamic> j) => Equipo(
    id: '${j['id']}',
    nombre: '${j['nombre'] ?? ''}',
    categoria: _texto(j['categoria']),
    temporada: _texto(j['temporada']),
    esPropietario: j['esPropietario'] == true,
    deportistas: _entero(j['deportistas']),
    entrenadores: _entero(j['entrenadores']),
    invitacionesPendientes: _entero(j['invitacionesPendientes']),
  );
}

/// Invitación recibida para ser co-entrenador de un equipo.
class Invitacion {
  final String id;
  final String invitadoPor;
  final String equipoNombre;
  final String? equipoCategoria;
  final String? equipoTemporada;

  const Invitacion({
    required this.id,
    required this.invitadoPor,
    required this.equipoNombre,
    this.equipoCategoria,
    this.equipoTemporada,
  });

  factory Invitacion.fromJson(Map<String, dynamic> j) {
    final eq = (j['equipo'] as Map?)?.cast<String, dynamic>() ?? const {};
    return Invitacion(
      id: '${j['id']}',
      invitadoPor: '${j['invitadoPor'] ?? ''}',
      equipoNombre: '${eq['nombre'] ?? ''}',
      equipoCategoria: _texto(eq['categoria']),
      equipoTemporada: _texto(eq['temporada']),
    );
  }
}

String? _texto(dynamic v) {
  final s = v?.toString().trim();
  return (s == null || s.isEmpty) ? null : s;
}

int _entero(dynamic v) => v is num ? v.toInt() : int.tryParse('$v') ?? 0;
