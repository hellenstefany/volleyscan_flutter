import 'package:flutter/material.dart';
import 'package:volleyscan_mobile/screens/dashboard_screen.dart';
import 'package:volleyscan_mobile/screens/entrenador/entrenador_shell.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';
import '../widgets/auth/auth_logo.dart';
import '../widgets/auth/auth_text_field.dart';
import '../widgets/auth/gradient_button.dart';
import '../widgets/auth/social_button.dart';
import '../widgets/usuario/dash_card.dart';
import 'forgot_password_screen.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  /// Oculto por ahora; activar cuando se configure Google OAuth en Flutter
  /// contra `POST /api/auth/google` (equivalente a `NEXT_PUBLIC_GOOGLE_CLIENT_ID`).
  static const bool _enableGoogleLogin = false;

  static final RegExp _emailRegex = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');

  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();

  bool _obscure = true;
  bool _remember = false;
  bool _loading = false;
  String? _emailError;
  String? _passError;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  /// Validación idéntica a `validate()` en `VolleyScan_Next/src/app/login/page.jsx`.
  bool _validate() {
    String? emailErr;
    String? passErr;

    final email = _emailCtrl.text.trim();
    final pass = _passCtrl.text;

    if (email.isEmpty) {
      emailErr = 'El correo es obligatorio.';
    } else if (!_emailRegex.hasMatch(email)) {
      emailErr = 'Introduce un correo válido.';
    }

    if (pass.isEmpty) {
      passErr = 'La contraseña es obligatoria.';
    } else if (pass.length < 6) {
      passErr = 'Mínimo 6 caracteres.';
    }

    setState(() {
      _emailError = emailErr;
      _passError = passErr;
    });

    return emailErr == null && passErr == null;
  }

  /// Redirige según el valor real de `usuario.rol` en el backend (`atleta`, `entrenador`, `admin`).
  Future<void> _redirigirPorRol(Map<String, dynamic> usuario) async {
    final rol = (usuario['rol'] ?? '').toString().trim().toLowerCase();

    if (rol == 'admin') {
      await ApiService().cerrarSesionCompleta();
      if (!mounted) return;
      showAppToast(
        context,
        'Los administradores gestionan desde el panel web.',
        type: 'info',
      );
      return;
    }

    final nombre = (usuario['nombre'] ?? '').toString().trim();
    showAppToast(
      context,
      '✓ Bienvenido/a${nombre.isNotEmpty ? ', $nombre' : ''}. Redirigiendo…',
      type: 'success',
    );

    await Future.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;

    if (rol == 'entrenador') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const EntrenadorShell()),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => DashboardScreen(userName: nombre),
        ),
      );
    }
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (_loading) return;
    if (!_validate()) return;

    setState(() {
      _loading = true;
      _emailError = null;
      _passError = null;
    });

    try {
      final usuario = await ApiService().login(
        _emailCtrl.text.trim(),
        _passCtrl.text,
      );
      if (!mounted) return;
      await _redirigirPorRol(usuario);
    } on ApiException catch (err) {
      if (!mounted) return;

      if (err.isNoConnection) {
        showAppToast(context, err.message, type: 'error');
      } else if (err.isRateLimited) {
        showAppToast(context, err.message, type: 'error');
      } else if (err.isForbidden) {
        // Muestra el mensaje exacto del backend (por ejemplo, falta de permiso del administrador o cuenta inactiva).
        showAppToast(context, err.message, type: 'error');
      } else if (err.statusCode == 400 || err.statusCode == 401) {
        setState(() {
          _emailError = 'Correo o contraseña incorrectos.';
          _passError = 'Correo o contraseña incorrectos.';
          _passCtrl.clear();
        });
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

  /// Preparado para activarse con `POST /api/auth/google` (ver `panel_usuario/google.py`).
  Future<void> _handleGoogleLogin() async {
    showAppToast(
      context,
      'El inicio con Google estará disponible próximamente.',
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
                    // ── Header (.login-header) ──
                    const AuthLogo(),
                    const SizedBox(height: 20),

                    // ── Card (.login-container) ──
                    DashCard.auth(
                      padding: cardPadding,
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const Text(
                              'Bienvenido',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 25.6, // 1.6rem
                                fontWeight: FontWeight.w700,
                                color: AppColors.loginAccentBlue,
                              ),
                            ),
                            const SizedBox(height: 5),
                            const Text(
                              'Ingresa tus credenciales para continuar.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 14,
                                color: AppColors.loginTextMuted,
                              ),
                            ),
                            const SizedBox(height: 25),

                            // Email (.form-group)
                            AuthTextField(
                              label: 'Correo Electrónico',
                              hint: 'usuario@volleyscan.com',
                              controller: _emailCtrl,
                              keyboardType: TextInputType.emailAddress,
                              textInputAction: TextInputAction.next,
                              autofillHints: const [AutofillHints.email],
                              errorText: _emailError,
                              onChanged: (_) {
                                if (_emailError != null) {
                                  setState(() => _emailError = null);
                                }
                              },
                            ),
                            const SizedBox(height: 18),

                            // Password (.form-group)
                            AuthTextField(
                              label: 'Contraseña',
                              hint: '••••••••',
                              controller: _passCtrl,
                              isPassword: true,
                              obscure: _obscure,
                              textInputAction: TextInputAction.done,
                              autofillHints: const [AutofillHints.password],
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
                            const SizedBox(height: 18),

                            // Opciones (.options)
                            Wrap(
                              alignment: WrapAlignment.spaceBetween,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                GestureDetector(
                                  behavior: HitTestBehavior.opaque,
                                  onTap: () =>
                                      setState(() => _remember = !_remember),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      SizedBox(
                                        width: 18,
                                        height: 18,
                                        child: Checkbox(
                                          value: _remember,
                                          onChanged: (v) => setState(
                                            () => _remember = v ?? false,
                                          ),
                                          materialTapTargetSize:
                                              MaterialTapTargetSize.shrinkWrap,
                                          visualDensity: VisualDensity.compact,
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      const Text(
                                        'Recordarme',
                                        style: TextStyle(
                                          fontFamily: 'Poppins',
                                          fontSize: 13,
                                          color: AppColors.textPrimary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          const ForgotPasswordScreen(),
                                    ),
                                  ),
                                  child: const Text(
                                    '¿Olvidaste tu contraseña?',
                                    style: TextStyle(
                                      fontFamily: 'Poppins',
                                      fontSize: 13,
                                      color: AppColors.loginAccentBlue,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),

                            // Botón Login (.btn-login)
                            GradientButton(
                              text: 'INGRESAR AHORA',
                              loadingText: 'VERIFICANDO…',
                              showArrow: true,
                              loading: _loading,
                              onPressed: _submit,
                            ),

                            // Social Google (oculto mientras _enableGoogleLogin == false)
                            if (_enableGoogleLogin) ...[
                              const SizedBox(height: 25),
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
                                      'O CONTINÚA CON',
                                      style: TextStyle(
                                        fontFamily: 'Poppins',
                                        fontSize: 12,
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
                                  onPressed: _handleGoogleLogin,
                                ),
                              ),
                            ],

                            // Footer (.register)
                            const SizedBox(height: 20),
                            Wrap(
                              alignment: WrapAlignment.center,
                              children: [
                                const Text(
                                  '¿Aún no tienes cuenta? ',
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 14,
                                    color: AppColors.loginTextMuted,
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () => Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => const RegisterScreen(),
                                    ),
                                  ),
                                  child: const Text(
                                    '¡Regístrate Gratis!',
                                    style: TextStyle(
                                      fontFamily: 'Poppins',
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: AppColors.loginAccentBlue,
                                    ),
                                  ),
                                ),
                              ],
                            ),
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

