import 'package:flutter/material.dart';

import '../../../services/api_service.dart';
import '../../../theme/app_theme.dart';
import '../../../theme/dash_colors.dart';

enum EquipoChipTone { azul, verde, naranja, gris }

class EquipoChip extends StatelessWidget {
  final String text;
  final EquipoChipTone tone;

  const EquipoChip({super.key, required this.text, this.tone = EquipoChipTone.gris});

  @override
  Widget build(BuildContext context) {
    final (Color bg, Color fg) = switch (tone) {
      EquipoChipTone.azul => (DashColors.blueLight.withValues(alpha: 0.16), DashColors.accent2),
      EquipoChipTone.verde => (DashColors.green.withValues(alpha: 0.14), DashColors.successBadgeText),
      EquipoChipTone.naranja => (DashColors.orange.withValues(alpha: 0.16), DashColors.warningText),
      EquipoChipTone.gris => (DashColors.textMuted.withValues(alpha: 0.14), DashColors.textSecondary),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(99)),
      child: Text(text, style: TextStyle(fontSize: 11.8, fontWeight: FontWeight.w600, color: fg)),
    );
  }
}

class EquipoPrimButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final bool enabled, mini;

  const EquipoPrimButton({
    super.key,
    required this.label,
    required this.onTap,
    this.enabled = true,
    this.mini = false,
  });

  @override
  Widget build(BuildContext context) {
    final active = enabled && onTap != null;
    final radius = BorderRadius.circular(mini ? 10 : 12);
    return Opacity(
      opacity: active ? 1.0 : 0.5,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: AppGradients.coachPrimaryBtn,
          borderRadius: radius,
          boxShadow: [BoxShadow(color: AppColors.blue.withValues(alpha: 0.35), blurRadius: 18, offset: const Offset(0, 6))],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: radius,
            onTap: active ? onTap : null,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: mini ? 12 : 16, vertical: mini ? 6 : 10),
              child: Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: mini ? 13.4 : 14, fontWeight: FontWeight.w700, color: DashColors.textPrimary),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class EquipoSecButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final bool enabled, mini;

  const EquipoSecButton({super.key, required this.label, required this.onTap, this.enabled = true, this.mini = false});

  @override
  Widget build(BuildContext context) => _OutlinedBtn(
        label: label,
        onTap: onTap,
        enabled: enabled,
        mini: mini,
        bg: DashColors.cardDark,
        border: DashColors.coachBorder,
        fg: DashColors.textSecondary,
      );
}

class EquipoDangerButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final bool enabled, mini;

  const EquipoDangerButton({super.key, required this.label, required this.onTap, this.enabled = true, this.mini = false});

  @override
  Widget build(BuildContext context) => _OutlinedBtn(
        label: label,
        onTap: onTap,
        enabled: enabled,
        mini: mini,
        bg: Colors.transparent,
        border: DashColors.orange.withValues(alpha: 0.5),
        fg: DashColors.warningText,
      );
}

class _OutlinedBtn extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final bool enabled, mini;
  final Color bg, border, fg;

  const _OutlinedBtn({
    required this.label,
    required this.onTap,
    required this.enabled,
    required this.mini,
    required this.bg,
    required this.border,
    required this.fg,
  });

  @override
  Widget build(BuildContext context) {
    final active = enabled && onTap != null;
    final radius = BorderRadius.circular(mini ? 10 : 12);
    return Opacity(
      opacity: active ? 1.0 : 0.5,
      child: Material(
        color: bg,
        borderRadius: radius,
        child: InkWell(
          borderRadius: radius,
          onTap: active ? onTap : null,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: mini ? 12 : 16, vertical: mini ? 6 : 9),
            decoration: BoxDecoration(borderRadius: radius, border: Border.all(color: border)),
            child: Text(label, textAlign: TextAlign.center, style: TextStyle(fontSize: mini ? 13.4 : 14, fontWeight: FontWeight.w600, color: fg)),
          ),
        ),
      ),
    );
  }
}

class EquipoAlertBanner extends StatelessWidget {
  final String text;
  final bool isError;
  final VoidCallback? onRetry;

  const EquipoAlertBanner({super.key, required this.text, this.isError = true, this.onRetry});

  @override
  Widget build(BuildContext context) {
    final c = isError ? DashColors.orange : DashColors.green;
    final fg = isError ? DashColors.warningText : DashColors.successBadgeText;
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: c.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: c.withValues(alpha: isError ? 0.40 : 0.35)),
      ),
      child: Row(
        children: [
          Expanded(child: Text(text, style: TextStyle(fontSize: 13.5, color: fg))),
          if (onRetry != null) ...[
            const SizedBox(width: 12),
            EquipoSecButton(label: 'Reintentar', mini: true, onTap: onRetry),
          ],
        ],
      ),
    );
  }
}

class EquipoAvatar extends StatelessWidget {
  final String? fotoUrl;
  final String iniciales;
  final double size;

  const EquipoAvatar({super.key, required this.fotoUrl, required this.iniciales, this.size = 44});

  @override
  Widget build(BuildContext context) {
    final resolved = ApiService.resolveMediaUrl(fotoUrl);
    final fallback = Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(gradient: AppGradients.coachPrimaryBtn, borderRadius: BorderRadius.circular(14)),
      child: Text(iniciales, style: TextStyle(fontSize: size * 0.36, fontWeight: FontWeight.w800, color: DashColors.textPrimary)),
    );
    if (resolved == null || resolved.isEmpty) return fallback;
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: Image.network(resolved, width: size, height: size, fit: BoxFit.cover, errorBuilder: (_, _, _) => fallback),
    );
  }
}

Future<bool> showEquipoConfirmDialog(
  BuildContext context, {
  required String title,
  required String message,
  String confirmLabel = 'Confirmar',
}) async {
  final res = await showDialog<bool>(
    context: context,
    barrierColor: DashColors.modalOverlay,
    builder: (ctx) => AlertDialog(
      backgroundColor: DashColors.cardDark,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadii.md),
        side: const BorderSide(color: DashColors.coachBorder),
      ),
      title: Text(title, style: const TextStyle(color: DashColors.text1, fontSize: 18, fontWeight: FontWeight.w700)),
      content: Text(message, style: const TextStyle(color: DashColors.textSecondary, fontSize: 14, height: 1.4)),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(false),
          child: const Text('Cancelar', style: TextStyle(color: DashColors.textMuted)),
        ),
        EquipoDangerButton(label: confirmLabel, mini: true, onTap: () => Navigator.of(ctx).pop(true)),
      ],
    ),
  );
  return res == true;
}
