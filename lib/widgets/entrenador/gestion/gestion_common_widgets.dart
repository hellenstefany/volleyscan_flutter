import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../services/api_service.dart';
import '../../../theme/app_theme.dart';
import 'gestion_athlete.dart';
import 'gestion_colors.dart';

Color colorNotaDeportista(int? valor) {
  final n = valor ?? 0;
  if (n >= 80) return GestionColors.green;
  if (n >= 60) return GestionColors.blue;
  return GestionColors.orange;
}

/// Avatar cuadrado con bordes redondeados (`.avatar` / `.avatarIni` en `deportistas.module.css`).
class DeportistaAvatar extends StatelessWidget {
  final EntrenadorDeportista atleta;
  final double size;

  const DeportistaAvatar({
    super.key,
    required this.atleta,
    this.size = 56,
  });

  @override
  Widget build(BuildContext context) {
    final resolved = ApiService.resolveMediaUrl(atleta.fotoUrl);
    final fallback = Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        gradient: AppGradients.coachPrimaryBtn,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Text(
        atleta.iniciales,
        style: TextStyle(
          fontSize: size * 0.36,
          fontWeight: FontWeight.w800,
          color: Colors.white,
        ),
      ),
    );

    if (resolved == null) return fallback;

    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: Image.network(
        resolved,
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => fallback,
      ),
    );
  }
}

/// Anillo circular de puntaje (`.anillo` en `deportistas.module.css` y `HistorialIA.jsx`).
class DeportistaScoreRing extends StatelessWidget {
  final int? valor;
  final double size;
  final double strokeWidth;
  final bool sinDato;

  const DeportistaScoreRing({
    super.key,
    required this.valor,
    this.size = 48,
    this.strokeWidth = 5,
    this.sinDato = false,
  });

  @override
  Widget build(BuildContext context) {
    final noData = sinDato || valor == null;
    final score = valor ?? 0;

    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _RingPainter(
          valor: score,
          strokeWidth: strokeWidth,
          sinDato: noData,
          color: colorNotaDeportista(score),
        ),
        child: Center(
          child: Text(
            noData ? '—' : '$score',
            style: TextStyle(
              fontSize: size * 0.30,
              fontWeight: FontWeight.w800,
              color: noData ? GestionColors.faint : GestionColors.text,
            ),
          ),
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  final int valor;
  final double strokeWidth;
  final bool sinDato;
  final Color color;

  const _RingPainter({
    required this.valor,
    required this.strokeWidth,
    required this.sinDato,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    final trackPaint = Paint()
      ..color = GestionColors.ringBg
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;
    canvas.drawCircle(center, radius, trackPaint);

    if (!sinDato) {
      final pct = (valor.clamp(0, 100)) / 100.0;
      final fgPaint = Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -math.pi / 2,
        2 * math.pi * pct,
        false,
        fgPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _RingPainter old) =>
      old.valor != valor || old.sinDato != sinDato || old.color != color;
}

/// Chips de posición y nivel (`<Chips a={a} />` en `page.jsx`).
class DeportistaChips extends StatelessWidget {
  final EntrenadorDeportista atleta;

  const DeportistaChips({super.key, required this.atleta});

  @override
  Widget build(BuildContext context) {
    final pos = atleta.posicion;
    final niv = atleta.nivel;
    if ((pos == null || pos.isEmpty) && (niv == null || niv.isEmpty)) {
      return const SizedBox.shrink();
    }

    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: [
        if (pos != null && pos.isNotEmpty)
          _Chip(
            label: kNombrePosicion[pos] ?? pos,
            bg: GestionColors.blue.withValues(alpha: 0.16),
            fg: GestionColors.blueLight,
          ),
        if (niv != null && niv.isNotEmpty)
          _Chip(
            label: kNombreNivel[niv] ?? niv,
            bg: _nivelBg(niv),
            fg: _nivelFg(niv),
          ),
      ],
    );
  }

  Color _nivelBg(String n) {
    switch (n) {
      case 'intermedio':
        return GestionColors.blue.withValues(alpha: 0.16);
      case 'avanzado':
        return GestionColors.green.withValues(alpha: 0.16);
      case 'profesional':
        return GestionColors.orange.withValues(alpha: 0.18);
      default:
        return GestionColors.muted.withValues(alpha: 0.16);
    }
  }

  Color _nivelFg(String n) {
    switch (n) {
      case 'intermedio':
        return GestionColors.blueLight;
      case 'avanzado':
        return GestionColors.successText;
      case 'profesional':
        return GestionColors.warningText;
      default:
        return GestionColors.text2;
    }
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final Color bg;
  final Color fg;

  const _Chip({required this.label, required this.bg, required this.fg});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(99),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11.8,
          fontWeight: FontWeight.w600,
          color: fg,
        ),
      ),
    );
  }
}

/// Bloque de Edad / Peso / Estatura (`<Perfil a={a} />` en `page.jsx`).
class DeportistaPerfilGrid extends StatelessWidget {
  final EntrenadorDeportista atleta;

  const DeportistaPerfilGrid({super.key, required this.atleta});

  String _fmtNum(double? v, String suffix) {
    if (v == null) return '—';
    final text = (v == v.roundToDouble())
        ? v.toInt().toString()
        : v.toStringAsFixed(2).replaceFirst(RegExp(r'0+$'), '').replaceFirst(RegExp(r'\.$'), '');
    return '$text $suffix';
  }

  @override
  Widget build(BuildContext context) {
    final edadStr = atleta.edad != null ? '${atleta.edad} años' : '—';
    final pesoStr = _fmtNum(atleta.pesoKg, 'kg');
    final estStr = _fmtNum(atleta.estaturaM, 'm');

    return Row(
      children: [
        Expanded(child: _DatoBox(label: 'EDAD', value: edadStr)),
        const SizedBox(width: 8),
        Expanded(child: _DatoBox(label: 'PESO', value: pesoStr)),
        const SizedBox(width: 8),
        Expanded(child: _DatoBox(label: 'ESTATURA', value: estStr)),
      ],
    );
  }
}

class _DatoBox extends StatelessWidget {
  final String label;
  final String value;

  const _DatoBox({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: GestionColors.card2,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: GestionColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              letterSpacing: 0.8,
              color: GestionColors.muted,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 14.5,
              fontWeight: FontWeight.w700,
              color: GestionColors.text,
            ),
          ),
        ],
      ),
    );
  }
}

/// Banner de alerta (`.alertaMal` y `.alertaBien` en `deportistas.module.css`).
class DeportistaAlertBanner extends StatelessWidget {
  final String text;
  final bool isError;

  const DeportistaAlertBanner({
    super.key,
    required this.text,
    this.isError = true,
  });

  @override
  Widget build(BuildContext context) {
    final baseColor = isError ? GestionColors.orange : GestionColors.green;
    final textColor =
        isError ? GestionColors.warningText : GestionColors.successText;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: baseColor.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: baseColor.withValues(alpha: 0.40)),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 13.5,
          color: textColor,
        ),
      ),
    );
  }
}
