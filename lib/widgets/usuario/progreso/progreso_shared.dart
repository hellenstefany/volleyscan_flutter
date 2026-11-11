import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';
import '../../../theme/dash_colors.dart';
import '../dash_card.dart';

/// Cabecera interna de las tarjetas de "Tu progreso" (`.ct` en `mi-progreso.module.css`).
class ProgresoCardHeader extends StatelessWidget {
  final String title;
  final String? tag;

  const ProgresoCardHeader({
    super.key,
    required this.title,
    this.tag,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: DashColors.text1,
            ),
          ),
        ),
        if (tag != null && tag!.isNotEmpty)
          Text(
            tag!,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 11.5,
              color: DashColors.textMuted,
            ),
          ),
      ],
    );
  }
}

/// Estado vacío de una tarjeta (`.empty` en `mi-progreso.module.css`).
class ProgresoEmptyBox extends StatelessWidget {
  final String title;
  final String subtitle;
  final String? actionLabel;
  final IconData? actionIcon;
  final VoidCallback? onAction;

  const ProgresoEmptyBox({
    super.key,
    required this.title,
    required this.subtitle,
    this.actionLabel,
    this.actionIcon,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadii.btn),
        border: Border.all(color: DashColors.border2),
        color: Colors.white.withValues(alpha: 0.015),
      ),
      child: Column(
        children: [
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 13.5,
              fontWeight: FontWeight.w700,
              color: DashColors.text1,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 12.5,
              height: 1.45,
              color: DashColors.textSecondary,
            ),
          ),
          if (actionLabel != null && onAction != null) ...[
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: onAction,
              icon: Icon(
                actionIcon ?? Icons.arrow_forward_rounded,
                size: 16,
              ),
              label: Text(actionLabel!),
              style: ElevatedButton.styleFrom(
                backgroundColor: DashColors.blueLight,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 9,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadii.sm),
                ),
                textStyle: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Banner de error con botón "Reintentar" (`.err` + `.retry` en `mi-progreso.module.css`).
class DashboardErrorBanner extends StatelessWidget {
  final String message;
  final String? detail;
  final VoidCallback onRetry;

  const DashboardErrorBanner({
    super.key,
    required this.message,
    this.detail,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: AppSpacing.dashCardPadding,
      decoration: BoxDecoration(
        color: DashColors.red.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(AppRadii.panel),
        border: Border.all(color: DashColors.red.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.error_outline_rounded,
            color: DashColors.errorText,
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  message,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: DashColors.errorText,
                  ),
                ),
                if (detail != null &&
                    detail!.trim().isNotEmpty &&
                    detail!.trim() != message)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(
                      detail!,
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 11.5,
                        color: DashColors.textSecondary,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          TextButton(
            onPressed: onRetry,
            child: const Text(
              'Reintentar',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
                color: DashColors.infoBadgeText,
                decoration: TextDecoration.underline,
                decorationColor: DashColors.infoBadgeText,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Tarjeta de carga reutilizando `DashCard`.
class DashboardSkeletonCard extends StatelessWidget {
  final double height;

  const DashboardSkeletonCard({super.key, required this.height});

  @override
  Widget build(BuildContext context) {
    return DashCard(
      padding: AppSpacing.dashCardPadding,
      borderRadius: AppRadii.panel,
      child: SizedBox(
        height: height - 34,
        child: Center(
          child: SizedBox(
            width: 22,
            height: 22,
            child: CircularProgressIndicator(
              strokeWidth: 2.2,
              color: DashColors.blueLight.withValues(alpha: 0.7),
            ),
          ),
        ),
      ),
    );
  }
}

/// Equivalente a `haceCuanto(iso)` en `VolleyScan_Next/src/lib/formato.js`.
String formatHaceCuanto(String? rawIso) {
  if (rawIso == null) return '';
  final str = rawIso.trim();
  if (str.isEmpty) return '';
  final dt = DateTime.tryParse(str);
  if (dt == null) return '';
  final diffMin = DateTime.now().difference(dt.toLocal()).inMinutes;
  if (diffMin < 1) return 'Hace un momento';
  if (diffMin < 60) return 'Hace $diffMin min';
  final h = diffMin ~/ 60;
  if (h < 24) return 'Hace $h ${h == 1 ? 'hora' : 'horas'}';
  final d = h ~/ 24;
  return 'Hace $d ${d == 1 ? 'día' : 'días'}';
}

/// Extrae el día del mes (`1`..`31`) de una fecha ISO (`YYYY-MM-DD`).
String extractDayOfMonth(String isoDate) {
  final parts = isoDate.split('-');
  if (parts.length >= 3) {
    final d = int.tryParse(parts[2].substring(0, 2));
    if (d != null) return '$d';
  }
  return '';
}

/// Formato numérico `d/m` como `numerica(iso)` en `MiProgreso.jsx`.
String formatFechaNumerica(String isoDate) {
  final parts = isoDate.split('-');
  if (parts.length >= 3) {
    final m = int.tryParse(parts[1]);
    final d = int.tryParse(parts[2].substring(0, 2));
    if (d != null && m != null) return '$d/$m';
  }
  return isoDate;
}

/// Formato corto `d mes` como `corta(iso)` en `MiProgreso.jsx`.
String formatFechaCorta(String? rawIso) {
  if (rawIso == null || rawIso.trim().isEmpty) return '';
  const meses = [
    'ene',
    'feb',
    'mar',
    'abr',
    'may',
    'jun',
    'jul',
    'ago',
    'sep',
    'oct',
    'nov',
    'dic',
  ];
  final dt = DateTime.tryParse(rawIso.trim());
  if (dt != null) {
    final local = dt.toLocal();
    return '${local.day} ${meses[local.month - 1]}';
  }
  final parts = rawIso.split('-');
  if (parts.length >= 3) {
    final m = int.tryParse(parts[1]);
    final d = int.tryParse(parts[2].substring(0, 2));
    if (d != null && m != null && m >= 1 && m <= 12) {
      return '$d ${meses[m - 1]}';
    }
  }
  return rawIso;
}
