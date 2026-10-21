import 'package:flutter/material.dart';

/// Foto de perfil. Si no hay imagen, muestra las iniciales sobre un degradado.
/// Con [cornerRadius] es un cuadrado redondeado; sin él, un círculo.
class ProfileAvatar extends StatelessWidget {
  const ProfileAvatar({
    super.key,
    required this.name,
    this.photoPath,
    this.size = 100,
    this.cornerRadius,
  });

  final String name;
  final String? photoPath;
  final double size;
  final double? cornerRadius;

  String get _initials {
    final parts = name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty);
    return parts.take(2).map((p) => p[0].toUpperCase()).join();
  }

  @override
  Widget build(BuildContext context) {
    final fallback = Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF6366F1), Color(0xFFA855F7)],
        ),
      ),
      child: Text(
        _initials,
        style: TextStyle(
          fontFamily: 'Poppins',
          fontSize: size * 0.32,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
      ),
    );

    final Widget image = photoPath == null
        ? fallback
        : Image.asset(
            photoPath!,
            width: size,
            height: size,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => fallback,
          );

    return cornerRadius == null
        ? ClipOval(child: image)
        : ClipRRect(
            borderRadius: BorderRadius.circular(cornerRadius!),
            child: image,
          );
  }
}
