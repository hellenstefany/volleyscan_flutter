import 'package:flutter/material.dart';
import '../theme/vs_colors.dart';

class SectionHead extends StatelessWidget {
  final String title;
  final String subtitle;
  const SectionHead({super.key, required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontFamily: VS.font,
            color: Colors.white,
            fontSize: 28,
            height: 1.15,
            letterSpacing: -0.5,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          subtitle,
          style: const TextStyle(
            fontFamily: VS.font,
            color: VS.muted,
            fontSize: 15,
            height: 1.6,
          ),
        ),
        const SizedBox(height: 28),
      ],
    );
  }
}
