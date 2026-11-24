import 'package:flutter/material.dart';

import '../../../theme/app_theme.dart';
import '../../../theme/dash_colors.dart';

/// Tokens de color del Horario del Entrenador mapeados 100% a `DashColors` y `AppGradients`
/// (sin colores hexadecimales ni `EntrenadorColors`).
class HC {
  HC._();

  static const bg2 = DashColors.bg;
  static const card = DashColors.cardDark;
  static const card2 = DashColors.card2;
  static const card3 = DashColors.surface;
  static const hover = DashColors.cardHover;
  static const border = DashColors.borderSubtle;
  static const border2 = DashColors.border2;
  static const blue = DashColors.blueLight;
  static const blue2 = DashColors.accent2;
  static const purple = DashColors.sidebarActiveBorder;
  static const purple2 = DashColors.coachPurple;
  static const green = DashColors.green;
  static const amber = DashColors.amber;
  static const orange = DashColors.orange;
  static const red = DashColors.red;
  static const redSoft = DashColors.deltaDown;
  static const t1 = DashColors.text1;
  static const t2 = DashColors.textMuted;
  static const t3 = DashColors.text3;

  static const activeGrad = AppGradients.sidebarLogoIcon;
}

String _normTipo(String raw) {
  final t = raw.trim().toLowerCase();
  if (t == 'competencia' || t == 'partido') return 'partido';
  if (t == 'evaluación' || t == 'evaluacion') return 'evaluacion';
  if (t == 'reunión' || t == 'reunion') return 'reunion';
  if (t == 'entrenamiento') return 'entrenamiento';
  return 'otro';
}

Color evBg(String tipo) => switch (_normTipo(tipo)) {
      'entrenamiento' => DashColors.blue.withValues(alpha: 0.28),
      'partido' => DashColors.red.withValues(alpha: 0.25),
      'evaluacion' => DashColors.amber.withValues(alpha: 0.22),
      'reunion' => DashColors.green.withValues(alpha: 0.22),
      _ => DashColors.coachPurple.withValues(alpha: 0.24),
    };

Color evBorder(String tipo) => switch (_normTipo(tipo)) {
      'entrenamiento' => HC.blue,
      'partido' => HC.red,
      'evaluacion' => HC.amber,
      'reunion' => HC.green,
      _ => HC.purple2,
    };

Color dotFg(String tipo) => switch (_normTipo(tipo)) {
      'entrenamiento' => HC.blue2,
      'partido' => HC.redSoft,
      'evaluacion' => HC.amber,
      'reunion' => DashColors.successBadgeText,
      _ => HC.purple2,
    };

IconData tipoIcon(String tipo) => switch (_normTipo(tipo)) {
      'partido' => Icons.emoji_events_rounded,
      'evaluacion' => Icons.fact_check_rounded,
      'reunion' => Icons.groups_rounded,
      'otro' => Icons.event_rounded,
      _ => Icons.sports_volleyball_rounded,
    };
