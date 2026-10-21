import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../utils/validators.dart';
import '../widgets/auth/back_home_button.dart';
import '../widgets/auth/gradient_button.dart';

const _cyan = Color(0xFF22D3EE);
const _sky = Color(0xFF38BDF8);
const _cardBg = Color(0xFF0B1226);
const _fieldBg = Color(0xFF111A33);

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  bool _loading = false;
  int _cooldown = 0;
  Timer? _timer;

  static final _emailFormatters = <TextInputFormatter>[
    FilteringTextInputFormatter.deny(RegExp(r'\s')),
    LengthLimitingTextInputFormatter(254),
  ];

  @override
  void dispose() {
    _timer?.cancel();
    _emailCtrl.dispose();
    super.dispose();
  }

  void _startCooldown() {
    _timer?.cancel();
    setState(() => _cooldown = 60);
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) {
        t.cancel();
        return;
      }
      setState(() => _cooldown--);
      if (_cooldown <= 0) t.cancel();
    });
  }

  Future<void> _sendResetLink(String email) async {
    // TODO: pedir a tu backend que envíe las instrucciones de recuperación.
    await Future.delayed(const Duration(seconds: 1));
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (_loading || _cooldown > 0) return;
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);
    try {
      await _sendResetLink(_emailCtrl.text.trim().toLowerCase());
      if (!mounted) return;
      _startCooldown();
      // Mensaje neutro: no revela si el correo existe o no.
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Si el correo está registrado, te enviamos las instrucciones para restablecer tu contraseña.',
          ),
        ),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No se pudo enviar el correo. Intenta de nuevo.'),
        ),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
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
            colors: [Color(0xFF0A0E1F), Color(0xFF0D1330)],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 400),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _topBar(),
                    const SizedBox(height: 22),
                    _logo(),
                    const SizedBox(height: 24),
                    _card(),
                    const SizedBox(height: 24),
                    _footer(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _topBar() {
    return const Align(
      alignment: Alignment.centerLeft,
      child: BackHomeButton(),
    );
  }

  Widget _logo() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: _cyan.withOpacity(0.3)),
            boxShadow: [
              BoxShadow(color: _cyan.withOpacity(0.22), blurRadius: 16),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.asset(
              'assets/images/Logo.VS.jpg',
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) =>
                  const Icon(Icons.sports_volleyball, size: 24, color: _cyan),
            ),
          ),
        ),
        const SizedBox(width: 10),
        RichText(
          text: const TextSpan(
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 26,
              fontWeight: FontWeight.w800,
            ),
            children: [
              TextSpan(
                text: 'Volley',
                style: TextStyle(color: Colors.white),
              ),
              TextSpan(
                text: 'Scan',
                style: TextStyle(color: _cyan),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _lockIcon() {
    return SizedBox(
      width: 84,
      height: 84,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF12294D), Color(0xFF0C1A33)],
              ),
              border: Border.all(color: _sky.withOpacity(0.35)),
              boxShadow: [
                BoxShadow(color: _sky.withOpacity(0.22), blurRadius: 20),
              ],
            ),
            child: const Icon(Icons.lock_outline, size: 34, color: _sky),
          ),
          Positioned(
            top: 0,
            right: 0,
            child: Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: const Color(0xFF2563EB),
                shape: BoxShape.circle,
                border: Border.all(color: _cardBg, width: 2),
              ),
              child: const Icon(Icons.bolt, size: 14, color: Color(0xFFFACC15)),
            ),
          ),
        ],
      ),
    );
  }

  OutlineInputBorder _border(Color c) => OutlineInputBorder(
    borderRadius: BorderRadius.circular(14),
    borderSide: BorderSide(color: c),
  );

  Widget _emailField() {
    return TextFormField(
      controller: _emailCtrl,
      keyboardType: TextInputType.emailAddress,
      textInputAction: TextInputAction.done,
      autofillHints: const [AutofillHints.email],
      inputFormatters: _emailFormatters,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      validator: Validators.email,
      onFieldSubmitted: (_) => _submit(),
      style: const TextStyle(
        fontFamily: 'Poppins',
        fontSize: 13,
        color: Colors.white,
      ),
      decoration: InputDecoration(
        hintText: 'usuario@volleyscan.com',
        hintStyle: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 13,
          color: Colors.white.withOpacity(0.35),
        ),
        prefixIcon: Icon(
          Icons.mail_outline,
          size: 20,
          color: Colors.white.withOpacity(0.55),
        ),
        filled: true,
        fillColor: _fieldBg,
        contentPadding: const EdgeInsets.symmetric(vertical: 16),
        enabledBorder: _border(Colors.white.withOpacity(0.1)),
        focusedBorder: _border(_sky),
        errorBorder: _border(const Color(0xFFF87171)),
        focusedErrorBorder: _border(const Color(0xFFF87171)),
      ),
    );
  }

  Widget _card() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(child: _lockIcon()),
            const SizedBox(height: 16),
            const Text(
              '¿Olvidaste tu contraseña?',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Ingresa tu correo registrado y te enviaremos las instrucciones y un enlace seguro para restablecerla.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 11.5,
                height: 1.5,
                color: Colors.white.withOpacity(0.6),
              ),
            ),
            const SizedBox(height: 22),
            Text(
              'CORREO ELECTRÓNICO',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 11,
                fontWeight: FontWeight.w500,
                letterSpacing: 0.3,
                color: Colors.white.withOpacity(0.85),
              ),
            ),
            const SizedBox(height: 8),
            _emailField(),
            const SizedBox(height: 18),
            GradientButton(
              text: _cooldown > 0
                  ? 'REENVIAR EN ${_cooldown}S'
                  : 'ENVIAR INSTRUCCIONES',
              loading: _loading,
              onPressed: _submit,
            ),
          ],
        ),
      ),
    );
  }

  Widget _footer() {
    return Column(
      children: [
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.arrow_back, size: 16, color: _cyan),
              SizedBox(width: 6),
              Text(
                'Volver a Iniciar Sesión',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: _cyan,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        Wrap(
          alignment: WrapAlignment.center,
          children: [
            Text(
              '¿Problemas con tu cuenta? ',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 11,
                color: Colors.white.withOpacity(0.55),
              ),
            ),
            GestureDetector(
              onTap: () {
                // TODO: abrir soporte (correo, WhatsApp o pantalla de ayuda)
              },
              child: Text(
                'Contactar Soporte VolleyScan',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 11,
                  color: Colors.white.withOpacity(0.8),
                  decoration: TextDecoration.underline,
                  decorationColor: Colors.white.withOpacity(0.8),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.shield, size: 14, color: Colors.white.withOpacity(0.3)),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                'Conexión protegida con cifrado SSL de extremo a extremo',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 9.5,
                  color: Colors.white.withOpacity(0.35),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
