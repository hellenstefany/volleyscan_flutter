import 'package:flutter/material.dart';

const _sky = Color(0xFF38BDF8);

/// Botón "Volver al inicio" (pastilla con borde) para las pantallas de auth.
/// Por defecto regresa a la primera pantalla de la app (la landing).
class BackHomeButton extends StatelessWidget {
  const BackHomeButton({super.key, this.onTap});

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap:
          onTap ?? () => Navigator.popUntil(context, (route) => route.isFirst),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withOpacity(0.12)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.chevron_left, size: 18, color: _sky),
            const SizedBox(width: 4),
            Text(
              'Volver',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 11.5,
                color: Colors.white.withOpacity(0.8),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
