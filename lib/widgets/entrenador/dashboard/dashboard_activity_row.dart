import 'package:flutter/material.dart';

import 'dashboard_avatar.dart';
import 'dashboard_models.dart';
import 'dashboard_theme.dart';

class DashboardActivityRow extends StatelessWidget {
  final EntrenadorEventoProximo evento;

  const DashboardActivityRow({super.key, required this.evento});

  @override
  Widget build(BuildContext context) {
    final sub = (evento.ubicacion != null && evento.ubicacion!.isNotEmpty)
        ? '${evento.tipoEvento} • ${evento.ubicacion}'
        : evento.tipoEvento;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        hoverColor: DashboardTheme.border,
        onTap: () {},
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          child: Row(
            children: [
              const DashboardAvatar(
                text: '📅',
                bg: DashboardTheme.bgCardHover,
                size: 36,
                fontSize: 18,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      evento.titulo,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: DashboardTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 1),
                    Text(
                      sub,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 11,
                        color: DashboardTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${evento.fecha} (${evento.horaInicioCorta})',
                style: const TextStyle(
                  fontSize: 11,
                  color: DashboardTheme.textMuted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
