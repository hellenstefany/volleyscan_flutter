import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

/// Replica `.btn-social` de VolleyScan_Next (`BotonGoogle.jsx` y `login/page.css`):
/// fondo `#ffffff`, texto `#1e293b`, `border-radius: 10px`, `padding: 12px 20px`,
/// `font-weight: 600`, `font-size: 0.95rem`, `box-shadow: 0 4px 6px -1px rgba(0,0,0,0.2)`.
class SocialButton extends StatelessWidget {
  final String label;
  final String iconPath;
  final VoidCallback? onPressed;

  const SocialButton({
    super.key,
    required this.label,
    required this.iconPath,
    this.onPressed,
  });

  /// Constructor preconfigurado para "Continuar con Google" (`POST /api/auth/google`).
  const SocialButton.google({
    super.key,
    this.onPressed,
    this.label = 'Continuar con Google',
  }) : iconPath = 'assets/images/google.jpg';

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 320),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppRadii.sm),
          boxShadow: AppShadows.socialBtn,
        ),
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.socialBtnBg,
            foregroundColor: AppColors.socialBtnText,
            elevation: 0,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadii.sm),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                iconPath,
                width: 20,
                height: 20,
                errorBuilder: (_, _, _) => const Icon(
                  Icons.g_mobiledata_rounded,
                  size: 22,
                  color: AppColors.socialBtnText,
                ),
              ),
              const SizedBox(width: 12),
              Flexible(
                child: Text(
                  label,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 15, // 0.95rem en login/page.css
                    fontWeight: FontWeight.w600,
                    color: AppColors.socialBtnText,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

