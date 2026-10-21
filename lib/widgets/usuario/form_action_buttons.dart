import 'package:flutter/material.dart';
import '../../theme/dash_colors.dart';

/// Botones "Cancelar" y "Guardar cambios" de los formularios del perfil.
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
            height: 46,
            child: OutlinedButton(
              onPressed: saving ? null : onCancel,
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: DashColors.cardDark,
                side: BorderSide(color: Colors.white.withOpacity(0.12)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Cancelar',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          flex: 2,
          child: SizedBox(
            height: 46,
            child: ElevatedButton(
              onPressed: saving ? null : onSave,
              style: ElevatedButton.styleFrom(
                backgroundColor: DashColors.blueLight,
                disabledBackgroundColor: DashColors.blueLight.withOpacity(0.6),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: saving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
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
