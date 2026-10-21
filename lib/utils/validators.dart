class PasswordRule {
  final String label;
  final String message;
  final bool passed;
  const PasswordRule(this.label, this.message, this.passed);
}

class PasswordCheck {
  final String password;
  final String email;
  PasswordCheck(this.password, {this.email = ''});

  static const _common = {
    '12345678',
    '123456789',
    '1234567890',
    'password',
    'password1',
    'contrasena',
    'contraseña',
    'qwerty123',
    'qwertyuiop',
    'abc12345',
    'iloveyou',
    'admin123',
    'volleyscan',
  };

  bool get hasLength => password.length >= 8;
  bool get hasUpper => RegExp(r'[A-Z]').hasMatch(password);
  bool get hasLower => RegExp(r'[a-z]').hasMatch(password);
  bool get hasDigit => RegExp(r'\d').hasMatch(password);
  bool get hasSpecial => RegExp(r'[^A-Za-z0-9\s]').hasMatch(password);
  bool get hasNoSpaces => !RegExp(r'\s').hasMatch(password);
  bool get notCommon => !_common.contains(password.toLowerCase());
  bool get notEmail {
    final local = email.trim().toLowerCase().split('@').first;
    return local.length < 3 || !password.toLowerCase().contains(local);
  }

  /// Las 5 reglas que se muestran en pantalla.
  List<PasswordRule> get visibleRules => [
    PasswordRule('8+ caracteres', 'Mínimo 8 caracteres', hasLength),
    PasswordRule('Una mayúscula', 'Agrega una mayúscula', hasUpper),
    PasswordRule('Una minúscula', 'Agrega una minúscula', hasLower),
    PasswordRule('Un número', 'Agrega un número', hasDigit),
    PasswordRule('Un símbolo', 'Agrega un símbolo (!@#%&*)', hasSpecial),
  ];

  /// Todas las reglas, incluidas las que solo se validan al enviar.
  List<PasswordRule> get rules => [
    ...visibleRules,
    PasswordRule('Sin espacios', 'No puede tener espacios', hasNoSpaces),
    PasswordRule('No es común', 'Esa contraseña es muy común', notCommon),
    PasswordRule(
      'No usa tu correo',
      'No uses tu correo en la contraseña',
      notEmail,
    ),
  ];

  bool get isValid => rules.every((r) => r.passed);

  /// 0 = vacía, 1 = débil, 2 = media, 3 = buena, 4 = fuerte
  int get level {
    if (password.isEmpty) return 0;
    if (!notCommon) return 1;
    final score = visibleRules.where((r) => r.passed).length;
    if (score <= 2) return 1;
    if (score == 3) return 2;
    if (score == 4) return 3;
    return 4;
  }
}

class Validators {
  static final _nameRegExp = RegExp(
    r"^[A-Za-zÁÉÍÓÚÜÑáéíóúüñ]+(?:[ '\-][A-Za-zÁÉÍÓÚÜÑáéíóúüñ]+)*$",
  );
  static final _emailRegExp = RegExp(
    r'^[A-Za-z0-9._%+\-]+@[A-Za-z0-9\-]+(\.[A-Za-z0-9\-]+)*\.[A-Za-z]{2,}$',
  );

  static String? name(String? v, {String field = 'Este campo'}) {
    final t = (v ?? '').trim();
    if (t.isEmpty) return '$field es obligatorio';
    if (t.length < 2) return 'Mínimo 2 letras';
    if (t.length > 40) return 'Máximo 40 caracteres';
    if (!_nameRegExp.hasMatch(t)) return 'Solo letras, sin números ni símbolos';
    return null;
  }

  static String? email(String? v) {
    final t = (v ?? '').trim();
    if (t.isEmpty) return 'Ingresa tu correo';
    if (t.length > 254) return 'Correo demasiado largo';
    if (!_emailRegExp.hasMatch(t)) return 'Correo no válido';
    return null;
  }

  static String? password(String? v, {String email = ''}) {
    final p = v ?? '';
    if (p.isEmpty) return 'Ingresa una contraseña';
    if (p.length > 64) return 'Máximo 64 caracteres';
    final failed = PasswordCheck(
      p,
      email: email,
    ).rules.where((r) => !r.passed).toList();
    return failed.isEmpty ? null : failed.first.message;
  }
}
