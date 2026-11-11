import 'package:flutter/material.dart';
import '../../models/profile_data.dart';
import '../../theme/dash_colors.dart';
import 'dash_card.dart';
import 'profile_avatar.dart';

/// Tarjeta superior del perfil (`.pf-user-card` en Next): foto, nombre, rol y insignia de nivel.
class ProfileSummaryCard extends StatelessWidget {
  const ProfileSummaryCard({
    super.key,
    required this.name,
    this.level,
    this.role = 'Deportista',
    this.photoPath,
  });

  final String name;
  final String? level;
  final String role;
  final String? photoPath;

  static Color _levelColor(String? rawLevel) {
    switch ((rawLevel ?? '').toLowerCase()) {
      case 'principiante':
        return DashColors.green;
      case 'intermedio':
        return DashColors.yellow;
      case 'avanzado':
        return DashColors.orange;
      case 'profesional':
        return DashColors.purple;
      default:
        return DashColors.blueLight;
    }
  }

  static String _levelLabel(String? rawLevel) {
    final key = (rawLevel ?? '').toLowerCase();
    return ProfileData.nivelLabels[key] ??
        (rawLevel != null && rawLevel.trim().isNotEmpty
            ? rawLevel.trim()
            : 'Intermedio');
  }

  @override
  Widget build(BuildContext context) {
    final levelColor = _levelColor(level);
    final levelText = _levelLabel(level);

    return SizedBox(
      width: double.infinity,
      child: DashCard(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 22),
        child: Column(
          children: [
            SizedBox(
              width: 100,
              height: 100,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: 96,
                    height: 96,
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: DashColors.blueLight,
                        width: 2.5,
                      ),
                    ),
                    child: ProfileAvatar(
                      name: name,
                      photoPath: photoPath,
                      size: 88,
                    ),
                  ),
                  Positioned(
                    right: 4,
                    bottom: 4,
                    child: Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        color: DashColors.blueLight,
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
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: DashColors.text,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              role,
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 12.5,
                color: DashColors.muted,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
              decoration: BoxDecoration(
                color: levelColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: levelColor.withValues(alpha: 0.55)),
              ),
              child: Text(
                levelText.toUpperCase(),
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
