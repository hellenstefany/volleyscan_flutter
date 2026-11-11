import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

/// Replica `.login-header` -> `.logo` de VolleyScan_Next (`login/page.jsx` y `page.css`):
/// Imagen `50x50` con `border-radius: 10px` (enlace a `/`) + texto `VolleyScan` (`1.4rem`, bold).
class AuthLogo extends StatelessWidget {
  const AuthLogo({super.key, this.onTap});

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onTap ??
              () => Navigator.popUntil(context, (route) => route.isFirst),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppRadii.sm),
            child: Image.asset(
              'assets/images/Logo.VS.jpg',
              width: 50,
              height: 50,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: AppColors.loginCardBg,
                  borderRadius: BorderRadius.circular(AppRadii.sm),
                ),
                alignment: Alignment.center,
                child: const Icon(
                  Icons.sports_volleyball,
                  size: 28,
                  color: AppColors.loginAccentBlue,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        const Text(
          'VolleyScan',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 22.4, // 1.4rem en login/page.css
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}

