/// Datos del perfil de usuario.
class ProfileData {
  const ProfileData({
    required this.fullName,
    required this.email,
    required this.birthDate,
    required this.level,
    required this.weightKg,
    required this.heightM,
    required this.position,
  });

  final String fullName;
  final String email;
  final DateTime birthDate;
  final String level;
  final double weightKg;
  final double heightM;
  final String position;

  static const levels = [
    'Principiante',
    'Intermedio',
    'Avanzado',
    'Profesional',
  ];
  static const positions = ['Armador', 'Opuesto', 'Central', 'Punta', 'Líbero'];

  ProfileData copyWith({
    String? fullName,
    String? email,
    DateTime? birthDate,
    String? level,
    double? weightKg,
    double? heightM,
    String? position,
  }) {
    return ProfileData(
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      birthDate: birthDate ?? this.birthDate,
      level: level ?? this.level,
      weightKg: weightKg ?? this.weightKg,
      heightM: heightM ?? this.heightM,
      position: position ?? this.position,
    );
  }
}
