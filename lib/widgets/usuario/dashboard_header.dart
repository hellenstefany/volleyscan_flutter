import 'package:flutter/material.dart';
import '../../theme/dash_colors.dart';

/// Encabezado: botón de menú, saludo y campana con contador.
class DashboardHeader extends StatelessWidget {
  const DashboardHeader({
    super.key,
    required this.userName,
    this.notifications = 0,
    this.onMenuTap,
    this.onBellTap,
  });

  final String userName;
  final int notifications;
  final VoidCallback? onMenuTap;
  final VoidCallback? onBellTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.white.withOpacity(0.06)),
        ),
      ),
      child: Row(
        children: [
          _RoundButton(icon: Icons.menu, onTap: onMenuTap),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        '¡Hola, $userName!',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Text('👋', style: TextStyle(fontSize: 18)),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  'Sigue entrenando y mejora cada día.',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 11,
                    color: DashColors.muted,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Stack(
            clipBehavior: Clip.none,
            children: [
              _RoundButton(
                icon: Icons.notifications_none_rounded,
                onTap: onBellTap,
              ),
              if (notifications > 0)
                Positioned(
                  top: -4,
                  right: -4,
                  child: Container(
                    width: 20,
                    height: 20,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: DashColors.orange,
                      shape: BoxShape.circle,
                      border: Border.all(color: DashColors.bg, width: 2),
                    ),
                    child: Text(
                      notifications > 9 ? '9+' : '$notifications',
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 9.5,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RoundButton extends StatelessWidget {
  const _RoundButton({required this.icon, this.onTap});

  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: DashColors.card,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white.withOpacity(0.1)),
        ),
        child: Icon(icon, size: 22, color: Colors.white),
      ),
    );
  }
}
