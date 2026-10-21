import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class FooterSection extends StatelessWidget {
  const FooterSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 22),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: const Column(
        children: [
          Text(
            'VolleyScan AI Mobile • v2.1.0',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.muted,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 4),
          Text(
            'Plataforma de análisis deportivo con inteligencia artificial.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.footerText,
              fontSize: 11,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}
