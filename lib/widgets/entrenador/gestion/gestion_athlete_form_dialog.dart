import 'package:flutter/material.dart';
import 'gestion_athlete.dart';
import 'gestion_colors.dart';
import 'gestion_common_widgets.dart';

class AthleteFormDialog extends StatefulWidget {
  final Athlete? editing;
  final int nextId;
  const AthleteFormDialog({
    super.key,
    required this.editing,
    required this.nextId,
  });

  @override
  State<AthleteFormDialog> createState() => _AthleteFormDialogState();
}

class _AthleteFormDialogState extends State<AthleteFormDialog> {
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
    if (nombre.isEmpty)
      return setState(() => _error = 'El nombre es obligatorio');
    if (edad == null || edad < 10 || edad > 60)
      return setState(() => _error = 'Edad inválida (10–60)');
    if (_c['pos']!.text.trim().isEmpty)
      return setState(() => _error = 'La posición es obligatoria');

    int n(String k) => int.tryParse(_c[k]!.text) ?? 0;
    Navigator.pop(
      context,
      Athlete(
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

  // ── helpers de UI ──
  InputDecoration get _deco => InputDecoration(
    isDense: true,
    filled: true,
    fillColor: GC.hover,
    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
    border: outline(GC.border, 9),
    enabledBorder: outline(GC.border, 9),
    focusedBorder: outline(GC.accent, 9),
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
          color: GC.t2,
        ),
      ),
      const SizedBox(height: 5),
      child,
    ],
  );

  Widget _input(String key, {bool number = false}) => TextField(
    controller: _c[key],
    keyboardType: number ? TextInputType.number : TextInputType.text,
    style: const TextStyle(color: GC.t1, fontSize: 13),
    decoration: _deco,
  );

  Widget _select(String value, List<String> items, ValueChanged<String> cb) =>
      DropdownButtonFormField<String>(
        value: value,
        isExpanded: true,
        dropdownColor: GC.hover,
        style: const TextStyle(color: GC.t1, fontSize: 13),
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
      backgroundColor: GC.card2,
      insetPadding: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: GC.border),
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
                  color: GC.t1,
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
                  _select(_cat, categorias, (v) => setState(() => _cat = v)),
                ),
                _field(
                  'Nivel',
                  _select(_nivel, niveles, (v) => setState(() => _nivel = v)),
                ),
              ),
              gap,
              _two(
                _field(
                  'Estado',
                  _select(_estado, estados, (v) => setState(() => _estado = v)),
                ),
                const SizedBox(),
              ),
              if (_error != null) ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(Icons.cancel, size: 15, color: GC.red),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        _error!,
                        style: const TextStyle(fontSize: 12, color: GC.redSoft),
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
                  GhostButton(
                    label: 'Cancelar',
                    onTap: () => Navigator.pop(context),
                  ),
                  GradientButton(label: 'Guardar', onTap: _save),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
