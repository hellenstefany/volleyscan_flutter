import 'package:flutter/material.dart';
import '../../models/content_data.dart';
import '../../theme/routine_colors.dart';

/// Etiqueta de categoría (SAQUE, RECEPCIÓN...).
class CategoryBadge extends StatelessWidget {
  final String cat;
  const CategoryBadge({super.key, required this.cat});

  @override
  Widget build(BuildContext context) {
    final color = ContentData.catColor[cat] ?? RoutineColors.blue;
    final label = ContentData.catLabel[cat] ?? cat;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label.toUpperCase(),
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w700,
          letterSpacing: 1,
        ),
      ),
    );
  }
}

/// Imagen con degradado de carga y recuadro oscuro si falla.
class VideoThumb extends StatelessWidget {
  final String url;
  const VideoThumb({super.key, required this.url});

  @override
  Widget build(BuildContext context) {
    return Image.network(
      url,
      fit: BoxFit.cover,
      width: double.infinity,
      height: double.infinity,
      loadingBuilder: (_, child, progress) =>
          progress == null ? child : Container(color: const Color(0xFF0F172A)),
      errorBuilder: (_, __, ___) => Container(color: const Color(0xFF0F172A)),
    );
  }
}

class ContentVideoCard extends StatelessWidget {
  final ContentVideo video;
  final VoidCallback onTap;

  const ContentVideoCard({super.key, required this.video, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: RoutineColors.cardDark,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: RoutineColors.border),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 110,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    VideoThumb(url: video.imageUrl),
                    Container(color: Colors.black.withOpacity(0.2)),
                    Center(
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.92),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.play_arrow_rounded,
                          color: Color(0xFF0B1226),
                          size: 26,
                        ),
                      ),
                    ),
                    Positioned(
                      left: 8,
                      top: 8,
                      child: CategoryBadge(cat: video.cat),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      video.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        height: 1.25,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(
                          Icons.access_time_rounded,
                          size: 13,
                          color: RoutineColors.textMuted,
                        ),
                        const SizedBox(width: 5),
                        Expanded(
                          child: Text(
                            video.duration,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: RoutineColors.textMuted,
                              fontSize: 12,
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
        ),
      ),
    );
  }
}
