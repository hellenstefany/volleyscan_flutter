import 'package:flutter/material.dart';
import '../../../theme/entrenador_colors.dart';
import 'perfil_common_widgets.dart';
import 'perfil_model.dart';

/// Modal "Nuevo logro". Devuelve un Achievement o null.
class LogroDialog extends StatefulWidget {
  const LogroDialog({super.key});

  @override
  State<LogroDialog> createState() => _LogroDialogState();
}

class _LogroDialogState extends State<LogroDialog> {
  final _title = TextEditingController();
  final _desc = TextEditingController();
  final _icon = TextEditingController(text: '🏆');
  String? _titleError, _descError;

  @override
  void dispose() {
    _title.dispose();
    _desc.dispose();
    _icon.dispose();
    super.dispose();
  }

  void _guardar() {
    setState(() {
      _titleError = _title.text.trim().isEmpty
          ? 'El título es obligatorio'
          : null;
      _descError = _desc.text.trim().isEmpty
          ? 'La descripción es obligatoria'
          : null;
    });
    if (_titleError != null || _descError != null) return;
    Navigator.pop(
      context,
      Achievement(
        DateTime.now().millisecondsSinceEpoch,
        _icon.text.trim().isEmpty ? '🏆' : _icon.text.trim(),
        _title.text.trim(),
        _desc.text.trim(),
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
        color: EC.text2,
      ),
    ),
  );

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: EC.bgCard2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: EC.border),
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
                          color: EC.text1,
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: () => Navigator.pop(context),
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: EC.bgCard,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: EC.border),
                        ),
                        child: const Icon(
                          Icons.close,
                          size: 16,
                          color: EC.text2,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(color: EC.border, height: 1),
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _modalLabel('Título del logro'),
                    TextField(
                      controller: _title,
                      style: const TextStyle(color: EC.text1),
                      decoration: perfilInputDeco(
                        hint: 'Ej: Campeón invicto',
                        error: _titleError,
                      ),
                    ),
                    const SizedBox(height: 20),
                    _modalLabel('Descripción'),
                    TextField(
                      controller: _desc,
                      style: const TextStyle(color: EC.text1),
                      decoration: perfilInputDeco(
                        hint: 'Ej: Liga Departamental 2025',
                        error: _descError,
                      ),
                    ),
                    const SizedBox(height: 20),
                    _modalLabel('Icono (emoji)'),
                    TextField(
                      controller: _icon,
                      maxLength: 2,
                      style: const TextStyle(color: EC.text1),
                      decoration: perfilInputDeco(
                        hint: 'Ej: 🏆',
                      ).copyWith(counterText: ''),
                    ),
                  ],
                ),
              ),
              const Divider(color: EC.border, height: 1),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: EC.text2,
                        side: const BorderSide(color: EC.border),
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
