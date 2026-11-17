import 'package:flutter/material.dart';

/// Pantalla temporal para secciones que aún no están construidas
/// (Equipos, Partidos, Registro de rutinas). Reemplázala por la real
/// cuando exista.
class PantallaPendiente extends StatelessWidget {
  final String titulo;
  const PantallaPendiente({super.key, required this.titulo});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF0F1425),
      alignment: Alignment.center,
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.construction_rounded,
            size: 40,
            color: Color(0xFF8892B0),
          ),
          const SizedBox(height: 12),
          Text(
            titulo,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: Color(0xFFE8EAF6),
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Próximamente',
            style: TextStyle(fontSize: 13, color: Color(0xFF8892B0)),
          ),
        ],
      ),
    );
  }
}
