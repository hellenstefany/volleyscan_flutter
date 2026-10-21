import 'package:flutter/material.dart';
import '../screens/login_screen.dart';

// ← Pon aquí la ruta EXACTA de tu logo (mayúsculas y extensión incluidas)
const _logoPath = 'assets/images/Logo.VS.jpg';

const _bg = Color(0xFF0A0E1F);
const _cyan = Color(0xFF22D3EE);
const _indigo = Color(0xFF6366F1);
const _links = ['Inicio', 'Tecnología', 'Métricas', 'Planes'];

class TopBar extends StatelessWidget implements PreferredSizeWidget {
  const TopBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(64);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: _bg,
      child: Container(
        height: 64,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: Colors.white.withOpacity(0.07)),
          ),
        ),
        child: const Row(children: [_Brand(), Spacer(), _LoginButton()]),
      ),
    );
  }
}

class _Brand extends StatelessWidget {
  const _Brand();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.asset(
            _logoPath,
            width: 38,
            height: 38,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(
              width: 38,
              height: 38,
              color: _indigo,
              child: const Icon(
                Icons.sports_volleyball,
                color: Colors.white,
                size: 22,
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        const Text(
          'VolleyScan',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 19,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        const SizedBox(width: 6),
        const Text(
          'IA',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 19,
            fontWeight: FontWeight.w700,
            color: _cyan,
          ),
        ),
      ],
    );
  }
}

class _VerPlanesButton extends StatelessWidget {
  const _VerPlanesButton();

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: () {},
      style: OutlinedButton.styleFrom(
        foregroundColor: Colors.white,
        side: BorderSide(color: Colors.white.withOpacity(0.18)),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: const Text(
        'Ver Planes',
        style: TextStyle(fontFamily: 'Poppins', fontSize: 13),
      ),
    );
  }
}

class _LoginButton extends StatelessWidget {
  const _LoginButton();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [_indigo, _cyan]),
        borderRadius: BorderRadius.circular(8),
      ),
      child: ElevatedButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const LoginScreen()),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: const Text(
          'Iniciar sesión',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

class TopBarDrawer extends StatelessWidget {
  const TopBarDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: _bg,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: IconButton(
                  icon: const Icon(Icons.close_rounded, color: Colors.white70),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
              for (final l in _links)
                ListTile(
                  title: Text(
                    l,
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    // TODO: navegar o hacer scroll a "$l"
                  },
                ),
              const Spacer(),
              const _VerPlanesButton(),
              const SizedBox(height: 12),
              const _LoginButton(),
            ],
          ),
        ),
      ),
    );
  }
}
