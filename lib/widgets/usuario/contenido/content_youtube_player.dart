import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';
import '../../../theme/app_theme.dart';
import '../../../theme/dash_colors.dart';
import 'content_video_card.dart';

/// Plataformas con implementación de WebView para `youtube_player_iframe` 6.0.2
/// (pubspec del paquete: android, ios, macos y web). Windows y Linux no la tienen.
bool get isYoutubePlayerSupported {
  if (kIsWeb) return true;
  switch (defaultTargetPlatform) {
    case TargetPlatform.android:
    case TargetPlatform.iOS:
    case TargetPlatform.macOS:
      return true;
    default:
      return false;
  }
}

Future<void> openYoutubeExternally(String url) async {
  final uri = Uri.tryParse(url);
  if (uri == null) return;
  try {
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  } catch (_) {}
}

/// Respaldo para plataformas sin WebView: miniatura + botón "Abrir en YouTube".
/// No instancia `YoutubePlayerController` ni `YoutubePlayer`.
class ContentYoutubeFallback extends StatelessWidget {
  final String? thumbnailUrl;
  final String? watchUrl;
  final VoidCallback? onClose;

  const ContentYoutubeFallback({super.key, this.thumbnailUrl, this.watchUrl, this.onClose});

  @override
  Widget build(BuildContext context) {
    final url = watchUrl;
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Container(color: Colors.black),
          VideoThumb(url: thumbnailUrl),
          Container(color: Colors.black.withValues(alpha: 0.45)),
          if (url != null && url.isNotEmpty)
            Center(
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: DashColors.red,
                  foregroundColor: DashColors.textPrimary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadii.sm)),
                ),
                onPressed: () => openYoutubeExternally(url),
                icon: const Icon(Icons.open_in_new_rounded, size: 16),
                label: const Text('Abrir en YouTube',
                    style: TextStyle(fontFamily: 'Poppins', fontSize: 12.5, fontWeight: FontWeight.w600)),
              ),
            ),
          if (onClose != null)
            Positioned(
              right: 12,
              top: 12,
              child: GestureDetector(
                onTap: onClose,
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.6), shape: BoxShape.circle),
                  child: const Icon(Icons.close_rounded, color: DashColors.textPrimary, size: 18),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Reproductor incrustado de YouTube en proporción 16:9 (`.video-modal__screen`).
///
/// - Key estable para evitar reciclaje erróneo de elementos en Web.
/// - Controlador único creado en `initState` y liberado en `dispose` con `close()`.
/// - Detección de errores (101/150, video no disponible) con botón de respaldo "Abrir en YouTube".
class ContentYoutubePlayer extends StatefulWidget {
  final String youtubeId;
  final String? thumbnailUrl;
  final String? watchUrl;
  final VoidCallback? onClose;
  final bool autoPlay;

  const ContentYoutubePlayer({
    super.key,
    required this.youtubeId,
    this.thumbnailUrl,
    this.watchUrl,
    this.onClose,
    this.autoPlay = true,
  });

  @override
  State<ContentYoutubePlayer> createState() => _ContentYoutubePlayerState();
}

class _ContentYoutubePlayerState extends State<ContentYoutubePlayer> {
  late final YoutubePlayerController _controller;
  StreamSubscription<YoutubePlayerValue>? _sub;
  YoutubeError _error = YoutubeError.none;

  @override
  void initState() {
    super.initState();
    _controller = YoutubePlayerController.fromVideoId(
      videoId: widget.youtubeId,
      autoPlay: widget.autoPlay,
      params: const YoutubePlayerParams(
        showFullscreenButton: true,
        showControls: true,
        mute: false,
        enableCaption: false,
      ),
    );
    _sub = _controller.stream.listen((value) {
      if (value.hasError && value.error != _error && mounted) {
        setState(() => _error = value.error);
      }
    });
  }

  @override
  void dispose() {
    _sub?.cancel();
    _controller.stopVideo();
    _controller.close();
    super.dispose();
  }

  String _resolveErrorMessage(YoutubeError error) {
    switch (error) {
      case YoutubeError.notEmbeddable:
      case YoutubeError.sameAsNotEmbeddable:
      case YoutubeError.sameAsNotEmbeddable2:
        return 'El autor no permite reproducir este video insertado en aplicaciones.';
      case YoutubeError.videoNotFound:
        return 'El video no fue encontrado o ha sido eliminado.';
      case YoutubeError.html5Error:
        return 'Error en el reproductor HTML5 del video.';
      default:
        return 'No fue posible reproducir este video en la aplicación.';
    }
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Container(color: Colors.black),
          YoutubePlayer(
            key: ValueKey('inner_yt_${widget.youtubeId}'),
            controller: _controller,
            aspectRatio: 16 / 9,
            backgroundColor: Colors.black,
          ),
          if (_error != YoutubeError.none) _buildErrorOverlay(_error),
          if (widget.onClose != null)
            Positioned(
              right: 12,
              top: 12,
              child: GestureDetector(
                onTap: widget.onClose,
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.6),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.close_rounded,
                    color: DashColors.textPrimary,
                    size: 18,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildErrorOverlay(YoutubeError error) {
    final msg = _resolveErrorMessage(error);
    final fallbackUrl = widget.watchUrl;

    return Container(
      color: DashColors.cardDark.withValues(alpha: 0.95),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.videocam_off_outlined,
                color: DashColors.orange,
                size: 38,
              ),
              const SizedBox(height: 10),
              Text(
                msg,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  color: DashColors.textPrimary,
                  fontSize: 12.5,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 14),
              if (fallbackUrl != null && fallbackUrl.isNotEmpty)
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: DashColors.red,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadii.sm),
                    ),
                  ),
                  onPressed: () => openYoutubeExternally(fallbackUrl),
                  icon: const Icon(Icons.open_in_new_rounded, size: 16),
                  label: const Text(
                    'Abrir en YouTube',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
