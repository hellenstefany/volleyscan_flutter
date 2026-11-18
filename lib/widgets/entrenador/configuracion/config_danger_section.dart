import 'package:flutter/material.dart';

import 'config_btn.dart';
import 'config_card.dart';
import 'config_data.dart';
import 'config_field_row.dart';
import 'config_section_header.dart';
import 'config_theme.dart';

class ConfigDangerSection extends StatelessWidget {
  final ConfigToast onToast;

  /// Restablece todos los valores a los predeterminados.
  final VoidCallback onReset;

  const ConfigDangerSection({
    super.key,
    required this.onToast,
    required this.onReset,
  });

  @override
  Widget build(BuildContext context) {
    const items = [
      (
        'Eliminar todos los reportes',
        'Borra permanentemente todos los reportes generados',
        'Eliminar',
      ),
      (
        'Restablecer configuración',
        'Vuelve a los valores predeterminados',
        '↺ Restablecer',
      ),
      (
        'Desactivar cuenta',
        'Pausa tu cuenta — tus datos se conservan',
        '⏸ Desactivar',
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const ConfigSectionHeader(
          'Zona peligrosa',
          'Acciones irreversibles. Procede con extrema cautela.',
        ),
        ConfigCard(
          title: 'Acciones irreversibles',
          titleColor: ConfigTheme.danger,
          borderColor: ConfigTheme.danger.withValues(alpha: 0.3),
          children: [
            for (var i = 0; i < items.length; i++)
              ConfigFieldRow(
                name: items[i].$1,
                desc: items[i].$2,
                last: i == items.length - 1,
                trailing: ConfigBtn(
                  label: items[i].$3,
                  style: ConfigBtnStyle.danger,
                  onTap: () {
                    if (items[i].$1 == 'Restablecer configuración') {
                      onReset();
                    }
                    onToast('⚠️', 'Acción: ${items[i].$1}', ConfigTheme.danger);
                  },
                ),
              ),
          ],
        ),
      ],
    );
  }
}
