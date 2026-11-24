import 'package:flutter/material.dart';
import '../../../theme/dash_colors.dart';

BoxDecoration rtBox(Color c, double r) => BoxDecoration(
      color: c,
      borderRadius: BorderRadius.circular(r),
      border: Border.all(color: DashColors.border),
    );

InputDecoration rtInputDeco(String hint) => InputDecoration(
      isDense: true,
      filled: true,
      fillColor: DashColors.card2,
      hintText: hint,
      hintStyle: const TextStyle(color: DashColors.textMuted, fontSize: 13),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(9),
        borderSide: const BorderSide(color: DashColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(9),
        borderSide: const BorderSide(color: DashColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(9),
        borderSide: const BorderSide(color: DashColors.coachPurple),
      ),
    );

class RtCardTitle extends StatelessWidget {
  final String icon;
  final String title;

  const RtCardTitle({super.key, required this.icon, required this.title});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Row(
          children: [
            if (icon.isNotEmpty) ...[
              Text(icon, style: const TextStyle(fontSize: 18)),
              const SizedBox(width: 8),
            ],
            Flexible(
              child: Text(
                title.toUpperCase(),
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.5,
                  color: DashColors.text,
                ),
              ),
            ),
          ],
        ),
      );
}

class RtLabel extends StatelessWidget {
  final String text;
  const RtLabel(this.text, {super.key});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 5),
        child: Text(
          text.toUpperCase(),
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            letterSpacing: 1,
            color: DashColors.textMuted,
          ),
        ),
      );
}

class RtTimeBox extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final int max;

  const RtTimeBox({
    super.key,
    required this.label,
    required this.controller,
    required this.max,
  });

  @override
  Widget build(BuildContext context) => Column(
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              letterSpacing: 1,
              color: DashColors.textMuted,
            ),
          ),
          const SizedBox(height: 4),
          SizedBox(
            width: 60,
            child: TextField(
              controller: controller,
              textAlign: TextAlign.center,
              keyboardType: TextInputType.number,
              maxLength: 2,
              style: const TextStyle(
                color: DashColors.text,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              decoration: rtInputDeco('').copyWith(
                counterText: '',
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 4,
                  vertical: 8,
                ),
              ),
              onChanged: (v) {
                final n = int.tryParse(v);
                if (n != null && n > max) controller.text = '$max';
              },
            ),
          ),
        ],
      );
}

class RtPill extends StatelessWidget {
  final String text;
  final bool selected;
  final VoidCallback onTap;

  const RtPill({
    super.key,
    required this.text,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: selected
                ? DashColors.coachPurple.withValues(alpha: 0.2)
                : DashColors.card2,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: selected ? DashColors.coachPurple : DashColors.border,
            ),
          ),
          child: Text(
            text,
            style: TextStyle(
              fontSize: 12,
              color: selected ? DashColors.text : DashColors.textMuted,
            ),
          ),
        ),
      );
}

class RtMiniTag extends StatelessWidget {
  final String text;
  final Color? color;
  final bool big;
  final bool done;

  const RtMiniTag(
    this.text, {
    super.key,
    this.color,
    this.big = false,
    this.done = false,
  });

  @override
  Widget build(BuildContext context) {
    final bg = done
        ? DashColors.greenTeal.withValues(alpha: 0.12)
        : Colors.white.withValues(alpha: 0.06);
    final fg = color ?? (done ? DashColors.greenTeal : DashColors.textMuted);
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: big ? 9 : 7,
        vertical: big ? 3 : 2,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        text,
        style: TextStyle(fontSize: big ? 11 : 10, color: fg),
      ),
    );
  }
}

class RtActBtn extends StatelessWidget {
  final String icon;
  final Color color;
  final VoidCallback onTap;
  final bool disabled;
  final String? tooltip;

  const RtActBtn(
    this.icon,
    this.color,
    this.onTap, {
    super.key,
    this.disabled = false,
    this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    final btn = Opacity(
      opacity: disabled ? 0.35 : 1.0,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: DashColors.border),
          ),
          alignment: Alignment.center,
          child: Text(icon, style: TextStyle(fontSize: 14, color: color)),
        ),
      ),
    );
    if (tooltip == null) return btn;
    return Tooltip(message: tooltip!, child: btn);
  }
}
