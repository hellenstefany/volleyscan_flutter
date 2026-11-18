import 'package:flutter/material.dart';
import 'gestion_athlete.dart';
import 'gestion_colors.dart';
import 'gestion_common_widgets.dart';

class AthletesToolbar extends StatelessWidget {
  final bool narrow;
  final String cat, estado;
  final ValueChanged<String> onSearch, onCat, onEstado;
  final VoidCallback onAdd;
  const AthletesToolbar({
    super.key,
    required this.narrow,
    required this.cat,
    required this.estado,
    required this.onSearch,
    required this.onCat,
    required this.onEstado,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    final search = TextField(
      onChanged: onSearch,
      style: const TextStyle(color: GC.t1, fontSize: 13),
      decoration: InputDecoration(
        isDense: true,
        filled: true,
        fillColor: GC.hover,
        hintText: 'Buscar deportista...',
        hintStyle: const TextStyle(color: GC.t3, fontSize: 13),
        prefixIcon: const Icon(Icons.search, size: 16, color: GC.t3),
        contentPadding: const EdgeInsets.symmetric(vertical: 12),
        border: outline(GC.border),
        enabledBorder: outline(GC.border),
        focusedBorder: outline(GC.accent),
      ),
    );

    final fCat = FilterSelect(
      hint: 'Categoría',
      value: cat,
      items: categorias,
      onChanged: onCat,
    );
    final fEstado = FilterSelect(
      hint: 'Estado',
      value: estado,
      items: estados,
      onChanged: onEstado,
    );

    final add = GradientButton(
      label: 'Agregar deportista',
      icon: Icons.add,
      colors: const [GC.purple, GC.purple2],
      radius: 10,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
      onTap: onAdd,
    );

    return Padding(
      padding: EdgeInsets.fromLTRB(
        narrow ? 12 : 18,
        narrow ? 14 : 18,
        narrow ? 12 : 18,
        narrow ? 12 : 14,
      ),
      child: narrow
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                search,
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(child: fCat),
                    const SizedBox(width: 8),
                    Expanded(child: fEstado),
                  ],
                ),
                const SizedBox(height: 8),
                add,
              ],
            )
          : Row(
              children: [
                Expanded(child: search),
                const SizedBox(width: 10),
                SizedBox(width: 130, child: fCat),
                const SizedBox(width: 10),
                SizedBox(width: 120, child: fEstado),
                const SizedBox(width: 10),
                add,
              ],
            ),
    );
  }
}
