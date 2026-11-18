import 'package:flutter/material.dart';

import '../../../theme/app_theme.dart';
import '../../../theme/dash_colors.dart';
import 'perfil_common_widgets.dart';
import 'perfil_model.dart';

/// Modal "Nuevo logro" (`addAchievement` en `page.jsx`). Devuelve un `Achievement` o `null`.
class LogroDialog extends StatefulWidget {
  const LogroDialog({super.key});

  @override
  State<LogroDialog> createState() => _LogroDialogState();
}

class _LogroDialogState extends State<LogroDialog> {
  final _title = TextEditingController();
  final _desc = TextEditingController();
  final _icon = TextEditingController(text: '🏆');

  @override
  void dispose() {
    _title.dispose();
    _desc.dispose();
    _icon.dispose();
    super.dispose();
  }

  void _guardar() {
    final t = _title.text.trim();
    final d = _desc.text.trim();
    if (t.isEmpty) {
      showAppToast(context, 'El título es obligatorio', type: 'error');
      return;
    }
    if (d.isEmpty) {
      showAppToast(context, 'La descripción es obligatoria', type: 'error');
      return;
    }
    Navigator.of(context).pop(
      Achievement(
        id: DateTime.now().millisecondsSinceEpoch,
        icon: _icon.text.trim().isEmpty ? '🏆' : _icon.text.trim(),
        title: t,
        description: d,
      ),
    );
  }

  Widget _modalLabel(String t) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(
      t,
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: DashColors.textMuted,
      ),
    ),
  );

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: DashColors.card2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: DashColors.border),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 20, 16, 16),
                child: Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Nuevo logro',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: DashColors.text1,
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: () => Navigator.of(context).maybePop(),
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: DashColors.cardDark,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: DashColors.border),
                        ),
                        child: const Icon(
                          Icons.close_rounded,
                          size: 16,
                          color: DashColors.textMuted,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(color: DashColors.border, height: 1),
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _modalLabel('Título del logro'),
                    TextField(
                      controller: _title,
                      style: const TextStyle(color: DashColors.text1),
                      decoration: perfilInputDeco(hint: 'Ej: Campeón invicto'),
                    ),
                    const SizedBox(height: 20),
                    _modalLabel('Descripción'),
                    TextField(
                      controller: _desc,
                      style: const TextStyle(color: DashColors.text1),
                      decoration: perfilInputDeco(
                        hint: 'Ej: Liga Departamental 2025',
                      ),
                    ),
                    const SizedBox(height: 20),
                    _modalLabel('Icono (emoji)'),
                    TextField(
                      controller: _icon,
                      maxLength: 2,
                      style: const TextStyle(color: DashColors.text1),
                      decoration: perfilInputDeco(
                        hint: 'Ej: 🏆',
                      ).copyWith(counterText: ''),
                    ),
                  ],
                ),
              ),
              const Divider(color: DashColors.border, height: 1),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    OutlinedButton(
                      onPressed: () => Navigator.of(context).maybePop(),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: DashColors.textMuted,
                        side: const BorderSide(color: DashColors.border),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 14,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text('Cancelar'),
                    ),
                    const SizedBox(width: 12),
                    PerfilGradientButton(
                      label: 'Guardar logro',
                      onTap: _guardar,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
