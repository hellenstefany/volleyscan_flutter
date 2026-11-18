import 'package:flutter/material.dart';

import 'config_card.dart';
import 'config_data.dart';
import 'config_section_header.dart';
import 'config_theme_card.dart';

class ConfigThemeSection extends StatelessWidget {
  final Map<String, dynamic> values;
  final ConfigSetter onSet;
  final ConfigToast onToast;

  const ConfigThemeSection({
    super.key,
    required this.values,
    required this.onSet,
    required this.onToast,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const ConfigSectionHeader(
          'Tema & Apariencia',
          'Personaliza la apariencia visual de VolleyAI.',
        ),
        ConfigCard(
          title: 'Modo de pantalla',
          children: [
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                for (final t in configThemes)
                  ConfigThemeCard(
                    theme: t,
                    selected: values['themeId'] == t.id,
                    onTap: () {
                      onSet('themeId', t.id);
                      onToast('', 'Tema "${t.name}" aplicado');
                    },
                  ),
              ],
            ),
          ],
        ),
        ConfigCard(
          title: 'Color de acento',
          children: [
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                for (final a in configAccentColors)
                  Tooltip(
                    message: a.$1,
                    child: GestureDetector(
                      onTap: () {
                        onSet('accent', a.$2.toARGB32());
                        onToast('', 'Acento: ${a.$1}');
                      },
                      child: Container(
                        width: 36,
                        height: 36,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: a.$2,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: values['accent'] == a.$2.toARGB32()
                                ? Colors.white
                                : Colors.transparent,
                            width: 2,
                          ),
                        ),
                        child: values['accent'] == a.$2.toARGB32()
                            ? const Icon(
                                Icons.check,
                                size: 18,
                                color: Colors.white,
                              )
                            : null,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}
