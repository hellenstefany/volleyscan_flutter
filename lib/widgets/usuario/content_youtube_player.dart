import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';
import '../../theme/app_theme.dart';
import '../../theme/dash_colors.dart';

/// Reproductor incrustado de YouTube en proporción 16:9 (`.video-modal__screen`).
///
/// - Inicializa el controlador iframe con `autoPlay: true`.
/// - Libera el controlador y silencia el video al desmontarse (`dispose`).
/// - Muestra estado de carga inicial.
/// - Si el video falla o no permite incrustarse (ej. errores 101/150),
///   despliega mensaje y botón de respaldo "Abrir en YouTube".
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
  late YoutubePlayerController _controller;

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
  }

  @override
  void didUpdateWidget(covariant ContentYoutubePlayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.youtubeId != widget.youtubeId) {
      _controller.loadVideoById(videoId: widget.youtubeId);
    }
  }

  @override
  void dispose() {
    _controller.stopVideo();
    _controller.close();
    super.dispose();
  }

  Future<void> _openExternal(String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null) return;
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      // Si el navegador externo falla, no interrumpir la app
    }
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
            controller: _controller,
            aspectRatio: 16 / 9,
            backgroundColor: Colors.black,
          ),
          YoutubeValueBuilder(
            controller: _controller,
            builder: (context, value) {
              if (value.hasError) {
                return _buildErrorOverlay(value.error);
              }
              if (value.playerState == PlayerState.unknown) {
                return _buildLoadingIndicator();
              }
              return const SizedBox.shrink();
            },
          ),
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

  Widget _buildLoadingIndicator() {
    return Positioned(
      left: 12,
      top: 12,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.65),
          borderRadius: BorderRadius.circular(AppRadii.sm),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 14,
              height: 14,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: DashColors.blueLight,
              ),
            ),
            SizedBox(width: 8),
            Text(
              'Cargando...',
              style: TextStyle(
                fontFamily: 'Poppins',
                color: DashColors.textMuted,
                fontSize: 11,
              ),
            ),
          ],
        ),
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
                  onPressed: () => _openExternal(fallbackUrl),
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
