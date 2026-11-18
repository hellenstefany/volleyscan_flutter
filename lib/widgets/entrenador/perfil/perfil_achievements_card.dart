import 'package:flutter/material.dart';
import '../../../theme/entrenador_colors.dart';
import 'perfil_common_widgets.dart';
import 'perfil_model.dart';

/// Tarjeta "Logros recientes".
class PerfilAchievementsCard extends StatelessWidget {
  final List<Achievement> achievements;
  final VoidCallback onAdd;
  final ValueChanged<int> onDelete;

  const PerfilAchievementsCard({
    super.key,
    required this.achievements,
    required this.onAdd,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: perfilCardDeco(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const PerfilCardHeader(
            icon: Icons.emoji_events,
            title: 'Logros recientes',
          ),
          if (achievements.isEmpty)
            const Padding(
              padding: EdgeInsets.all(20),
              child: Center(
                child: Text(
                  'No hay logros aún',
                  style: TextStyle(color: EC.text3),
                ),
              ),
            )
          else
            for (final a in achievements)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: AchievementItem(a: a, onDelete: () => onDelete(a.id)),
              ),
          const SizedBox(height: 8),
          InkWell(
            onTap: onAdd,
            borderRadius: BorderRadius.circular(10),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color: EC.accent.withOpacity(0.08),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: EC.border2),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add, size: 16, color: EC.accent2),
                  SizedBox(width: 8),
                  Text(
                    'Añadir logro',
                    style: TextStyle(
                      color: EC.accent2,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class AchievementItem extends StatelessWidget {
  final Achievement a;
  final VoidCallback onDelete;
  const AchievementItem({super.key, required this.a, required this.onDelete});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: EC.bgCard2,
      borderRadius: BorderRadius.circular(12),
    ),
    child: Row(
      children: [
        Container(
          width: 48,
          height: 48,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: EC.bgCard,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(a.icon, style: const TextStyle(fontSize: 26)),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                a.title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: EC.text1,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                a.description,
                style: const TextStyle(fontSize: 12, color: EC.text2),
              ),
            ],
          ),
        ),
        InkWell(
          onTap: onDelete,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: EC.red.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.delete_outline, size: 16, color: EC.red),
          ),
        ),
      ],
    ),
  );
}
