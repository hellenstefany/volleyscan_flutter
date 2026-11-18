import 'package:flutter/material.dart';

import 'config_card.dart';
import 'config_data.dart';
import 'config_field_row.dart';
import 'config_section_header.dart';
import 'config_toggle.dart';

class ConfigNotificationsSection extends StatelessWidget {
  final Map<String, dynamic> values;
  final ConfigSetter onSet;

  const ConfigNotificationsSection({
    super.key,
    required this.values,
    required this.onSet,
  });

  Widget _toggle(String key) =>
      ConfigValueToggle(values: values, id: key, onSet: onSet);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const ConfigSectionHeader(
          'Notificaciones',
          'Controla qué alertas recibes y por qué canal.',
        ),
        ConfigCard(
          title: 'Canales',
          children: [
            ConfigFieldRow(
              name: 'Notificaciones push',
              desc: 'Alertas en el navegador',
              trailing: _toggle('push'),
            ),
            ConfigFieldRow(
              name: 'Email',
              desc: 'Resumen diario',
              trailing: _toggle('email'),
            ),
            ConfigFieldRow(
              name: 'SMS',
              desc: 'Solo alertas críticas',
              trailing: _toggle('sms'),
              last: true,
            ),
          ],
        ),
        ConfigCard(
          title: 'Tipo de alertas',
          children: [
            for (var i = 0; i < configNotifTypes.length; i++)
              ConfigFieldRow(
                name: configNotifTypes[i],
                trailing: _toggle('n:${configNotifTypes[i]}'),
                last: i == configNotifTypes.length - 1,
              ),
          ],
        ),
      ],
    );
  }
}
