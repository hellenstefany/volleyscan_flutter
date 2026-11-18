import 'package:flutter/material.dart';
import '../../../models/notification_data.dart';
import '../../../theme/app_theme.dart';
import '../../../theme/dash_colors.dart';

class RecommendationCard extends StatelessWidget {
  final Recommendation recommendation;
  final VoidCallback onTap;

  const RecommendationCard({
    super.key,
    required this.recommendation,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final rec = recommendation;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: DashColors.cardDark,
        borderRadius: BorderRadius.circular(AppRadii.md),
        border: Border.all(color: DashColors.border),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppRadii.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 140,
              width: double.infinity,
              child: Image.network(
                rec.imageUrl,
                fit: BoxFit.cover,
                loadingBuilder: (_, child, progress) =>
                    progress == null ? child : _placeholder(),
                errorBuilder: (_, _, _) => _placeholder(),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    rec.title,
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      color: DashColors.textPrimary,
                      fontSize: 15.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    rec.desc,
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      color: DashColors.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 10),
                  GestureDetector(
                    onTap: onTap,
                    behavior: HitTestBehavior.opaque,
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Ver ejercicios',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            color: DashColors.blueLight,
                            fontSize: 13.5,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        SizedBox(width: 6),
                        Icon(
                          Icons.arrow_forward_rounded,
                          size: 16,
                          color: DashColors.blueLight,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _placeholder() => Container(
        color: DashColors.surface,
        alignment: Alignment.center,
        child: const Icon(
          Icons.image_outlined,
          color: DashColors.muted,
          size: 32,
        ),
      );
}
