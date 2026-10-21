import 'package:flutter/material.dart';
import '../../utils/validators.dart';

class PasswordStrength extends StatelessWidget {
  final String password;
  final String email;

  const PasswordStrength({super.key, required this.password, this.email = ''});

  static const _colors = [
    Colors.transparent,
    Color(0xFFEF4444),
    Color(0xFFF59E0B),
    Color(0xFFEAB308),
    Color(0xFF22C55E),
  ];
  static const _labels = ['', 'Débil', 'Media', 'Buena', 'Fuerte'];

  @override
  Widget build(BuildContext context) {
    final check = PasswordCheck(password, email: email);
    final level = check.level;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            for (var i = 1; i <= 4; i++)
              Expanded(
                child: Container(
                  height: 4,
                  margin: EdgeInsets.only(right: i == 4 ? 0 : 4),
                  decoration: BoxDecoration(
                    color: i <= level
                        ? _colors[level]
                        : Colors.white.withOpacity(0.10),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            const SizedBox(width: 10),
            Text(
              _labels[level],
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: _colors[level],
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 12,
          runSpacing: 4,
          children: [
            for (final r in check.visibleRules)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    r.passed
                        ? Icons.check_circle_rounded
                        : Icons.circle_outlined,
                    size: 12,
                    color: r.passed ? const Color(0xFF22C55E) : Colors.white38,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    r.label,
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 10.5,
                      color: r.passed ? Colors.white70 : Colors.white38,
                    ),
                  ),
                ],
              ),
          ],
        ),
      ],
    );
  }
}
