import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../theme/dash_colors.dart';
import 'profile_avatar.dart';

class DrawerSection {
  const DrawerSection(this.title, this.items);
  final String title;
  final List<DrawerItem> items;
}

class DrawerItem {
  const DrawerItem(this.id, this.label, this.icon);
  final String id;
  final String label;
  final IconData icon;
}

/// Cabecera del sidebar replicando `.sb-logo` de Next.js
class DashboardDrawerHeader extends StatelessWidget {
  const DashboardDrawerHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 8, 14),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              gradient: AppGradients.sidebarLogoIcon,
              borderRadius: BorderRadius.circular(12),
              boxShadow: const [
                BoxShadow(
                  color: DashColors.sidebarActiveGlow,
                  blurRadius: 16,
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset(
                'assets/images/Logo.VS.jpg',
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => const Icon(
                  Icons.sports_volleyball,
                  size: 22,
                  color: DashColors.text1,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'VolleyAI',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: DashColors.text1,
                    letterSpacing: -0.2,
                  ),
                ),
                Text(
                  'Deportista/Usuario',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 11,
                    color: DashColors.muted,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(
              Icons.close_rounded,
              size: 20,
              color: DashColors.muted,
            ),
            tooltip: 'Cerrar menú',
          ),
        ],
      ),
    );
  }
}

/// Ítem de navegación individual replicando `.nav-item` y `.nav-item.active`
class DrawerNavItemTile extends StatelessWidget {
  const DrawerNavItemTile({
    super.key,
    required this.item,
    required this.isActive,
    required this.onTap,
    this.badgeCount = 0,
  });

  final DrawerItem item;
  final bool isActive;
  final VoidCallback onTap;
  final int badgeCount;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(9),
        child: InkWell(
          borderRadius: BorderRadius.circular(9),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(9),
              gradient: isActive ? AppGradients.sidebarActiveItem : null,
              border: isActive
                  ? const Border(
                      left: BorderSide(
                        color: DashColors.sidebarActiveBorder,
                        width: 2.5,
                      ),
                    )
                  : null,
            ),
            child: Row(
              children: [
                Icon(
                  item.icon,
                  size: 16,
                  color: isActive
                      ? DashColors.sidebarActiveBorder
                      : DashColors.muted,
                ),
                const SizedBox(width: 11),
                Expanded(
                  child: Text(
                    item.label,
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 13,
                      fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                      color: isActive ? DashColors.text1 : DashColors.muted,
                    ),
                  ),
                ),
                if (badgeCount > 0)
                  Container(
                    margin: const EdgeInsets.only(left: 6),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: DashColors.orange,
                      borderRadius: BorderRadius.circular(9),
                    ),
                    child: Text(
                      badgeCount > 99 ? '99+' : '$badgeCount',
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Pie del sidebar con tarjeta de usuario y botón de cerrar sesión replicando `.sb-footer`
class DashboardDrawerFooter extends StatelessWidget {
  const DashboardDrawerFooter({
    super.key,
    required this.name,
    this.photoUrl,
    required this.role,
    required this.onLogout,
  });

  final String name;
  final String? photoUrl;
  final String role;
  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          ProfileAvatar(name: name, photoPath: photoUrl, size: 38),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    color: DashColors.text1,
                  ),
                ),
                Text(
                  role,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 10.5,
                    color: DashColors.muted,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 9,
            height: 9,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: DashColors.green,
              boxShadow: [
                BoxShadow(
                  color: DashColors.greenGlow,
                  blurRadius: 8,
                ),
              ],
            ),
          ),
          const SizedBox(width: 4),
          IconButton(
            onPressed: onLogout,
            icon: const Icon(
              Icons.logout_rounded,
              size: 18,
              color: DashColors.red,
            ),
            tooltip: 'Cerrar sesión',
          ),
        ],
      ),
    );
  }
}
