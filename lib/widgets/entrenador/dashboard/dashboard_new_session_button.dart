import 'package:flutter/material.dart';

import '../../../theme/app_theme.dart';
import 'dashboard_theme.dart';

class DashboardNewSessionButton extends StatelessWidget {
  final VoidCallback onTap;
  const DashboardNewSessionButton({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 11),
        decoration: BoxDecoration(
          gradient: AppGradients.sidebarLogoIcon,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: DashboardTheme.purple.withValues(alpha: 0.35),
              blurRadius: 15,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.add, size: 16, color: Colors.white),
            SizedBox(width: 6),
            Text(
              'Nueva sesión',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
