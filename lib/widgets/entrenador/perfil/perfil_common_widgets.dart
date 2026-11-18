import 'package:flutter/material.dart';
import '../../../theme/entrenador_colors.dart';

BoxDecoration perfilCardDeco() => BoxDecoration(
  color: EC.bgCard,
  borderRadius: BorderRadius.circular(16),
  border: Border.all(color: EC.border),
);

InputDecoration perfilInputDeco({String? hint, String? error}) =>
    InputDecoration(
      isDense: true,
      filled: true,
      fillColor: EC.bgCard2,
      hintText: hint,
      hintStyle: const TextStyle(color: EC.text3),
      errorText: error,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: EC.border2),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: EC.border2),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: EC.accent),
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
      color: EC.bgHover,
      borderRadius: BorderRadius.circular(20),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: EC.accent2),
        const SizedBox(width: 6),
        Text(text, style: const TextStyle(fontSize: 12, color: EC.text2)),
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
      border: Border(bottom: BorderSide(color: EC.border)),
    ),
    child: Row(
      children: [
        Icon(icon, size: 18, color: EC.accent2),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: EC.text1,
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
            color: EC.text3,
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
  const PerfilValueText(this.text, {super.key});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 10),
    child: Text(text, style: const TextStyle(fontSize: 14, color: EC.text1)),
  );
}

class PerfilGradientButton extends StatelessWidget {
  final IconData? icon;
  final String label;
  final VoidCallback onTap;
  const PerfilGradientButton({
    super.key,
    this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => Material(
    color: Colors.transparent,
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Ink(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [EC.accent, EC.purple],
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
              label,
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
  );
}
