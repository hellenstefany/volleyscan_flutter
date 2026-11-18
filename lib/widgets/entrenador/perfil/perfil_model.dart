import 'package:flutter/material.dart';

class Achievement {
  final int id;
  final String icon, title, description;
  const Achievement(this.id, this.icon, this.title, this.description);
}

const kDefaultProfile = {
  'fullName': 'Agustín Luligo',
  'email': 'agustin@volleyai.com',
  'phone': '+57 310 000 0000',
  'club': 'Club Atlético Popayán',
  'experience': '5',
  'level': 'Nivel 3',
};

const kNiveles = ['Nivel 1', 'Nivel 2', 'Nivel 3', 'Nivel 4', 'Nivel 5'];

// (etiqueta, clave, teclado)
const kCampos = [
  ('Nombre completo', 'fullName', TextInputType.text),
  ('Correo electrónico', 'email', TextInputType.emailAddress),
  ('Teléfono', 'phone', TextInputType.phone),
  ('Club', 'club', TextInputType.text),
  ('Años de experiencia', 'experience', TextInputType.number),
];

const kInitialAchievements = [
  Achievement(1, '🏆', 'Mejor entrenador', 'Torneo Regional 2024'),
  Achievement(2, '📈', '+8% rendimiento', 'Esta semana'),
  Achievement(3, '🎯', '100 sesiones', 'Completadas este año'),
];

String perfilInitials(String fullName) => fullName
    .split(' ')
    .where((s) => s.isNotEmpty)
    .map((s) => s[0])
    .join()
    .toUpperCase();
