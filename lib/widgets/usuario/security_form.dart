import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../services/api_service.dart';
import '../../theme/app_theme.dart';
import '../../theme/dash_colors.dart';
import 'dash_card.dart';
import 'form_action_buttons.dart';
import 'profile_field.dart';

/// Tarjeta "Cuenta y seguridad" (`SeccionSeguridad.jsx` en Next):
/// cambio de contraseña (`PUT /api/usuario/perfil/password/`) con medidor de fortaleza
/// y errores debajo de cada campo.
class SecurityForm extends StatefulWidget {
  const SecurityForm({super.key, required this.onChangePassword});

  final Future<String> Function(String current, String next) onChangePassword;

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
  Map<String, String> _apiErrors = {};

  static final _passFormatters = <TextInputFormatter>[
    LengthLimitingTextInputFormatter(72),
  ];

  @override
  void dispose() {
    _currentCtrl.dispose();
    _newCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  /// Calcula la fortaleza (0..4) igual que `calcularFuerza(pwd)` en `SeccionSeguridad.jsx`.
  int _calcStrength(String pwd) {
    if (pwd.isEmpty) return 0;
    int pts = 0;
    if (pwd.length >= 8) pts++;
    if (pwd.length >= 12) pts++;
    if (RegExp(r'[A-Z]').hasMatch(pwd) && RegExp(r'[a-z]').hasMatch(pwd)) {
      pts++;
    }
    if (RegExp(r'\d').hasMatch(pwd) &&
        RegExp(r'[^A-Za-z0-9]').hasMatch(pwd)) {
      pts++;
    }
    return pts < 1 ? 1 : pts;
  }

  String? _validateCurrent(String? v) {
    if (v == null || v.isEmpty) return 'Introduce tu contraseña actual.';
    return null;
  }

  String? _validateNew(String? v) {
    if (v == null || v.isEmpty) return 'Introduce la nueva contraseña.';
    if (v.length < 8) return 'Mínimo 8 caracteres.';
    if (v.length > 72) return 'Máximo 72 caracteres.';
    return null;
  }

  String? _validateConfirm(String? v) {
    if (v == null || v.isEmpty) return 'Confirma tu nueva contraseña.';
    if (v != _newCtrl.text) return 'Las contraseñas no coinciden.';
    return null;
  }

  void _clear() {
    _formKey.currentState?.reset();
    _currentCtrl.clear();
    _newCtrl.clear();
    _confirmCtrl.clear();
    _apiErrors = {};
  }

  void _cancel() {
    FocusScope.of(context).unfocus();
    setState(_clear);
  }

  Future<void> _save() async {
    FocusScope.of(context).unfocus();
    if (_saving) return;
    setState(() => _apiErrors = {});
    if (!_formKey.currentState!.validate()) return;

    setState(() => _saving = true);
    try {
      final msg = await widget.onChangePassword(
        _currentCtrl.text,
        _newCtrl.text,
      );
      if (!mounted) return;
      setState(_clear);
      showAppToast(context, '✓ $msg', type: 'ok');
    } on ApiException catch (err) {
      if (!mounted) return;
      final fieldErrs = <String, String>{};
      if (err.data is Map) {
        (err.data as Map).forEach((k, v) {
          if (v is List && v.isNotEmpty) {
            fieldErrs[k.toString()] = v.first.toString();
          } else if (v is String && v.isNotEmpty) {
            fieldErrs[k.toString()] = v;
          }
        });
      }
      if (fieldErrs.isNotEmpty) setState(() => _apiErrors = fieldErrs);
      showAppToast(context, err.message, type: 'error');
    } catch (_) {
      if (mounted) {
        showAppToast(
          context,
          'Error al actualizar la contraseña.',
          type: 'error',
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Widget _strengthBar() {
    final pwd = _newCtrl.text;
    if (pwd.isEmpty) return const SizedBox.shrink();
    final level = _calcStrength(pwd);
    const colors = [
      Colors.transparent,
      DashColors.red,
      DashColors.orange,
      DashColors.yellow,
      DashColors.green,
    ];
    const labels = ['', 'Débil', 'Regular', 'Buena', 'Fuerte'];
    final activeColor = colors[level];

    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        children: [
          for (int i = 1; i <= 4; i++) ...[
            Expanded(
              child: Container(
                height: 4,
                decoration: BoxDecoration(
                  color: i <= level
                      ? activeColor
                      : Colors.white.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            if (i < 4) const SizedBox(width: 5),
          ],
          const SizedBox(width: 10),
          Text(
            labels[level],
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: activeColor,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DashCard(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: _formKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Cuenta y seguridad',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: DashColors.text,
              ),
            ),
            const SizedBox(height: 18),
            ProfileTextField(
              label: 'Contraseña actual',
              hint: '••••••••',
              controller: _currentCtrl,
              obscure: _obscureCurrent,
              onToggleObscure: () =>
                  setState(() => _obscureCurrent = !_obscureCurrent),
              textInputAction: TextInputAction.next,
              inputFormatters: _passFormatters,
              errorText: _apiErrors['password_actual'],
              onChanged: (_) {
                if (_apiErrors.containsKey('password_actual')) {
                  setState(
                    () => _apiErrors = {..._apiErrors}
                      ..remove('password_actual'),
                  );
                }
              },
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
              errorText: _apiErrors['password_nueva'],
              onChanged: (_) {
                setState(() => _apiErrors.remove('password_nueva'));
                if (_confirmCtrl.text.isNotEmpty) {
                  _formKey.currentState?.validate();
                }
              },
              validator: _validateNew,
            ),
            _strengthBar(),
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
    );
  }
}
