import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../models/content_data.dart';
import '../../services/api_service.dart';
import '../../theme/app_theme.dart';
import '../../theme/dash_colors.dart';
import 'content_video_card.dart';
import 'content_youtube_player.dart';

/// Estados del modal para garantizar que el reproductor solo se monte al estar listo.
enum _ModalState { loading, error, ready }

/// Modal de detalle de contenido educativo (`.video-modal` en `contenido.css` y `page.jsx`).
/// Usa `showGeneralDialog` con `FadeTransition` para eliminar la animación de escala (`ScaleTransition`)
/// de `showDialog`, evitando conflictos con `HtmlElementView` en Flutter Web.
Future<void> showContentVideoDialog(BuildContext context, ContentVideo initialVideo) {
  return showGeneralDialog<void>(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Cerrar video',
    barrierColor: Colors.black.withValues(alpha: 0.75),
    transitionDuration: const Duration(milliseconds: 180),
    transitionBuilder: (_, anim, secondaryAnim, child) => FadeTransition(opacity: anim, child: child),
    pageBuilder: (context, anim, secondaryAnim) => Center(child: _ContentVideoDialog(initialVideo: initialVideo)),
  );
}

class _ContentVideoDialog extends StatefulWidget {
  final ContentVideo initialVideo;
  const _ContentVideoDialog({required this.initialVideo});

  @override
  State<_ContentVideoDialog> createState() => _ContentVideoDialogState();
}

class _ContentVideoDialogState extends State<_ContentVideoDialog> {
  late ContentVideo _video;
  _ModalState _state = _ModalState.loading;
  String? _detailError;

  @override
  void initState() {
    super.initState();
    _video = widget.initialVideo;
    _fetchDetail();
  }

  Future<void> _fetchDetail() async {
    setState(() {
      _state = _ModalState.loading;
      _detailError = null;
    });
    try {
      final fresh = await ApiService().obtenerContenidoDetalle(widget.initialVideo.id);
      if (!mounted) return;
      setState(() {
        _video = fresh;
        _state = _ModalState.ready;
      });
    } on ApiException catch (err) {
      if (!mounted) return;
      setState(() {
        _detailError = err.message;
        _state = _ModalState.error;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _detailError = 'No se pudo actualizar el detalle del contenido.';
        _state = _ModalState.error;
      });
    }
  }

  Future<void> _copyWatchUrl(String url) async {
    await Clipboard.setData(ClipboardData(text: url));
    if (!mounted) return;
    showAppToast(context, '✓ Enlace del video copiado al portapapeles.');
  }

  @override
  Widget build(BuildContext context) {
    final video = _video;
    final key = video.categoria.trim().toLowerCase();
    final catLabel = ContentData.catLabel[key] ?? video.categoria;
    final metaText = video.hasDuration ? '$catLabel · ${video.duracion}' : catLabel;
    final watchUrl = video.watchUrl;

    return Dialog(
      backgroundColor: DashColors.card,
      insetPadding: const EdgeInsets.all(20),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadii.authCard),
        side: const BorderSide(color: DashColors.border2),
      ),
      clipBehavior: Clip.antiAlias,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 560),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildPlayerScreen(video, watchUrl),
              Padding(
                padding: const EdgeInsets.fromLTRB(22, 20, 22, 22),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CategoryBadge(cat: video.categoria),
                    const SizedBox(height: 10),
                    Text(
                      video.titulo,
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        color: DashColors.textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      metaText,
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        color: DashColors.textMuted,
                        fontSize: 12.5,
                      ),
                    ),
                    if (video.hasDescription) ...[
                      const SizedBox(height: 12),
                      Text(
                        video.descripcion!,
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          color: DashColors.textSecondary,
                          fontSize: 13.5,
                          height: 1.6,
                        ),
                      ),
                    ],
                    const SizedBox(height: 16),
                    _buildCopyLinkAction(watchUrl),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlayerScreen(ContentVideo video, String? watchUrl) {
    switch (_state) {
      case _ModalState.loading:
        return _buildScreenFrame(
          video: video,
          overlayOpacity: 0.6,
          child: const Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 32,
                  height: 32,
                  child: CircularProgressIndicator(strokeWidth: 2.5, color: DashColors.blueLight),
                ),
                SizedBox(height: 12),
                Text('Cargando contenido...', style: TextStyle(fontFamily: 'Poppins', color: DashColors.textMuted, fontSize: 12)),
              ],
            ),
          ),
        );
      case _ModalState.error:
        return _buildScreenFrame(
          video: video,
          overlayOpacity: 0.75,
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline_rounded, color: DashColors.red, size: 36),
                  const SizedBox(height: 8),
                  Text(_detailError ?? 'No se pudo cargar el video.', textAlign: TextAlign.center, style: const TextStyle(fontFamily: 'Poppins', color: DashColors.errorText, fontSize: 12)),
                  const SizedBox(height: 10),
                  TextButton.icon(
                    style: TextButton.styleFrom(foregroundColor: DashColors.blueLight, backgroundColor: DashColors.surface),
                    onPressed: _fetchDetail,
                    icon: const Icon(Icons.refresh_rounded, size: 16),
                    label: const Text('Reintentar', style: TextStyle(fontFamily: 'Poppins', fontSize: 12, fontWeight: FontWeight.w600)),
                  ),
                ],
              ),
            ),
          ),
        );
      case _ModalState.ready:
        final ytId = video.youtubeId;
        if (ytId != null && ytId.isNotEmpty) {
          return ContentYoutubePlayer(
            key: ValueKey('yt_player_${video.id}_$ytId'),
            youtubeId: ytId,
            thumbnailUrl: video.resolvedThumbnailUrl,
            watchUrl: watchUrl,
            onClose: () => Navigator.pop(context),
          );
        }
        return _buildScreenFrame(
          video: video,
          overlayOpacity: 0.35,
          child: const Center(child: Icon(Icons.play_circle_fill_rounded, color: Colors.white, size: 56)),
        );
    }
  }

  Widget _buildScreenFrame({
    required ContentVideo video,
    required double overlayOpacity,
    required Widget child,
  }) {
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Container(color: Colors.black),
          VideoThumb(url: video.resolvedThumbnailUrl),
          Container(color: Colors.black.withValues(alpha: overlayOpacity)),
          child,
          Positioned(
            right: 12,
            top: 12,
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.6),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.close_rounded, color: DashColors.textPrimary, size: 18),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCopyLinkAction(String? watchUrl) {
    if (watchUrl == null) {
      return const Text(
        'Video próximamente.',
        style: TextStyle(
          fontFamily: 'Poppins',
          color: DashColors.textSecondary,
          fontSize: 13.5,
        ),
      );
    }
    return InkWell(
      borderRadius: BorderRadius.circular(AppRadii.sm),
      onTap: () => _copyWatchUrl(watchUrl),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: DashColors.surface,
          borderRadius: BorderRadius.circular(AppRadii.sm),
          border: Border.all(color: DashColors.border2),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.copy_rounded, size: 16, color: DashColors.blueLight),
            SizedBox(width: 8),
            Flexible(
              child: Text(
                'Copiar enlace del video',
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  color: DashColors.blueLight,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
