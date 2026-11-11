import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:volleyscan_mobile/screens/dashboard_screen.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';
import '../widgets/auth/auth_logo.dart';
import '../widgets/auth/auth_text_field.dart';
import '../widgets/auth/gradient_button.dart';
import '../widgets/auth/social_button.dart';
import '../widgets/usuario/dash_card.dart';
import 'login_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  /// Oculto por ahora; activar cuando se configure Google OAuth en Flutter
  /// contra `POST /api/auth/google`.
  static const bool _enableGoogleLogin = false;

  static final RegExp _emailRegex = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');

  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _lastCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();

  bool _obscure = true;
  bool _loading = false;

  String? _nameError;
  String? _lastError;
  String? _emailError;
  String? _passError;

  static final _nameFormatters = <TextInputFormatter>[
    LengthLimitingTextInputFormatter(100),
  ];
  static final _emailFormatters = <TextInputFormatter>[
    FilteringTextInputFormatter.deny(RegExp(r'\s')),
    LengthLimitingTextInputFormatter(150),
  ];
  static final _passFormatters = <TextInputFormatter>[
    LengthLimitingTextInputFormatter(72),
  ];

  @override
  void dispose() {
    _nameCtrl.dispose();
    _lastCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  /// Validación cliente idéntica a `validate()` en `VolleyScan_Next/src/app/registro/page.jsx`.
  bool _validate() {
    String? nameErr;
    String? lastErr;
    String? emailErr;
    String? passErr;

    final nombre = _nameCtrl.text.trim();
    final apellido = _lastCtrl.text.trim();
    final email = _emailCtrl.text.trim();
    final password = _passCtrl.text;

    if (nombre.isEmpty) {
      nameErr = 'El nombre es obligatorio.';
    }
    if (apellido.isEmpty) {
      lastErr = 'El apellido es obligatorio.';
    }
    if (email.isEmpty) {
      emailErr = 'El correo es obligatorio.';
    } else if (!_emailRegex.hasMatch(email)) {
      emailErr = 'Introduce un correo válido.';
    }
    if (password.isEmpty) {
      passErr = 'La contraseña es obligatoria.';
    } else if (password.length < 8) {
      passErr = 'Mínimo 8 caracteres.';
    }

    setState(() {
      _nameError = nameErr;
      _lastError = lastErr;
      _emailError = emailErr;
      _passError = passErr;
    });

    return nameErr == null &&
        lastErr == null &&
        emailErr == null &&
        passErr == null;
  }

  /// Extrae el primer mensaje de un campo devuelto por el backend (`{ campo: ["msg"] }` o `"msg"`).
  String? _campoError(dynamic datos, String campo) {
    if (datos is! Map) return null;
    final valor = datos[campo];
    if (valor == null) return null;
    if (valor is List && valor.isNotEmpty) {
      return valor.first.toString();
    }
    final texto = valor.toString();
    return texto.isNotEmpty ? texto : null;
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (_loading) return;
    if (!_validate()) return;

    setState(() {
      _loading = true;
      _nameError = null;
      _lastError = null;
      _emailError = null;
      _passError = null;
    });

    try {
      // En el backend (registro.py), POST /api/auth/registro crea siempre un ATLETA,
      // devuelve { access, usuario } (201 Created) y deja la sesión iniciada.
      final usuario = await ApiService().registro(
        _nameCtrl.text.trim(),
        _lastCtrl.text.trim(),
        _emailCtrl.text.trim(),
        _passCtrl.text,
      );
      if (!mounted) return;

      final nombre = (usuario['nombre'] ?? _nameCtrl.text.trim())
          .toString()
          .trim();
      showAppToast(
        context,
        '✓ ¡Bienvenido/a, $nombre! Redirigiendo…',
        type: 'success',
      );

      await Future.delayed(const Duration(milliseconds: 1200));
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => DashboardScreen(userName: nombre),
        ),
      );
    } on ApiException catch ( err) {
      if (!mounted) return;

      if (err.statusCode == 400 || err.statusCode == 409) {
        final nameErr = _campoError(err.data, 'nombre');
        final lastErr = _campoError(err.data, 'apellido');
        var emailErr = _campoError(err.data, 'email');
        final passErr = _campoError(err.data, 'password');

        if (err.statusCode == 409 && emailErr == null) {
          emailErr = 'Ese correo ya está registrado.';
        }

        final hayErroresPorCampo = nameErr != null ||
            lastErr != null ||
            emailErr != null ||
            passErr != null;

        setState(() {
          _nameError = nameErr;
          _lastError = lastErr;
          _emailError = emailErr;
          _passError = passErr;
        });

        showAppToast(
          context,
          hayErroresPorCampo ? 'Revisa los datos del formulario.' : err.message,
          type: 'error',
        );
      } else if (err.isRateLimited) {
        showAppToast(
          context,
          'Demasiados intentos. Inténtalo de nuevo más tarde.',
          type: 'error',
        );
      } else if (err.isNoConnection) {
        showAppToast(context, err.message, type: 'error');
      } else {
        showAppToast(context, err.message, type: 'error');
      }
    } catch (_) {
      if (!mounted) return;
      showAppToast(
        context,
        'No se pudo conectar con el servidor.',
        type: 'error',
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _handleGoogleRegister() async {
    showAppToast(
      context,
      'El registro con Google estará disponible próximamente.',
      type: 'info',
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final cardPadding = screenWidth <= 480
        ? const EdgeInsets.all(25)
        : const EdgeInsets.all(40);

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(gradient: AppGradients.background),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 500),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // ── Header (misma familia visual que Login) ──
                    const AuthLogo(),
                    const SizedBox(height: 20),

                    // ── Card (.contenedor-registro + .login-container) ──
                    DashCard.auth(
                      padding: cardPadding,
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const Text(
                              'Crear ID de atleta',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 24,
                                fontWeight: FontWeight.w700,
                                color: AppColors.loginAccentBlue,
                              ),
                            ),
                            const SizedBox(height: 5),
                            const Text(
                              'Únete para analizar y mejorar tu técnica',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 13.5,
                                color: AppColors.loginTextMuted,
                              ),
                            ),
                            const SizedBox(height: 22),

                            // Fila Nombre + Apellido (.fila-formulario)
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
                                    errorText: _nameError,
                                    onChanged: (_) {
                                      if (_nameError != null) {
                                        setState(() => _nameError = null);
                                      }
                                    },
                                  ),
                                ),
                                const SizedBox(width: 12),
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
                                    errorText: _lastError,
                                    onChanged: (_) {
                                      if (_lastError != null) {
                                        setState(() => _lastError = null);
                                      }
                                    },
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),

                            // Correo electrónico
                            AuthTextField(
                              label: 'Correo electrónico',
                              hint: 'tuemail@ejemplo.com',
                              controller: _emailCtrl,
                              keyboardType: TextInputType.emailAddress,
                              textInputAction: TextInputAction.next,
                              autofillHints: const [AutofillHints.email],
                              inputFormatters: _emailFormatters,
                              errorText: _emailError,
                              onChanged: (_) {
                                if (_emailError != null) {
                                  setState(() => _emailError = null);
                                }
                              },
                            ),
                            const SizedBox(height: 16),

                            // Contraseña
                            AuthTextField(
                              label: 'Contraseña',
                              hint: '••••••••',
                              controller: _passCtrl,
                              isPassword: true,
                              obscure: _obscure,
                              textInputAction: TextInputAction.done,
                              autofillHints: const [AutofillHints.newPassword],
                              inputFormatters: _passFormatters,
                              errorText: _passError,
                              onToggleObscure: () =>
                                  setState(() => _obscure = !_obscure),
                              onFieldSubmitted: (_) => _submit(),
                              onChanged: (_) {
                                if (_passError != null) {
                                  setState(() => _passError = null);
                                }
                              },
                            ),
                            const SizedBox(height: 20),

                            // Botón principal (.boton-principal)
                            GradientButton(
                              text: 'Completar registro',
                              loadingText: 'Creando cuenta…',
                              showArrow: false,
                              loading: _loading,
                              onPressed: _submit,
                            ),
                            const SizedBox(height: 14),

                            // Aviso para entrenadores (igual que en Next)
                            const Text(
                              '¿Eres entrenador? Solicita tu cuenta al administrador.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 12,
                                color: AppColors.loginTextMuted,
                              ),
                            ),
                            const SizedBox(height: 14),

                            // Redirección a Login (.redireccion-inicio)
                            Wrap(
                              alignment: WrapAlignment.center,
                              children: [
                                const Text(
                                  '¿Ya tienes cuenta? ',
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 13.5,
                                    color: AppColors.loginTextMuted,
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
                                      fontSize: 13.5,
                                      fontWeight: FontWeight.w500,
                                      color: AppColors.loginAccentBlue,
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            // Social Google (oculto mientras _enableGoogleLogin == false)
                            if (_enableGoogleLogin) ...[
                              const SizedBox(height: 20),
                              Row(
                                children: [
                                  const Expanded(
                                    child: Divider(
                                      color: AppColors.inputBorder,
                                      thickness: 1,
                                    ),
                                  ),
                                  const Padding(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 12,
                                    ),
                                    child: Text(
                                      'O REGÍSTRATE CON',
                                      style: TextStyle(
                                        fontFamily: 'Poppins',
                                        fontSize: 11,
                                        letterSpacing: 0.8,
                                        color: AppColors.loginTextMuted,
                                      ),
                                    ),
                                  ),
                                  const Expanded(
                                    child: Divider(
                                      color: AppColors.inputBorder,
                                      thickness: 1,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Center(
                                child: SocialButton.google(
                                  onPressed: _handleGoogleRegister,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

