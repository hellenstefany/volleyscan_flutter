import 'package:flutter/material.dart';
import '../../theme/dash_colors.dart';
import 'dash_card.dart';

/// Tarjeta "Último análisis": replica `.card1.card--analysis` de `Dashboard.css`.
/// Si [hasData] es `false`, muestra el estado vacío real de Next:
/// `"Aún no has realizado ningún análisis."` sin inventar datos.
class LastAnalysisCard extends StatelessWidget {
  const LastAnalysisCard({
    super.key,
    required this.technique,
    required this.timeAgo,
    required this.score,
    this.hasData = true,
    this.imagePath,
    this.imageUrl,
    this.onTap,
  });

  final String technique;
  final String timeAgo;
  final int score; // 0 - 100
  final bool hasData;
  final String? imagePath;
  final String? imageUrl;
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
            Container(
              width: double.infinity,
              padding: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: DashColors.border)),
              ),
              child: const Text(
                'Último análisis',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: DashColors.textSecondary,
                ),
              ),
            ),
            const SizedBox(height: 8),
            if (!hasData)
              Expanded(
                child: Align(
                  alignment: Alignment.topLeft,
                  child: Text(
                    'Aún no has realizado ningún análisis.',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 11.5,
                      height: 1.4,
                      color: DashColors.muted,
                    ),
                  ),
                ),
              )
            else ...[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          technique,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 14.5,
                            height: 1.25,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          timeAgo,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 10.5,
                            height: 1.25,
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
          ],
        ),
      ),
    );
  }

  Widget _thumbnail() {
    final placeholder = Container(
      color: DashColors.bg,
      alignment: Alignment.center,
      child: const Icon(
        Icons.sports_volleyball,
        size: 26,
        color: DashColors.sky,
      ),
    );

    final netUrl = imageUrl?.trim() ?? '';
    if (netUrl.isNotEmpty) {
      return Image.network(
        netUrl,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => placeholder,
      );
    }

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
      width: 42,
      height: 42,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox.expand(
            child: CircularProgressIndicator(
              value: (score.clamp(0, 100)) / 100,
              strokeWidth: 3.5,
              strokeCap: StrokeCap.round,
              color: DashColors.green,
              backgroundColor: Colors.white.withValues(alpha: 0.08),
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
                  height: 1.05,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
              Text(
                '/100',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 7.5,
                  height: 1.05,
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
