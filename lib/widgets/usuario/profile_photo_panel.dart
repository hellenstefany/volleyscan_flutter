import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../theme/dash_colors.dart';
import 'profile_avatar.dart';
import 'profile_field.dart';

/// Bloque de foto de perfil dentro de "Información personal" (`.section-photo` en `perfil.css`):
/// vista previa con borde `2px solid var(--border-bright)`, botón primario (`--accent-blue`)
/// y botón secundario "Quitar foto" (`--bg-surface`, `--text-secondary`, `--border-bright`).
class ProfilePhotoPanel extends StatelessWidget {
  const ProfilePhotoPanel({
    super.key,
    required this.name,
    required this.photoUrl,
    required this.uploading,
    required this.onChangePhoto,
    required this.onRemovePhoto,
  });

  final String name;
  final String? photoUrl;
  final bool uploading;
  final VoidCallback onChangePhoto;
  final VoidCallback onRemovePhoto;

  @override
  Widget build(BuildContext context) {
    final hasPhoto = (photoUrl ?? '').trim().isNotEmpty;
    return Row(
      children: [
        Container(
          width: 84,
          height: 84,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadii.md),
            border: Border.all(color: DashColors.border2, width: 2),
          ),
          child: ProfileAvatar(
            name: name,
            photoPath: photoUrl,
            size: 80,
            cornerRadius: AppRadii.panel,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const FieldLabel('Foto de perfil'),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  SizedBox(
                    height: 36,
                    child: ElevatedButton.icon(
                      onPressed: uploading ? null : onChangePhoto,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: DashColors.blueLight,
                        disabledBackgroundColor:
                            DashColors.blueLight.withValues(alpha: 0.55),
                        foregroundColor: DashColors.textPrimary,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppRadii.sm),
                        ),
                      ),
                      icon: const Icon(Icons.camera_alt_rounded, size: 14),
                      label: Text(
                        uploading ? 'Subiendo…' : 'Cambiar foto',
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  if (hasPhoto)
                    SizedBox(
                      height: 36,
                      child: OutlinedButton(
                        onPressed: uploading ? null : onRemovePhoto,
                        style: OutlinedButton.styleFrom(
                          backgroundColor: DashColors.surface,
                          foregroundColor: DashColors.textSecondary,
                          side: const BorderSide(color: DashColors.border2),
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppRadii.sm),
                          ),
                        ),
                        child: const Text(
                          'Quitar foto',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
