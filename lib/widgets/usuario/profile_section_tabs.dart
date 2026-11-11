import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../theme/dash_colors.dart';

enum ProfileSection { personal, preferences, security }

/// Selector de secciones del perfil (`.profile-nav__btn` en `perfil.css`):
/// inactiva transparente con texto `--text-secondary`; activa con `--accent-blue` y texto `#fff`.
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
            Padding(padding: const EdgeInsets.only(right: 6), child: _chip(t)),
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
          color: active ? DashColors.blueLight : Colors.transparent,
          borderRadius: BorderRadius.circular(AppRadii.sm),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              t.icon,
              size: 16,
              color: active
                  ? DashColors.textPrimary
                  : DashColors.textSecondary,
            ),
            const SizedBox(width: 10),
            Text(
              t.label,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 13.5,
                fontWeight: FontWeight.w500,
                color: active
                    ? DashColors.textPrimary
                    : DashColors.textSecondary,
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
