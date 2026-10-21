import 'package:flutter/material.dart';
import '../../theme/dash_colors.dart';

/// Contenedor base (tarjeta oscura con borde) para todo el panel.
class DashCard extends StatelessWidget {
  const DashCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(14),
  });

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: DashColors.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: DashColors.border),
      ),
      child: child,
    );
  }
}
