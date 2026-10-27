import 'package:flutter/material.dart';

// ───────── Colores (de tu :root en Gestion.css) ─────────
class _C {
  static const bg = Color(0xFF080C18);
  static const card = Color(0xFF0E1525);
  static const card2 = Color(0xFF121D30);
  static const hover = Color(0xFF1A2540);
  static const border = Color(0x0FFFFFFF); // .06
  static const accent = Color(0xFF3B82F6);
  static const accent2 = Color(0xFF60A5FA);
  static const red = Color(0xFFEF4444);
  static const redSoft = Color(0xFFF87171);
  static const purple = Color(0xFF6D28D9);
  static const purple2 = Color(0xFF8B5CF6);
  static const green = Color(0xFF10B981);
  static const mint = Color(0xFF22D3A5);
  static const t1 = Color(0xFFEEF4FF);
  static const t2 = Color(0xFF7A90B8);
  static const t3 = Color(0xFF374A6E);
}

const _avatarColors = [
  Color(0xFF3B82F6),
  Color(0xFF7C3AED),
  Color(0xFF06B6D4),
  Color(0xFFF59E0B),
  Color(0xFF22D3A5),
  Color(0xFFF43F5E),
  Color(0xFF8B5CF6),
  Color(0xFF10B981),
];
Color _colorFor(int id) => _avatarColors[(id - 1) % _avatarColors.length];

String _initials(String n) => n
    .split(' ')
    .where((p) => p.isNotEmpty)
    .map((p) => p[0])
    .join()
    .toUpperCase()
    .substring(
      0,
      n.trim().isEmpty
          ? 0
          : (n.split(' ').where((p) => p.isNotEmpty).length >= 2 ? 2 : 1),
    );

const _categorias = ['Juvenil', 'Mayor', 'Infantil'];
const _niveles = ['Principiante', 'Intermedio', 'Avanzado'];
const _estados = ['Activo', 'Inactivo'];

class _Athlete {
  final int id;
  final String nombre, pos, cat, nivel, estado;
  final int edad, perf, trend, asis, ses;
  const _Athlete({
    required this.id,
    required this.nombre,
    required this.edad,
    required this.pos,
    required this.cat,
    required this.nivel,
    required this.estado,
    required this.perf,
    required this.trend,
    required this.asis,
    required this.ses,
  });
}

// ───────── Pantalla ─────────
class GestionScreen extends StatefulWidget {
  const GestionScreen({super.key});

  @override
  State<GestionScreen> createState() => _GestionScreenState();
}

class _GestionScreenState extends State<GestionScreen> {
  List<_Athlete> _athletes = const [
    _Athlete(
      id: 1,
      nombre: 'Juan Pérez',
      edad: 17,
      pos: 'Opuesto',
      cat: 'Juvenil',
      nivel: 'Avanzado',
      estado: 'Activo',
      perf: 85,
      trend: 12,
      asis: 92,
      ses: 24,
    ),
    _Athlete(
      id: 2,
      nombre: 'María González',
      edad: 16,
      pos: 'Líbero',
      cat: 'Juvenil',
      nivel: 'Intermedio',
      estado: 'Activo',
      perf: 78,
      trend: 8,
      asis: 88,
      ses: 20,
    ),
    _Athlete(
      id: 3,
      nombre: 'Carlos Ramírez',
      edad: 18,
      pos: 'Central',
      cat: 'Mayor',
      nivel: 'Avanzado',
      estado: 'Activo',
      perf: 91,
      trend: 5,
      asis: 96,
      ses: 30,
    ),
    _Athlete(
      id: 4,
      nombre: 'Sofía Ortega',
      edad: 15,
      pos: 'Armadora',
      cat: 'Juvenil',
      nivel: 'Principiante',
      estado: 'Inactivo',
      perf: 62,
      trend: -3,
      asis: 70,
      ses: 12,
    ),
    _Athlete(
      id: 5,
      nombre: 'Andrés López',
      edad: 17,
      pos: 'Receptor',
      cat: 'Juvenil',
      nivel: 'Intermedio',
      estado: 'Activo',
      perf: 80,
      trend: 10,
      asis: 90,
      ses: 22,
    ),
  ];
  int _nextId = 6;
  int? _selectedId;
  String _search = '';
  String _cat = '';
  String _estado = '';

  void _toast(String msg, {bool error = false}) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          duration: const Duration(seconds: 3),
          behavior: SnackBarBehavior.floating,
          backgroundColor: _C.card2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: _C.border),
          ),
          content: Row(
            children: [
              Icon(
                error ? Icons.cancel : Icons.check_circle,
                color: error ? _C.red : _C.green,
                size: 18,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(msg, style: const TextStyle(color: _C.t1)),
              ),
            ],
          ),
        ),
      );
  }

  List<_Athlete> get _filtered => _athletes.where((a) {
    final q = _search.toLowerCase();
    return (q.isEmpty ||
            a.nombre.toLowerCase().contains(q) ||
            a.pos.toLowerCase().contains(q)) &&
        (_cat.isEmpty || a.cat == _cat) &&
        (_estado.isEmpty || a.estado == _estado);
  }).toList();

  _Athlete? get _selected {
    for (final a in _athletes) {
      if (a.id == _selectedId) return a;
    }
    return null;
  }

  Future<void> _openForm([_Athlete? editing]) async {
    final res = await showDialog<_Athlete>(
      context: context,
      builder: (_) => _FormDialog(editing: editing, nextId: _nextId),
    );
    if (res == null) return;
    setState(() {
      if (editing != null) {
        _athletes = [for (final a in _athletes) a.id == editing.id ? res : a];
        _toast('${res.nombre} actualizado correctamente');
      } else {
        _athletes = [..._athletes, res];
        _nextId++;
        _toast('${res.nombre} agregado correctamente');
      }
    });
  }

  Future<void> _askDelete(_Athlete a) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: _C.card2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: const BorderSide(color: _C.border),
        ),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 340),
          child: Padding(
            padding: const EdgeInsets.all(28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.warning_amber_rounded,
                  size: 32,
                  color: _C.red,
                ),
                const SizedBox(height: 12),
                const Text(
                  '¿Eliminar deportista?',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: _C.t1,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Esta acción eliminará al deportista permanentemente.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12.5, color: _C.t2),
                ),
                const SizedBox(height: 20),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  alignment: WrapAlignment.center,
                  children: [
                    _GhostButton(
                      label: 'Cancelar',
                      onTap: () => Navigator.pop(ctx, false),
                    ),
                    OutlinedButton(
                      onPressed: () => Navigator.pop(ctx, true),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: _C.redSoft,
                        backgroundColor: _C.redSoft.withValues(alpha: 0.15),
                        side: BorderSide(
                          color: _C.redSoft.withValues(alpha: 0.3),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 22,
                          vertical: 14,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(9),
                        ),
                      ),
                      child: const Text(
                        'Eliminar',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
    if (ok != true) return;
    setState(() {
      _athletes = _athletes.where((x) => x.id != a.id).toList();
      if (_selectedId == a.id) _selectedId = null;
    });
    _toast('${a.nombre} eliminado');
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        final narrow = c.maxWidth < 950;
        final list = _filtered;
        final sel = _selected;

        final table = _tablePanel(list, narrow);
        final detail = _detailPanel(sel);

        return SingleChildScrollView(
          // 👈 nuevo
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'GESTIÓN DE DEPORTISTAS',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: narrow ? 15 : 17,
                  fontWeight: FontWeight.w700,
                  letterSpacing: narrow ? 0.6 : 1,
                  color: _C.t1,
                ),
              ),
              SizedBox(height: narrow ? 14 : 20),
              if (narrow) ...[
                table,
                if (sel != null) ...[const SizedBox(height: 14), detail],
              ] else
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: table),
                    const SizedBox(width: 20),
                    SizedBox(width: 240, child: detail),
                  ],
                ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  // ───────── Tabla ─────────
  Widget _tablePanel(List<_Athlete> list, bool narrow) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: _box(_C.card2, 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _toolbar(narrow),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.fromLTRB(
              narrow ? 12 : 18,
              0,
              narrow ? 12 : 18,
              0,
            ),
            child: ConstrainedBox(
              constraints: BoxConstraints(minWidth: narrow ? 620 : 560),
              child: _table(list),
            ),
          ),
          if (list.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 32),
              child: Center(
                child: Text(
                  'No se encontraron deportistas.',
                  style: TextStyle(fontSize: 13, color: _C.t3),
                ),
              ),
            ),
          const SizedBox(height: 18),
        ],
      ),
    );
  }

  Widget _toolbar(bool narrow) {
    final search = TextField(
      onChanged: (v) => setState(() => _search = v),
      style: const TextStyle(color: _C.t1, fontSize: 13),
      decoration: InputDecoration(
        isDense: true,
        filled: true,
        fillColor: _C.hover,
        hintText: 'Buscar deportista...',
        hintStyle: const TextStyle(color: _C.t3, fontSize: 13),
        prefixIcon: const Icon(Icons.search, size: 16, color: _C.t3),
        contentPadding: const EdgeInsets.symmetric(vertical: 12),
        border: _outline(_C.border),
        enabledBorder: _outline(_C.border),
        focusedBorder: _outline(_C.accent),
      ),
    );

    final filtros = [
      _FilterSelect(
        hint: 'Categoría',
        value: _cat,
        items: _categorias,
        onChanged: (v) => setState(() => _cat = v),
      ),
      _FilterSelect(
        hint: 'Estado',
        value: _estado,
        items: _estados,
        onChanged: (v) => setState(() => _estado = v),
      ),
    ];

    final add = Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _openForm(),
        borderRadius: BorderRadius.circular(10),
        child: Ink(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [_C.purple, _C.purple2],
            ),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.add, size: 15, color: Colors.white),
              SizedBox(width: 7),
              Text(
                'Agregar deportista',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
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
                    Expanded(child: filtros[0]),
                    const SizedBox(width: 8),
                    Expanded(child: filtros[1]),
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
                SizedBox(width: 130, child: filtros[0]),
                const SizedBox(width: 10),
                SizedBox(width: 120, child: filtros[1]),
                const SizedBox(width: 10),
                add,
              ],
            ),
    );
  }

  Widget _table(List<_Athlete> list) {
    const head = TextStyle(
      fontSize: 11.5,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.6,
      color: _C.t2,
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
            border: Border(bottom: BorderSide(color: _C.border)),
          ),
          children: [
            th('Foto'),
            th('Nombre'),
            th('Edad'),
            th('Categoría'),
            th('Nivel'),
            th('Estado'),
            th('Acciones'),
          ],
        ),
        for (final a in list) _row(a),
      ],
    );
  }

  TableRow _row(_Athlete a) {
    final selected = _selectedId == a.id;

    Widget cell(Widget child, {double v = 11}) => InkWell(
      onTap: () => setState(() => _selectedId = a.id),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: v),
        child: child,
      ),
    );
    Widget txt(String t) =>
        Text(t, style: const TextStyle(fontSize: 13, color: _C.t1));

    final active = a.estado == 'Activo';

    return TableRow(
      decoration: BoxDecoration(
        color: selected ? _C.accent.withValues(alpha: 0.1) : null,
        border: const Border(bottom: BorderSide(color: _C.border)),
      ),
      children: [
        cell(
          Align(
            alignment: Alignment.centerLeft,
            child: _Avatar(id: a.id, name: a.nombre, size: 34, font: 12),
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
                color: (active ? _C.mint : _C.redSoft).withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(99),
              ),
              child: Text(
                a.estado,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.4,
                  color: active ? _C.green : _C.red,
                ),
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
          child: Row(
            children: [
              _ActionBtn(
                icon: Icons.visibility_outlined,
                bg: _C.accent.withValues(alpha: 0.12),
                fg: _C.accent2,
                onTap: () => setState(() => _selectedId = a.id),
              ),
              const SizedBox(width: 8),
              _ActionBtn(
                icon: Icons.edit_outlined,
                bg: const Color(0xFF94A3B8).withValues(alpha: 0.1),
                fg: _C.t2,
                onTap: () => _openForm(a),
              ),
              const SizedBox(width: 8),
              _ActionBtn(
                icon: Icons.delete_outline,
                bg: _C.redSoft.withValues(alpha: 0.1),
                fg: _C.red,
                onTap: () => _askDelete(a),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ───────── Detalle ─────────
  Widget _detailPanel(_Athlete? s) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: _box(_C.card2, 18),
      child: s == null
          ? const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 60),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.person_off_outlined, size: 28, color: _C.t3),
                  SizedBox(height: 10),
                  Text(
                    'Selecciona un deportista para ver su información',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 13, color: _C.t3),
                  ),
                ],
              ),
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  padding: const EdgeInsets.fromLTRB(18, 22, 18, 18),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [_C.card, _C.hover],
                    ),
                    border: Border(bottom: BorderSide(color: _C.border)),
                  ),
                  child: Column(
                    children: [
                      Container(
                        width: 72,
                        height: 72,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _colorFor(s.id),
                          border: Border.all(
                            color: _C.accent.withValues(alpha: 0.35),
                            width: 3,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: _C.accent.withValues(alpha: 0.18),
                              blurRadius: 20,
                            ),
                          ],
                        ),
                        child: Text(
                          _initials(s.nombre),
                          style: const TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        s.nombre,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: _C.t1,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        s.pos,
                        style: const TextStyle(fontSize: 12, color: _C.t2),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${s.edad} años · Categoría: ${s.cat}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 11.5, color: _C.t3),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'RENDIMIENTO PROMEDIO',
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.6,
                          color: _C.t3,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text(
                            '${s.perf}%',
                            style: const TextStyle(
                              fontFamily: 'monospace',
                              fontSize: 28,
                              fontWeight: FontWeight.w700,
                              color: _C.t1,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            '${s.trend >= 0 ? '↑' : '↓'} ${s.trend.abs()}%',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: s.trend >= 0 ? _C.green : _C.red,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      _StatLine('Asistencia', '${s.asis}%', last: false),
                      _StatLine(
                        'Sesiones completadas',
                        '${s.ses}',
                        last: false,
                      ),
                      _StatLine('Nivel', s.nivel, last: true),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => _toast(
                        'Perfil de ${s.nombre} — función próximamente 🚀',
                      ),
                      borderRadius: BorderRadius.circular(11),
                      child: Ink(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [_C.accent, Color(0xFF818CF8)],
                          ),
                          borderRadius: BorderRadius.circular(11),
                        ),
                        child: const Center(
                          child: Text(
                            'Ver perfil completo',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}

// ───────── Helpers ─────────
BoxDecoration _box(Color c, double r) => BoxDecoration(
  color: c,
  borderRadius: BorderRadius.circular(r),
  border: Border.all(color: _C.border),
);

OutlineInputBorder _outline(Color c, [double r = 10]) => OutlineInputBorder(
  borderRadius: BorderRadius.circular(r),
  borderSide: BorderSide(color: c),
);

class _Avatar extends StatelessWidget {
  final int id;
  final String name;
  final double size, font;
  const _Avatar({
    required this.id,
    required this.name,
    required this.size,
    required this.font,
  });

  @override
  Widget build(BuildContext context) => Container(
    width: size,
    height: size,
    alignment: Alignment.center,
    decoration: BoxDecoration(shape: BoxShape.circle, color: _colorFor(id)),
    child: Text(
      _initials(name),
      style: TextStyle(
        fontSize: font,
        fontWeight: FontWeight.w700,
        color: Colors.white,
      ),
    ),
  );
}

class _ActionBtn extends StatelessWidget {
  final IconData icon;
  final Color bg, fg;
  final VoidCallback onTap;
  const _ActionBtn({
    required this.icon,
    required this.bg,
    required this.fg,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(8),
    child: Container(
      width: 30,
      height: 30,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(icon, size: 15, color: fg),
    ),
  );
}

class _StatLine extends StatelessWidget {
  final String k, v;
  final bool last;
  const _StatLine(this.k, this.v, {required this.last});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(vertical: 9),
    decoration: BoxDecoration(
      border: last ? null : const Border(bottom: BorderSide(color: _C.border)),
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(k, style: const TextStyle(fontSize: 12.5, color: _C.t2)),
        Text(
          v,
          style: const TextStyle(
            fontFamily: 'monospace',
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: _C.t1,
          ),
        ),
      ],
    ),
  );
}

class _GhostButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _GhostButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) => OutlinedButton(
    onPressed: onTap,
    style: OutlinedButton.styleFrom(
      foregroundColor: _C.t2,
      side: const BorderSide(color: _C.border),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9)),
    ),
    child: Text(label, style: const TextStyle(fontSize: 13)),
  );
}

/// Select de filtro: '' = sin filtro (muestra el hint).
class _FilterSelect extends StatelessWidget {
  final String hint, value;
  final List<String> items;
  final ValueChanged<String> onChanged;
  const _FilterSelect({
    required this.hint,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12),
    decoration: BoxDecoration(
      color: _C.hover,
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: _C.border),
    ),
    child: DropdownButtonHideUnderline(
      child: DropdownButton<String>(
        value: value,
        isExpanded: true,
        dropdownColor: _C.hover,
        style: const TextStyle(color: _C.t2, fontSize: 13),
        icon: const Icon(Icons.arrow_drop_down, color: _C.t2),
        items: [
          DropdownMenuItem(value: '', child: Text(hint)),
          for (final i in items) DropdownMenuItem(value: i, child: Text(i)),
        ],
        onChanged: (v) => onChanged(v ?? ''),
      ),
    ),
  );
}

// ───────── Modal agregar / editar ─────────
class _FormDialog extends StatefulWidget {
  final _Athlete? editing;
  final int nextId;
  const _FormDialog({required this.editing, required this.nextId});

  @override
  State<_FormDialog> createState() => _FormDialogState();
}

class _FormDialogState extends State<_FormDialog> {
  late final Map<String, TextEditingController> _c;
  late String _cat, _nivel, _estado;
  String? _error;

  @override
  void initState() {
    super.initState();
    final e = widget.editing;
    String v(Object? x) => x == null ? '' : '$x';
    _c = {
      'nombre': TextEditingController(text: e?.nombre ?? ''),
      'edad': TextEditingController(text: v(e?.edad)),
      'pos': TextEditingController(text: e?.pos ?? ''),
      'perf': TextEditingController(text: v(e?.perf)),
      'asis': TextEditingController(text: v(e?.asis)),
      'ses': TextEditingController(text: v(e?.ses)),
      'trend': TextEditingController(text: v(e?.trend)),
    };
    _cat = e?.cat ?? 'Juvenil';
    _nivel = e?.nivel ?? 'Principiante';
    _estado = e?.estado ?? 'Activo';
  }

  @override
  void dispose() {
    for (final c in _c.values) {
      c.dispose();
    }
    super.dispose();
  }

  void _save() {
    final nombre = _c['nombre']!.text.trim();
    final edad = int.tryParse(_c['edad']!.text);
    if (nombre.isEmpty) {
      setState(() => _error = 'El nombre es obligatorio');
      return;
    }
    if (edad == null || edad < 10 || edad > 60) {
      setState(() => _error = 'Edad inválida (10–60)');
      return;
    }
    if (_c['pos']!.text.trim().isEmpty) {
      setState(() => _error = 'La posición es obligatoria');
      return;
    }
    int n(String k) => int.tryParse(_c[k]!.text) ?? 0;
    Navigator.pop(
      context,
      _Athlete(
        id: widget.editing?.id ?? widget.nextId,
        nombre: nombre,
        edad: edad,
        pos: _c['pos']!.text.trim(),
        cat: _cat,
        nivel: _nivel,
        estado: _estado,
        perf: n('perf'),
        trend: n('trend'),
        asis: n('asis'),
        ses: n('ses'),
      ),
    );
  }

  InputDecoration get _deco => InputDecoration(
    isDense: true,
    filled: true,
    fillColor: _C.hover,
    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
    border: _outline(_C.border, 9),
    enabledBorder: _outline(_C.border, 9),
    focusedBorder: _outline(_C.accent, 9),
  );

  Widget _field(String label, Widget child) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label.toUpperCase(),
        style: const TextStyle(
          fontSize: 11.5,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.6,
          color: _C.t2,
        ),
      ),
      const SizedBox(height: 5),
      child,
    ],
  );

  Widget _input(String key, {bool number = false}) => TextField(
    controller: _c[key],
    keyboardType: number ? TextInputType.number : TextInputType.text,
    style: const TextStyle(color: _C.t1, fontSize: 13),
    decoration: _deco,
  );

  Widget _select(String value, List<String> items, ValueChanged<String> cb) =>
      DropdownButtonFormField<String>(
        value: value,
        isExpanded: true,
        dropdownColor: _C.hover,
        style: const TextStyle(color: _C.t1, fontSize: 13),
        decoration: _deco,
        items: [
          for (final i in items) DropdownMenuItem(value: i, child: Text(i)),
        ],
        onChanged: (v) => cb(v ?? value),
      );

  Widget _two(Widget a, Widget b) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Expanded(child: a),
      const SizedBox(width: 14),
      Expanded(child: b),
    ],
  );

  @override
  Widget build(BuildContext context) {
    final editing = widget.editing != null;
    const gap = SizedBox(height: 14);
    return Dialog(
      backgroundColor: _C.card2,
      insetPadding: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: _C.border),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 460),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                '${editing ? 'Editar' : 'Agregar'} Deportista',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.6,
                  color: _C.t1,
                ),
              ),
              const SizedBox(height: 20),
              _field('Nombre completo', _input('nombre')),
              gap,
              _two(
                _field('Edad', _input('edad', number: true)),
                _field('Posición', _input('pos')),
              ),
              gap,
              _two(
                _field('Rendimiento (%)', _input('perf', number: true)),
                _field('Asistencia (%)', _input('asis', number: true)),
              ),
              gap,
              _two(
                _field('Sesiones', _input('ses', number: true)),
                _field('Tendencia (%)', _input('trend', number: true)),
              ),
              gap,
              _two(
                _field(
                  'Categoría',
                  _select(_cat, _categorias, (v) => setState(() => _cat = v)),
                ),
                _field(
                  'Nivel',
                  _select(_nivel, _niveles, (v) => setState(() => _nivel = v)),
                ),
              ),
              gap,
              _two(
                _field(
                  'Estado',
                  _select(
                    _estado,
                    _estados,
                    (v) => setState(() => _estado = v),
                  ),
                ),
                const SizedBox(),
              ),
              if (_error != null) ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(Icons.cancel, size: 15, color: _C.red),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        _error!,
                        style: const TextStyle(fontSize: 12, color: _C.redSoft),
                      ),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 20),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                alignment: WrapAlignment.end,
                children: [
                  _GhostButton(
                    label: 'Cancelar',
                    onTap: () => Navigator.pop(context),
                  ),
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: _save,
                      borderRadius: BorderRadius.circular(9),
                      child: Ink(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 22,
                          vertical: 14,
                        ),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [_C.accent, Color(0xFF818CF8)],
                          ),
                          borderRadius: BorderRadius.circular(9),
                        ),
                        child: const Text(
                          'Guardar',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
