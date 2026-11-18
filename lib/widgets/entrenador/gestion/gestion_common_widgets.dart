import 'package:flutter/material.dart';
import 'gestion_athlete.dart';
import 'gestion_colors.dart';

BoxDecoration boxDeco(Color c, double r) => BoxDecoration(
  color: c,
  borderRadius: BorderRadius.circular(r),
  border: Border.all(color: GC.border),
);

OutlineInputBorder outline(Color c, [double r = 10]) => OutlineInputBorder(
  borderRadius: BorderRadius.circular(r),
  borderSide: BorderSide(color: c),
);

class Avatar extends StatelessWidget {
  final int id;
  final String name;
  final double size, font;
  const Avatar({
    super.key,
    required this.id,
    required this.name,
    required this.size,
    required this.font,
  });

  @override
  Widget build(BuildContext context) => Container(
    width: size,
    height: size,
    alignment: Alignment.center,
    decoration: BoxDecoration(shape: BoxShape.circle, color: colorFor(id)),
    child: Text(
      initials(name),
      style: TextStyle(
        fontSize: font,
        fontWeight: FontWeight.w700,
        color: Colors.white,
      ),
    ),
  );
}

class ActionBtn extends StatelessWidget {
  final IconData icon;
  final Color bg, fg;
  final VoidCallback onTap;
  const ActionBtn({
    super.key,
    required this.icon,
    required this.bg,
    required this.fg,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(8),
    child: Container(
      width: 30,
      height: 30,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(icon, size: 15, color: fg),
    ),
  );
}

class StatLine extends StatelessWidget {
  final String k, v;
  final bool last;
  const StatLine(this.k, this.v, {super.key, this.last = false});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(vertical: 9),
    decoration: BoxDecoration(
      border: last ? null : const Border(bottom: BorderSide(color: GC.border)),
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(k, style: const TextStyle(fontSize: 12.5, color: GC.t2)),
        Text(
          v,
          style: const TextStyle(
            fontFamily: 'monospace',
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: GC.t1,
          ),
        ),
      ],
    ),
  );
}

class GhostButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const GhostButton({super.key, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) => OutlinedButton(
    onPressed: onTap,
    style: OutlinedButton.styleFrom(
      foregroundColor: GC.t2,
      side: const BorderSide(color: GC.border),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9)),
    ),
    child: Text(label, style: const TextStyle(fontSize: 13)),
  );
}

/// Botón con degradado (reemplaza los 3 botones repetidos).
class GradientButton extends StatelessWidget {
  final String label;
  final IconData? icon;
  final List<Color> colors;
  final double radius;
  final EdgeInsets padding;
  final VoidCallback onTap;
  const GradientButton({
    super.key,
    required this.label,
    required this.onTap,
    this.icon,
    this.colors = const [GC.accent, GC.indigo],
    this.radius = 9,
    this.padding = const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
  });

  @override
  Widget build(BuildContext context) => Material(
    color: Colors.transparent,
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(radius),
      child: Ink(
        padding: padding,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: colors,
          ),
          borderRadius: BorderRadius.circular(radius),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 15, color: Colors.white),
              const SizedBox(width: 7),
            ],
            Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

/// Select de filtro: '' = sin filtro (muestra el hint).
class FilterSelect extends StatelessWidget {
  final String hint, value;
  final List<String> items;
  final ValueChanged<String> onChanged;
  const FilterSelect({
    super.key,
    required this.hint,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12),
    decoration: BoxDecoration(
      color: GC.hover,
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: GC.border),
    ),
    child: DropdownButtonHideUnderline(
      child: DropdownButton<String>(
        value: value,
        isExpanded: true,
        dropdownColor: GC.hover,
        style: const TextStyle(color: GC.t2, fontSize: 13),
        icon: const Icon(Icons.arrow_drop_down, color: GC.t2),
        items: [
          DropdownMenuItem(value: '', child: Text(hint)),
          for (final i in items) DropdownMenuItem(value: i, child: Text(i)),
        ],
        onChanged: (v) => onChanged(v ?? ''),
      ),
    ),
  );
}
