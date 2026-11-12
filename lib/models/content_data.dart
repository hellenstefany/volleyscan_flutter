import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../theme/dash_colors.dart';

/// Modelo de un video educativo (`GET /api/usuario/contenido/` y `/<id>/`).
/// Replica la estructura de `ContenidoSerializer` en `Backend_VolleyScan`
/// y `normalizarVideo(v)` en `VolleyScan_Next/src/app/usuario/contenido/page.jsx`.
class ContentVideo {
  final int id;
  final String titulo;
  final String categoria; // saque, recepcion, bloqueo, pose, preparacion
  final String? duracion;
  final String? descripcion;
  final String? videoUrl;
  final String? imagenUrl;
  final String? youtubeId;
  final String? embedUrl;
  final String? miniaturaUrl;

  const ContentVideo({
    required this.id,
    required this.titulo,
    required this.categoria,
    this.duracion,
    this.descripcion,
    this.videoUrl,
    this.imagenUrl,
    this.youtubeId,
    this.embedUrl,
    this.miniaturaUrl,
  });

  // Getters de compatibilidad semántica
  String get cat => categoria;
  String get title => titulo;
  String get duration => duracion ?? '';
  String get desc => descripcion ?? '';
  String get imageUrl => resolvedThumbnailUrl ?? '';

  bool get hasDuration => duracion != null && duracion!.trim().isNotEmpty;
  bool get hasDescription =>
      descripcion != null && descripcion!.trim().isNotEmpty;

  /// Extrae el ID de 11 caracteres de cualquier URL de YouTube
  /// (`watch?v=`, `embed/`, `shorts/`, `youtu.be/`), igual que en Next y Backend.
  static final RegExp _ytRegex = RegExp(
    r'(?:youtube\.com\/(?:watch\?v=|embed\/|shorts\/)|youtu\.be\/)([a-zA-Z0-9_-]{11})',
  );

  static String? extractYoutubeId(String? url) {
    if (url == null || url.trim().isEmpty) return null;
    final match = _ytRegex.firstMatch(url.trim());
    return match?.group(1);
  }

  /// URL de miniatura resuelta contra el backend si es ruta relativa (`/media/...`),
  /// o generada desde `youtubeId` si el backend o `videoUrl` corresponden a YouTube.
  String? get resolvedThumbnailUrl {
    final rawMini = miniaturaUrl?.trim();
    if (rawMini != null && rawMini.isNotEmpty) {
      return ApiService.resolveMediaUrl(rawMini);
    }
    final yt = youtubeId?.trim();
    if (yt != null && yt.isNotEmpty) {
      return 'https://i.ytimg.com/vi/$yt/hqdefault.jpg';
    }
    final rawImg = imagenUrl?.trim();
    if (rawImg != null && rawImg.isNotEmpty) {
      return ApiService.resolveMediaUrl(rawImg);
    }
    return null;
  }

  /// URL para abrir/ver el video en YouTube o enlace directo si existe.
  String? get watchUrl {
    final yt = youtubeId?.trim();
    if (yt != null && yt.isNotEmpty) {
      return 'https://www.youtube.com/watch?v=$yt';
    }
    final rawVideo = videoUrl?.trim();
    if (rawVideo != null && rawVideo.isNotEmpty) {
      return ApiService.resolveMediaUrl(rawVideo);
    }
    return null;
  }

  static String? _cleanNullableString(dynamic value) {
    if (value == null) return null;
    final text = value.toString().trim();
    return text.isEmpty ? null : text;
  }

  factory ContentVideo.fromJson(Map<String, dynamic> json) {
    final rawVideoUrl = _cleanNullableString(json['video_url']);
    final rawYtId =
        _cleanNullableString(json['youtube_id']) ?? extractYoutubeId(rawVideoUrl);
    final rawImgUrl = _cleanNullableString(json['imagen_url']);
    final rawMiniUrl = _cleanNullableString(json['miniatura_url']) ??
        (rawYtId != null
            ? 'https://i.ytimg.com/vi/$rawYtId/hqdefault.jpg'
            : rawImgUrl);
    final rawEmbedUrl = _cleanNullableString(json['embed_url']) ??
        (rawYtId != null
            ? 'https://www.youtube-nocookie.com/embed/$rawYtId?rel=0'
            : null);

    return ContentVideo(
      id: (json['id'] as num?)?.toInt() ?? 0,
      titulo: (json['titulo'] ?? '').toString().trim(),
      categoria: (json['categoria'] ?? '').toString().trim().toLowerCase(),
      duracion: _cleanNullableString(json['duracion']),
      descripcion: _cleanNullableString(json['descripcion']),
      videoUrl: rawVideoUrl,
      imagenUrl: rawImgUrl,
      youtubeId: rawYtId,
      embedUrl: rawEmbedUrl,
      miniaturaUrl: rawMiniUrl,
    );
  }
}

class ContentTab {
  final String value;
  final String label;
  const ContentTab(this.value, this.label);
}

/// Constantes de categorías, etiquetas y colores de `contenido.css` y `page.jsx`.
class ContentData {
  ContentData._();

  static const int pageSize = 6;

  static const Map<String, String> catLabel = {
    'saque': 'Saque',
    'recepcion': 'Recepción',
    'bloqueo': 'Bloqueo',
    'pose': 'Pose',
    'preparacion': 'Preparación física',
  };

  /// Colores de texto de `.badge-<cat>` en `contenido.css`.
  static const Map<String, Color> catColor = {
    'saque': DashColors.accent2, // #60a5fa
    'recepcion': DashColors.badgeRecepcionText, // #4ade80
    'bloqueo': DashColors.badgeBloqueoText, // #c084fc
    'pose': DashColors.amber, // #fbbf24
    'preparacion': DashColors.badgePrepText, // #2dd4bf
  };

  /// Colores base para el fondo semitransparente (`alpha: 0.2`) de `.badge-<cat>`.
  static const Map<String, Color> catBgBaseColor = {
    'saque': DashColors.blueLight, // rgba(59, 130, 246, .2)
    'recepcion': DashColors.green, // rgba(34, 197, 94, .2)
    'bloqueo': DashColors.purple, // rgba(168, 85, 247, .2)
    'pose': DashColors.accentYellow, // rgba(234, 179, 8, .2)
    'preparacion': DashColors.teal, // rgba(20, 184, 166, .2)
  };

  static const List<ContentTab> tabs = [
    ContentTab('all', 'Todos'),
    ContentTab('saque', 'Saque'),
    ContentTab('recepcion', 'Recepción'),
    ContentTab('bloqueo', 'Bloqueo'),
    ContentTab('pose', 'Pose'),
    ContentTab('preparacion', 'Preparación física'),
  ];
}
