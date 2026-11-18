import 'package:flutter/material.dart';

import '../../../theme/dash_colors.dart';

/// Tokens de estilo de `deportistas.module.css` mapeados a `DashColors`
/// (sin definir colores nuevos).
abstract final class GestionColors {
  static const Color bg = DashColors.bg; // #0b0f1a
  static const Color card = DashColors.cardDark; // #111827
  static const Color card2 = DashColors.coachCard2; // #0e1422
  static const Color border = DashColors.coachBorder; // #1f2634
  static const Color blue = DashColors.blueLight; // #3b82f6
  static const Color blueLight = DashColors.accent2; // #60a5fa
  static const Color green = DashColors.green; // #22c55e
  static const Color orange = DashColors.orange; // #f97316
  static const Color text = DashColors.text1; // #f1f5f9
  static const Color text2 = DashColors.textSecondary; // #cbd5e1
  static const Color muted = DashColors.textMuted; // #94a3b8
  static const Color faint = DashColors.text3; // #475569
  static const Color ringBg = DashColors.card; // #1a2235
  static const Color warningText = DashColors.warningText; // #fdba74
  static const Color successText = DashColors.successBadgeText; // #86efac
}
