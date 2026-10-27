import 'package:flutter/material.dart';
import '../../models/content_data.dart';
import '../../theme/routine_colors.dart';
import 'content_video_card.dart';

/// Ventana con el detalle del video (equivale al modal del JSX).
Future<void> showContentVideoDialog(BuildContext context, ContentVideo video) {
  return showDialog<void>(
    context: context,
    builder: (_) => _ContentVideoDialog(video: video),
  );
}

class _ContentVideoDialog extends StatelessWidget {
  final ContentVideo video;
  const _ContentVideoDialog({required this.video});

  @override
  Widget build(BuildContext context) {
    final label = ContentData.catLabel[video.cat] ?? video.cat;

    return Dialog(
      backgroundColor: RoutineColors.card,
      insetPadding: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: RoutineColors.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 560),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AspectRatio(
                aspectRatio: 16 / 9,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    VideoThumb(url: video.imageUrl),
                    Container(color: Colors.black.withOpacity(0.25)),
                    // TODO: aquí va el reproductor de video (paquete
                    // `video_player`). Por ahora solo se muestra la portada.
                    Center(
                      child: Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.92),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.play_arrow_rounded,
                          color: Color(0xFF0B1226),
                          size: 38,
                        ),
                      ),
                    ),
                    Positioned(
                      right: 10,
                      top: 10,
                      child: GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.55),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.close_rounded,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CategoryBadge(cat: video.cat),
                    const SizedBox(height: 12),
                    Text(
                      video.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '$label · ${video.duration}',
                      style: const TextStyle(
                        color: RoutineColors.textMuted,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      video.desc,
                      style: const TextStyle(
                        color: Color(0xFFCBD5E1),
                        fontSize: 14.5,
                        height: 1.45,
                      ),
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
