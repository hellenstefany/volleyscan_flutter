import 'package:flutter/material.dart';
import '../../../theme/dash_colors.dart';

/// Diálogo de confirmación reutilizable para acciones sensibles
/// (cerrar sesión, cerrar un dispositivo o cerrar otros dispositivos).
Future<bool> showConfigConfirmDialog(
  BuildContext context, {
  required String title,
  required String message,
  required String confirmLabel,
  bool danger = true,
}) async {
  final res = await showDialog<bool>(
    context: context,
    barrierColor: DashColors.modalOverlay,
    builder: (ctx) => AlertDialog(
      backgroundColor: DashColors.cardDark,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: const BorderSide(color: DashColors.coachBorder),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.w700,
          color: DashColors.text,
        ),
      ),
      content: Text(
        message,
        style: const TextStyle(
          fontSize: 13.5,
          color: DashColors.textSecondary,
          height: 1.5,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(false),
          child: const Text(
            'Cancelar',
            style: TextStyle(color: DashColors.textSecondary),
          ),
        ),
        ElevatedButton(
          onPressed: () => Navigator.of(ctx).pop(true),
          style: ElevatedButton.styleFrom(
            backgroundColor: danger
                ? DashColors.red.withValues(alpha: 0.18)
                : DashColors.blueLight,
            foregroundColor: danger ? DashColors.red : Colors.white,
            side: danger
                ? BorderSide(color: DashColors.red.withValues(alpha: 0.5))
                : null,
          ),
          child: Text(confirmLabel),
        ),
      ],
    ),
  );
  return res == true;
}
