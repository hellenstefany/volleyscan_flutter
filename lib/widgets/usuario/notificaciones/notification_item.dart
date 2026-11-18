import 'package:flutter/material.dart';
import '../../../models/notification_data.dart';
import '../../../theme/app_theme.dart';
import '../../../theme/dash_colors.dart';

Color notificationColor(NotificationType t) {
  switch (t) {
    case NotificationType.logro:
      return DashColors.green;
    case NotificationType.rutina:
      return DashColors.purple;
    case NotificationType.racha:
      return DashColors.orange;
    case NotificationType.recordatorio:
    case NotificationType.vinculo:
      return DashColors.blueLight;
    case NotificationType.analisis:
      return DashColors.accentYellow;
    case NotificationType.equipo:
      return DashColors.cyan;
    case NotificationType.otro:
      return DashColors.accent2;
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
    case NotificationType.vinculo:
      return Icons.how_to_reg_rounded;
    case NotificationType.equipo:
      return Icons.groups_rounded;
    case NotificationType.otro:
      return Icons.notifications_rounded;
  }
}

class NotificationItem extends StatelessWidget {
  final AppNotification notification;
  final bool dismissing;
  final bool busy;
  final VoidCallback onTap;
  final VoidCallback onMarkRead;
  final VoidCallback onDelete;

  const NotificationItem({
    super.key,
    required this.notification,
    required this.dismissing,
    this.busy = false,
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
        opacity: dismissing ? 0 : (n.unread ? 1.0 : 0.78),
        duration: const Duration(milliseconds: 300),
        child: Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: GestureDetector(
            onTap: busy ? null : onTap,
            child: Container(
              decoration: BoxDecoration(
                color: n.unread ? DashColors.surface : DashColors.cardDark,
                borderRadius: BorderRadius.circular(AppRadii.md),
                border: Border.all(
                  color: n.unread
                      ? DashColors.blueLight.withValues(alpha: 0.25)
                      : DashColors.border,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(AppRadii.md),
                child: Stack(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 14, 8, 14),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: color.withValues(alpha: 0.18),
                              borderRadius: BorderRadius.circular(AppRadii.btn),
                            ),
                            child: Icon(
                              notificationIcon(n.type),
                              color: color,
                              size: 22,
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
                                    fontFamily: 'Poppins',
                                    color: DashColors.textPrimary,
                                    fontSize: 14.5,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  n.msg,
                                  style: const TextStyle(
                                    fontFamily: 'Poppins',
                                    color: DashColors.textSecondary,
                                    fontSize: 13,
                                    height: 1.35,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.access_time_filled,
                                      size: 13,
                                      color: DashColors.muted,
                                    ),
                                    const SizedBox(width: 5),
                                    Text(
                                      n.time,
                                      style: const TextStyle(
                                        fontFamily: 'Poppins',
                                        color: DashColors.muted,
                                        fontSize: 11.5,
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
                                      busy ? null : onMarkRead,
                                    ),
                                    Positioned(
                                      top: 4,
                                      right: 2,
                                      child: Container(
                                        width: 8,
                                        height: 8,
                                        decoration: const BoxDecoration(
                                          color: DashColors.blueLight,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              _iconBtn(
                                Icons.close_rounded,
                                'Eliminar',
                                busy ? null : onDelete,
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
                        child: ColoredBox(color: DashColors.blueLight),
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

  Widget _iconBtn(IconData icon, String tooltip, VoidCallback? onPressed) {
    return IconButton(
      onPressed: onPressed,
      tooltip: tooltip,
      icon: Icon(
        icon,
        size: 18,
        color: DashColors.textPrimary.withValues(alpha: 0.55),
      ),
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
    );
  }
}
