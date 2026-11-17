import 'package:flutter/material.dart';

import 'config_btn.dart';
import 'config_card.dart';
import 'config_data.dart';
import 'config_field_row.dart';
import 'config_section_header.dart';
import 'config_select.dart';
import 'config_theme.dart';
import 'config_toggle.dart';

class ConfigGeneralSection extends StatelessWidget {
  final double width;
  final Map<String, dynamic> values;
  final ConfigSetter onSet;
  final VoidCallback onLogout;

  const ConfigGeneralSection({
    super.key,
    required this.width,
    required this.values,
    required this.onSet,
    required this.onLogout,
  });

  Widget _select(String key, List<String> options, {double w = 170}) {
    return ConfigSelect(
      value: values[key] as String,
      options: options,
      width: w,
      onChanged: (x) => onSet(key, x),
    );
  }

  Widget _toggle(String key) =>
      ConfigValueToggle(values: values, id: key, onSet: onSet);

  @override
  Widget build(BuildContext context) {
    final main = ConfigCard(
      children: [
        ConfigFieldRow(
          name: 'Unidad de medida',
          trailing: _select('unidad', const [
            'Métrico (kg, cm)',
            'Imperial (lb, in)',
          ]),
        ),
        ConfigFieldRow(
          name: 'Idioma',
          trailing: _select('idioma', const [
            'Español',
            'English',
            'Português',
          ]),
        ),
        ConfigFieldRow(
          name: 'Tema',
          trailing: _select('tema', const [
            'Oscuro',
            'AMOLED',
            'Navy',
            'Midnight',
          ]),
        ),
        ConfigFieldRow(
          name: 'Calidad de video para análisis',
          trailing: _select('video', const ['Baja', 'Media', 'Alta']),
        ),
        ConfigFieldRow(
          name: 'Guardar videos automáticamente',
          desc: 'Los videos de análisis se guardan en tu historial',
          trailing: _toggle('autoVideo'),
          last: true,
        ),
      ],
    );

    final side = ConfigCard(
      title: 'Privacidad rápida',
      children: [
        const Padding(
          padding: EdgeInsets.only(bottom: 8),
          child: Text(
            'Quién puede ver mis análisis',
            style: TextStyle(fontSize: 12, color: ConfigTheme.muted),
          ),
        ),
        _select('privacidad', const [
          'Solo yo',
          'Mi equipo',
          'Todos',
        ], w: double.infinity),
        const SizedBox(height: 14),
        ConfigFieldRow(
          name: 'Permitir comentarios',
          small: true,
          trailing: _toggle('comentarios'),
        ),
        ConfigFieldRow(
          name: 'Compartir progreso',
          small: true,
          trailing: _toggle('compartir'),
          last: true,
        ),
        const SizedBox(height: 16),
        ConfigBtn(
          label: 'Cerrar sesión',
          style: ConfigBtnStyle.danger,
          expand: true,
          onTap: onLogout,
        ),
      ],
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const ConfigSectionHeader(
          'General',
          'Ajusta las preferencias generales de tu cuenta.',
        ),
        if (width >= 900)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: main),
              const SizedBox(width: 16),
              SizedBox(width: 220, child: side),
            ],
          )
        else ...[
          main,
          side,
        ],
      ],
    );
  }
}
