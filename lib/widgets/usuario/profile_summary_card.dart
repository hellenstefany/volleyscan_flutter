import 'package:flutter/material.dart';
import '../../models/profile_data.dart';
import '../../theme/app_theme.dart';
import '../../theme/dash_colors.dart';
import 'dash_card.dart';
import 'profile_avatar.dart';

/// Tarjeta superior del perfil (`.identity-card` en `perfil.css`):
/// foto con borde `--accent-blue`, nombre (`#fff`), rol (`--text-muted`) y `.badge--level` (`--accent-yellow`).
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

  static String _levelLabel(String? rawLevel) {
    final key = (rawLevel ?? '').toLowerCase();
    return ProfileData.nivelLabels[key] ??
        (rawLevel != null && rawLevel.trim().isNotEmpty
            ? rawLevel.trim()
            : 'Principiante');
  }

  @override
  Widget build(BuildContext context) {
    final levelText = _levelLabel(level);

    return SizedBox(
      width: double.infinity,
      child: DashCard(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 22),
        borderRadius: AppRadii.md,
        child: Column(
          children: [
            SizedBox(
              width: 84,
              height: 84,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: DashColors.blueLight,
                        width: 2,
                      ),
                    ),
                    child: ProfileAvatar(
                      name: name,
                      photoPath: photoPath,
                      size: 76,
                    ),
                  ),
                  Positioned(
                    right: 2,
                    bottom: 2,
                    child: Container(
                      width: 26,
                      height: 26,
                      decoration: BoxDecoration(
                        color: DashColors.blueLight,
                        shape: BoxShape.circle,
                        border: Border.all(color: DashColors.card, width: 2),
                      ),
                      child: const Icon(
                        Icons.edit_rounded,
                        size: 12,
                        color: DashColors.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Text(
              name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: DashColors.textPrimary,
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
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
              decoration: BoxDecoration(
                color: DashColors.accentYellow.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: DashColors.accentYellow.withValues(alpha: 0.30),
                ),
              ),
              child: Text(
                levelText.toUpperCase(),
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.6,
                  color: DashColors.accentYellow,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
