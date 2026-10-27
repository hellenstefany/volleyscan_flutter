enum NotificationType { logro, rutina, racha, recordatorio, analisis }

class AppNotification {
  final int id;
  final NotificationType type;
  final bool unread;
  final String title;
  final String msg;
  final String time;

  const AppNotification({
    required this.id,
    required this.type,
    required this.unread,
    required this.title,
    required this.msg,
    required this.time,
  });

  AppNotification copyWith({bool? unread}) => AppNotification(
    id: id,
    type: type,
    unread: unread ?? this.unread,
    title: title,
    msg: msg,
    time: time,
  );
}

class NotificationFilter {
  final String value; // 'all', 'unread' o el nombre de un NotificationType
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
  /// Datos de ejemplo. Reemplázalos por la respuesta de tu API.
  static const initial = [
    AppNotification(
      id: 1,
      type: NotificationType.logro,
      unread: true,
      title: '¡Buen trabajo! 🏆',
      msg: 'Has mejorado tu puntuación promedio en un 15% esta semana.',
      time: 'Hace 2 horas',
    ),
    AppNotification(
      id: 2,
      type: NotificationType.rutina,
      unread: true,
      title: 'Nueva rutina disponible',
      msg: 'Tu entrenador ha creado una nueva rutina para ti.',
      time: 'Hace 1 día',
    ),
    AppNotification(
      id: 3,
      type: NotificationType.racha,
      unread: true,
      title: 'Racha en progreso 🔥',
      msg: 'Llevas 5 días entrenando seguidos. ¡Sigue así!',
      time: 'Hace 1 día',
    ),
    AppNotification(
      id: 4,
      type: NotificationType.recordatorio,
      unread: false,
      title: 'Recordatorio',
      msg: 'No olvides realizar tu rutina diaria.',
      time: 'Hace 2 días',
    ),
    AppNotification(
      id: 5,
      type: NotificationType.analisis,
      unread: false,
      title: 'Análisis completado ⚡',
      msg:
          'Tu análisis de "Remate por zona 4" ya está listo. Puntuación: 85/100.',
      time: 'Hace 3 días',
    ),
    AppNotification(
      id: 6,
      type: NotificationType.logro,
      unread: false,
      title: 'Nuevo logro desbloqueado 🎖️',
      msg: 'Has completado 10 sesiones de análisis. ¡Eres constante!',
      time: 'Hace 4 días',
    ),
  ];

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
    NotificationFilter('recordatorio', 'Recordatorios'),
  ];
}
