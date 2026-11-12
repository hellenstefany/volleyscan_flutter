import 'package:flutter/material.dart';
import '../../models/content_data.dart';
import '../../services/api_service.dart';
import '../../theme/app_theme.dart';
import '../../theme/dash_colors.dart';

/// Etiqueta de categoría (`.video-card__cat-badge` / `.video-modal__cat` en `contenido.css`).
class CategoryBadge extends StatelessWidget {
  final String cat;
  const CategoryBadge({super.key, required this.cat});

  @override
  Widget build(BuildContext context) {
    final key = cat.trim().toLowerCase();
    final textColor = ContentData.catColor[key] ?? DashColors.accent2;
    final bgBase = ContentData.catBgBaseColor[key] ?? DashColors.blueLight;
    final label = ContentData.catLabel[key] ?? (cat.isEmpty ? 'General' : cat);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bgBase.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(AppRadii.sm),
      ),
      child: Text(
        label.toUpperCase(),
        style: TextStyle(
          fontFamily: 'Poppins',
          color: textColor,
          fontSize: 10,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.7,
        ),
      ),
    );
  }
}

/// Miniatura de video (`.video-card__thumb` / `.video-modal__thumb` en `contenido.css`).
/// Resuelve rutas relativas `/media/...` y nunca invoca `Image.network` con rutas vacías.
class VideoThumb extends StatelessWidget {
  final String? url;
  const VideoThumb({super.key, required this.url});

  Widget _placeholder() {
    return Container(
      color: DashColors.bg,
      alignment: Alignment.center,
      child: Icon(
        Icons.movie_creation_outlined,
        size: 32,
        color: DashColors.textMuted.withValues(alpha: 0.4),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final resolved = ApiService.resolveMediaUrl(url);
    if (resolved == null || resolved.isEmpty) {
      return _placeholder();
    }

    return Image.network(
      resolved,
      fit: BoxFit.cover,
      width: double.infinity,
      height: double.infinity,
      loadingBuilder: (_, child, progress) {
        if (progress == null) return child;
        return Container(
          color: DashColors.bg,
          alignment: Alignment.center,
          child: const SizedBox(
            width: 22,
            height: 22,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: DashColors.blueLight,
            ),
          ),
        );
      },
      errorBuilder: (_, _, _) => _placeholder(),
    );
  }
}

/// Tarjeta de video educativo (`.video-card` en `contenido.css`).
class ContentVideoCard extends StatelessWidget {
  final ContentVideo video;
  final VoidCallback onTap;

  const ContentVideoCard({
    super.key,
    required this.video,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: DashColors.surface,
          borderRadius: BorderRadius.circular(AppRadii.panel),
          border: Border.all(color: DashColors.border),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 16 / 9,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  VideoThumb(url: video.resolvedThumbnailUrl),
                  Container(color: Colors.black.withValues(alpha: 0.25)),
                  Center(
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: DashColors.textPrimary.withValues(alpha: 0.9),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.play_arrow_rounded,
                        color: DashColors.bg,
                        size: 24,
                      ),
                    ),
                  ),
                  Positioned(
                    left: 8,
                    top: 8,
                    child: CategoryBadge(cat: video.categoria),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    video.titulo,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      color: DashColors.textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      height: 1.3,
                    ),
                  ),
                  if (video.hasDuration) ...[
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(
                          Icons.access_time_rounded,
                          size: 13,
                          color: DashColors.textMuted,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            video.duracion!,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontFamily: 'Poppins',
                              color: DashColors.textMuted,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
