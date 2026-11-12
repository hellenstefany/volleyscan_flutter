import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../models/content_data.dart';
import '../../services/api_service.dart';
import '../../theme/app_theme.dart';
import '../../theme/dash_colors.dart';
import 'content_video_card.dart';

/// Modal de detalle de contenido educativo (`.video-modal` en `contenido.css` y `page.jsx`).
/// Consulta `GET /api/usuario/contenido/<id>/` al abrirse sin perder el filtro ni el scroll de la lista.
Future<void> showContentVideoDialog(
  BuildContext context,
  ContentVideo initialVideo,
) {
  return showDialog<void>(
    context: context,
    barrierColor: Colors.black.withValues(alpha: 0.75),
    builder: (_) => _ContentVideoDialog(initialVideo: initialVideo),
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
  bool _loadingDetail = true;
  String? _detailError;

  @override
  void initState() {
    super.initState();
    _video = widget.initialVideo;
    _fetchDetail();
  }

  Future<void> _fetchDetail() async {
    setState(() {
      _loadingDetail = true;
      _detailError = null;
    });
    try {
      final fresh = await ApiService().obtenerContenidoDetalle(
        widget.initialVideo.id,
      );
      if (!mounted) return;
      setState(() {
        _video = fresh;
        _loadingDetail = false;
      });
    } on ApiException catch (err) {
      if (!mounted) return;
      setState(() {
        _loadingDetail = false;
        _detailError = err.message;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loadingDetail = false;
        _detailError = 'No se pudo actualizar el detalle del contenido.';
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
    final metaText =
        video.hasDuration ? '$catLabel · ${video.duracion}' : catLabel;
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
              _buildScreen(watchUrl),
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
                    if (_detailError != null) _buildDetailError(),
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
                    const SizedBox(height: 14),
                    _buildWatchAction(watchUrl),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildScreen(String? watchUrl) {
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Container(color: Colors.black),
          VideoThumb(url: _video.resolvedThumbnailUrl),
          Container(color: Colors.black.withValues(alpha: 0.25)),
          Center(
            child: GestureDetector(
              onTap: watchUrl != null ? () => _copyWatchUrl(watchUrl) : null,
              child: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: DashColors.textPrimary.withValues(alpha: 0.9),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.play_arrow_rounded, color: DashColors.bg, size: 36),
              ),
            ),
          ),
          if (_loadingDetail)
            const Positioned(
              left: 12,
              top: 12,
              child: SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2, color: DashColors.blueLight),
              ),
            ),
          Positioned(
            right: 12,
            top: 12,
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.55),
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

  Widget _buildDetailError() {
    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: DashColors.surface,
        borderRadius: BorderRadius.circular(AppRadii.sm),
        border: Border.all(color: DashColors.red.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline_rounded, color: DashColors.red, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _detailError!,
              style: const TextStyle(
                fontFamily: 'Poppins',
                color: DashColors.errorText,
                fontSize: 12,
              ),
            ),
          ),
          TextButton(
            onPressed: _fetchDetail,
            child: const Text(
              'Reintentar',
              style: TextStyle(
                fontFamily: 'Poppins',
                color: DashColors.blueLight,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWatchAction(String? watchUrl) {
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
    final label = _video.youtubeId != null ? 'Ver en YouTube ($watchUrl)' : watchUrl;
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
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.open_in_new_rounded, size: 16, color: DashColors.blueLight),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                label,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
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
