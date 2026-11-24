import 'package:flutter/material.dart';
import '../../../theme/dash_colors.dart';
import 'rutinas_catalog.dart';
import 'rutinas_common_widgets.dart';

/// Carrusel horizontal de rutinas prediseñadas.
class RutinasPresetsCard extends StatelessWidget {
  final ValueChanged<RutinaPreset> onLoad;

  const RutinasPresetsCard({super.key, required this.onLoad});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: rtBox(DashColors.card, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const RtCardTitle(icon: '📋', title: 'Rutinas prediseñadas'),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (final p in kRutinaPresets)
                  Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: InkWell(
                      onTap: () => onLoad(p),
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        width: 190,
                        padding: const EdgeInsets.all(14),
                        decoration: rtBox(DashColors.card2, 12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(p.emoji, style: const TextStyle(fontSize: 26)),
                            const SizedBox(height: 8),
                            Text(
                              p.name,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 1,
                                color: DashColors.text,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              p.desc,
                              style: const TextStyle(
                                fontSize: 11,
                                height: 1.4,
                                color: DashColors.textMuted,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 4,
                              runSpacing: 4,
                              children: [
                                RtMiniTag(
                                  p.type,
                                  color: kRutinaTypeColors[p.type],
                                ),
                                RtMiniTag(p.dur),
                                RtMiniTag('⚡ ${p.intensity}/10'),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
