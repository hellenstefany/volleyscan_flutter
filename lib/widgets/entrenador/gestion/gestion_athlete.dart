const categorias = ['Juvenil', 'Mayor', 'Infantil'];
const niveles = ['Principiante', 'Intermedio', 'Avanzado'];
const estados = ['Activo', 'Inactivo'];

class Athlete {
  final int id;
  final String nombre, pos, cat, nivel, estado;
  final int edad, perf, trend, asis, ses;
  const Athlete({
    required this.id,
    required this.nombre,
    required this.edad,
    required this.pos,
    required this.cat,
    required this.nivel,
    required this.estado,
    required this.perf,
    required this.trend,
    required this.asis,
    required this.ses,
  });
}

String initials(String name) => name
    .split(' ')
    .where((p) => p.isNotEmpty)
    .take(2)
    .map((p) => p[0])
    .join()
    .toUpperCase();

const initialAthletes = [
  Athlete(
    id: 1,
    nombre: 'Juan Pérez',
    edad: 17,
    pos: 'Opuesto',
    cat: 'Juvenil',
    nivel: 'Avanzado',
    estado: 'Activo',
    perf: 85,
    trend: 12,
    asis: 92,
    ses: 24,
  ),
  Athlete(
    id: 2,
    nombre: 'María González',
    edad: 16,
    pos: 'Líbero',
    cat: 'Juvenil',
    nivel: 'Intermedio',
    estado: 'Activo',
    perf: 78,
    trend: 8,
    asis: 88,
    ses: 20,
  ),
  Athlete(
    id: 3,
    nombre: 'Carlos Ramírez',
    edad: 18,
    pos: 'Central',
    cat: 'Mayor',
    nivel: 'Avanzado',
    estado: 'Activo',
    perf: 91,
    trend: 5,
    asis: 96,
    ses: 30,
  ),
  Athlete(
    id: 4,
    nombre: 'Sofía Ortega',
    edad: 15,
    pos: 'Armadora',
    cat: 'Juvenil',
    nivel: 'Principiante',
    estado: 'Inactivo',
    perf: 62,
    trend: -3,
    asis: 70,
    ses: 12,
  ),
  Athlete(
    id: 5,
    nombre: 'Andrés López',
    edad: 17,
    pos: 'Receptor',
    cat: 'Juvenil',
    nivel: 'Intermedio',
    estado: 'Activo',
    perf: 80,
    trend: 10,
    asis: 90,
    ses: 22,
  ),
];
