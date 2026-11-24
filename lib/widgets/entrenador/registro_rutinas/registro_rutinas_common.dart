import 'package:flutter/material.dart';
import '../../../models/registro_rutina_data.dart';
import '../../../services/api_service.dart';
import '../../../theme/app_theme.dart';
import '../../../theme/dash_colors.dart';

const _mesesCortos = <String>[
  'ene', 'feb', 'mar', 'abr', 'may', 'jun',
  'jul', 'ago', 'sep', 'oct', 'nov', 'dic',
];

String regIsoDate(DateTime d) =>
    '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

String regFormatFechaHora(String? iso) {
  if (iso == null || iso.trim().isEmpty) return '—';
  final d = DateTime.tryParse(iso.trim())?.toLocal();
  if (d == null) return '—';
  final mes = _mesesCortos[d.month - 1];
  final h12 = d.hour % 12 == 0 ? 12 : d.hour % 12;
  final mm = d.minute.toString().padLeft(2, '0');
  final ampm = d.hour < 12 ? 'a. m.' : 'p. m.';
  return '${d.day} $mes, $h12:$mm $ampm';
}

String regFormatFecha(String? iso) {
  if (iso == null || iso.trim().isEmpty) return '—';
  final d = DateTime.tryParse(iso.trim())?.toLocal();
  if (d == null) return '—';
  return '${d.day} ${_mesesCortos[d.month - 1]} ${d.year}';
}

String regDec(double n) => n.toStringAsFixed(1).replaceAll('.', ',');

Color regNivelColor(String? nivel) {
  switch ((nivel ?? '').trim().toLowerCase()) {
    case 'principiante':
      return DashColors.accent2;
    case 'intermedio':
      return DashColors.teal;
    case 'avanzado':
      return DashColors.green;
    case 'profesional':
      return DashColors.orange;
    case 'todos':
      return DashColors.blueLight;
    default:
      return DashColors.textMuted;
  }
}

/// Avatar circular del deportista (foto o iniciales sobre gradiente).
class RegAvatar extends StatelessWidget {
  final String? fotoUrl;
  final String iniciales;
  final double size;

  const RegAvatar({
    super.key,
    this.fotoUrl,
    required this.iniciales,
    this.size = 44,
  });

  @override
  Widget build(BuildContext context) {
    final resolved = ApiService.resolveMediaUrl(fotoUrl);
    if (resolved != null) {
      return ClipOval(
        child: Image.network(
          resolved,
          width: size,
          height: size,
          fit: BoxFit.cover,
          errorBuilder: (_, _, _) => _fallback(),
        ),
      );
    }
    return _fallback();
  }

  Widget _fallback() => Container(
        width: size,
        height: size,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          gradient: AppGradients.coachPrimaryBtn,
        ),
        alignment: Alignment.center,
        child: Text(
          iniciales,
          style: TextStyle(
            color: Colors.white,
            fontSize: size * 0.34,
            fontWeight: FontWeight.w700,
          ),
        ),
      );
}

/// Chip con borde de color según el nivel del deportista o rutina.
class RegChipNivel extends StatelessWidget {
  final String nivel;

  const RegChipNivel({super.key, required this.nivel});

  @override
  Widget build(BuildContext context) {
    final col = regNivelColor(nivel);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 2),
      decoration: BoxDecoration(
        color: col.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(99),
        border: Border.all(color: col),
      ),
      child: Text(
        nombreNivelRegistro(nivel).toUpperCase(),
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.8,
          color: col,
        ),
      ),
    );
  }
}

/// Chip informativo reutilizable.
class RegChip extends StatelessWidget {
  final String text;
  final Color? bg;
  final Color? fg;
  final Color? border;

  const RegChip(
    this.text, {
    super.key,
    this.bg,
    this.fg,
    this.border,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: bg ?? DashColors.textMuted.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(99),
        border: border != null ? Border.all(color: border!) : null,
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 11.5,
          fontWeight: FontWeight.w600,
          color: fg ?? DashColors.textSecondary,
        ),
      ),
    );
  }
}

/// Fila de 5 estrellas (solo lectura o interactiva).
class RegEstrellas extends StatelessWidget {
  final int valor;
  final ValueChanged<int>? onCambiar;
  final double size;

  const RegEstrellas({
    super.key,
    required this.valor,
    this.onCambiar,
    this.size = 16,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var n = 1; n <= 5; n++)
          onCambiar != null
              ? IconButton(
                  onPressed: () => onCambiar!(n),
                  padding: const EdgeInsets.symmetric(horizontal: 3),
                  constraints: const BoxConstraints(),
                  icon: Icon(
                    n <= valor ? Icons.star_rounded : Icons.star_border_rounded,
                    size: size,
                    color: n <= valor ? DashColors.amber : DashColors.text3,
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.only(right: 2),
                  child: Icon(
                    n <= valor ? Icons.star_rounded : Icons.star_border_rounded,
                    size: size,
                    color: n <= valor ? DashColors.amber : DashColors.text3,
                  ),
                ),
      ],
    );
  }
}
