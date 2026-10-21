import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../utils/validators.dart';
import '../widgets/auth/auth_text_field.dart';
import '../widgets/auth/back_home_button.dart';
import '../widgets/auth/gradient_button.dart';
import '../widgets/auth/password_strength.dart';
import '../widgets/auth/social_button.dart';
import 'login_screen.dart';

const _cyan = Color(0xFF22D3EE);

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _lastCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();

  bool _obscure = true;
  bool _obscureConfirm = true;
  bool _loading = false;

  static final _nameFormatters = <TextInputFormatter>[
    FilteringTextInputFormatter.allow(RegExp(r"[A-Za-zÁÉÍÓÚÜÑáéíóúüñ '\-]")),
    LengthLimitingTextInputFormatter(40),
  ];
  static final _emailFormatters = <TextInputFormatter>[
    FilteringTextInputFormatter.deny(RegExp(r'\s')),
    LengthLimitingTextInputFormatter(254),
  ];
  static final _passFormatters = <TextInputFormatter>[
    FilteringTextInputFormatter.deny(RegExp(r'\s')),
    LengthLimitingTextInputFormatter(64),
  ];

  @override
  void dispose() {
    _nameCtrl.dispose();
    _lastCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  String? _validateConfirm(String? v) {
    if (v == null || v.isEmpty) return 'Confirma tu contraseña';
    if (v != _passCtrl.text) return 'Las contraseñas no coinciden';
    return null;
  }

  Future<void> _registerUser(Map<String, String> data) async {
    // TODO: enviar `data` por HTTPS a tu backend.
    await Future.delayed(const Duration(seconds: 1));
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (_loading) return;
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);
    try {
      await _registerUser({
        'nombre': _nameCtrl.text.trim(),
        'apellido': _lastCtrl.text.trim(),
        'correo': _emailCtrl.text.trim().toLowerCase(),
        'contrasena': _passCtrl.text,
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cuenta creada correctamente')),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No se pudo crear la cuenta. Intenta de nuevo.'),
        ),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  /// Logo centrado arriba con el nombre "VolleyScan" debajo.
  Widget _logoOnly() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: _cyan.withOpacity(0.25)),
            boxShadow: [
              BoxShadow(color: _cyan.withOpacity(0.18), blurRadius: 14),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.asset(
              'assets/images/Logo.VS.jpg',
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) =>
                  const Icon(Icons.sports_volleyball, size: 28, color: _cyan),
            ),
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'VolleyScan',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0A0E1F), Color(0xFF111A3A)],
          ),
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, c) => SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: 400,
                    minHeight: c.maxHeight - 32,
                  ),
                  child: IntrinsicHeight(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Align(
                          alignment: Alignment.centerLeft,
                          child: BackHomeButton(),
                        ),
                        const SizedBox(height: 18),
                        _logoOnly(),
                        const SizedBox(height: 18),
                        const Text(
                          'Crear ID de atleta',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Únete para analizar y mejorar tu técnica',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 11.5,
                            color: Colors.white.withOpacity(0.6),
                          ),
                        ),
                        const SizedBox(height: 22),
                        const SizedBox(height: 10),
                        const SizedBox(height: 16),
                        AutofillGroup(
                          child: Form(
                            key: _formKey,
                            autovalidateMode:
                                AutovalidateMode.onUserInteraction,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: AuthTextField(
                                        label: 'Nombre',
                                        hint: 'Tu nombre',
                                        controller: _nameCtrl,
                                        textCapitalization:
                                            TextCapitalization.words,
                                        textInputAction: TextInputAction.next,
                                        autofillHints: const [
                                          AutofillHints.givenName,
                                        ],
                                        inputFormatters: _nameFormatters,
                                        validator: (v) => Validators.name(
                                          v,
                                          field: 'El nombre',
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: AuthTextField(
                                        label: 'Apellido',
                                        hint: 'Tu apellido',
                                        controller: _lastCtrl,
                                        textCapitalization:
                                            TextCapitalization.words,
                                        textInputAction: TextInputAction.next,
                                        autofillHints: const [
                                          AutofillHints.familyName,
                                        ],
                                        inputFormatters: _nameFormatters,
                                        validator: (v) => Validators.name(
                                          v,
                                          field: 'El apellido',
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 14),
                                AuthTextField(
                                  label: 'Correo electrónico',
                                  hint: 'tuemail@ejemplo.com',
                                  controller: _emailCtrl,
                                  keyboardType: TextInputType.emailAddress,
                                  textInputAction: TextInputAction.next,
                                  autofillHints: const [AutofillHints.email],
                                  inputFormatters: _emailFormatters,
                                  validator: Validators.email,
                                ),
                                const SizedBox(height: 14),
                                AuthTextField(
                                  label: 'Contraseña',
                                  hint: '••••••••',
                                  controller: _passCtrl,
                                  isPassword: true,
                                  obscure: _obscure,
                                  onToggleObscure: () =>
                                      setState(() => _obscure = !_obscure),
                                  textInputAction: TextInputAction.next,
                                  autofillHints: const [
                                    AutofillHints.newPassword,
                                  ],
                                  inputFormatters: _passFormatters,
                                  onChanged: (_) => setState(() {}),
                                  validator: (v) => Validators.password(
                                    v,
                                    email: _emailCtrl.text,
                                  ),
                                ),
                                if (_passCtrl.text.isNotEmpty) ...[
                                  const SizedBox(height: 10),
                                  PasswordStrength(
                                    password: _passCtrl.text,
                                    email: _emailCtrl.text,
                                  ),
                                ],
                                const SizedBox(height: 14),
                                AuthTextField(
                                  label: 'Confirmar contraseña',
                                  hint: '••••••••',
                                  controller: _confirmCtrl,
                                  isPassword: true,
                                  obscure: _obscureConfirm,
                                  onToggleObscure: () => setState(
                                    () => _obscureConfirm = !_obscureConfirm,
                                  ),
                                  textInputAction: TextInputAction.done,
                                  autofillHints: const [
                                    AutofillHints.newPassword,
                                  ],
                                  inputFormatters: _passFormatters,
                                  validator: _validateConfirm,
                                ),
                                const SizedBox(height: 18),
                                GradientButton(
                                  text: 'Completar registro',
                                  showArrow: false,
                                  loading: _loading,
                                  onPressed: _submit,
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),
                        Wrap(
                          alignment: WrapAlignment.center,
                          children: [
                            Text(
                              '¿Ya tienes cuenta? ',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 11.5,
                                color: Colors.white.withOpacity(0.6),
                              ),
                            ),
                            GestureDetector(
                              onTap: () => Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const LoginScreen(),
                                ),
                              ),
                              child: const Text(
                                'Inicia sesión aquí',
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w600,
                                  color: _cyan,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 18),
                        Row(
                          children: [
                            Expanded(
                              child: Divider(
                                color: Colors.white.withOpacity(0.12),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                              ),
                              child: Text(
                                'O REGÍSTRATE CON',
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 9.5,
                                  letterSpacing: 0.4,
                                  color: Colors.white.withOpacity(0.5),
                                ),
                              ),
                            ),
                            Expanded(
                              child: Divider(
                                color: Colors.white.withOpacity(0.12),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        Row(
                          children: [
                            Expanded(
                              child: SocialButton(
                                label: 'Google',
                                iconPath: 'assets/images/google.jpg',
                                onPressed: () {},
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: SocialButton(
                                label: 'Facebook',
                                iconPath: 'assets/images/facebook.jpg',
                                onPressed: () {},
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
