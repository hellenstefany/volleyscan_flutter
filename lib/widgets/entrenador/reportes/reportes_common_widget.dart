import 'package:flutter/material.dart';
import 'reportes_colors.dart';

BoxDecoration repBox(Color c, double r) => BoxDecoration(
  color: c,
  borderRadius: BorderRadius.circular(r),
  border: Border.all(color: RC.border),
);

class RepStepNum extends StatelessWidget {
  final int n;
  final bool active, done;
  const RepStepNum({
    super.key,
    required this.n,
    required this.active,
    required this.done,
  });

  @override
  Widget build(BuildContext context) => Container(
    width: 26,
    height: 26,
    alignment: Alignment.center,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      gradient: active
          ? const LinearGradient(colors: [RC.purple, RC.purple2])
          : null,
      color: active ? null : (done ? RC.green2 : RC.hover),
      border: Border.all(
        color: (active || done) ? Colors.transparent : RC.border,
        width: 1.5,
      ),
      boxShadow: active
          ? [
              BoxShadow(
                color: const Color(0xFF7C3AED).withValues(alpha: 0.4),
                blurRadius: 12,
              ),
            ]
          : null,
    ),
    child: Text(
      '$n',
      style: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w700,
        color: (active || done) ? Colors.white : RC.t3,
      ),
    ),
  );
}

class RepFieldLabel extends StatelessWidget {
  final String text;
  const RepFieldLabel(this.text, {super.key});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Text(
      text.toUpperCase(),
      style: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.8,
        color: RC.t2,
      ),
    ),
  );
}

class RepRadioOpt extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const RepRadioOpt({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    child: Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(
            width: 18,
            height: 18,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: selected ? RC.purple2 : RC.t3,
                width: 2,
              ),
              boxShadow: selected
                  ? [
                      BoxShadow(
                        color: RC.purple2.withValues(alpha: 0.4),
                        blurRadius: 8,
                      ),
                    ]
                  : null,
            ),
            child: selected
                ? Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: RC.purple2,
                    ),
                  )
                : null,
          ),
          const SizedBox(width: 10),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
              color: selected ? RC.t1 : RC.t2,
            ),
          ),
        ],
      ),
    ),
  );
}

class RepCheckOpt extends StatelessWidget {
  final String label;
  final bool value;
  final VoidCallback onTap;
  const RepCheckOpt({
    super.key,
    required this.label,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    child: Padding(
      padding: const EdgeInsets.only(bottom: 9),
      child: Row(
        children: [
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: value ? RC.green2 : Colors.transparent,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: value ? RC.green2 : RC.t3, width: 2),
            ),
            child: value
                ? const Icon(Icons.check, size: 13, color: Colors.white)
                : null,
          ),
          const SizedBox(width: 10),
          Text(
            label,
            style: TextStyle(fontSize: 13, color: value ? RC.t1 : RC.t2),
          ),
        ],
      ),
    ),
  );
}

class RepDateBox extends StatelessWidget {
  final String text;
  final VoidCallback onTap;
  const RepDateBox({super.key, required this.text, required this.onTap});

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(10),
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      decoration: BoxDecoration(
        color: RC.hover,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: RC.border),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 12, color: RC.t1),
            ),
          ),
          const Icon(Icons.calendar_today, size: 13, color: RC.t2),
        ],
      ),
    ),
  );
}

class RepMiniStat extends StatelessWidget {
  final String label;
  final Widget child;
  const RepMiniStat({super.key, required this.label, required this.child});

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    decoration: repBox(RC.card2, 12),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: const TextStyle(
            fontSize: 10.5,
            letterSpacing: 0.5,
            color: RC.t2,
          ),
        ),
        const SizedBox(height: 8),
        child,
      ],
    ),
  );
}

class RepStatsGrid extends StatelessWidget {
  final List<(String, String, Color)> stats;
  const RepStatsGrid({super.key, required this.stats});

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, c) {
      final w = (c.maxWidth - 14) / 2;
      return Wrap(
        spacing: 14,
        runSpacing: 14,
        children: [
          for (final s in stats)
            SizedBox(
              width: w,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: repBox(RC.card, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      s.$1,
                      style: TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: s.$3,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      s.$2,
                      style: const TextStyle(fontSize: 11, color: RC.t2),
                    ),
                  ],
                ),
              ),
            ),
        ],
      );
    },
  );
}

class RepSecButton extends StatelessWidget {
  final IconData? icon;
  final String label;
  final VoidCallback onTap;
  const RepSecButton({
    super.key,
    this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => OutlinedButton(
    onPressed: onTap,
    style: OutlinedButton.styleFrom(
      foregroundColor: RC.t2,
      side: const BorderSide(color: RC.border),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (icon != null) ...[Icon(icon, size: 15), const SizedBox(width: 7)],
        Text(label, style: const TextStyle(fontSize: 13)),
      ],
    ),
  );
}

class RepPriButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final List<Color> colors;
  const RepPriButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
    this.colors = const [RC.purple, RC.purple2],
  });

  @override
  Widget build(BuildContext context) => Material(
    color: Colors.transparent,
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Ink(
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: colors,
          ),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 15, color: Colors.white),
            const SizedBox(width: 7),
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
