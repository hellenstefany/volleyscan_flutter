import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../theme/app_theme.dart';
import '../../theme/dash_colors.dart';

/// Foto de perfil. Si no hay imagen o falla la carga, muestra las iniciales sobre un degradado.
/// Soporta URLs de red (`http://`, `https://`), rutas relativas del backend (`/media/...`) y assets locales.
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
    final res = parts.take(2).map((p) => p[0].toUpperCase()).join();
    return res.isEmpty ? '?' : res;
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
          colors: [AppColors.blue, DashColors.purple],
        ),
      ),
      child: Text(
        _initials,
        style: TextStyle(
          fontFamily: 'Poppins',
          fontSize: size * 0.32,
          fontWeight: FontWeight.w700,
          color: DashColors.textPrimary,
        ),
      ),
    );

    final raw = photoPath?.trim() ?? '';
    final Widget image;
    if (raw.isEmpty) {
      image = fallback;
    } else if (raw.startsWith('http://') ||
        raw.startsWith('https://') ||
        raw.startsWith('/')) {
      final resolved = ApiService.resolveMediaUrl(raw) ?? raw;
      image = Image.network(
        resolved,
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => fallback,
      );
    } else {
      image = Image.asset(
        raw,
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => fallback,
      );
    }

    return cornerRadius == null
        ? ClipOval(child: image)
        : ClipRRect(
            borderRadius: BorderRadius.circular(cornerRadius!),
            child: image,
          );
  }
}
