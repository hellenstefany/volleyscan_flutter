import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../theme/dash_colors.dart';
import 'dash_card.dart';
import 'form_action_buttons.dart';
import 'profile_field.dart';

const _danger = Color(0xFFF87171);

/// Tarjeta "Cuenta y seguridad": cambio de contraseña y zona de peligro.
class SecurityForm extends StatefulWidget {
  const SecurityForm({
    super.key,
    required this.onChangePassword,
    required this.onDeleteAccount,
  });

  final Future<void> Function(String current, String next) onChangePassword;
  final Future<void> Function() onDeleteAccount;

  @override
  State<SecurityForm> createState() => _SecurityFormState();
}

class _SecurityFormState extends State<SecurityForm> {
  final _formKey = GlobalKey<FormState>();
  final _currentCtrl = TextEditingController();
  final _newCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();

  bool _obscureCurrent = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;
  bool _saving = false;
  bool _deleting = false;

  static final _passFormatters = <TextInputFormatter>[
    FilteringTextInputFormatter.deny(RegExp(r'\s')),
    LengthLimitingTextInputFormatter(64),
  ];

  @override
  void dispose() {
    _currentCtrl.dispose();
    _newCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  // ---------- validaciones ----------

  String? _validateCurrent(String? v) {
    if (v == null || v.isEmpty) return 'Ingresa tu contraseña actual';
    return null;
  }

  String? _validateNew(String? v) {
    if (v == null || v.isEmpty) return 'Ingresa la nueva contraseña';
    if (v.length < 8) return 'Mínimo 8 caracteres';
    if (!RegExp(r'[A-Z]').hasMatch(v)) return 'Incluye una mayúscula';
    if (!RegExp(r'[0-9]').hasMatch(v)) return 'Incluye un número';
    if (v == _currentCtrl.text) return 'Debe ser distinta a la actual';
    return null;
  }

  String? _validateConfirm(String? v) {
    if (v == null || v.isEmpty) return 'Repite la nueva contraseña';
    if (v != _newCtrl.text) return 'Las contraseñas no coinciden';
    return null;
  }

  // ---------- acciones ----------

  void _clear() {
    _formKey.currentState?.reset();
    _currentCtrl.clear();
    _newCtrl.clear();
    _confirmCtrl.clear();
  }

  void _cancel() {
    FocusScope.of(context).unfocus();
    setState(_clear);
  }

  Future<void> _save() async {
    FocusScope.of(context).unfocus();
    if (_saving) return;
    if (!_formKey.currentState!.validate()) return;

    setState(() => _saving = true);
    try {
      await widget.onChangePassword(_currentCtrl.text, _newCtrl.text);
      if (!mounted) return;
      setState(_clear);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Contraseña actualizada correctamente')),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'No se pudo actualizar la contraseña. Revisa tu contraseña actual.',
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _confirmDelete() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: DashColors.card,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: BorderSide(color: Colors.white.withOpacity(0.08)),
        ),
        title: const Text(
          '¿Eliminar cuenta?',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        content: Text(
          'Esta acción es permanente e irreversible. Perderás tu historial y tus análisis.',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 12.5,
            height: 1.5,
            color: Colors.white.withOpacity(0.7),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(
              'Cancelar',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w600,
                color: Colors.white.withOpacity(0.8),
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text(
              'Eliminar',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w600,
                color: _danger,
              ),
            ),
          ),
        ],
      ),
    );

    if (ok != true || !mounted) return;

    setState(() => _deleting = true);
    try {
      await widget.onDeleteAccount();
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No se pudo eliminar la cuenta. Intenta de nuevo.'),
        ),
      );
    } finally {
      if (mounted) setState(() => _deleting = false);
    }
  }

  // ---------- UI ----------

  @override
  Widget build(BuildContext context) {
    return DashCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Cuenta y seguridad',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 18),
          Form(
            key: _formKey,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ProfileTextField(
                  label: 'Contraseña actual',
                  hint: '••••••••',
                  controller: _currentCtrl,
                  obscure: _obscureCurrent,
                  onToggleObscure: () =>
                      setState(() => _obscureCurrent = !_obscureCurrent),
                  textInputAction: TextInputAction.next,
                  inputFormatters: _passFormatters,
                  validator: _validateCurrent,
                ),
                const SizedBox(height: 14),
                ProfileTextField(
                  label: 'Nueva contraseña',
                  hint: 'Mín. 8 caracteres',
                  controller: _newCtrl,
                  obscure: _obscureNew,
                  onToggleObscure: () =>
                      setState(() => _obscureNew = !_obscureNew),
                  textInputAction: TextInputAction.next,
                  inputFormatters: _passFormatters,
                  validator: _validateNew,
                ),
                const SizedBox(height: 14),
                ProfileTextField(
                  label: 'Confirmar contraseña',
                  hint: 'Repite la nueva contraseña',
                  controller: _confirmCtrl,
                  obscure: _obscureConfirm,
                  onToggleObscure: () =>
                      setState(() => _obscureConfirm = !_obscureConfirm),
                  textInputAction: TextInputAction.done,
                  inputFormatters: _passFormatters,
                  validator: _validateConfirm,
                ),
                const SizedBox(height: 22),
                FormActionButtons(
                  saving: _saving,
                  saveLabel: 'Actualizar contraseña',
                  onCancel: _cancel,
                  onSave: _save,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Divider(height: 1, color: Colors.white.withOpacity(0.08)),
          const SizedBox(height: 22),
          const Text(
            'Zona de peligro',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 14.5,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Estas acciones son permanentes e irreversibles.',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 11.5,
              color: Colors.white.withOpacity(0.45),
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            height: 46,
            child: OutlinedButton(
              onPressed: _deleting ? null : _confirmDelete,
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.white,
                side: BorderSide(color: _danger.withOpacity(0.45)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _deleting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: _danger,
                      ),
                    )
                  : const Text(
                      'Eliminar cuenta',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
