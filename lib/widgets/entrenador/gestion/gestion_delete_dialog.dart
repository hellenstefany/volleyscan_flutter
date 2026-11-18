import 'package:flutter/material.dart';
import 'gestion_colors.dart';
import 'gestion_common_widgets.dart';

Future<bool?> confirmDelete(BuildContext context) => showDialog<bool>(
  context: context,
  builder: (ctx) => Dialog(
    backgroundColor: GC.card2,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(18),
      side: const BorderSide(color: GC.border),
    ),
    child: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 340),
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.warning_amber_rounded, size: 32, color: GC.red),
            const SizedBox(height: 12),
            const Text(
              '¿Eliminar deportista?',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: GC.t1,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Esta acción eliminará al deportista permanentemente.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12.5, color: GC.t2),
            ),
            const SizedBox(height: 20),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              alignment: WrapAlignment.center,
              children: [
                GhostButton(
                  label: 'Cancelar',
                  onTap: () => Navigator.pop(ctx, false),
                ),
                OutlinedButton(
                  onPressed: () => Navigator.pop(ctx, true),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: GC.redSoft,
                    backgroundColor: GC.redSoft.withValues(alpha: 0.15),
                    side: BorderSide(color: GC.redSoft.withValues(alpha: 0.3)),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 22,
                      vertical: 14,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(9),
                    ),
                  ),
                  child: const Text(
                    'Eliminar',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  ),
);
