import 'package:flutter/material.dart';
import '../theme/vs_colors.dart';

class FooterSection extends StatelessWidget {
  const FooterSection({super.key});

  Widget _social(IconData i) => Container(
    width: 36,
    height: 36,
    margin: const EdgeInsets.only(right: 10),
    decoration: BoxDecoration(
      color: const Color(0x05FFFFFF),
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: VS.line),
    ),
    child: Icon(i, color: VS.muted, size: 16),
  );

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 28),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: VS.line)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'VolleyScan AI',
            style: TextStyle(
              fontFamily: VS.font,
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Plataforma de análisis deportivo con inteligencia artificial.',
            style: TextStyle(
              fontFamily: VS.font,
              color: VS.faint,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              _social(Icons.mail_outline),
              _social(Icons.camera_alt_outlined),
              _social(Icons.facebook_outlined),
            ],
          ),
        ],
      ),
    );
  }
}
