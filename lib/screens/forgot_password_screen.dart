import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';
import '../widgets/auth/auth_logo.dart';
import '../widgets/auth/auth_text_field.dart';
import '../widgets/auth/gradient_button.dart';
import '../widgets/usuario/dash_card.dart';
import 'login_screen.dart';

/// Pantalla de Recuperación y Restablecimiento de Contraseña.
/// Replica exactamente `VolleyScan_Next/src/app/recuperacion/page.jsx` (`recuperacio.css`)
/// y `VolleyScan_Next/src/app/restablecer/page.jsx` (`restablecer.css`),
/// conectada con `POST /api/auth/recuperar` y `POST /api/auth/restablecer`.
class ForgotPasswordScreen extends StatefulWidget {
  /// Si se recibe un token inicial (por ejemplo desde un enlace `/restablecer#token=...`),
  /// abre directamente la vista de "Nueva contraseña".
  final String? initialToken;

  const ForgotPasswordScreen({super.key, this.initialToken});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  static final RegExp _emailRegex = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');

  // ── Controles paso 1: Solicitar enlace (POST /api/auth/recuperar) ──
  final _emailCtrl = TextEditingController();
  bool _loadingRecover = false;
  bool _sent = false;
  String _sentEmail = '';
  String? _emailError;

  // ── Controles paso 2: Restablecer contraseña (POST /api/auth/restablecer) ──
  final _tokenCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  bool _resetMode = false;
  bool _hasPreloadedToken = false;
  bool _obscurePass = true;
  bool _obscureConfirm = true;
  bool _loadingReset = false;
  bool _resetDone = false;
  bool _tokenRejected = false;
  String? _tokenError;
  String? _resetError;

  static final _emailFormatters = <TextInputFormatter>[
    FilteringTextInputFormatter.deny(RegExp(r'\s')),
    LengthLimitingTextInputFormatter(150),
  ];

  static final _passFormatters = <TextInputFormatter>[
    LengthLimitingTextInputFormatter(72),
  ];

  @override
  void initState() {
    super.initState();
    final detectedToken = _detectInitialToken();
    if (detectedToken != null && detectedToken.isNotEmpty) {
      _tokenCtrl.text = detectedToken;
      _hasPreloadedToken = true;
      _resetMode = true;
    }
  }

  /// Detecta si se pasó `initialToken` o si la URL actual (en Web/DeepLink) trae `#token=...` o `?token=...`.
  String? _detectInitialToken() {
    if (widget.initialToken != null && widget.initialToken!.trim().isNotEmpty) {
      return _extractToken(widget.initialToken!);
    }
    try {
      final uri = Uri.base;
      if (uri.fragment.isNotEmpty) {
        final fragParams = Uri.splitQueryString(
          uri.fragment.startsWith('?')
              ? uri.fragment.substring(1)
              : uri.fragment,
        );
        final t = fragParams['token'];
        if (t != null && t.isNotEmpty) return t;
      }
      final qToken = uri.queryParameters['token'];
      if (qToken != null && qToken.isNotEmpty) return qToken;
    } catch (_) {
      // Ignorar si el fragmento no tiene formato query-string.
    }
    return null;
  }

  /// Permite pegar tanto el enlace completo del correo (`http://.../restablecer#token=XYZ`)
  /// como directamente el token firmado (`XYZ`).
  String _extractToken(String rawInput) {
    final trimmed = rawInput.trim();
    if (trimmed.isEmpty) return '';

    final hashIdx = trimmed.indexOf('#token=');
    if (hashIdx != -1) {
      final after = trimmed.substring(hashIdx + '#token='.length);
      return Uri.decodeComponent(after.split('&').first.trim());
    }

    final queryIdx = trimmed.indexOf('token=');
    if (queryIdx != -1) {
      final after = trimmed.substring(queryIdx + 'token='.length);
      return Uri.decodeComponent(after.split('&').first.trim());
    }

    return trimmed;
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _tokenCtrl.dispose();
    _passCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  // ── Paso 1: Solicitar enlace (`POST /api/auth/recuperar`) ──

  Future<void> _submitRecover() async {
    FocusScope.of(context).unfocus();
    if (_loadingRecover) return;

    final correo = _emailCtrl.text.trim();
    if (correo.isEmpty) {
      setState(() => _emailError = 'El correo es obligatorio.');
      return;
    }
    if (!_emailRegex.hasMatch(correo)) {
      setState(() => _emailError = 'Introduce un correo válido.');
      return;
    }

    setState(() {
      _loadingRecover = true;
      _emailError = null;
    });

    try {
      await ApiService().recuperarPassword(correo);
      if (!mounted) return;
      setState(() {
        _sentEmail = correo;
        _sent = true;
      });
      showAppToast(
        context,
        '✓ Solicitud enviada. Revisa tu correo.',
        type: 'success',
      );
    } on ApiException catch (err) {
      if (!mounted) return;
      setState(() {
        if (err.isRateLimited) {
          _emailError =
              'Demasiados intentos. Espera un momento e inténtalo de nuevo.';
        } else if (err.isNoConnection) {
          _emailError = 'No hay conexión con el servidor.';
        } else {
          _emailError =
              'No pudimos procesar la solicitud. Inténtalo de nuevo.';
        }
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _emailError = 'No hay conexión con el servidor.');
    } finally {
      if (mounted) setState(() => _loadingRecover = false);
    }
  }

  // ── Paso 2: Restablecer contraseña (`POST /api/auth/restablecer`) ──

  Future<void> _submitReset() async {
    FocusScope.of(context).unfocus();
    if (_loadingReset) return;

    final token = _extractToken(_tokenCtrl.text);
    final password = _passCtrl.text;
    final confirm = _confirmCtrl.text;

    if (token.isEmpty) {
      setState(() {
        _tokenError = 'Pega el enlace o token recibido en tu correo.';
      });
      return;
    }
    if (password.length < 8) {
      setState(() {
        _tokenError = null;
        _resetError = 'La contraseña debe tener al menos 8 caracteres.';
      });
      return;
    }
    if (password != confirm) {
      setState(() {
        _tokenError = null;
        _resetError = 'Las contraseñas no coinciden.';
      });
      return;
    }

    setState(() {
      _loadingReset = true;
      _tokenError = null;
      _resetError = null;
    });

    try {
      await ApiService().restablecerPassword(
        token: token,
        passwordNueva: password,
      );
      if (!mounted) return;
      setState(() => _resetDone = true);
    } on ApiException catch (err) {
      if (!mounted) return;

      if (err.isRateLimited) {
        setState(() {
          _resetError =
              'Demasiados intentos. Espera un momento e inténtalo de nuevo.';
        });
        return;
      }

      final data = err.data;
      if (data is Map && data['password_nueva'] is List) {
        final list = data['password_nueva'] as List;
        if (list.isNotEmpty) {
          setState(() => _resetError = list.first.toString());
          return;
        }
      }

      if (err.statusCode == 400 && data is Map && data['detail'] != null) {
        setState(() => _tokenRejected = true);
        return;
      }

      if (err.isNoConnection) {
        setState(() => _resetError = 'No hay conexión con el servidor.');
        return;
      }

      setState(() {
        _resetError = 'No pudimos cambiar la contraseña. Inténtalo de nuevo.';
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _resetError = 'No hay conexión con el servidor.');
    } finally {
      if (mounted) setState(() => _loadingReset = false);
    }
  }

  void _volverALogin() {
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    }
  }

  void _abrirModoRecuperar() {
    setState(() {
      _resetMode = false;
      _tokenRejected = false;
      _resetDone = false;
      _tokenError = null;
      _resetError = null;
      _sent = false;
    });
  }

  void _abrirModoRestablecer() {
    setState(() {
      _resetMode = true;
      _tokenRejected = false;
      _resetDone = false;
      _tokenError = null;
      _resetError = null;
    });
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
                // En recuperacio.css y restablecer.css: max-width: 420px
                constraints: const BoxConstraints(maxWidth: 420),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // ── Header (.login-header) ──
                    const AuthLogo(),
                    const SizedBox(height: 20),

                    // ── Card (.login-container) ──
                    DashCard.auth(
                      padding: cardPadding,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          if (_resetMode)
                            _buildRestablecerContent()
                          else
                            _buildRecuperarContent(),

                          // ── Footer (.register) ──
                          const SizedBox(height: 20),
                          Center(
                            child: GestureDetector(
                              onTap: _volverALogin,
                              child: Text(
                                _resetMode
                                    ? 'Volver a iniciar sesión'
                                    : '¿Recordaste tu contraseña?',
                                style: const TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.loginAccentBlue,
                                ),
                              ),
                            ),
                          ),
                        ],
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

  // ── Contenido de `/recuperacion/page.jsx` ──

  Widget _buildRecuperarContent() {
    if (_sent) {
      // Estado: solicitud enviada (.sent-state)
      return Padding(
        padding: const EdgeInsets.only(top: 10, bottom: 20),
        child: Column(
          children: [
            _buildSentStateIcon(
              icon: Icons.mark_email_read_rounded,
              isError: false,
            ),
            const SizedBox(height: 14),
            const Text(
              'Revisa tu correo',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 22.4, // 1.4rem
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 14),
            RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 14,
                  height: 1.6,
                  color: AppColors.loginTextMuted,
                ),
                children: [
                  const TextSpan(text: 'Si '),
                  TextSpan(
                    text: _sentEmail,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      color: AppColors.textLabel,
                    ),
                  ),
                  const TextSpan(
                    text:
                        ' está registrado, recibirás un enlace para restablecer tu contraseña. El enlace vale 30 minutos.',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            GradientButton(
              text: 'Enviar de nuevo',
              showArrow: false,
              onPressed: () {
                setState(() {
                  _sent = false;
                  _emailCtrl.clear();
                  _emailError = null;
                });
              },
            ),
            const SizedBox(height: 14),
            GestureDetector(
              onTap: _abrirModoRestablecer,
              child: const Text(
                '¿Ya tienes el enlace del correo? Restablecer contraseña',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 12.5,
                  fontWeight: FontWeight.w500,
                  color: AppColors.cyan,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Recuperar contraseña',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 24, // 1.5rem
            fontWeight: FontWeight.w700,
            color: AppColors.loginAccentBlue,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Ingresa tu correo electrónico y te enviaremos un enlace para restablecer tu contraseña.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 14,
            height: 1.5,
            color: AppColors.loginTextMuted,
          ),
        ),
        const SizedBox(height: 25),
        AuthTextField(
          label: 'Correo Electrónico',
          hint: 'usuario@volleyscan.com',
          controller: _emailCtrl,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.done,
          autofillHints: const [AutofillHints.email],
          inputFormatters: _emailFormatters,
          errorText: _emailError,
          onFieldSubmitted: (_) => _submitRecover(),
          onChanged: (_) {
            if (_emailError != null) {
              setState(() => _emailError = null);
            }
          },
        ),
        const SizedBox(height: 18),
        GradientButton(
          text: 'ENVIAR ENLACE',
          loadingText: 'ENVIANDO…',
          showArrow: true,
          loading: _loadingRecover,
          onPressed: _submitRecover,
        ),
        const SizedBox(height: 14),
        Center(
          child: GestureDetector(
            onTap: _abrirModoRestablecer,
            child: const Text(
              '¿Ya tienes un enlace de recuperación?',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 12.5,
                color: AppColors.loginTextMuted,
                decoration: TextDecoration.underline,
                decorationColor: AppColors.loginTextMuted,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ── Contenido de `/restablecer/page.jsx` ──

  Widget _buildRestablecerContent() {
    if (_tokenRejected) {
      // Estado: enlace inválido o vencido (.sent-state)
      return Padding(
        padding: const EdgeInsets.only(top: 10, bottom: 20),
        child: Column(
          children: [
            _buildSentStateIcon(
              icon: Icons.link_off_rounded,
              isError: true,
            ),
            const SizedBox(height: 14),
            const Text(
              'Enlace no válido',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 22.4, // 1.4rem
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 14),
            const Text(
              'El enlace venció o ya se usó. Pide uno nuevo para continuar.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 14,
                height: 1.6,
                color: AppColors.loginTextMuted,
              ),
            ),
            const SizedBox(height: 18),
            GradientButton(
              text: 'Pedir otro enlace',
              showArrow: false,
              onPressed: _abrirModoRecuperar,
            ),
          ],
        ),
      );
    }

    if (_resetDone) {
      // Estado: contraseña cambiada (.sent-state)
      return Padding(
        padding: const EdgeInsets.only(top: 10, bottom: 20),
        child: Column(
          children: [
            _buildSentStateIcon(
              icon: Icons.check_circle_rounded,
              isError: false,
            ),
            const SizedBox(height: 14),
            const Text(
              '¡Contraseña actualizada!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 22.4, // 1.4rem
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 14),
            const Text(
              'Ya puedes iniciar sesión con tu nueva contraseña.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 14,
                height: 1.6,
                color: AppColors.loginTextMuted,
              ),
            ),
            const SizedBox(height: 18),
            GradientButton(
              text: 'Iniciar sesión',
              showArrow: false,
              onPressed: _volverALogin,
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Nueva contraseña',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 24, // 1.5rem
            fontWeight: FontWeight.w700,
            color: AppColors.loginAccentBlue,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Elige una contraseña de al menos 8 caracteres.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 14,
            height: 1.5,
            color: AppColors.loginTextMuted,
          ),
        ),
        const SizedBox(height: 25),
        if (!_hasPreloadedToken) ...[
          AuthTextField(
            label: 'Enlace o token del correo',
            hint: 'Pega el enlace o token recibido',
            controller: _tokenCtrl,
            textInputAction: TextInputAction.next,
            errorText: _tokenError,
            onChanged: (_) {
              if (_tokenError != null) {
                setState(() => _tokenError = null);
              }
            },
          ),
          const SizedBox(height: 18),
        ],
        AuthTextField(
          label: 'Nueva contraseña',
          hint: '••••••••',
          controller: _passCtrl,
          isPassword: true,
          obscure: _obscurePass,
          textInputAction: TextInputAction.next,
          autofillHints: const [AutofillHints.newPassword],
          inputFormatters: _passFormatters,
          onToggleObscure: () =>
              setState(() => _obscurePass = !_obscurePass),
          onChanged: (_) {
            if (_resetError != null) {
              setState(() => _resetError = null);
            }
          },
        ),
        const SizedBox(height: 18),
        AuthTextField(
          label: 'Confirmar contraseña',
          hint: '••••••••',
          controller: _confirmCtrl,
          isPassword: true,
          obscure: _obscureConfirm,
          textInputAction: TextInputAction.done,
          autofillHints: const [AutofillHints.newPassword],
          inputFormatters: _passFormatters,
          errorText: _resetError,
          onToggleObscure: () =>
              setState(() => _obscureConfirm = !_obscureConfirm),
          onFieldSubmitted: (_) => _submitReset(),
          onChanged: (_) {
            if (_resetError != null) {
              setState(() => _resetError = null);
            }
          },
        ),
        const SizedBox(height: 18),
        GradientButton(
          text: 'GUARDAR CONTRASEÑA',
          loadingText: 'GUARDANDO…',
          showArrow: false,
          loading: _loadingReset,
          onPressed: _submitReset,
        ),
        if (!_hasPreloadedToken) ...[
          const SizedBox(height: 14),
          Center(
            child: GestureDetector(
              onTap: _abrirModoRecuperar,
              child: const Text(
                '← Solicitar un nuevo enlace por correo',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 12.5,
                  color: AppColors.loginTextMuted,
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  /// Replica `.sent-state__icon` y `.sent-state__icon--error` de `recuperacio.css` / `restablecer.css`:
  /// - `width: 72px; height: 72px; border-radius: 50%`
  /// - Success: `background: rgba(34, 197, 94, .15); border: 2px solid rgba(34, 197, 94, .4); color: #22c55e`
  /// - Error:   `background: rgba(239, 68, 68, .15); border: 2px solid rgba(239, 68, 68, .4); color: #ef4444`
  Widget _buildSentStateIcon({
    required IconData icon,
    required bool isError,
  }) {
    final bgColor = isError
        ? const Color(0x26EF4444) // rgba(239, 68, 68, 0.15)
        : const Color(0x2622C55E); // rgba(34, 197, 94, 0.15)
    final borderColor = isError
        ? const Color(0x66EF4444) // rgba(239, 68, 68, 0.40)
        : const Color(0x6622C55E); // rgba(34, 197, 94, 0.40)
    final iconColor = isError ? AppColors.errorRed : AppColors.green;

    return Container(
      width: 72,
      height: 72,
      decoration: BoxDecoration(
        color: bgColor,
        shape: BoxShape.circle,
        border: Border.all(color: borderColor, width: 2),
      ),
      alignment: Alignment.center,
      child: Icon(icon, size: 32, color: iconColor),
    );
  }
}
