import 'package:flutter/material.dart';

import '../../../theme/dash_colors.dart';
import 'config_btn.dart';
import 'config_theme.dart';

class ConfigTopbar extends StatelessWidget {
  final bool narrow;
  final bool dirty;
  final VoidCallback onDiscard;
  final VoidCallback onSave;

  const ConfigTopbar({
    super.key,
    required this.narrow,
    required this.dirty,
    required this.onDiscard,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    final title = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text(
          '⚙',
          style: TextStyle(fontSize: 22, color: ConfigTheme.accent),
        ),
        const SizedBox(width: 8),
        const Text(
          'Configuración',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            letterSpacing: 1,
            color: ConfigTheme.text,
          ),
        ),
        if (dirty) ...[
          const SizedBox(width: 14),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: DashColors.amber.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(99),
              border: Border.all(
                color: DashColors.amber.withValues(alpha: 0.35),
              ),
            ),
            child: const Text(
              'Cambios sin guardar',
              style: TextStyle(fontSize: 11, color: DashColors.amber),
            ),
          ),
        ],
      ],
    );

    final actions = Wrap(
      spacing: 10,
      runSpacing: 8,
      children: [
        ConfigBtn(
          label: '↺ Descartar',
          style: ConfigBtnStyle.ghost,
          onTap: onDiscard,
        ),
        ConfigBtn(
          label: 'Guardar cambios',
          style: ConfigBtnStyle.primary,
          onTap: onSave,
        ),
      ],
    );

    return Container(
      width: double.infinity,
      // En móvil dejamos espacio para el botón flotante del menú
      padding: EdgeInsets.fromLTRB(narrow ? 64 : 28, 18, narrow ? 16 : 28, 18),
      decoration: const BoxDecoration(
        color: ConfigTheme.panel,
        border: Border(bottom: BorderSide(color: ConfigTheme.border)),
      ),
      child: narrow
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: title,
                ),
                const SizedBox(height: 12),
                actions,
              ],
            )
          : Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 16,
              runSpacing: 12,
              children: [title, actions],
            ),
    );
  }
}
