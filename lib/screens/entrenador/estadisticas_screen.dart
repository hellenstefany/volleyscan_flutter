import 'dart:math' as math;
import 'package:flutter/material.dart';

// ── Colores (variables CSS) ──
const _bg = Color(0xFF0D0F1A);
const _panel2 = Color(0xFF181C30);
const _border = Color(0x12FFFFFF);
const _accent = Color(0xFF7C5CFC);
const _accent2 = Color(0xFF00D4FF);
const _accent3 = Color(0xFFFF6B6B);
const _accent4 = Color(0xFFF7B731);
const _accent5 = Color(0xFF26DE81);
const _text = Color(0xFFE8EAF6);
const _muted = Color(0xFF7A7F9A);

// ── Modelos / datos ──
class _Player {
  final String name;
  final int perf;
  final int attendance;
  final Color color;
  final List<Color> gradient;
  const _Player(
    this.name,
    this.perf,
    this.attendance,
    this.color,
    this.gradient,
  );
}

class _Series {
  final String name;
  final Color color;
  final List<int> values;
  const _Series(this.name, this.color, this.values);
}

class _Item {
  final String name;
  final int pct;
  final Color color;
  const _Item(this.name, this.pct, this.color);
}

const _players = [
  _Player('Juan', 88, 92, _accent, [Color(0xFF7C5CFC), Color(0xFFA488FF)]),
  _Player('María', 82, 92, _accent4, [Color(0xFFF7B731), Color(0xFFFFD470)]),
  _Player('Carlos', 74, 92, _accent5, [Color(0xFF26DE81), Color(0xFF5EF5A0)]),
  _Player('Sofía', 65, 92, _accent2, [Color(0xFF00D4FF), Color(0xFF7EEEFF)]),
  _Player('Andrés', 60, 92, _accent3, [Color(0xFFFF6B6B), Color(0xFFFF9F9F)]),
];

const _dates = ['4 May', '7 May', '10 May', '13 May', '16 May'];

const _evolution = [
  _Series('Juan', _accent, [72, 80, 78, 85, 90]),
  _Series('María', _accent4, [65, 70, 68, 72, 69]),
  _Series('Carlos', _accent5, [55, 62, 60, 58, 65]),
];

const _exercisesAll = [
  _Item('Saque', 35, _accent),
  _Item('Recepción', 25, _accent2),
  _Item('Remate', 20, _accent4),
  _Item('Bloqueo', 20, _accent3),
];

const _exerciseOverrides = {
  'Juan': [
    _Item('Saque', 50, _accent),
    _Item('Remate', 30, _accent4),
    _Item('Recepción', 20, _accent2),
  ],
  'María': [
    _Item('Recepción', 45, _accent2),
    _Item('Bloqueo', 35, _accent3),
    _Item('Saque', 20, _accent),
  ],
  'Carlos': [
    _Item('Remate', 40, _accent4),
    _Item('Bloqueo', 35, _accent3),
    _Item('Saque', 25, _accent),
  ],
};

const _errors = [
  _Item('Postura incorrecta', 32, _accent3),
  _Item('Brazo bajo en saque', 28, _accent3),
  _Item('Piernas semiflexionadas', 20, _accent4),
  _Item('Falta de coordinación', 20, _accent4),
];

const _errorOffsets = {
  'Juan': 5,
  'María': -3,
  'Carlos': 2,
  'Sofía': -5,
  'Andrés': 8,
};

// ── Pantalla ──
class EstadisticasScreen extends StatefulWidget {
  const EstadisticasScreen({super.key});

  @override
  State<EstadisticasScreen> createState() => _EstadisticasScreenState();
}

class _EstadisticasScreenState extends State<EstadisticasScreen> {
  String _deportista = 'all';
  String _ejercicio = 'all';
  final _searchCtrl = TextEditingController();
  final Set<String> _hidden = {};
  String? _chartTip;

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  String get _search => _searchCtrl.text.trim().toLowerCase();

  List<_Player> get _filteredPlayers => _players
      .where(
        (p) =>
            (_deportista == 'all' || p.name == _deportista) &&
            (_search.isEmpty || p.name.toLowerCase().contains(_search)),
      )
      .toList();

  List<_Item> get _filteredExercises {
    final base = _exerciseOverrides[_deportista] ?? _exercisesAll;
    return _ejercicio == 'all'
        ? base
        : base.where((e) => e.name == _ejercicio).toList();
  }

  List<_Series> get _filteredSeries => _evolution
      .where(
        (s) =>
            (_deportista == 'all' || s.name == _deportista) &&
            (_search.isEmpty || s.name.toLowerCase().contains(_search)),
      )
      .toList();

  void _reset() {
    setState(() {
      _deportista = 'all';
      _ejercicio = 'all';
      _searchCtrl.clear();
      _chartTip = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final players = _filteredPlayers;
    final exercises = _filteredExercises;
    final series = _filteredSeries;

    final avgPerf = players.isEmpty
        ? 0
        : (players.fold<int>(0, (a, p) => a + p.perf) / players.length).round();
    final avgAtt = players.isEmpty
        ? 0
        : (players.fold<int>(0, (a, p) => a + p.attendance) / players.length)
              .round();

    final screenW = MediaQuery.of(context).size.width;
    // En móvil dejamos espacio para el botón flotante del menú
    final topPad = screenW < 900 ? 60.0 : 30.0;

    return Material(
      color: _bg,
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
          screenW < 900 ? 12 : 32,
          topPad,
          screenW < 900 ? 12 : 32,
          24,
        ),
        child: LayoutBuilder(
          builder: (context, c) {
            final w = c.maxWidth;
            final wide = w >= 1100;
            final mid = w >= 700;

            final barCard = _Card(
              title: 'Rendimiento promedio',
              child: _buildBarChart(players),
            );
            final lineCard = _Card(
              title: 'Evolución de rendimiento',
              child: _buildLineChart(series),
            );
            final donutCard = _Card(
              title: 'Asistencia',
              child: _buildDonut(avgAtt),
            );
            final exCard = _Card(
              title: 'Tipos de ejercicios',
              child: _buildExercises(exercises),
            );
            final errCard = _Card(
              title: 'Errores comunes',
              child: _buildErrors(),
            );

            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'ESTADÍSTICAS AVANZADAS',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: screenW < 900 ? 18 : 26,
                    fontWeight: FontWeight.w700,
                    letterSpacing: screenW < 900 ? 0 : 2,
                    color: _text,
                  ),
                ),
                const SizedBox(height: 24),
                _buildFilters(w),
                const SizedBox(height: 26),
                _buildMiniCards(w, avgPerf, avgAtt, players.length),
                const SizedBox(height: 18),

                // grid-top
                if (wide)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(flex: 10, child: barCard),
                      const SizedBox(width: 18),
                      Expanded(flex: 14, child: lineCard),
                    ],
                  )
                else ...[
                  barCard,
                  const SizedBox(height: 14),
                  lineCard,
                ],
                const SizedBox(height: 18),

                // grid-bottom
                if (wide)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(flex: 10, child: donutCard),
                      const SizedBox(width: 18),
                      Expanded(flex: 11, child: exCard),
                      const SizedBox(width: 18),
                      Expanded(flex: 13, child: errCard),
                    ],
                  )
                else if (mid) ...[
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: donutCard),
                      const SizedBox(width: 14),
                      Expanded(child: exCard),
                    ],
                  ),
                  const SizedBox(height: 14),
                  errCard,
                ] else ...[
                  donutCard,
                  const SizedBox(height: 14),
                  exCard,
                  const SizedBox(height: 14),
                  errCard,
                ],
              ],
            );
          },
        ),
      ),
    );
  }

  // ── Filtros ──
  Widget _buildFilters(double w) {
    final fieldW = w < 500 ? w : 200.0;
    return Wrap(
      spacing: 14,
      runSpacing: 14,
      crossAxisAlignment: WrapCrossAlignment.end,
      children: [
        _FilterGroup(
          label: 'DEPORTISTA',
          width: fieldW,
          child: _dropdown(
            value: _deportista,
            items: ['all', ..._players.map((p) => p.name)],
            onChanged: (v) => setState(() => _deportista = v),
          ),
        ),
        _FilterGroup(
          label: 'TIPO DE EJERCICIO',
          width: fieldW,
          child: _dropdown(
            value: _ejercicio,
            items: const ['all', 'Saque', 'Recepción', 'Remate', 'Bloqueo'],
            onChanged: (v) => setState(() => _ejercicio = v),
          ),
        ),
        _FilterGroup(
          label: 'BUSCAR',
          width: fieldW,
          child: Container(
            height: 40,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: _fieldDecoration(),
            child: TextField(
              controller: _searchCtrl,
              onChanged: (_) => setState(() {}),
              style: const TextStyle(color: _text, fontSize: 13),
              cursorColor: _accent,
              decoration: const InputDecoration(
                hintText: 'Nombre...',
                hintStyle: TextStyle(color: _muted, fontSize: 13),
                border: InputBorder.none,
                isCollapsed: true,
                contentPadding: EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ),
        OutlinedButton(
          onPressed: _reset,
          style: OutlinedButton.styleFrom(
            foregroundColor: _muted,
            side: const BorderSide(color: _border),
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

  BoxDecoration _fieldDecoration() => BoxDecoration(
    color: _panel2,
    borderRadius: BorderRadius.circular(8),
    border: Border.all(color: _border),
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
          icon: const Icon(Icons.keyboard_arrow_down, color: _muted, size: 18),
          style: const TextStyle(color: _text, fontSize: 13),
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

  // ── Mini cards ──
  Widget _buildMiniCards(double w, int avgPerf, int avgAtt, int active) {
    final cards = [
      ('Rendimiento promedio', '$avgPerf%', '+3.2%', true, _accent),
      ('Asistencia promedio', '$avgAtt%', '-1.1%', false, _accent2),
      ('Deportistas activos', '$active', '$active de 5', true, _accent5),
      ('Sesiones registradas', '24', '+4 este mes', true, _accent4),
    ];
    final cols = w >= 700 ? 4 : 2;
    const gap = 14.0;
    final itemW = (w - gap * (cols - 1)) / cols;

    return Wrap(
      spacing: gap,
      runSpacing: gap,
      children: cards.map((c) {
        final up = c.$4;
        return Container(
          width: itemW,
          padding: EdgeInsets.all(w < 900 ? 12 : 16),
          decoration: BoxDecoration(
            color: _panel2,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: _border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                c.$1,
                style: const TextStyle(
                  fontSize: 11,
                  color: _muted,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                c.$2,
                style: TextStyle(
                  fontSize: w < 900 ? 24 : 28,
                  fontWeight: FontWeight.w700,
                  height: 1,
                  color: c.$5,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${up ? '▲' : '▼'} ${c.$3}',
                style: TextStyle(fontSize: 11, color: up ? _accent5 : _accent3),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  // ── Gráfica de barras ──
  Widget _buildBarChart(List<_Player> players) {
    const chartH = 110.0;
    if (players.isEmpty) return const _NoData(icon: '📊');

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // Eje Y
        SizedBox(
          height: chartH,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: ['100%', '75%', '50%', '25%', '0%']
                .map(
                  (l) => Text(
                    l,
                    style: const TextStyle(
                      fontSize: 10,
                      color: _muted,
                      height: 1,
                    ),
                  ),
                )
                .toList(),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: players.map((p) {
              final h = p.perf / 100 * chartH;
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 7),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${p.perf}%',
                        style: const TextStyle(fontSize: 11, color: _muted),
                      ),
                      const SizedBox(height: 6),
                      SizedBox(
                        height: chartH,
                        child: Align(
                          alignment: Alignment.bottomCenter,
                          child: Tooltip(
                            message: '${p.name}: ${p.perf}%',
                            child: Container(
                              height: h,
                              decoration: BoxDecoration(
                                borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(6),
                                  bottom: Radius.circular(2),
                                ),
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    p.gradient[0],
                                    p.gradient[1].withOpacity(0.7),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        p.name,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 12, color: _muted),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  // ── Gráfica de líneas ──
  Widget _buildLineChart(List<_Series> series) {
    final visible = series.where((s) => !_hidden.contains(s.name)).toList();
    final vals = series.expand((s) => s.values).toList();
    final minV = vals.isEmpty ? 0.0 : vals.reduce(math.min) - 5.0;
    final maxV = vals.isEmpty ? 100.0 : vals.reduce(math.max) + 5.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LayoutBuilder(
          builder: (context, c) {
            final painter = _LinePainter(
              series: visible,
              dates: _dates,
              minV: minV,
              maxV: maxV,
            );
            return GestureDetector(
              onTapDown: (d) {
                final hit = painter.findPoint(
                  d.localPosition,
                  Size(c.maxWidth, 150),
                );
                setState(() => _chartTip = hit);
              },
              child: CustomPaint(size: Size(c.maxWidth, 150), painter: painter),
            );
          },
        ),
        if (_chartTip != null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFF1E2235),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: _border),
              ),
              child: Text(
                _chartTip!,
                style: const TextStyle(fontSize: 12, color: _text),
              ),
            ),
          ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 16,
          runSpacing: 8,
          children: series.map((s) {
            final hidden = _hidden.contains(s.name);
            return GestureDetector(
              onTap: () => setState(() {
                hidden ? _hidden.remove(s.name) : _hidden.add(s.name);
              }),
              child: Opacity(
                opacity: hidden ? 0.4 : 1,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: s.color,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      s.name,
                      style: const TextStyle(fontSize: 12, color: _muted),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  // ── Dona ──
  Widget _buildDonut(int avgAtt) {
    return SizedBox(
      height: 160,
      child: Center(
        child: SizedBox(
          width: 160,
          height: 160,
          child: Stack(
            alignment: Alignment.center,
            children: [
              CustomPaint(
                size: const Size(160, 160),
                painter: _DonutPainter(avgAtt / 100),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '$avgAtt%',
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w700,
                      height: 1,
                      color: _text,
                    ),
                  ),
                  const SizedBox(height: 2),
                  const Text(
                    'Promedio',
                    style: TextStyle(fontSize: 11, color: _muted),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Tipos de ejercicio ──
  Widget _buildExercises(List<_Item> exercises) {
    if (exercises.isEmpty) return const _NoData(icon: '🏐');
    return Column(
      children: exercises
          .map(
            (e) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: e.color,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      e.name,
                      style: const TextStyle(fontSize: 13, color: _text),
                    ),
                  ),
                  Text(
                    '${e.pct}%',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: _muted,
                    ),
                  ),
                ],
              ),
            ),
          )
          .toList(),
    );
  }

  // ── Errores comunes ──
  Widget _buildErrors() {
    final off = _errorOffsets[_deportista] ?? 0;
    return Column(
      children: _errors.map((e) {
        final pct = (e.pct + off).clamp(5, 99);
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Text(
                      e.name,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 12, color: _text),
                    ),
                  ),
                  Text(
                    '$pct%',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: _text,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              ClipRRect(
                borderRadius: BorderRadius.circular(99),
                child: Container(
                  height: 5,
                  color: Colors.white.withOpacity(0.07),
                  alignment: Alignment.centerLeft,
                  child: FractionallySizedBox(
                    widthFactor: pct / 100,
                    child: Container(color: e.color),
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

// ── Widgets auxiliares ──
class _Card extends StatelessWidget {
  final String title;
  final Widget child;
  const _Card({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _border),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color.alphaBlend(_accent.withOpacity(0.04), _panel2),
            _panel2,
          ],
          stops: const [0, 0.6],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title.toUpperCase(),
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              letterSpacing: 1,
              color: _text,
            ),
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}

class _FilterGroup extends StatelessWidget {
  final String label;
  final double width;
  final Widget child;
  const _FilterGroup({
    required this.label,
    required this.width,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              color: _muted,
              letterSpacing: 1,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 5),
          child,
        ],
      ),
    );
  }
}

class _NoData extends StatelessWidget {
  final String icon;
  const _NoData({required this.icon});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 120,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(icon, style: const TextStyle(fontSize: 24)),
            const SizedBox(height: 8),
            const Text(
              'Sin datos',
              style: TextStyle(fontSize: 13, color: _muted),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Painter: gráfica de líneas ──
class _LinePainter extends CustomPainter {
  final List<_Series> series;
  final List<String> dates;
  final double minV;
  final double maxV;

  static const padL = 34.0, padR = 10.0, padT = 10.0, padB = 30.0;

  _LinePainter({
    required this.series,
    required this.dates,
    required this.minV,
    required this.maxV,
  });

  double _x(int i, Size s) =>
      padL + (i / (dates.length - 1)) * (s.width - padL - padR);

  double _y(num v, Size s) {
    final cH = s.height - padT - padB;
    return padT + cH - ((v - minV) / (maxV - minV)) * cH;
  }

  void _text(Canvas canvas, String t, Offset pos, TextAlign align) {
    final tp = TextPainter(
      text: TextSpan(
        text: t,
        style: const TextStyle(color: _muted, fontSize: 9),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    double dx = pos.dx;
    if (align == TextAlign.right) dx -= tp.width;
    if (align == TextAlign.center) dx -= tp.width / 2;
    tp.paint(canvas, Offset(dx, pos.dy - tp.height / 2));
  }

  @override
  void paint(Canvas canvas, Size size) {
    final cH = size.height - padT - padB;

    // Rejilla + etiquetas Y
    final grid = Paint()
      ..color = Colors.white.withOpacity(0.05)
      ..strokeWidth = 1;
    for (final t in [0.0, 0.25, 0.5, 0.75, 1.0]) {
      final y = padT + cH * (1 - t);
      canvas.drawLine(Offset(padL, y), Offset(size.width - padR, y), grid);
      _text(
        canvas,
        '${(minV + t * (maxV - minV)).round()}%',
        Offset(padL - 4, y),
        TextAlign.right,
      );
    }

    // Etiquetas X
    for (var i = 0; i < dates.length; i++) {
      _text(
        canvas,
        dates[i],
        Offset(_x(i, size), size.height - 6),
        TextAlign.center,
      );
    }

    // Series
    for (final s in series) {
      final pts = s.values.take(dates.length).toList();
      final line = Path();
      for (var i = 0; i < pts.length; i++) {
        final p = Offset(_x(i, size), _y(pts[i], size));
        i == 0 ? line.moveTo(p.dx, p.dy) : line.lineTo(p.dx, p.dy);
      }

      final area = Path.from(line)
        ..lineTo(_x(pts.length - 1, size), padT + cH)
        ..lineTo(_x(0, size), padT + cH)
        ..close();

      canvas.drawPath(
        area,
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [s.color.withOpacity(0.25), s.color.withOpacity(0)],
          ).createShader(Rect.fromLTWH(0, padT, size.width, cH)),
      );

      canvas.drawPath(
        line,
        Paint()
          ..color = s.color
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2
          ..strokeJoin = StrokeJoin.round
          ..strokeCap = StrokeCap.round,
      );

      for (var i = 0; i < pts.length; i++) {
        final c = Offset(_x(i, size), _y(pts[i], size));
        canvas.drawCircle(c, 4, Paint()..color = s.color);
        canvas.drawCircle(
          c,
          4,
          Paint()
            ..color = _panel2
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2,
        );
      }
    }
  }

  /// Devuelve el texto del punto más cercano al toque (o null).
  String? findPoint(Offset pos, Size size) {
    double best = 18;
    String? result;
    for (final s in series) {
      final pts = s.values.take(dates.length).toList();
      for (var i = 0; i < pts.length; i++) {
        final d = (Offset(_x(i, size), _y(pts[i], size)) - pos).distance;
        if (d < best) {
          best = d;
          result = '${s.name} (${dates[i]}): ${pts[i]}%';
        }
      }
    }
    return result;
  }

  @override
  bool shouldRepaint(covariant _LinePainter old) => true;
}

// ── Painter: dona ──
class _DonutPainter extends CustomPainter {
  final double progress;
  _DonutPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    const sw = 16.0;
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width / 2) - sw / 2 - 12; // equivale a r=60 en 160px
    final rect = Rect.fromCircle(center: center, radius: radius);

    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = Colors.white.withOpacity(0.06)
        ..style = PaintingStyle.stroke
        ..strokeWidth = sw,
    );

    canvas.drawArc(
      rect,
      -math.pi / 2,
      2 * math.pi * progress,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = sw
        ..strokeCap = StrokeCap.round
        ..shader = const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [_accent, _accent5],
        ).createShader(Rect.fromLTWH(0, 0, size.width, size.height)),
    );
  }

  @override
  bool shouldRepaint(covariant _DonutPainter old) => old.progress != progress;
}
