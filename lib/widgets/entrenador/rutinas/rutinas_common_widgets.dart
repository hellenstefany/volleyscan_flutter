import 'package:flutter/material.dart';
import 'rutinas_colors.dart';

BoxDecoration rtBox(Color c, double r) => BoxDecoration(
  color: c,
  borderRadius: BorderRadius.circular(r),
  border: Border.all(color: RtC.border),
);

InputDecoration rtInputDeco(String hint) => InputDecoration(
  isDense: true,
  filled: true,
  fillColor: RtC.card2,
  hintText: hint,
  hintStyle: const TextStyle(color: RtC.muted, fontSize: 13),
  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
  border: OutlineInputBorder(
    borderRadius: BorderRadius.circular(9),
    borderSide: const BorderSide(color: RtC.border),
  ),
  enabledBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(9),
    borderSide: const BorderSide(color: RtC.border),
  ),
  focusedBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(9),
    borderSide: const BorderSide(color: RtC.accent),
  ),
);

class RtCardTitle extends StatelessWidget {
  final String icon, title;
  const RtCardTitle({super.key, required this.icon, required this.title});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Row(
      children: [
        Text(icon, style: const TextStyle(fontSize: 18)),
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            title.toUpperCase(),
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.5,
              color: RtC.text,
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
        color: RtC.muted,
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
          color: RtC.muted,
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
            color: RtC.text,
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
        color: selected ? RtC.accent.withValues(alpha: 0.2) : RtC.card2,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: selected ? RtC.accent : RtC.border),
      ),
      child: Text(
        text,
        style: TextStyle(fontSize: 12, color: selected ? RtC.text : RtC.muted),
      ),
    ),
  );
}

class RtMiniTag extends StatelessWidget {
  final String text;
  final Color? color;
  final bool big;
  const RtMiniTag(this.text, {super.key, this.color, this.big = false});

  @override
  Widget build(BuildContext context) => Container(
    padding: EdgeInsets.symmetric(
      horizontal: big ? 9 : 7,
      vertical: big ? 3 : 2,
    ),
    decoration: BoxDecoration(
      color: Colors.white.withValues(alpha: big ? 0.05 : 0.06),
      borderRadius: BorderRadius.circular(10),
    ),
    child: Text(
      text,
      style: TextStyle(fontSize: big ? 11 : 10, color: color ?? RtC.muted),
    ),
  );
}

class RtActBtn extends StatelessWidget {
  final String icon;
  final Color color;
  final VoidCallback onTap;
  const RtActBtn(this.icon, this.color, this.onTap, {super.key});

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(8),
    child: Container(
      width: 30,
      height: 30,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: RtC.border),
      ),
      child: Text(icon, style: const TextStyle(fontSize: 14)),
    ),
  );
}
