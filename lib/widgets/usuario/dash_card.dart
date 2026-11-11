import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../theme/dash_colors.dart';

/// Contenedor base reutilizable para tarjetas del panel (`.card1` / `.stat-card`)
/// y contenedores de autenticación (`.login-container`).
class DashCard extends StatelessWidget {
  const DashCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(14),
    this.backgroundColor = DashColors.card,
    this.borderRadius = AppRadii.md,
    this.borderColor,
    this.boxShadow,
  });

  /// Variante para la tarjeta de Login / Auth (`.login-container` en Next:
  /// fondo `#050814`, `border-radius: 20px`, `box-shadow: 0 15px 40px rgba(0,0,0,.3)`).
  const DashCard.auth({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(25),
  })  : backgroundColor = AppColors.loginCardBg,
        borderRadius = AppRadii.authCard,
        borderColor = Colors.transparent,
        boxShadow = AppShadows.authCard;

  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color backgroundColor;
  final double borderRadius;
  final Color? borderColor;
  final List<BoxShadow>? boxShadow;

  @override
  Widget build(BuildContext context) {
    final effectiveBorderColor = borderColor ?? DashColors.border;
    return Container(
      padding: padding,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(borderRadius),
        border: effectiveBorderColor == Colors.transparent
            ? null
            : Border.all(color: effectiveBorderColor),
        boxShadow: boxShadow,
      ),
      child: child,
    );
  }
}

