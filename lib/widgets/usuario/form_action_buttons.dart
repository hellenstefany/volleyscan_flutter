import 'package:flutter/material.dart';
import '../../theme/dash_colors.dart';

/// Botones "Cancelar" y "Guardar cambios" de los formularios del perfil (`.pf-acciones` en Next).
class FormActionButtons extends StatelessWidget {
  const FormActionButtons({
    super.key,
    required this.saving,
    required this.onCancel,
    required this.onSave,
    this.saveLabel = 'Guardar cambios',
  });

  final bool saving;
  final VoidCallback onCancel;
  final VoidCallback onSave;
  final String saveLabel;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: 44,
            child: OutlinedButton(
              onPressed: saving ? null : onCancel,
              style: OutlinedButton.styleFrom(
                foregroundColor: DashColors.muted,
                backgroundColor: DashColors.surface,
                side: const BorderSide(color: DashColors.border),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                'Cancelar',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          flex: 2,
          child: SizedBox(
            height: 44,
            child: ElevatedButton(
              onPressed: saving ? null : onSave,
              style: ElevatedButton.styleFrom(
                backgroundColor: DashColors.blueLight,
                disabledBackgroundColor:
                    DashColors.blueLight.withValues(alpha: 0.55),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: saving
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text(
                      saveLabel,
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
          ),
        ),
      ],
    );
  }
}
