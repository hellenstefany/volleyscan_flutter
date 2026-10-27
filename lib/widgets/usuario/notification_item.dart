import 'package:flutter/material.dart';
import '../../models/notification_data.dart';
import '../../theme/routine_colors.dart';

Color notificationColor(NotificationType t) {
  switch (t) {
    case NotificationType.logro:
      return const Color(0xFF22C55E);
    case NotificationType.rutina:
      return const Color(0xFFA855F7);
    case NotificationType.racha:
      return const Color(0xFFF97316);
    case NotificationType.recordatorio:
      return const Color(0xFF3B82F6);
    case NotificationType.analisis:
      return const Color(0xFFEAB308);
  }
}

IconData notificationIcon(NotificationType t) {
  switch (t) {
    case NotificationType.logro:
      return Icons.emoji_events_rounded;
    case NotificationType.rutina:
      return Icons.star_rounded;
    case NotificationType.racha:
      return Icons.local_fire_department_rounded;
    case NotificationType.recordatorio:
      return Icons.lock_rounded;
    case NotificationType.analisis:
      return Icons.bolt_rounded;
  }
}

class NotificationItem extends StatelessWidget {
  final AppNotification notification;
  final bool dismissing;
  final VoidCallback onTap;
  final VoidCallback onMarkRead;
  final VoidCallback onDelete;

  const NotificationItem({
    super.key,
    required this.notification,
    required this.dismissing,
    required this.onTap,
    required this.onMarkRead,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final n = notification;
    final color = notificationColor(n.type);

    return AnimatedSlide(
      offset: dismissing ? const Offset(0.12, 0) : Offset.zero,
      duration: const Duration(milliseconds: 300),
      child: AnimatedOpacity(
        opacity: dismissing ? 0 : 1,
        duration: const Duration(milliseconds: 300),
        child: Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: GestureDetector(
            onTap: n.unread ? onTap : null,
            child: Container(
              decoration: BoxDecoration(
                color: n.unread
                    ? const Color(0xFF1A2240)
                    : RoutineColors.cardDark,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: n.unread
                      ? RoutineColors.blue.withOpacity(0.25)
                      : RoutineColors.border,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Stack(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 14, 8, 14),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: color.withOpacity(0.18),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              notificationIcon(n.type),
                              color: color,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  n.title,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  n.msg,
                                  style: const TextStyle(
                                    color: Color(0xFFCBD5E1),
                                    fontSize: 13.5,
                                    height: 1.3,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.access_time_filled,
                                      size: 13,
                                      color: RoutineColors.textMuted,
                                    ),
                                    const SizedBox(width: 5),
                                    Text(
                                      n.time,
                                      style: const TextStyle(
                                        color: RoutineColors.textMuted,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Column(
                            children: [
                              if (n.unread)
                                Stack(
                                  clipBehavior: Clip.none,
                                  children: [
                                    _iconBtn(
                                      Icons.check_rounded,
                                      'Marcar como leída',
                                      onMarkRead,
                                    ),
                                    Positioned(
                                      top: 4,
                                      right: 2,
                                      child: Container(
                                        width: 8,
                                        height: 8,
                                        decoration: const BoxDecoration(
                                          color: RoutineColors.blue,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              _iconBtn(
                                Icons.close_rounded,
                                'Eliminar',
                                onDelete,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    if (n.unread)
                      const Positioned(
                        left: 0,
                        top: 0,
                        bottom: 0,
                        width: 3,
                        child: ColoredBox(color: RoutineColors.blue),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _iconBtn(IconData icon, String tooltip, VoidCallback onPressed) {
    return IconButton(
      onPressed: onPressed,
      tooltip: tooltip,
      icon: Icon(icon, size: 18, color: Colors.white.withOpacity(0.55)),
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
    );
  }
}
