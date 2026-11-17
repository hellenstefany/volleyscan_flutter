import 'package:flutter/material.dart';

import 'config_btn.dart';
import 'config_data.dart';
import 'config_theme.dart';

/// Encabezado de la tabla de miembros.
class ConfigMemberHeader extends StatelessWidget {
  const ConfigMemberHeader({super.key});

  Widget _h(String t, double w) => SizedBox(
    width: w,
    child: Text(
      t.toUpperCase(),
      style: const TextStyle(
        fontSize: 11,
        letterSpacing: 0.8,
        fontWeight: FontWeight.w600,
        color: ConfigTheme.muted,
      ),
    ),
  );

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: ConfigTheme.border)),
      ),
      child: Row(
        children: [
          _h('Miembro', 190),
          _h('Email', 200),
          _h('Rol', 120),
          _h('Acciones', 90),
        ],
      ),
    );
  }
}

/// Fila de un miembro del equipo.
class ConfigMemberRow extends StatelessWidget {
  final ConfigMember member;
  final VoidCallback onEdit;

  const ConfigMemberRow({
    super.key,
    required this.member,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final m = member;
    final initials = m.$1.split(' ').map((p) => p[0]).join();

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: ConfigTheme.border)),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 190,
            child: Row(
              children: [
                Container(
                  width: 30,
                  height: 30,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: m.$4.withValues(alpha: 0.13),
                    shape: BoxShape.circle,
                    border: Border.all(color: m.$4.withValues(alpha: 0.19)),
                  ),
                  child: Text(
                    initials,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: m.$4,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    m.$1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13,
                      color: ConfigTheme.text,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            width: 200,
            child: Text(
              m.$2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 13, color: ConfigTheme.muted),
            ),
          ),
          SizedBox(
            width: 120,
            child: Align(
              alignment: Alignment.centerLeft,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 3,
                ),
                decoration: BoxDecoration(
                  color: m.$4.withValues(alpha: 0.09),
                  borderRadius: BorderRadius.circular(99),
                  border: Border.all(color: m.$4.withValues(alpha: 0.19)),
                ),
                child: Text(
                  m.$3,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: m.$4,
                  ),
                ),
              ),
            ),
          ),
          SizedBox(
            width: 90,
            child: m.$3 != 'Admin'
                ? Align(
                    alignment: Alignment.centerLeft,
                    child: ConfigBtn(
                      label: 'Editar',
                      style: ConfigBtnStyle.ghost,
                      small: true,
                      onTap: onEdit,
                    ),
                  )
                : const Text(
                    '—',
                    style: TextStyle(fontSize: 12, color: ConfigTheme.muted),
                  ),
          ),
        ],
      ),
    );
  }
}
