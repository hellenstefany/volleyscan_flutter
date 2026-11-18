/// Modelos de la pantalla "Notificaciones" (`/usuario/notificaciones`) alineados
/// con `VolleyScan_Next/src/app/usuario/notificaciones/page.jsx` y
/// `Backend_VolleyScan/vinculos/avisos.py`.
enum NotificationType {
  logro,
  rutina,
  racha,
  recordatorio,
  analisis,
  vinculo,
  equipo,
  otro;

  static NotificationType fromApi(String? raw) {
    switch ((raw ?? '').trim().toLowerCase()) {
      case 'logro':
        return NotificationType.logro;
      case 'rutina':
        return NotificationType.rutina;
      case 'racha':
        return NotificationType.racha;
      case 'recordatorio':
        return NotificationType.recordatorio;
      case 'analisis':
        return NotificationType.analisis;
      case 'vinculo':
        return NotificationType.vinculo;
      case 'equipo':
        return NotificationType.equipo;
      default:
        return NotificationType.otro;
    }
  }
}

class AppNotification {
  final int id;
  final NotificationType type;
  final String rawType;
  final bool unread;
  final String title;
  final String msg;
  final int haceSeg;
  final String time;
  final String? link;

  const AppNotification({
    required this.id,
    required this.type,
    required this.rawType,
    required this.unread,
    required this.title,
    required this.msg,
    required this.haceSeg,
    required this.time,
    this.link,
  });

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    final tipo = (json['tipo'] ?? '').toString().trim().toLowerCase();
    final seg = _toInt(json['haceSeg']) ?? 0;
    final rawLink = json['enlace']?.toString().trim();
    return AppNotification(
      id: _toInt(json['id']) ?? 0,
      type: NotificationType.fromApi(tipo),
      rawType: tipo,
      unread: json['leida'] != true,
      title: (json['titulo'] ?? '').toString().trim(),
      msg: (json['mensaje'] ?? '').toString().trim(),
      haceSeg: seg,
      time: formatRelativeSeconds(seg),
      link: (rawLink != null && rawLink.isNotEmpty) ? rawLink : null,
    );
  }

  AppNotification copyWith({bool? unread}) => AppNotification(
        id: id,
        type: type,
        rawType: rawType,
        unread: unread ?? this.unread,
        title: title,
        msg: msg,
        haceSeg: haceSeg,
        time: time,
        link: link,
      );
}

class AvisosListResponse {
  final List<AppNotification> avisos;
  final int noLeidas;

  const AvisosListResponse({
    this.avisos = const <AppNotification>[],
    this.noLeidas = 0,
  });

  factory AvisosListResponse.fromJson(Map<String, dynamic> json) {
    final rawList = json['avisos'];
    final list = rawList is List
        ? rawList
            .whereType<Map>()
            .map((e) => AppNotification.fromJson(Map<String, dynamic>.from(e)))
            .toList()
        : const <AppNotification>[];
    return AvisosListResponse(
      avisos: list,
      noLeidas: _toInt(json['noLeidas']) ?? 0,
    );
  }
}

class NotificationFilter {
  final String value;
  final String label;
  const NotificationFilter(this.value, this.label);
}

enum RecommendationTarget { routines, analysis }

class Recommendation {
  final int id;
  final String title;
  final String desc;
  final String imageUrl;
  final RecommendationTarget target;

  const Recommendation({
    required this.id,
    required this.title,
    required this.desc,
    required this.imageUrl,
    required this.target,
  });
}

class NotificationsData {
  static const recommendations = [
    Recommendation(
      id: 1,
      title: 'Enfócate en tu salto',
      desc: 'Mejora la altura y la explosividad.',
      imageUrl:
          'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?w=400&q=75',
      target: RecommendationTarget.routines,
    ),
    Recommendation(
      id: 2,
      title: 'Trabaja tu recepción',
      desc: 'Practica la plataforma más baja.',
      imageUrl:
          'https://images.unsplash.com/photo-1574629810360-7efbbe195018?w=400&q=75',
      target: RecommendationTarget.routines,
    ),
    Recommendation(
      id: 3,
      title: 'Analiza tu saque',
      desc: 'Detecta errores con la IA en tiempo real.',
      imageUrl:
          'https://images.unsplash.com/photo-1547347298-4074fc3086f0?w=400&q=75',
      target: RecommendationTarget.analysis,
    ),
  ];

  static const filters = [
    NotificationFilter('all', 'Todas'),
    NotificationFilter('unread', 'Sin leer'),
    NotificationFilter('logro', 'Logros'),
    NotificationFilter('rutina', 'Rutinas'),
    NotificationFilter('racha', 'Rachas'),
    NotificationFilter('analisis', 'Análisis'),
    NotificationFilter('vinculo', 'Entrenador'),
    NotificationFilter('recordatorio', 'Recordatorios'),
  ];
}

/// Replica `haceTexto(seg)` de `VolleyScan_Next/src/app/usuario/notificaciones/page.jsx`.
String formatRelativeSeconds(int seg) {
  String plural(int n, String uno, String varios) =>
      'Hace $n ${n == 1 ? uno : varios}';
  if (seg < 60) return 'Hace un momento';
  final min = seg ~/ 60;
  if (min < 60) return plural(min, 'minuto', 'minutos');
  final h = min ~/ 60;
  if (h < 24) return plural(h, 'hora', 'horas');
  final d = h ~/ 24;
  if (d < 7) return plural(d, 'día', 'días');
  final sem = d ~/ 7;
  if (sem < 5) return plural(sem, 'semana', 'semanas');
  final mes = d ~/ 30;
  return plural(mes > 0 ? mes : 1, 'mes', 'meses');
}

int? _toInt(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value.toString());
}
