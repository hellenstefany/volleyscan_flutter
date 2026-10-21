import 'package:flutter/material.dart';
import '../../theme/dash_colors.dart';
import 'dash_card.dart';

/// Tarjeta de métrica (Progreso general, Sesiones completadas).
/// Si recibe [chart], lo dibuja pegado al borde inferior.
class StatCard extends StatelessWidget {
  const StatCard({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.label,
    required this.value,
    this.delta,
    this.caption,
    this.chart,
  });

  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final String label;
  final String value;
  final String? delta;
  final String? caption;
  final Widget? chart;

  @override
  Widget build(BuildContext context) {
    return DashCard(
      padding: EdgeInsets.zero,
      child: Stack(
        children: [
          if (chart != null)
            Positioned(left: 0, right: 0, bottom: 0, height: 38, child: chart!),
          Positioned.fill(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(14, 14, 14, 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      color: iconBg,
                      borderRadius: BorderRadius.circular(9),
                      border: Border.all(color: iconColor.withOpacity(0.35)),
                    ),
                    child: Icon(icon, size: 16, color: iconColor),
                  ),
                  if (chart != null)
                    const SizedBox(height: 10)
                  else
                    const Spacer(),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      label.toUpperCase(),
                      maxLines: 1,
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 10.5,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.6,
                        color: DashColors.muted,
                      ),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        value,
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 26,
                          height: 1.2,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      if (delta != null) ...[
                        const SizedBox(width: 8),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 5),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.arrow_upward_rounded,
                                size: 12,
                                color: DashColors.green,
                              ),
                              const SizedBox(width: 2),
                              Text(
                                delta!,
                                style: const TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w600,
                                  color: DashColors.green,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                  if (caption != null)
                    Text(
                      caption!,
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 11,
                        color: DashColors.muted,
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
