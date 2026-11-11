import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Colores tomados de VolleyScan_Next (globals.css, login/page.css, Dashboard.css).
class AppColors {
  // Base y navegación existentes
  static const bg = Color(0xFF0B0F1A); // --bg-base / --bg-deep
  static const navBg = Color(0xFF050814);
  static const card = Color(0x0AFFFFFF); // rgba(255,255,255,.04) en landing
  static const border = Color(0x14FFFFFF); // --border: rgba(255,255,255,.08)

  // Superficies de paneles (globals.css)
  static const bgBase = Color(0xFF0B0F1A); // --bg-base
  static const bgSurface = Color(0xFF131929); // --bg-surface / --bg-sidebar
  static const bgCard = Color(0xFF1A2235); // --bg-card
  static const bgCardDeep = Color(0xFF111827); // --bg-card (bloque 2)
  static const bgCard2 = Color(0xFF161E2E); // --bg-card2
  static const bgCardHover = Color(0xFF222D46); // --bg-card-hover
  static const bgHover = Color(0xFF1E2A3D); // --bg-hover
  static const borderSubtle = Color(0x0FFFFFFF); // rgba(255,255,255,.06)
  static const borderStrong = Color(0x1AFFFFFF); // rgba(255,255,255,.10)

  // Paleta de Login / Auth (login/page.css)
  static const loginCardBg = Color(0xFF050814); // .login-container background
  static const loginAccentBlue = Color(0xFF0D6EFD); // h1, links, focus, checkbox
  static const loginFocusGlow = Color(0x330D6EFD); // rgba(13, 110, 253, .2)
  static const inputBg = Color(0xFF0F1629); // .form-group input background
  static const inputBorder = Color(0xFF333333); // .form-group input border (#333)
  static const loginTextMuted = Color(0xFFAAAAAA); // .subtitle, .divider, .register
  static const socialBtnBg = Color(0xFFFFFFFF); // .btn-social background
  static const socialBtnText = Color(0xFF1E293B); // .btn-social color

  // Textos (globals.css & login/page.css)
  static const textPrimary = Color(0xFFFFFFFF); // --text-primary
  static const text1 = Color(0xFFF1F5F9); // --text-1
  static const textSecondary = Color(0xFFCBD5E1); // --text-secondary
  static const textLabel = Color(0xFFE2E8F0); // .form-group label & .toast
  static const muted = Color(0xFF94A3B8); // --text-muted / --text-2
  static const text3 = Color(0xFF475569); // --text-3
  static const footerText = Color(0xFF64748B);

  // Colores de acento y estados (globals.css)
  static const cyan = Color(0xFF22D3EE);
  static const blue = Color(0xFF6366F1); // inicio gradiente .btn-login
  static const indigoSoft = Color(0xFF818CF8);
  static const accentBlue = Color(0xFF3B82F6); // --accent-blue / --accent
  static const accentBlue2 = Color(0xFF60A5FA); // --accent2
  static const accentBlueGlow = Color(0x333B82F6); // --accent-blue-glow
  static const green = Color(0xFF22C55E); // --accent-green
  static const accentGreenGlow = Color(0x3322C55E); // --accent-green-glow
  static const teal = Color(0xFF2DD4BF);
  static const accentTeal = Color(0xFF22D3A5); // --green
  static const orange = Color(0xFFF97316); // --accent-orange
  static const purple = Color(0xFFA855F7); // --accent-purple
  static const errorRed = Color(0xFFEF4444); // --red / .input-error
  static const errorGlow = Color(0x33EF4444); // rgba(239, 68, 68, .2)
  static const gold = Color(0xFFFFD700);
  static const goldDeep = Color(0xFFF59E0B);
}

class AppGradients {
  /// Gradiente global y de `.login-page`:
  /// `linear-gradient(135deg, #0B1023 0%, #111A3A 50%, #050814 100%)`
  static const background = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    stops: [0.0, 0.5, 1.0],
    colors: [Color(0xFF0B1023), Color(0xFF111A3A), Color(0xFF050814)],
  );

  /// Gradiente de `.btn-login`:
  /// `linear-gradient(90deg, #6366f1, #22d3ee)`
  static const primary = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [AppColors.blue, AppColors.cyan],
  );

  static const goldBtn = LinearGradient(
    colors: [AppColors.gold, AppColors.goldDeep],
  );
}

class AppRadii {
  static const double sm = 10.0; // --radius-sm: 10px (inputs, toast, social btn)
  static const double btn = 12.0; // .btn-login: 12px
  static const double panel = 14.0; // --radius: 14px
  static const double md = 16.0; // --radius-md: 16px (stat-card, card1)
  static const double authCard = 20.0; // .login-container: 20px
}

class AppShadows {
  /// `.login-container`: `0 15px 40px rgba(0, 0, 0, .3)`
  static const List<BoxShadow> authCard = [
    BoxShadow(
      color: Color(0x4D000000),
      blurRadius: 40,
      offset: Offset(0, 15),
    ),
  ];

  /// `.stat-card:hover`: `0 8px 24px rgba(0, 0, 0, .3)`
  static const List<BoxShadow> cardHover = [
    BoxShadow(
      color: Color(0x4D000000),
      blurRadius: 24,
      offset: Offset(0, 8),
    ),
  ];

  /// `.toast`: `0 8px 24px rgba(0, 0, 0, .4)`
  static const List<BoxShadow> toast = [
    BoxShadow(
      color: Color(0x66000000),
      blurRadius: 24,
      offset: Offset(0, 8),
    ),
  ];

  /// `.btn-social`: `0 4px 6px -1px rgba(0, 0, 0, 0.2)`
  static const List<BoxShadow> socialBtn = [
    BoxShadow(
      color: Color(0x33000000),
      blurRadius: 6,
      offset: Offset(0, 4),
      spreadRadius: -1,
    ),
  ];
}

ThemeData buildTheme() {
  final base = ThemeData.dark();
  final poppinsTextTheme = GoogleFonts.poppinsTextTheme(base.textTheme).apply(
    bodyColor: AppColors.textPrimary,
    displayColor: AppColors.textPrimary,
  );

  return base.copyWith(
    scaffoldBackgroundColor: AppColors.bgBase,
    colorScheme: const ColorScheme.dark(
      primary: AppColors.accentBlue,
      secondary: AppColors.cyan,
      surface: AppColors.bgCard,
      error: AppColors.errorRed,
      onPrimary: AppColors.textPrimary,
      onSecondary: AppColors.textPrimary,
      onSurface: AppColors.textPrimary,
      onError: AppColors.textPrimary,
    ),
    textTheme: poppinsTextTheme,
    cardTheme: CardThemeData(
      color: AppColors.bgCard,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadii.md),
        side: const BorderSide(color: AppColors.border),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      isDense: true,
      filled: true,
      fillColor: AppColors.inputBg,
      contentPadding: const EdgeInsets.all(12),
      hintStyle: const TextStyle(
        fontFamily: 'Poppins',
        fontSize: 12,
        color: AppColors.muted,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadii.sm),
        borderSide: const BorderSide(color: AppColors.inputBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadii.sm),
        borderSide: const BorderSide(color: AppColors.loginAccentBlue),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadii.sm),
        borderSide: const BorderSide(color: AppColors.errorRed),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadii.sm),
        borderSide: const BorderSide(color: AppColors.errorRed),
      ),
      errorStyle: const TextStyle(
        fontFamily: 'Poppins',
        color: AppColors.errorRed,
        fontSize: 12,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.accentBlue,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.sm),
        ),
        textStyle: const TextStyle(
          fontFamily: 'Poppins',
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    checkboxTheme: CheckboxThemeData(
      fillColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return AppColors.loginAccentBlue;
        }
        return Colors.transparent;
      }),
      checkColor: const WidgetStatePropertyAll(Colors.white),
      side: const BorderSide(color: AppColors.loginTextMuted, width: 1.4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: AppColors.bgCard,
      behavior: SnackBarBehavior.floating,
      elevation: 8,
      contentTextStyle: const TextStyle(
        fontFamily: 'Poppins',
        color: AppColors.textLabel,
        fontSize: 13.5,
        fontWeight: FontWeight.w500,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadii.sm),
        side: const BorderSide(color: AppColors.green),
      ),
    ),
  );
}

/// Muestra un Toast flotante idéntico al `.toast` de VolleyScan_Next
/// (`type`: `'success'` -> `#22c55e`, `'error'` -> `#ef4444`, `'info'` -> `#3b82f6`).
void showAppToast(
  BuildContext context,
  String message, {
  String type = 'success',
  Duration duration = const Duration(milliseconds: 3500),
}) {
  final Color borderColor = switch (type) {
    'error' => AppColors.errorRed,
    'info' => AppColors.accentBlue,
    _ => AppColors.green,
  };

  final messenger = ScaffoldMessenger.of(context);
  messenger.hideCurrentSnackBar();
  messenger.showSnackBar(
    SnackBar(
      duration: duration,
      backgroundColor: AppColors.bgCard,
      behavior: SnackBarBehavior.floating,
      margin: const EdgeInsets.only(bottom: 24, right: 24, left: 24),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadii.sm),
        side: BorderSide(color: borderColor, width: 1),
      ),
      content: Text(
        message,
        style: const TextStyle(
          fontFamily: 'Poppins',
          color: AppColors.textLabel,
          fontSize: 13.5,
          fontWeight: FontWeight.w500,
        ),
      ),
    ),
  );
}

