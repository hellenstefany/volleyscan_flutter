import 'package:flutter/material.dart';
import '../../theme/dash_colors.dart';
import 'dash_card.dart';
import 'profile_avatar.dart';

/// Tarjeta superior del perfil: foto, nombre, rol y nivel.
class ProfileSummaryCard extends StatelessWidget {
  const ProfileSummaryCard({
    super.key,
    required this.name,
    required this.level,
    this.role = 'Deportista',
    this.photoPath,
  });

  final String name;
  final String level;
  final String role;
  final String? photoPath;

  static Color _levelColor(String level) {
    switch (level) {
      case 'Principiante':
        return DashColors.green;
      case 'Avanzado':
        return DashColors.orange;
      case 'Profesional':
        return const Color(0xFFA855F7);
      default:
        return const Color(0xFFFACC15);
    }
  }

  @override
  Widget build(BuildContext context) {
    final levelColor = _levelColor(level);

    return SizedBox(
      width: double.infinity,
      child: DashCard(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 22),
        child: Column(
          children: [
            SizedBox(
              width: 104,
              height: 104,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: DashColors.blueLight, width: 2),
                    ),
                    child: ProfileAvatar(
                      name: name,
                      photoPath: photoPath,
                      size: 90,
                    ),
                  ),
                  Positioned(
                    right: 2,
                    bottom: 4,
                    child: Container(
                      width: 22,
                      height: 22,
                      decoration: BoxDecoration(
                        color: DashColors.blue,
                        shape: BoxShape.circle,
                        border: Border.all(color: DashColors.card, width: 3),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Text(
              name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 19,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              role,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 12.5,
                color: DashColors.muted,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
              decoration: BoxDecoration(
                color: levelColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: levelColor.withOpacity(0.6)),
              ),
              child: Text(
                level.toUpperCase(),
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 10.5,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.8,
                  color: levelColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
