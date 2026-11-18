import 'package:flutter/material.dart';

import 'estadisticas_filter_group.dart';
import 'estadisticas_models.dart';
import 'estadisticas_theme.dart';

/// Barra de filtros: deportista, tipo de ejercicio, búsqueda y reset.
class EstadisticasFilters extends StatelessWidget {
  final double width;
  final String deportista;
  final String ejercicio;
  final TextEditingController searchCtrl;
  final ValueChanged<String> onDeportista;
  final ValueChanged<String> onEjercicio;
  final VoidCallback onSearchChanged;
  final VoidCallback onReset;

  const EstadisticasFilters({
    super.key,
    required this.width,
    required this.deportista,
    required this.ejercicio,
    required this.searchCtrl,
    required this.onDeportista,
    required this.onEjercicio,
    required this.onSearchChanged,
    required this.onReset,
  });

  BoxDecoration _fieldDecoration() => BoxDecoration(
    color: EstadisticasTheme.panel2,
    borderRadius: BorderRadius.circular(8),
    border: Border.all(color: EstadisticasTheme.border),
  );

  Widget _dropdown({
    required String value,
    required List<String> items,
    required ValueChanged<String> onChanged,
  }) {
    return Container(
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: _fieldDecoration(),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          dropdownColor: const Color(0xFF1A1E30),
          icon: const Icon(
            Icons.keyboard_arrow_down,
            color: EstadisticasTheme.muted,
            size: 18,
          ),
          style: const TextStyle(color: EstadisticasTheme.text, fontSize: 13),
          items: items
              .map(
                (i) => DropdownMenuItem(
                  value: i,
                  child: Text(i == 'all' ? 'Todos' : i),
                ),
              )
              .toList(),
          onChanged: (v) {
            if (v != null) onChanged(v);
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final fieldW = width < 500 ? width : 200.0;

    return Wrap(
      spacing: 14,
      runSpacing: 14,
      crossAxisAlignment: WrapCrossAlignment.end,
      children: [
        EstadisticasFilterGroup(
          label: 'DEPORTISTA',
          width: fieldW,
          child: _dropdown(
            value: deportista,
            items: ['all', ...estadisticasPlayers.map((p) => p.name)],
            onChanged: onDeportista,
          ),
        ),
        EstadisticasFilterGroup(
          label: 'TIPO DE EJERCICIO',
          width: fieldW,
          child: _dropdown(
            value: ejercicio,
            items: const ['all', 'Saque', 'Recepción', 'Remate', 'Bloqueo'],
            onChanged: onEjercicio,
          ),
        ),
        EstadisticasFilterGroup(
          label: 'BUSCAR',
          width: fieldW,
          child: Container(
            height: 40,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: _fieldDecoration(),
            child: TextField(
              controller: searchCtrl,
              onChanged: (_) => onSearchChanged(),
              style: const TextStyle(
                color: EstadisticasTheme.text,
                fontSize: 13,
              ),
              cursorColor: EstadisticasTheme.accent,
              decoration: const InputDecoration(
                hintText: 'Nombre...',
                hintStyle: TextStyle(
                  color: EstadisticasTheme.muted,
                  fontSize: 13,
                ),
                border: InputBorder.none,
                isCollapsed: true,
                contentPadding: EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ),
        OutlinedButton(
          onPressed: onReset,
          style: OutlinedButton.styleFrom(
            foregroundColor: EstadisticasTheme.muted,
            side: const BorderSide(color: EstadisticasTheme.border),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: const Text('↺ Resetear', style: TextStyle(fontSize: 13)),
        ),
      ],
    );
  }
}
