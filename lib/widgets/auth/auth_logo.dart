import 'package:flutter/material.dart';

class AuthLogo extends StatelessWidget {
  const AuthLogo({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Image.asset(
            'assets/images/Logo.VS.jpg',
            width: 40,
            height: 40,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => const Icon(
              Icons.sports_volleyball,
              size: 28,
              color: Color(0xFF22D3EE),
            ),
          ),
        ),
        const SizedBox(width: 10),
        const Text(
          'VolleyScan',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      ],
    );
  }
}
