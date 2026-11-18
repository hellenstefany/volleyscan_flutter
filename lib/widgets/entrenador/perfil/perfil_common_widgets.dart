import 'package:flutter/material.dart';

import '../../../theme/app_theme.dart';
import '../../../theme/dash_colors.dart';

BoxDecoration perfilCardDeco() => BoxDecoration(
  color: DashColors.cardDark,
  borderRadius: BorderRadius.circular(AppRadii.panel),
  border: Border.all(color: DashColors.border),
);

InputDecoration perfilInputDeco({String? hint, String? error}) =>
    InputDecoration(
      isDense: true,
      filled: true,
      fillColor: DashColors.card2,
      hintText: hint,
      hintStyle: const TextStyle(color: DashColors.text3, fontSize: 13.5),
      errorText: error,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: DashColors.border2),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: DashColors.border2),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: DashColors.blueLight),
      ),
    );

class PerfilTag extends StatelessWidget {
  final IconData icon;
  final String text;
  const PerfilTag(this.icon, this.text, {super.key});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
    decoration: BoxDecoration(
      color: DashColors.hover,
      borderRadius: BorderRadius.circular(20),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: DashColors.accent2),
        const SizedBox(width: 6),
        Text(
          text,
          style: const TextStyle(fontSize: 12, color: DashColors.textMuted),
        ),
      ],
    ),
  );
}

class PerfilCardHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  final Widget? trailing;
  const PerfilCardHeader({
    super.key,
    required this.icon,
    required this.title,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: 24),
    padding: const EdgeInsets.only(bottom: 12),
    decoration: const BoxDecoration(
      border: Border(bottom: BorderSide(color: DashColors.border)),
    ),
    child: Row(
      children: [
        Icon(icon, size: 18, color: DashColors.accent2),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: DashColors.text1,
            ),
          ),
        ),
        if (trailing != null) trailing!,
      ],
    ),
  );
}

class PerfilFormGroup extends StatelessWidget {
  final String label;
  final Widget child;
  const PerfilFormGroup({super.key, required this.label, required this.child});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 18),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.6,
            color: DashColors.text3,
          ),
        ),
        const SizedBox(height: 6),
        child,
      ],
    ),
  );
}

class PerfilValueText extends StatelessWidget {
  final String text;
  final Color? color;
  const PerfilValueText(this.text, {super.key, this.color});

  @override
  Widget build(BuildContext context) {
    final display = text.trim().isNotEmpty ? text : '—';
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Text(
        display,
        style: TextStyle(fontSize: 14, color: color ?? DashColors.text1),
      ),
    );
  }
}

class PerfilGradientButton extends StatelessWidget {
  final IconData? icon;
  final String label;
  final VoidCallback? onTap;
  final bool loading;

  const PerfilGradientButton({
    super.key,
    this.icon,
    required this.label,
    required this.onTap,
    this.loading = false,
  });

  @override
  Widget build(BuildContext context) => Opacity(
    opacity: (onTap == null || loading) ? 0.7 : 1,
    child: Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: loading ? null : onTap,
        borderRadius: BorderRadius.circular(8),
        child: Ink(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [DashColors.blueLight, DashColors.sidebarActiveBorder],
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 16, color: Colors.white),
                const SizedBox(width: 8),
              ],
              Text(
                loading ? 'Guardando…' : label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
