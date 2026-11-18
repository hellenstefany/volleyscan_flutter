import 'package:flutter/material.dart';
import 'gestion_athlete.dart';
import 'gestion_colors.dart';
import 'gestion_athletes_toolbar.dart';
import 'gestion_common_widgets.dart';

/// Panel completo: toolbar + tabla + estado vacío.
class AthletesPanel extends StatelessWidget {
  final List<Athlete> athletes;
  final int? selectedId;
  final bool narrow;
  final String cat, estado;
  final ValueChanged<String> onSearch, onCat, onEstado;
  final ValueChanged<Athlete> onSelect, onEdit, onDelete;
  final VoidCallback onAdd;

  const AthletesPanel({
    super.key,
    required this.athletes,
    required this.selectedId,
    required this.narrow,
    required this.cat,
    required this.estado,
    required this.onSearch,
    required this.onCat,
    required this.onEstado,
    required this.onSelect,
    required this.onEdit,
    required this.onDelete,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    final pad = narrow ? 12.0 : 18.0;
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: boxDeco(GC.card2, 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AthletesToolbar(
            narrow: narrow,
            cat: cat,
            estado: estado,
            onSearch: onSearch,
            onCat: onCat,
            onEstado: onEstado,
            onAdd: onAdd,
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: pad),
            child: ConstrainedBox(
              constraints: BoxConstraints(minWidth: narrow ? 620 : 560),
              child: _table(),
            ),
          ),
          if (athletes.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 32),
              child: Center(
                child: Text(
                  'No se encontraron deportistas.',
                  style: TextStyle(fontSize: 13, color: GC.t3),
                ),
              ),
            ),
          const SizedBox(height: 18),
        ],
      ),
    );
  }

  Widget _table() {
    const head = TextStyle(
      fontSize: 11.5,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.6,
      color: GC.t2,
    );
    Widget th(String t) => Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Text(t.toUpperCase(), style: head),
    );

    return Table(
      columnWidths: const {
        0: FixedColumnWidth(70),
        1: FlexColumnWidth(2.2),
        2: FixedColumnWidth(60),
        3: FlexColumnWidth(1.3),
        4: FlexColumnWidth(1.4),
        5: FlexColumnWidth(1.3),
        6: FixedColumnWidth(122),
      },
      defaultVerticalAlignment: TableCellVerticalAlignment.middle,
      children: [
        TableRow(
          decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: GC.border)),
          ),
          children: [
            for (final t in [
              'Foto',
              'Nombre',
              'Edad',
              'Categoría',
              'Nivel',
              'Estado',
              'Acciones',
            ])
              th(t),
          ],
        ),
        for (final a in athletes) _row(a),
      ],
    );
  }

  TableRow _row(Athlete a) {
    Widget cell(Widget child) => InkWell(
      onTap: () => onSelect(a),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
        child: child,
      ),
    );
    Widget txt(String t) =>
        Text(t, style: const TextStyle(fontSize: 13, color: GC.t1));
    final active = a.estado == 'Activo';

    return TableRow(
      decoration: BoxDecoration(
        color: selectedId == a.id ? GC.accent.withValues(alpha: 0.1) : null,
        border: const Border(bottom: BorderSide(color: GC.border)),
      ),
      children: [
        cell(
          Align(
            alignment: Alignment.centerLeft,
            child: Avatar(id: a.id, name: a.nombre, size: 34, font: 12),
          ),
        ),
        cell(txt(a.nombre)),
        cell(txt('${a.edad}')),
        cell(txt(a.cat)),
        cell(txt(a.nivel)),
        cell(
          Align(
            alignment: Alignment.centerLeft,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
              decoration: BoxDecoration(
                color: (active ? GC.mint : GC.redSoft).withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(99),
              ),
              child: Text(
                a.estado,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.4,
                  color: active ? GC.green : GC.red,
                ),
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
          child: Row(
            children: [
              ActionBtn(
                icon: Icons.visibility_outlined,
                bg: GC.accent.withValues(alpha: 0.12),
                fg: GC.accent2,
                onTap: () => onSelect(a),
              ),
              const SizedBox(width: 8),
              ActionBtn(
                icon: Icons.edit_outlined,
                bg: const Color(0xFF94A3B8).withValues(alpha: 0.1),
                fg: GC.t2,
                onTap: () => onEdit(a),
              ),
              const SizedBox(width: 8),
              ActionBtn(
                icon: Icons.delete_outline,
                bg: GC.redSoft.withValues(alpha: 0.1),
                fg: GC.red,
                onTap: () => onDelete(a),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
