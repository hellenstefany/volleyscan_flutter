import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import 'common/tag.dart';

class HeroSection extends StatelessWidget {
  const HeroSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.45),
            blurRadius: 40,
            offset: const Offset(0, 20),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Tag(
            'ANÁLISIS BIOMECÁNICO V2.4',
            AppColors.cyan,
            dot: true,
            pill: true,
          ),
          const SizedBox(height: 16),
          Text.rich(
            TextSpan(
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w800,
                height: 1.2,
                color: Colors.white,
              ),
              children: [
                const TextSpan(text: 'Transforma tu '),
                const TextSpan(
                  text: 'rendimiento',
                  style: TextStyle(color: AppColors.gold, shadows: []),
                ),
                const TextSpan(text: '\nen el voleibol con '),
                TextSpan(
                  text: 'IA',
                  style: TextStyle(color: Color(0xFF22D3EE), shadows: []),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          const Text(
            'Detecta errores técnicos, analiza movimientos cinemáticos de remate y bloqueo, y mejora el rendimiento deportivo al instante.',
            style: TextStyle(color: AppColors.muted, fontSize: 14, height: 1.7),
          ),
          const SizedBox(height: 18),
          const _HeroImage(),
          const SizedBox(height: 18),
          const _PrimaryButton(),
        ],
      ),
    );
  }
}

class _HeroImage extends StatelessWidget {
  const _HeroImage();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 230,
      width: double.infinity,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/images/image.jpg',
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => Container(
              color: const Color(0xFF0A1128),
              child: const Icon(
                Icons.sports_volleyball,
                size: 80,
                color: AppColors.cyan,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  const _PrimaryButton();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 54,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        gradient: AppGradients.primary,
        boxShadow: [
          BoxShadow(
            color: AppColors.blue.withValues(alpha: 0.4),
            blurRadius: 28,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () {},
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.play_circle_outline, size: 20, color: Colors.white),
              SizedBox(width: 8),
              Text(
                'Crear Cuenta Gratis',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                  color: Colors.white,
                ),
              ),
              SizedBox(width: 8),
              Icon(Icons.arrow_forward, size: 16, color: Colors.white),
            ],
          ),
        ),
      ),
    );
  }
}
