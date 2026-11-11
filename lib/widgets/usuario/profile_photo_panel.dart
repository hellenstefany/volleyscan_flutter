import 'package:flutter/material.dart';
import '../../theme/dash_colors.dart';
import 'profile_avatar.dart';
import 'profile_field.dart';

/// Bloque de foto de perfil dentro de "Información personal" (`.pf-foto-panel` en Next).
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
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: DashColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: DashColors.border),
      ),
      child: Row(
        children: [
          ProfileAvatar(
            name: name,
            photoPath: photoUrl,
            size: 76,
            cornerRadius: 16,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const FieldLabel('Foto de perfil'),
                const SizedBox(height: 4),
                const Text(
                  'JPG, PNG o WEBP · máx. 2 MB',
                  style: TextStyle(fontSize: 11, color: DashColors.muted),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    SizedBox(
                      height: 34,
                      child: ElevatedButton(
                        onPressed: uploading ? null : onChangePhoto,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: DashColors.blueLight,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(9),
                          ),
                        ),
                        child: Text(
                          uploading ? 'Subiendo…' : 'Cambiar foto',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    if (hasPhoto)
                      SizedBox(
                        height: 34,
                        child: OutlinedButton(
                          onPressed: uploading ? null : onRemovePhoto,
                          style: OutlinedButton.styleFrom(
                            foregroundColor: DashColors.red,
                            side: BorderSide(
                              color: DashColors.red.withValues(alpha: 0.45),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(9),
                            ),
                          ),
                          child: const Text(
                            'Quitar foto',
                            style: TextStyle(
                              fontSize: 12,
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
      ),
    );
  }
}
