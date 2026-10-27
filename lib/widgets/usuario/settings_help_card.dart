import 'package:flutter/material.dart';
import '../../theme/routine_colors.dart';

/// Sección "Ayuda" de Configuración: título + lista de opciones de soporte.
class SettingsHelpCard extends StatelessWidget {
  const SettingsHelpCard({super.key});

  void _soon(BuildContext context, String name) {
    // TODO: reemplazar por la acción real (abrir URL, correo, formulario...).
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('$name estará disponible pronto')));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Ayuda y soporte',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 14),
        _HelpTile(
          icon: Icons.menu_book_rounded,
          title: 'Centro de ayuda',
          subtitle: 'Guías y preguntas frecuentes',
          onTap: () => _soon(context, 'Centro de ayuda'),
        ),
        _HelpTile(
          icon: Icons.mail_rounded,
          title: 'Contactar soporte',
          subtitle: 'soporte@volleyscan.app',
          onTap: () => _soon(context, 'Contactar soporte'),
        ),
        _HelpTile(
          icon: Icons.bug_report_rounded,
          title: 'Reportar un problema',
          subtitle: 'Cuéntanos qué no funciona',
          onTap: () => _soon(context, 'Reportar un problema'),
        ),
        _HelpTile(
          icon: Icons.info_rounded,
          title: 'Versión de la app',
          subtitle: 'VolleyScan v2.4.1 · Build 241',
          onTap: () => _soon(context, 'Versión de la app'),
        ),
      ],
    );
  }
}

class _HelpTile extends StatelessWidget {
  const _HelpTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: RoutineColors.card,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: RoutineColors.border),
            ),
            child: Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: const Color(0xFF14264D),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, size: 20, color: const Color(0xFF3B82F6)),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: RoutineColors.textMuted,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.chevron_right_rounded,
                  color: RoutineColors.textMuted,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
