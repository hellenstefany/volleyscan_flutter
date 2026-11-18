import 'package:flutter/material.dart';

import 'dashboard_theme.dart';

class DashboardTopbar extends StatelessWidget {
  final bool narrow;
  final String? nombreCompleto;
  final String? email;
  final bool loadingUser;
  final VoidCallback onNewSession;

  const DashboardTopbar({
    super.key,
    required this.narrow,
    required this.onNewSession,
    this.nombreCompleto,
    this.email,
    this.loadingUser = false,
  });

  @override
  Widget build(BuildContext context) {
    final cleanName = (nombreCompleto ?? '').trim();
    final cleanEmail = (email ?? '').trim();

    final titleText = cleanName.isNotEmpty
        ? 'Bienvenido, $cleanName'
        : 'Dashboard';
    final subtitleText =
        'Resumen general de tu equipo • ${cleanEmail.isNotEmpty ? cleanEmail : 'Entrenador'}';

    final titleBlock = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          titleText,
          style: TextStyle(
            fontSize: narrow ? 20 : 24,
            fontWeight: FontWeight.w700,
            color: DashboardTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 2),
        if (loadingUser && cleanName.isEmpty && cleanEmail.isEmpty)
          Container(
            margin: const EdgeInsets.only(top: 4),
            width: 200,
            height: 12,
            decoration: BoxDecoration(
              color: DashboardTheme.bgCardHover,
              borderRadius: BorderRadius.circular(6),
            ),
          )
        else
          Text(
            subtitleText,
            style: const TextStyle(
              fontSize: 13,
              color: DashboardTheme.textSecondary,
            ),
          ),
      ],
    );

    return Container(
      width: double.infinity,
      // En móvil dejamos espacio para el botón flotante del menú
      padding: EdgeInsets.fromLTRB(narrow ? 68 : 28, 20, narrow ? 16 : 28, 20),
      decoration: const BoxDecoration(
        color: DashboardTheme.bgSecondary,
        border: Border(bottom: BorderSide(color: DashboardTheme.border)),
      ),
      child: Row(
        children: [
          Expanded(child: titleBlock),
        ],
      ),
    );
  }
}
