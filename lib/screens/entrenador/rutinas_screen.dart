import 'dart:math' as math;
import 'package:flutter/material.dart';

// ───────── Colores (de tu :root en Rutinas.css) ─────────
class _C {
  static const bg = Color(0xFF0D0F1A); // --bg
  static const card = Color(0xFF181C30); // --panel2
  static const card2 = Color(0xFF1E2238); // --panel3
  static const border = Color(0x12FFFFFF); // --border
  static const text = Color(0xFFE8EAF6); // --text
  static const muted = Color(0xFF7A7F9A); // --muted
  static const muted2 = Color(0xFF4A4F6A); // --muted2
  static const accent = Color(0xFF7C5CFC); // --accent
  static const accent2 = Color(0xFF00D4FF); // --accent2
  static const accent3 = Color(0xFFFF6B6B); // --accent3
  static const accent4 = Color(0xFFF7B731); // --accent4
  static const accent5 = Color(0xFF26DE81); // --accent5
  static const orange = Color(0xFFFF9F43); // --accent6
}

const _typeColors = <String, Color>{
  'Técnico': Color(0xFF7C5CFC),
  'Físico': Color(0xFF00D4FF),
  'Táctico': Color(0xFFF7B731),
  'Potencia': Color(0xFFFF6B6B),
  'Resistencia': Color(0xFF26DE81),
  'Recuperación': Color(0xFFFF9F43),
  'Precompetencia': Color(0xFFE056FD),
};

const _exercises = <String, List<String>>{
  'Técnico': [
    'Saque flotante',
    'Recepción pasiva',
    'Colocación',
    'Remate cruzado',
    'Bloqueo doble',
    'Defensa en W',
    'Saque potencia',
    'Pase de dedos',
  ],
  'Físico': [
    'Saltos de cajón',
    'Sentadillas',
    'Plancha lateral',
    'Sprint 20m',
    'Escaladores',
    'Flexiones explosivas',
    'Zancadas',
    'Banda elástica',
  ],
  'Táctico': [
    'Sistema 6-2',
    'Rotación posicional',
    'Contraataque',
    'Lectura del bloqueo',
    'Defensa zona',
    'Ataque en diagonal',
    'Finta de remate',
  ],
  'Potencia': [
    'Salto vertical',
    'Remate con carga',
    'Arranque',
    'Kettlebell swing',
    'Drop jump',
    'Banded sprint',
    'Cargada olímpica',
  ],
  'Resistencia': [
    'Carrera continua',
    'Circuito funcional',
    'Remo ergómetro',
    'Bicicleta HIIT',
    'Natación técnica',
    'Escalera de agilidad',
  ],
  'Recuperación': [
    'Foam roller',
    'Estiramientos activos',
    'Yoga deportivo',
    'Movilidad de hombro',
    'Crioterapia',
    'Respiración diafragmática',
  ],
  'Precompetencia': [
    'Activación neuromuscular',
    'Tiro libre',
    'Recepción simulada',
    'Formación táctica',
    'Calentamiento dinámico',
    'Visualización',
  ],
};

const _athletes = [
  'Juan García',
  'María López',
  'Carlos Ruiz',
  'Sofía Mendez',
  'Andrés Mora',
  'Todo el equipo',
];
const _durations = ['30 min', '45 min', '60 min', '90 min', '2 hrs'];

class _Preset {
  final String emoji, name, type, desc, dur;
  final int intensity;
  final List<String> exs;
  const _Preset(
    this.emoji,
    this.name,
    this.type,
    this.desc,
    this.dur,
    this.intensity,
    this.exs,
  );
}

const _presets = [
  _Preset(
    '⚡',
    'Saque Explosivo',
    'Técnico',
    'Dominio del saque flotante y de potencia.',
    '60 min',
    8,
    ['Saque flotante', 'Saque potencia', 'Recepción pasiva'],
  ),
  _Preset(
    '💪',
    'Fuerza & Salto',
    'Físico',
    'Circuito de potencia para el salto vertical.',
    '90 min',
    9,
    ['Saltos de cajón', 'Sentadillas', 'Drop jump'],
  ),
  _Preset(
    '🧠',
    'Juego Táctico 6-2',
    'Táctico',
    'Sistema 6-2 con rotaciones.',
    '60 min',
    6,
    ['Sistema 6-2', 'Rotación posicional', 'Contraataque'],
  ),
  _Preset(
    '🔥',
    'HIIT Voleibol',
    'Potencia',
    'Alta intensidad intervalada.',
    '45 min',
    10,
    ['Sprint 20m', 'Remate con carga', 'Drop jump'],
  ),
  _Preset(
    '🧘',
    'Regeneración',
    'Recuperación',
    'Post-partido, recuperación muscular.',
    '30 min',
    3,
    ['Foam roller', 'Estiramientos activos'],
  ),
];

class _Routine {
  final String id, name, athlete, type, hour, dur, notes, date;
  final int intensity;
  final List<String> exs;
  final bool done;
  const _Routine({
    required this.id,
    required this.name,
    required this.athlete,
    required this.type,
    required this.hour,
    required this.dur,
    required this.intensity,
    required this.exs,
    required this.notes,
    required this.date,
    required this.done,
  });

  _Routine copyWith({bool? done}) => _Routine(
    id: id,
    name: name,
    athlete: athlete,
    type: type,
    hour: hour,
    dur: dur,
    intensity: intensity,
    exs: exs,
    notes: notes,
    date: date,
    done: done ?? this.done,
  );
}

String _iso(DateTime d) =>
    '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
String _daysAgo(int n) => _iso(DateTime.now().subtract(Duration(days: n)));

Color _iCol(int v) => v <= 3
    ? _C.accent5
    : v <= 6
    ? _C.accent4
    : v <= 8
    ? _C.orange
    : _C.accent3;

// ───────── Pantalla ─────────
class RutinasScreen extends StatefulWidget {
  const RutinasScreen({super.key});

  @override
  State<RutinasScreen> createState() => _RutinasScreenState();
}

class _RutinasScreenState extends State<RutinasScreen> {
  final _formKey = GlobalKey();

  late List<_Routine> _routines;

  String? _athlete;
  String? _type;
  final _name = TextEditingController();
  final _hour = TextEditingController(text: '08');
  final _min = TextEditingController(text: '00');
  final _notes = TextEditingController();
  double _intensity = 6;
  List<String> _selectedExs = [];
  String _selectedDur = '60 min';
  String _filter = 'Todas';
  String? _editingId;

  @override
  void initState() {
    super.initState();
    _routines = [
      _Routine(
        id: 'a1',
        name: 'Saque Explosivo Matutino',
        athlete: 'Juan García',
        type: 'Técnico',
        hour: '08:00',
        dur: '60 min',
        intensity: 8,
        exs: const ['Saque flotante', 'Saque potencia'],
        notes: 'Posición del pie derecho.',
        date: _daysAgo(0),
        done: false,
      ),
      _Routine(
        id: 'a2',
        name: 'Fuerza & Explosividad',
        athlete: 'María López',
        type: 'Físico',
        hour: '10:00',
        dur: '90 min',
        intensity: 9,
        exs: const ['Saltos de cajón', 'Sentadillas'],
        notes: '',
        date: _daysAgo(1),
        done: true,
      ),
      _Routine(
        id: 'a3',
        name: 'Juego Táctico 6-2',
        athlete: 'Todo el equipo',
        type: 'Táctico',
        hour: '16:00',
        dur: '60 min',
        intensity: 6,
        exs: const ['Sistema 6-2', 'Contraataque'],
        notes: 'Llevar pizarrón.',
        date: _daysAgo(1),
        done: false,
      ),
      _Routine(
        id: 'a4',
        name: 'Regeneración Post-Partido',
        athlete: 'Carlos Ruiz',
        type: 'Recuperación',
        hour: '07:00',
        dur: '30 min',
        intensity: 3,
        exs: const ['Foam roller'],
        notes: '',
        date: _daysAgo(2),
        done: true,
      ),
    ];
  }

  @override
  void dispose() {
    _name.dispose();
    _hour.dispose();
    _min.dispose();
    _notes.dispose();
    super.dispose();
  }

  void _toast(String msg) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          duration: const Duration(seconds: 3),
          behavior: SnackBarBehavior.floating,
          backgroundColor: _C.card,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
            side: const BorderSide(color: _C.border),
          ),
          content: Row(
            children: [
              const Text('✅', style: TextStyle(fontSize: 18)),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  msg,
                  style: const TextStyle(color: _C.text, fontSize: 13),
                ),
              ),
            ],
          ),
        ),
      );
  }

  void _resetForm() {
    _athlete = null;
    _type = null;
    _name.clear();
    _hour.text = '08';
    _min.text = '00';
    _notes.clear();
    _intensity = 6;
    _selectedExs = [];
    _selectedDur = '60 min';
  }

  void _save() {
    if (_athlete == null || _type == null || _name.text.trim().isEmpty) {
      _toast('Completa deportista, tipo y nombre');
      return;
    }
    final r = _Routine(
      id: _editingId ?? DateTime.now().microsecondsSinceEpoch.toString(),
      name: _name.text.trim(),
      athlete: _athlete!,
      type: _type!,
      hour: '${_hour.text.padLeft(2, '0')}:${_min.text.padLeft(2, '0')}',
      dur: _selectedDur,
      intensity: _intensity.round(),
      exs: List.of(_selectedExs),
      notes: _notes.text,
      date: _iso(DateTime.now()),
      done: false,
    );
    setState(() {
      if (_editingId != null) {
        _routines = [for (final x in _routines) x.id == _editingId ? r : x];
        _toast('"${r.name}" actualizada');
        _editingId = null;
      } else {
        _routines = [r, ..._routines];
        _toast('"${r.name}" guardada');
      }
      _resetForm();
    });
  }

  void _edit(_Routine r) {
    final parts = r.hour.split(':');
    setState(() {
      _athlete = r.athlete;
      _type = r.type;
      _name.text = r.name;
      _hour.text = parts[0];
      _min.text = parts[1];
      _intensity = r.intensity.toDouble();
      _notes.text = r.notes;
      _selectedExs = List.of(r.exs);
      _selectedDur = r.dur;
      _editingId = r.id;
    });
    final ctx = _formKey.currentContext;
    if (ctx != null) {
      Scrollable.ensureVisible(
        ctx,
        duration: const Duration(milliseconds: 300),
      );
    }
    _toast('Editando "${r.name}"');
  }

  void _loadPreset(_Preset p) {
    setState(() {
      _type = p.type;
      _name.text = p.name;
      _intensity = p.intensity.toDouble();
      _selectedExs = List.of(p.exs);
      _selectedDur = p.dur;
    });
    _toast('"${p.name}" cargada');
  }

  @override
  Widget build(BuildContext context) {
    final today = _iso(DateTime.now());
    final filtered = _filter == 'Todas'
        ? _routines
        : _routines.where((r) => r.type == _filter).toList();

    return LayoutBuilder(
      builder: (context, c) {
        final w = c.maxWidth;
        final ancho = w >= 700;
        return SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 90),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _header(),
              const SizedBox(height: 18),
              _stats(w, today),
              const SizedBox(height: 10),
              _weekCard(today),
              const SizedBox(height: 14),
              if (ancho)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: _formCard()),
                    const SizedBox(width: 14),
                    Expanded(child: _rightColumn()),
                  ],
                )
              else ...[
                _formCard(),
                const SizedBox(height: 14),
                _rightColumn(),
              ],
              const SizedBox(height: 22),
              _divider(),
              const SizedBox(height: 22),
              _listHeader(filtered.length),
              const SizedBox(height: 16),
              _grid(w, filtered),
            ],
          ),
        );
      },
    );
  }

  // ───────── Header (centrado) ─────────
  Widget _header() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Text.rich(
          TextSpan(
            children: [
              TextSpan(text: 'PANEL DE '),
              TextSpan(
                text: 'RUTINAS',
                style: TextStyle(color: _C.accent),
              ),
            ],
          ),
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            letterSpacing: 2,
            color: _C.text,
          ),
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: _C.accent.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: _C.accent.withValues(alpha: 0.3)),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.circle, size: 8, color: _C.accent),
              SizedBox(width: 8),
              Text(
                'Sistema activo',
                style: TextStyle(
                  fontSize: 12,
                  letterSpacing: 1,
                  color: _C.accent,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ───────── Stats ─────────
  Widget _stats(double w, String today) {
    final done = _routines.where((r) => r.done).length;
    final pct = _routines.isEmpty ? 0 : (done / _routines.length * 100).round();
    final items = [
      ('Total rutinas', '${_routines.length}', 'registradas', _C.accent),
      ('Completadas', '$done', '$pct% del total', _C.accent5),
      (
        'Hoy programadas',
        '${_routines.where((r) => r.date == today).length}',
        'sesiones',
        _C.accent2,
      ),
      ('Deportistas activos', '5', 'en el sistema', _C.accent4),
    ];
    const gap = 10.0;
    final cols = w >= 600 ? 4 : 2;
    final itemW = (w - gap * (cols - 1)) / cols;
    return Wrap(
      spacing: gap,
      runSpacing: gap,
      children: [
        for (final s in items)
          SizedBox(
            width: itemW,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: _box(_C.card, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    s.$1,
                    style: const TextStyle(fontSize: 11, color: _C.muted),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    s.$2,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      height: 1,
                      color: s.$4,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    s.$3,
                    style: const TextStyle(fontSize: 11, color: _C.muted),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  // ───────── Semana ─────────
  Widget _weekCard(String today) {
    const names = ['Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb', 'Dom'];
    final now = DateTime.now();
    final monday = now.subtract(Duration(days: now.weekday - 1));
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _box(_C.card, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _CardTitle(icon: '📅', title: 'Semana actual'),
          Row(
            children: [
              for (var i = 0; i < 7; i++)
                Expanded(
                  child: Builder(
                    builder: (_) {
                      final d = monday.add(Duration(days: i));
                      final iso = _iso(d);
                      final has = _routines.any((r) => r.date == iso);
                      final isToday = iso == today;
                      return Column(
                        children: [
                          Text(
                            names[i],
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                              color: _C.muted,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: has ? _C.accent : _C.border,
                              boxShadow: has
                                  ? [
                                      BoxShadow(
                                        color: _C.accent.withValues(
                                          alpha: 0.25,
                                        ),
                                        blurRadius: 6,
                                      ),
                                    ]
                                  : null,
                              border: isToday
                                  ? Border.all(color: _C.accent4, width: 2)
                                  : null,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            '${d.day}',
                            style: const TextStyle(
                              fontSize: 10,
                              color: _C.muted,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  // ───────── Formulario ─────────
  Widget _formCard() {
    final pool = _exercises[_type] ?? const <String>[];
    return Container(
      key: _formKey,
      padding: const EdgeInsets.all(16),
      decoration: _box(_C.card, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _CardTitle(
            icon: '➕',
            title: '${_editingId != null ? 'Editar' : 'Nueva'} rutina',
          ),
          LayoutBuilder(
            builder: (context, c) {
              final dep = _dropdown(
                'Deportista',
                _athlete,
                _athletes,
                (v) => setState(() => _athlete = v),
              );
              final tipo = _dropdown(
                'Tipo de entrenamiento',
                _type,
                _exercises.keys.toList(),
                (v) {
                  setState(() {
                    _type = v;
                    _selectedExs = [];
                  });
                },
              );
              if (c.maxWidth >= 380) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: dep),
                    const SizedBox(width: 10),
                    Expanded(child: tipo),
                  ],
                );
              }
              return Column(children: [dep, const SizedBox(height: 10), tipo]);
            },
          ),
          const SizedBox(height: 10),
          const _Label('Nombre de la rutina'),
          TextField(
            controller: _name,
            style: const TextStyle(color: _C.text, fontSize: 13),
            decoration: _inputDeco('Ej: Entrenamiento de saque explosivo…'),
          ),
          const SizedBox(height: 10),
          const _Label('Hora de inicio'),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _TimeBox(label: 'HH', controller: _hour, max: 23),
              const Padding(
                padding: EdgeInsets.only(left: 10, right: 10, bottom: 8),
                child: Text(
                  ':',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: _C.accent,
                  ),
                ),
              ),
              _TimeBox(label: 'MM', controller: _min, max: 59),
            ],
          ),
          const SizedBox(height: 10),
          const _Label('Duración'),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final d in _durations)
                _Pill(
                  text: d,
                  selected: _selectedDur == d,
                  onTap: () => setState(() => _selectedDur = d),
                ),
            ],
          ),
          const SizedBox(height: 10),
          const _Label('Intensidad'),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              trackHeight: 5,
              activeTrackColor: _iCol(_intensity.round()),
              thumbColor: _C.text,
              inactiveTrackColor: Colors.white12,
              overlayColor: _C.accent.withValues(alpha: 0.2),
            ),
            child: Slider(
              min: 1,
              max: 10,
              divisions: 9,
              value: _intensity,
              onChanged: (v) => setState(() => _intensity = v),
            ),
          ),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Suave', style: TextStyle(fontSize: 10, color: _C.muted)),
              Text('Moderado', style: TextStyle(fontSize: 10, color: _C.muted)),
              Text('Máximo', style: TextStyle(fontSize: 10, color: _C.muted)),
            ],
          ),
          const SizedBox(height: 6),
          Center(
            child: Text(
              '${_intensity.round()} / 10',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: _iCol(_intensity.round()),
              ),
            ),
          ),
          if (pool.isNotEmpty) ...[
            const SizedBox(height: 10),
            const _Label('Ejercicios incluidos'),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final ex in pool)
                  _Pill(
                    text: ex,
                    selected: _selectedExs.contains(ex),
                    onTap: () => setState(() {
                      _selectedExs.contains(ex)
                          ? _selectedExs.remove(ex)
                          : _selectedExs.add(ex);
                    }),
                  ),
              ],
            ),
          ],
          const SizedBox(height: 12),
          const _Label('Notas / Observaciones'),
          TextField(
            controller: _notes,
            maxLines: 3,
            style: const TextStyle(color: _C.text, fontSize: 13),
            decoration: _inputDeco('Indicaciones especiales…'),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: _save,
                borderRadius: BorderRadius.circular(10),
                child: Ink(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [_C.accent, Color(0xFFA078FF)],
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Text(
                      _editingId != null
                          ? '✏️ ACTUALIZAR RUTINA'
                          : '⚡ GUARDAR RUTINA',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 2,
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

  Widget _dropdown(
    String label,
    String? value,
    List<String> items,
    ValueChanged<String?> onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Label(label),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: _C.card2,
            borderRadius: BorderRadius.circular(9),
            border: Border.all(color: _C.border),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              hint: const Text(
                'Seleccionar...',
                style: TextStyle(color: _C.muted, fontSize: 13),
              ),
              dropdownColor: const Color(0xFF1A1E30),
              style: const TextStyle(color: _C.text, fontSize: 13),
              icon: const Icon(Icons.arrow_drop_down, color: _C.muted),
              items: [
                for (final i in items)
                  DropdownMenuItem(value: i, child: Text(i)),
              ],
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }

  // ───────── Columna derecha ─────────
  Widget _rightColumn() {
    const rings = [
      ('Técnico', 75),
      ('Físico', 60),
      ('Táctico', 45),
      ('Recuperación', 90),
    ];
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: _box(_C.card, 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _CardTitle(icon: '📋', title: 'Rutinas prediseñadas'),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (final p in _presets)
                      Padding(
                        padding: const EdgeInsets.only(right: 12),
                        child: InkWell(
                          onTap: () => _loadPreset(p),
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            width: 190,
                            padding: const EdgeInsets.all(14),
                            decoration: _box(_C.card2, 12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  p.emoji,
                                  style: const TextStyle(fontSize: 26),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  p.name,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 1,
                                    color: _C.text,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  p.desc,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    height: 1.4,
                                    color: _C.muted,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Wrap(
                                  spacing: 4,
                                  runSpacing: 4,
                                  children: [
                                    _MiniTag(
                                      p.type,
                                      color: _typeColors[p.type],
                                    ),
                                    _MiniTag(p.dur),
                                    _MiniTag('⚡ ${p.intensity}/10'),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: _box(_C.card, 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _CardTitle(icon: '📊', title: 'Progreso semanal'),
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 20,
                runSpacing: 12,
                children: [
                  for (final r in rings)
                    Column(
                      children: [
                        SizedBox(
                          width: 70,
                          height: 70,
                          child: CustomPaint(
                            painter: _RingPainter(
                              r.$2 / 100,
                              _typeColors[r.$1]!,
                            ),
                            child: Center(
                              child: Text(
                                '${r.$2}%',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: _typeColors[r.$1],
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          r.$1,
                          style: const TextStyle(fontSize: 11, color: _C.muted),
                        ),
                      ],
                    ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: _C.card,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: _C.accent.withValues(alpha: 0.25)),
          ),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _CardTitle(icon: '🤖', title: 'Sugerencia IA'),
              Text.rich(
                TextSpan(
                  children: [
                    TextSpan(text: '🏐 '),
                    TextSpan(
                      text: 'Juan García',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: _C.text,
                      ),
                    ),
                    TextSpan(
                      text:
                          ' lleva 3 sesiones consecutivas de alta intensidad. Considera agregar recuperación activa mañana.',
                    ),
                  ],
                ),
                style: TextStyle(fontSize: 13, color: _C.muted, height: 1.6),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ───────── Lista ─────────
  Widget _divider() {
    return const Row(
      children: [
        Expanded(child: Divider(color: _C.border, height: 1)),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 14),
          child: Text(
            'RUTINAS REGISTRADAS',
            style: TextStyle(fontSize: 11, letterSpacing: 2, color: _C.muted),
          ),
        ),
        Expanded(child: Divider(color: _C.border, height: 1)),
      ],
    );
  }

  Widget _listHeader(int count) {
    return Wrap(
      alignment: WrapAlignment.spaceBetween,
      crossAxisAlignment: WrapCrossAlignment.center,
      runSpacing: 10,
      spacing: 12,
      children: [
        Text.rich(
          TextSpan(
            children: [
              const TextSpan(text: 'Total: '),
              TextSpan(
                text: '$count',
                style: const TextStyle(color: _C.accent),
              ),
              const TextSpan(text: ' rutinas'),
            ],
          ),
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: _C.text,
          ),
        ),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final t in ['Todas', ..._typeColors.keys])
              _Pill(
                text: t,
                selected: _filter == t,
                onTap: () => setState(() => _filter = t),
              ),
          ],
        ),
      ],
    );
  }

  Widget _grid(double w, List<_Routine> list) {
    if (list.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 60, horizontal: 20),
        child: Center(
          child: Column(
            children: [
              Opacity(
                opacity: 0.3,
                child: Text('📋', style: TextStyle(fontSize: 48)),
              ),
              SizedBox(height: 10),
              Opacity(
                opacity: 0.5,
                child: Text(
                  'Sin rutinas registradas',
                  style: TextStyle(
                    fontSize: 18,
                    letterSpacing: 1,
                    color: _C.muted,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }
    const gap = 16.0;
    final cols = math.max(1, ((w + gap) / (300 + gap)).floor());
    final itemW = (w - gap * (cols - 1)) / cols;
    return Wrap(
      spacing: gap,
      runSpacing: gap,
      children: [
        for (final r in list) SizedBox(width: itemW, child: _routineCard(r)),
      ],
    );
  }

  Widget _routineCard(_Routine r) {
    final col = _typeColors[r.type] ?? _C.accent;
    return Container(
      decoration: _box(_C.card, 14),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 3,
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [col, Colors.transparent]),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: col.withValues(alpha: 0.09),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: col.withValues(alpha: 0.25)),
                      ),
                      child: Text(
                        r.type,
                        style: TextStyle(
                          fontSize: 11,
                          letterSpacing: 1,
                          color: col,
                        ),
                      ),
                    ),
                    r.done
                        ? const Text(
                            '✔ Completada',
                            style: TextStyle(fontSize: 11, color: _C.accent5),
                          )
                        : Text(
                            r.date,
                            style: const TextStyle(
                              fontSize: 11,
                              color: _C.muted,
                            ),
                          ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  r.name,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1,
                    color: _C.text,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '👤 ${r.athlete}',
                  style: const TextStyle(fontSize: 12, color: _C.muted),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 14,
                  runSpacing: 4,
                  children: [
                    Text(
                      '⏰ ${r.hour}',
                      style: const TextStyle(fontSize: 12, color: _C.muted),
                    ),
                    Text(
                      '⏱ ${r.dur}',
                      style: const TextStyle(fontSize: 12, color: _C.muted),
                    ),
                    Text(
                      '⚡ ${r.intensity}/10',
                      style: const TextStyle(fontSize: 12, color: _C.muted),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 5,
                  runSpacing: 5,
                  children: [
                    for (final e in r.exs.take(4)) _MiniTag(e, big: true),
                    if (r.exs.length > 4)
                      _MiniTag('+${r.exs.length - 4}', big: true),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Intensidad',
                            style: TextStyle(fontSize: 10, color: _C.muted),
                          ),
                          const SizedBox(height: 3),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(99),
                            child: LinearProgressIndicator(
                              value: r.intensity / 10,
                              minHeight: 4,
                              backgroundColor: Colors.white12,
                              valueColor: AlwaysStoppedAnimation(
                                _iCol(r.intensity),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    _ActBtn('✔', _C.accent5, () {
                      setState(
                        () => _routines = [
                          for (final x in _routines)
                            x.id == r.id ? x.copyWith(done: !x.done) : x,
                        ],
                      );
                    }),
                    const SizedBox(width: 6),
                    _ActBtn('✏️', _C.accent2, () => _edit(r)),
                    const SizedBox(width: 6),
                    _ActBtn('🗑', _C.accent3, () {
                      setState(
                        () => _routines = _routines
                            .where((x) => x.id != r.id)
                            .toList(),
                      );
                      _toast('"${r.name}" eliminada');
                    }),
                  ],
                ),
              ],
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

InputDecoration _inputDeco(String hint) => InputDecoration(
  isDense: true,
  filled: true,
  fillColor: _C.card2,
  hintText: hint,
  hintStyle: const TextStyle(color: _C.muted, fontSize: 13),
  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
  border: OutlineInputBorder(
    borderRadius: BorderRadius.circular(9),
    borderSide: const BorderSide(color: _C.border),
  ),
  enabledBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(9),
    borderSide: const BorderSide(color: _C.border),
  ),
  focusedBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(9),
    borderSide: const BorderSide(color: _C.accent),
  ),
);

class _CardTitle extends StatelessWidget {
  final String icon, title;
  const _CardTitle({required this.icon, required this.title});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Row(
      children: [
        Text(icon, style: const TextStyle(fontSize: 18)),
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            title.toUpperCase(),
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.5,
              color: _C.text,
            ),
          ),
        ),
      ],
    ),
  );
}

class _Label extends StatelessWidget {
  final String text;
  const _Label(this.text);

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 5),
    child: Text(
      text.toUpperCase(),
      style: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        letterSpacing: 1,
        color: _C.muted,
      ),
    ),
  );
}

class _TimeBox extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final int max;
  const _TimeBox({
    required this.label,
    required this.controller,
    required this.max,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            letterSpacing: 1,
            color: _C.muted,
          ),
        ),
        const SizedBox(height: 4),
        SizedBox(
          width: 60,
          child: TextField(
            controller: controller,
            textAlign: TextAlign.center,
            keyboardType: TextInputType.number,
            maxLength: 2,
            style: const TextStyle(
              color: _C.text,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
            decoration: _inputDeco('').copyWith(
              counterText: '',
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 4,
                vertical: 8,
              ),
            ),
            onChanged: (v) {
              final n = int.tryParse(v);
              if (n != null && n > max) controller.text = '$max';
            },
          ),
        ),
      ],
    );
  }
}

class _Pill extends StatelessWidget {
  final String text;
  final bool selected;
  final VoidCallback onTap;
  const _Pill({
    required this.text,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? _C.accent.withValues(alpha: 0.2) : _C.card2,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: selected ? _C.accent : _C.border),
        ),
        child: Text(
          text,
          style: TextStyle(fontSize: 12, color: selected ? _C.text : _C.muted),
        ),
      ),
    );
  }
}

class _MiniTag extends StatelessWidget {
  final String text;
  final Color? color;
  final bool big;
  const _MiniTag(this.text, {this.color, this.big = false});

  @override
  Widget build(BuildContext context) => Container(
    padding: EdgeInsets.symmetric(
      horizontal: big ? 9 : 7,
      vertical: big ? 3 : 2,
    ),
    decoration: BoxDecoration(
      color: Colors.white.withValues(alpha: big ? 0.05 : 0.06),
      borderRadius: BorderRadius.circular(10),
    ),
    child: Text(
      text,
      style: TextStyle(fontSize: big ? 11 : 10, color: color ?? _C.muted),
    ),
  );
}

class _ActBtn extends StatelessWidget {
  final String icon;
  final Color color;
  final VoidCallback onTap;
  const _ActBtn(this.icon, this.color, this.onTap);

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(8),
    child: Container(
      width: 30,
      height: 30,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _C.border),
      ),
      child: Text(icon, style: const TextStyle(fontSize: 14)),
    ),
  );
}

class _RingPainter extends CustomPainter {
  final double value;
  final Color color;
  _RingPainter(this.value, this.color);

  @override
  void paint(Canvas canvas, Size size) {
    const sw = 7.0;
    final rect = (Offset.zero & size).deflate(sw / 2 + 3);
    canvas.drawArc(
      rect,
      0,
      math.pi * 2,
      false,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.06)
        ..style = PaintingStyle.stroke
        ..strokeWidth = sw,
    );
    canvas.drawArc(
      rect,
      -math.pi / 2,
      math.pi * 2 * value,
      false,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = sw
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(covariant _RingPainter o) =>
      o.value != value || o.color != color;
}
