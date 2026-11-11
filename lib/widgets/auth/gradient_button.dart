import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

/// Replica `.btn-login` de VolleyScan_Next (`login/page.css`):
/// `width: 100%`, `padding: 14px`, `border-radius: 12px`,
/// `background: linear-gradient(90deg, #6366f1, #22d3ee)`,
/// `font-weight: 600`, `font-size: 14px`, `letter-spacing: 0.03em`,
/// y cuando `loading` es true muestra `loadingText` (por ejemplo `'VERIFICANDO…'`) con `opacity: 0.7`.
class GradientButton extends StatelessWidget {
  final String text;
  final String? loadingText;
  final VoidCallback? onPressed;
  final bool loading;
  final bool showArrow;

  const GradientButton({
    super.key,
    required this.text,
    this.loadingText,
    this.onPressed,
    this.loading = false,
    this.showArrow = true,
  });

  @override
  Widget build(BuildContext context) {
    final String label = showArrow ? '$text →' : text;

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 200),
      opacity: loading ? 0.7 : 1.0,
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: AppGradients.primary,
          borderRadius: BorderRadius.circular(AppRadii.btn),
        ),
        child: ElevatedButton(
          onPressed: loading ? null : onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            disabledBackgroundColor: Colors.transparent,
            disabledForegroundColor: AppColors.textPrimary,
            shadowColor: Colors.transparent,
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
            minimumSize: const Size(double.infinity, 48),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadii.btn),
            ),
          ),
          child: loading
              ? (loadingText != null
                  ? Text(
                      loadingText!,
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                        letterSpacing: 0.42, // 0.03em
                      ),
                    )
                  : const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.2,
                        color: AppColors.textPrimary,
                      ),
                    ))
              : Text(
                  label,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                    letterSpacing: 0.42, // 0.03em
                  ),
                ),
        ),
      ),
    );
  }
}

