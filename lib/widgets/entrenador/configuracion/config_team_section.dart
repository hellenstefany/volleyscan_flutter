import 'package:flutter/material.dart';

import 'config_card.dart';
import 'config_data.dart';
import 'config_member_row.dart';
import 'config_section_header.dart';
import 'config_theme.dart';

class ConfigTeamSection extends StatelessWidget {
  final ConfigToast onToast;

  const ConfigTeamSection({super.key, required this.onToast});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const ConfigSectionHeader(
          'Equipo',
          'Gestiona los miembros y roles del equipo técnico.',
        ),
        ConfigCard(
          title: 'Miembros del equipo',
          children: [
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SizedBox(
                width: 620,
                child: Column(
                  children: [
                    const ConfigMemberHeader(),
                    for (final m in configMembers)
                      ConfigMemberRow(
                        member: m,
                        onEdit: () => onToast(
                          '✏️',
                          'Editando rol de ${m.$1}',
                          ConfigTheme.accent2,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
