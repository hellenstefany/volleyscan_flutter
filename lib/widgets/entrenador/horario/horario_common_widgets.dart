import 'package:flutter/material.dart';
import 'horario_colors.dart';

BoxDecoration hBox(Color c, double r) => BoxDecoration(
  color: c,
  borderRadius: BorderRadius.circular(r),
  border: Border.all(color: HC.border),
);

class CtrlBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const CtrlBtn({super.key, required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(8),
    child: Container(
      width: 30,
      height: 30,
      decoration: BoxDecoration(
        color: HC.card2,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: HC.border2),
      ),
      child: Icon(icon, size: 16, color: HC.t2),
    ),
  );
}

class ViewBtn extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;
  const ViewBtn({
    super.key,
    required this.label,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(8),
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
      decoration: BoxDecoration(
        gradient: active
            ? const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [HC.purpleG1, HC.purpleG2],
              )
            : null,
        color: active ? null : HC.card2,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: active ? Colors.transparent : HC.border2),
        boxShadow: active
            ? [
                BoxShadow(
                  color: HC.purple.withValues(alpha: 0.35),
                  blurRadius: 12,
                ),
              ]
            : null,
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: active ? Colors.white : HC.t2,
        ),
      ),
    ),
  );
}

/// Caja con barra de color a la izquierda (border-left del CSS).
class EvBox extends StatelessWidget {
  final Color bg, border;
  final double radius, width;
  final EdgeInsets padding;
  final Widget child;
  const EvBox({
    super.key,
    required this.bg,
    required this.border,
    required this.radius,
    required this.padding,
    required this.child,
    this.width = 3,
  });

  @override
  Widget build(BuildContext context) => ClipRRect(
    borderRadius: BorderRadius.circular(radius),
    child: DecoratedBox(
      decoration: BoxDecoration(
        color: bg,
        border: Border(
          left: BorderSide(color: border, width: width),
        ),
      ),
      child: Padding(padding: padding, child: child),
    ),
  );
}

class CloseBtn extends StatelessWidget {
  final VoidCallback onTap;
  const CloseBtn({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(8),
    child: Container(
      width: 30,
      height: 30,
      decoration: BoxDecoration(
        color: HC.card3,
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Icon(Icons.close, size: 14, color: HC.t2),
    ),
  );
}
