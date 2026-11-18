import 'package:flutter/material.dart';

/// Paleta y gradientes exactos de `VolleyScan_Next/src/app/panel_entrenador/analisis/Analisis.css` (`.ai-panel`).
abstract final class AnalisisTheme {
  // ── Variables CSS de `.ai-panel` ──
  static const bg = Color(0xFF15181E); // --ai-bg: #15181e
  static const surface = Color(0xFF1E232B); // --ai-surface: #1e232b
  static const surface2 = Color(0xFF262C35); // --ai-surface-2: #262c35
  static const line = Color(0xFF2B313B); // --ai-line: #2b313b
  static const lineStrong = Color(0xFF3A414D); // --ai-line-strong: #3a414d
  static const text = Color(0xFFEEF2F6); // --ai-text: #eef2f6
  static const text2 = Color(0xFFAAB3C0); // --ai-text-2: #aab3c0
  static const text3 = Color(0xFF7A8494); // --ai-text-3: #7a8494
  static const accent = Color(0xFF2DD4BF); // --ai-accent: #2dd4bf
  static const accent2 = Color(0xFF38BDF8); // --ai-accent-2: #38bdf8

  // ── Colores específicos de componentes en `Analisis.css` ──
  static const spark = Color(0xFF7DD3FC); // .ai-composer-spark: #7dd3fc
  static const cardIconFg = Color(0xFF99F6E4); // .ai-card-icon: #99f6e4
  static const sendBg = Color(0xFFFFFFFF); // .ai-composer-send: #ffffff
  static const sendFg = Color(0xFF14171C); // .ai-composer-send color: #14171c
  static const confirmed = Color(0xFF34D399); // .ai-action-btn.is-confirmed: #34d399

  // ── Gradientes ──
  /// `--ai-gradient: linear-gradient(135deg, #0d9488 0%, #0284c7 100%)`
  static const aiGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF0D9488), Color(0xFF0284C7)],
  );

  // ── Radios ──
  static const double radiusBubble = 16.0; // --ai-radius: 16px
  static const double radiusComposer = 14.0; // .ai-composer: 14px
  static const double radiusCard = 12.0; // .ai-card: 12px

  // ── Tipografía ──
  static const mono = TextStyle(fontFamily: 'monospace');
}
