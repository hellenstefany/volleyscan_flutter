import 'package:flutter/material.dart';

import '../../../theme/dash_colors.dart';

/// Tokens de estilo del Dashboard del entrenador mapeados a `DashColors`
/// (sin definir colores nuevos).
abstract final class DashboardTheme {
  static const Color bgSecondary = DashColors.bg;
  static const Color bgCard = DashColors.surface;
  static const Color bgCardHover = DashColors.sidebarItemHover;
  static const Color blue = DashColors.sidebarLogoBlue;
  static const Color purple = DashColors.sidebarActiveBorder;
  static const Color teal = DashColors.teal;
  static const Color gold = DashColors.amber;
  static const Color green = DashColors.green;
  static const Color red = DashColors.red;
  static const Color textPrimary = DashColors.text1;
  static const Color textSecondary = DashColors.textMuted;
  static const Color textMuted = DashColors.text3;
  static const Color border = DashColors.border;
  static const Color border2 = DashColors.border2;
}
