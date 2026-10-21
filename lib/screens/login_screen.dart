import 'package:flutter/material.dart';
import '../widgets/auth/auth_text_field.dart';
import '../widgets/auth/back_home_button.dart';
import '../widgets/auth/gradient_button.dart';
import '../widgets/auth/social_button.dart';
import 'forgot_password_screen.dart';
import 'register_screen.dart';

const _sky = Color(0xFF38BDF8);
const _cyan = Color(0xFF22D3EE);

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _obscure = true;
  bool _remember = true;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    // TODO: conectar con tu backend / autenticación
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
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 360),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: BackHomeButton(),
                    ),
                    const SizedBox(height: 18),
                    _logo(),
                    const SizedBox(height: 26),
                    _card(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _logo() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: _cyan.withOpacity(0.25)),
            boxShadow: [
              BoxShadow(color: _cyan.withOpacity(0.18), blurRadius: 14),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.asset(
              'assets/images/Logo.VS.jpg',
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) =>
                  const Icon(Icons.sports_volleyball, size: 22, color: _cyan),
            ),
          ),
        ),
        const SizedBox(width: 10),
        const Text(
          'VolleyScan',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _card() {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 22, 18, 18),
      decoration: BoxDecoration(
        color: const Color(0xFF080C1C),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withOpacity(0.07)),
      ),
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
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: _sky,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Ingresa tus credenciales para continuar.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 11,
                color: Colors.white.withOpacity(0.6),
              ),
            ),
            const SizedBox(height: 20),
            AuthTextField(
              label: 'Correo Electrónico',
              hint: 'usuario@volleyscan.com',
              controller: _emailCtrl,
              keyboardType: TextInputType.emailAddress,
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Ingresa tu correo';
                if (!v.contains('@')) return 'Correo no válido';
                return null;
              },
            ),
            const SizedBox(height: 14),
            AuthTextField(
              label: 'Contraseña',
              hint: '••••••••',
              controller: _passCtrl,
              isPassword: true,
              obscure: _obscure,
              onToggleObscure: () => setState(() => _obscure = !_obscure),
              validator: (v) =>
                  (v == null || v.length < 6) ? 'Mínimo 6 caracteres' : null,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                SizedBox(
                  width: 18,
                  height: 18,
                  child: Checkbox(
                    value: _remember,
                    onChanged: (v) => setState(() => _remember = v ?? false),
                    activeColor: _cyan,
                    checkColor: const Color(0xFF080C1C),
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    visualDensity: VisualDensity.compact,
                    side: const BorderSide(color: Colors.white54),
                  ),
                ),
                const SizedBox(width: 8),
                const Text(
                  'Recordarme',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 10.5,
                    color: Colors.white,
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const ForgotPasswordScreen(),
                    ),
                  ),
                  child: const Text(
                    '¿Olvidaste tu contraseña?',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 10.5,
                      color: _sky,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            GradientButton(text: 'INGRESAR AHORA', onPressed: _submit),
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(child: Divider(color: Colors.white.withOpacity(0.12))),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Text(
                    'O CONTINÚA CON',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 9.5,
                      letterSpacing: 0.4,
                      color: Colors.white.withOpacity(0.5),
                    ),
                  ),
                ),
                Expanded(child: Divider(color: Colors.white.withOpacity(0.12))),
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
            const SizedBox(height: 16),
            Wrap(
              alignment: WrapAlignment.center,
              children: [
                Text(
                  '¿Aún no tienes cuenta? ',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 10.5,
                    color: Colors.white.withOpacity(0.6),
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const RegisterScreen()),
                  ),
                  child: const Text(
                    '¡Regístrate Gratis!',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 10.5,
                      color: _sky,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
