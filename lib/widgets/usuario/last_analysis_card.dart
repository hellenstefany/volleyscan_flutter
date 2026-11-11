import 'package:flutter/material.dart';
import '../../theme/dash_colors.dart';
import 'dash_card.dart';

/// Tarjeta "Último análisis": técnica, antigüedad, puntaje y miniatura.
class LastAnalysisCard extends StatelessWidget {
  const LastAnalysisCard({
    super.key,
    required this.technique,
    required this.timeAgo,
    required this.score,
    this.imagePath,
    this.onTap,
  });

  final String technique;
  final String timeAgo;
  final int score; // 0 - 100
  final String? imagePath;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: DashCard(
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Último análisis',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 12,
                          height: 1.3,
                          color: Colors.white.withValues(alpha: 0.85),
                        ),
                      ),
                      Text(
                        technique,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 15,
                          height: 1.3,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        timeAgo,
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 10.5,
                          height: 1.3,
                          color: DashColors.muted,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 6),
                _ScoreRing(score: score),
              ],
            ),
            const SizedBox(height: 8),
            Expanded(
              child: SizedBox(
                width: double.infinity,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: _thumbnail(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _thumbnail() {
    final placeholder = Container(
      color: DashColors.card,
      alignment: Alignment.center,
      child: const Icon(
        Icons.sports_volleyball,
        size: 28,
        color: DashColors.sky,
      ),
    );

    final path = imagePath?.trim() ?? '';
    if (path.isEmpty) return placeholder;

    return Image.asset(
      path,
      fit: BoxFit.cover,
      errorBuilder: (_, _, _) => placeholder,
    );
  }
}

class _ScoreRing extends StatelessWidget {
  const _ScoreRing({required this.score});

  final int score;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 40,
      height: 40,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox.expand(
            child: CircularProgressIndicator(
              value: (score.clamp(0, 100)) / 100,
              strokeWidth: 3,
              strokeCap: StrokeCap.round,
              color: DashColors.green,
              backgroundColor: Colors.white.withValues(alpha: 0.1),
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '$score',
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 12,
                  height: 1.1,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              Text(
                '/100',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 7,
                  height: 1.1,
                  color: DashColors.muted,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
