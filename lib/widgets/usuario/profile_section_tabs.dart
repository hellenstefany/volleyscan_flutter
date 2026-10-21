import 'package:flutter/material.dart';
import '../../theme/dash_colors.dart';

enum ProfileSection { personal, goals, preferences, security }

/// Selector de secciones del perfil (fila de botones que se desplaza).
class ProfileSectionTabs extends StatelessWidget {
  const ProfileSectionTabs({
    super.key,
    required this.selected,
    required this.onSelected,
  });

  final ProfileSection selected;
  final ValueChanged<ProfileSection> onSelected;

  static const _tabs = <_Tab>[
    _Tab(
      ProfileSection.personal,
      'Información personal',
      Icons.account_circle_rounded,
    ),
    _Tab(ProfileSection.goals, 'Objetivos', Icons.track_changes_rounded),
    _Tab(ProfileSection.preferences, 'Preferencias', Icons.tune_rounded),
    _Tab(ProfileSection.security, 'Cuenta y seguridad', Icons.lock_rounded),
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (final t in _tabs)
            Padding(padding: const EdgeInsets.only(right: 8), child: _chip(t)),
        ],
      ),
    );
  }

  Widget _chip(_Tab t) {
    final active = t.section == selected;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => onSelected(t.section),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: active ? DashColors.blue : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: active ? DashColors.blue : Colors.white.withOpacity(0.1),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              t.icon,
              size: 18,
              color: active ? Colors.white : Colors.white.withOpacity(0.6),
            ),
            const SizedBox(width: 8),
            Text(
              t.label,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 12.5,
                fontWeight: active ? FontWeight.w600 : FontWeight.w400,
                color: active ? Colors.white : Colors.white.withOpacity(0.75),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Tab {
  const _Tab(this.section, this.label, this.icon);
  final ProfileSection section;
  final String label;
  final IconData icon;
}
