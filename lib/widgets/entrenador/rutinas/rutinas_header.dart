import 'package:flutter/material.dart';
import '../../../theme/dash_colors.dart';

class RutinasHeader extends StatelessWidget {
  const RutinasHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Text.rich(
          TextSpan(
            children: [
              TextSpan(text: 'PANEL DE '),
              TextSpan(
                text: 'RUTINAS',
                style: TextStyle(color: DashColors.coachPurple),
              ),
            ],
          ),
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            letterSpacing: 2,
            color: DashColors.text,
          ),
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: DashColors.coachPurple.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: DashColors.coachPurple.withValues(alpha: 0.3),
            ),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.circle, size: 8, color: DashColors.coachPurple),
              SizedBox(width: 8),
              Text(
                'Sistema activo',
                style: TextStyle(
                  fontSize: 12,
                  letterSpacing: 1,
                  color: DashColors.coachPurple,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
