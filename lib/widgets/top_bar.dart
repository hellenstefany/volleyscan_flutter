import 'package:flutter/material.dart';
import '../theme/vs_colors.dart';

class TopBar extends StatelessWidget implements PreferredSizeWidget {
  /// Se mantiene por compatibilidad con home_screen.dart (ya no se usa).
  final void Function(String id)? onNavigate;
  const TopBar({super.key, this.onNavigate});

  @override
  Size get preferredSize => const Size.fromHeight(72);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
        child: Container(
          height: 52,
          padding: const EdgeInsets.fromLTRB(14, 0, 8, 0),
          decoration: BoxDecoration(
            color: const Color(0xD9060A16),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: VS.line),
            boxShadow: const [
              BoxShadow(
                color: Color(0x4D000000),
                blurRadius: 24,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              // Logo + nombre
              SizedBox(
                width: 30,
                height: 30,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.asset(
                    'assets/images/Logo.VS.jpg',
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const Icon(
                      Icons.sports_volleyball,
                      color: VS.cyan,
                      size: 22,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(text: 'VolleyScan '),
                        TextSpan(
                          text: 'AI',
                          style: TextStyle(color: VS.cyan),
                        ),
                      ],
                    ),
                    style: TextStyle(
                      fontFamily: VS.font,
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // Botón Iniciar sesión (degradado índigo -> cyan)
              Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(999),
                  onTap: () => Navigator.pushNamed(context, '/login'),
                  child: Ink(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(999),
                      gradient: const LinearGradient(
                        colors: [VS.indigo, VS.cyan],
                      ),
                    ),
                    child: const Text(
                      'Iniciar sesión',
                      style: TextStyle(
                        fontFamily: VS.font,
                        color: Colors.white,
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
