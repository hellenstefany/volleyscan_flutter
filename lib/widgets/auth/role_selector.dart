import 'package:flutter/material.dart';

enum UserRole { entrenador, usuario }

class RoleSelector extends StatelessWidget {
  final UserRole value;
  final ValueChanged<UserRole> onChanged;

  const RoleSelector({super.key, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _RoleCard(
            label: 'Entrenador',
            icon: Icons.how_to_reg_rounded,
            selected: value == UserRole.entrenador,
            onTap: () => onChanged(UserRole.entrenador),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _RoleCard(
            label: 'Usuario',
            icon: Icons.person_rounded,
            selected: value == UserRole.usuario,
            onTap: () => onChanged(UserRole.usuario),
          ),
        ),
      ],
    );
  }
}

class _RoleCard extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _RoleCard({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const cyan = Color(0xFF22D3EE);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        height: 48,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF12274A) : const Color(0xFF151B33),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: selected ? cyan : Colors.white.withOpacity(0.10),
            width: selected ? 1.4 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: selected ? cyan : Colors.white38,
                  width: 1.6,
                ),
              ),
              child: selected
                  ? Center(
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: cyan,
                          shape: BoxShape.circle,
                        ),
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 8),
            Icon(icon, size: 16, color: Colors.white),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                label,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
