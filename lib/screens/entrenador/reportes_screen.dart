import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';

// ───────── Colores (de tu :root) ─────────
class _C {
  static const bg = Color(0xFF0D0F1A);
  static const card = Color(0xFF0E1525);
  static const card2 = Color(0xFF121D30);
  static const hover = Color(0xFF1A2540);
  static const blue = Color(0xFF3B82F6);
  static const blue2 = Color(0xFF60A5FA);
  static const purple = Color(0xFF6D28D9);
  static const purple2 = Color(0xFF8B5CF6);
  static const green = Color(0xFF10B981);
  static const green2 = Color(0xFF059669); // aprox. (--green2)
  static const red = Color(0xFFEF4444);
  static const mint = Color(0xFF22D3A5);
  static const t1 = Color(0xFFEEF4FF);
  static const t2 = Color(0xFF7A90B8);
  static const t3 = Color(0xFF374A6E);
  static const border = Color(0x14FFFFFF); // aprox. (--border)
}

// ───────── Datos ─────────
class _Dep {
  final int perf, asis, ses, errores, ejercicios;
  final List<double> spark;
  const _Dep(
    this.perf,
    this.asis,
    this.ses,
    this.errores,
    this.ejercicios,
    this.spark,
  );
}

const _data = <String, _Dep>{
  'Juan Pérez': _Dep(85, 92, 24, 8, 47, [60, 65, 70, 68, 78, 82, 85]),
  'María González': _Dep(78, 88, 20, 12, 38, [55, 58, 62, 65, 70, 75, 78]),
  'Carlos Ramírez': _Dep(91, 96, 30, 4, 60, [75, 80, 82, 85, 88, 90, 91]),
  'Sofía Ortega': _Dep(62, 70, 12, 20, 25, [45, 48, 50, 55, 57, 60, 62]),
  'Andrés López': _Dep(80, 90, 22, 9, 44, [60, 65, 68, 72, 75, 78, 80]),
};

const _recs = <String, List<String>>{
  'Juan Pérez': [
    'Aumentar series de bloqueo',
    'Reforzar recepción en diagonal',
    'Trabajar posición de ataque Z4',
  ],
  'María González': [
    'Mejorar velocidad de reacción',
    'Consolidar defensa de pipe',
    'Ejercicios de salto vertical',
  ],
  'Carlos Ramírez': [
    'Mantener rutina de fuerza',
    'Explorar variantes de saque float',
    'Liderazgo en sistema 6-2',
  ],
  'Sofía Ortega': [
    'Recuperar consistencia en asistencia',
    'Repasar fundamentos de armado',
    'Sesiones de confianza mental',
  ],
  'Andrés López': [
    'Mejorar recepción en zona 1',
    'Trabajar coordinación con armadora',
    'Fortalecer tren superior',
  ],
};

String _fmtDisp(DateTime d) =>
    '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

// ───────── Pantalla ─────────
class ReportesScreen extends StatefulWidget {
  const ReportesScreen({super.key});

  @override
  State<ReportesScreen> createState() => _ReportesScreenState();
}

class _ReportesScreenState extends State<ReportesScreen> {
  int _step = 1;
  String _tipo = 'Individual';
  String _dep = 'Juan Pérez';
  late DateTime _from;
  late DateTime _to;
  final Map<String, bool> _checks = {
    'Rendimiento': true,
    'Asistencia': true,
    'Ejercicios': true,
    'Errores': true,
    'Recomendaciones': true,
  };
  String _fmt = 'pdf';
  int _progress = 0;
  String _progressLabel = '';
  bool _exporting = false;
  bool _exportDone = false;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _to = DateTime.now();
    _from = _to.subtract(const Duration(days: 17));
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  _Dep get _d => _data[_dep] ?? _data['Juan Pérez']!;
  String get _fileName =>
      'reporte_${_dep.replaceAll(' ', '_').toLowerCase()}.$_fmt';

  void _toast(String msg) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          duration: const Duration(milliseconds: 3200),
          behavior: SnackBarBehavior.floating,
          backgroundColor: _C.card2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: _C.border),
          ),
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: _C.green, size: 18),
              const SizedBox(width: 10),
              Expanded(
                child: Text(msg, style: const TextStyle(color: _C.t1)),
              ),
            ],
          ),
        ),
      );
  }

  void _goStep(int n) {
    if (n > _step && _step == 1 && _from.isAfter(_to)) {
      _toast('La fecha inicio debe ser antes del fin');
      return;
    }
    setState(() {
      _step = n;
      if (n == 3) {
        _progress = 0;
        _exporting = false;
        _exportDone = false;
      }
    });
  }

  void _reset() {
    setState(() {
      _tipo = 'Individual';
      _dep = 'Juan Pérez';
      _to = DateTime.now();
      _from = _to.subtract(const Duration(days: 17));
      for (final k in _checks.keys) {
        _checks[k] = true;
      }
    });
    _toast('Filtros restablecidos');
  }

  void _doExport() {
    setState(() {
      _exporting = true;
      _exportDone = false;
      _progress = 0;
      _progressLabel = '';
    });
    const labels = [
      'Recopilando datos...',
      'Generando estadísticas...',
      'Aplicando formato...',
      'Finalizando...',
    ];
    final rnd = math.Random();
    double p = 0;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(milliseconds: 120), (t) {
      p = math.min(p + rnd.nextDouble() * 12 + 3, 100);
      setState(() {
        _progress = p.round();
        final i = math.min((p / 25).floor(), labels.length - 1);
        _progressLabel = labels[i];
      });
      if (p >= 100) {
        t.cancel();
        Future.delayed(const Duration(milliseconds: 400), () {
          if (!mounted) return;
          setState(() {
            _exporting = false;
            _exportDone = true;
          });
          _toast('Reporte exportado exitosamente ✓');
        });
      }
    });
  }

  Future<void> _pickDate(bool isFrom) async {
    final d = await showDatePicker(
      context: context,
      initialDate: isFrom ? _from : _to,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (d != null) setState(() => isFrom ? _from = d : _to = d);
  }

  List<(String, String, Color)> get _stats => [
    if (_checks['Rendimiento']!)
      ('${_d.perf}%', 'Rendimiento promedio', _C.green),
    if (_checks['Asistencia']!) ('${_d.asis}%', 'Asistencia', _C.blue2),
    if (_checks['Ejercicios']!)
      ('${_d.ejercicios}', 'Ejercicios completados', _C.purple2),
    if (_checks['Errores']!) ('${_d.errores}', 'Errores registrados', _C.red),
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      // arriba: espacio para el botón de menú; abajo: para la barra inferior
      padding: const EdgeInsets.fromLTRB(16, 56, 16, 110),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'REPORTES',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.4,
              color: _C.t1,
            ),
          ),
          const SizedBox(height: 22),
          _stepper(),
          const SizedBox(height: 26),
          if (_step == 1) _step1(),
          if (_step == 2) _step2(),
          if (_step == 3) _step3(),
        ],
      ),
    );
  }

  // ───────── Stepper ─────────
  Widget _stepper() {
    const labels = ['Filtros', 'Vista previa', 'Exportar'];
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: _box(_C.card2, 14),
      child: Row(
        children: [
          for (var i = 0; i < 3; i++) ...[
            Expanded(
              child: InkWell(
                onTap: () => _goStep(i + 1),
                child: Row(
                  children: [
                    _StepNum(
                      n: i + 1,
                      active: _step == i + 1,
                      done: _step > i + 1,
                    ),
                    const SizedBox(width: 9),
                    Flexible(
                      child: Text(
                        labels[i],
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: _step == i + 1
                              ? _C.t1
                              : _step > i + 1
                              ? _C.green
                              : _C.t3,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (i < 2)
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: Icon(Icons.chevron_right, size: 16, color: _C.t3),
              ),
          ],
        ],
      ),
    );
  }

  // ───────── PASO 1 ─────────
  Widget _step1() {
    return LayoutBuilder(
      builder: (context, c) {
        final ancho = c.maxWidth >= 800;
        final filtros = _filtrosPanel();
        final preview = _previewCard();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (ancho)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: filtros),
                  const SizedBox(width: 18),
                  Expanded(child: preview),
                ],
              )
            else ...[
              filtros,
              const SizedBox(height: 18),
              preview,
            ],
            const SizedBox(height: 18),
            Wrap(
              alignment: WrapAlignment.end,
              spacing: 10,
              runSpacing: 10,
              children: [
                _SecButton(
                  icon: Icons.restart_alt,
                  label: 'Restablecer',
                  onTap: _reset,
                ),
                _PriButton(
                  icon: Icons.visibility,
                  label: 'Vista previa',
                  onTap: () => _goStep(2),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _filtrosPanel() {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: _box(_C.card2, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _FieldLabel('Tipo de reporte'),
          for (final t in ['Individual', 'Grupal', 'Por fechas'])
            _RadioOpt(
              label: t,
              selected: _tipo == t,
              onTap: () => setState(() => _tipo = t),
            ),
          const SizedBox(height: 18),
          if (_tipo == 'Individual') ...[
            const _FieldLabel('Deportista'),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: _C.hover,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: _C.border),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _dep,
                  isExpanded: true,
                  dropdownColor: _C.hover,
                  style: const TextStyle(color: _C.t1, fontSize: 13),
                  icon: const Icon(Icons.arrow_drop_down, color: _C.t2),
                  items: [
                    for (final k in _data.keys)
                      DropdownMenuItem(value: k, child: Text(k)),
                  ],
                  onChanged: (v) => setState(() => _dep = v ?? _dep),
                ),
              ),
            ),
          ],
          const _FieldLabel('Rango de fechas'),
          Row(
            children: [
              Expanded(
                child: _DateBox(
                  text: _fmtDisp(_from),
                  onTap: () => _pickDate(true),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _DateBox(
                  text: _fmtDisp(_to),
                  onTap: () => _pickDate(false),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          const _FieldLabel('Incluir'),
          for (final k in _checks.keys)
            _CheckOpt(
              label: k,
              value: _checks[k]!,
              onTap: () => setState(() => _checks[k] = !_checks[k]!),
            ),
        ],
      ),
    );
  }

  Widget _previewCard() {
    final d = _d;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: _box(_C.card, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Reporte $_tipo',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: _C.t1,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _tipo == 'Grupal' ? 'Todos los deportistas' : _dep,
            style: const TextStyle(fontSize: 11.5, color: _C.t2),
          ),
          const SizedBox(height: 2),
          Text(
            '${_fmtDisp(_from)} – ${_fmtDisp(_to)}',
            style: const TextStyle(fontSize: 11, color: _C.t3),
          ),
          const SizedBox(height: 16),
          if (_checks['Rendimiento']!)
            Center(
              child: _Donut(
                size: 140,
                stroke: 14,
                value: d.perf / 100,
                center: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${d.perf}%',
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const Text(
                      'Rendimiento',
                      style: TextStyle(fontSize: 9, color: _C.t2),
                    ),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_checks['Asistencia']!)
                Expanded(
                  child: _MiniStat(
                    label: 'Asistencia',
                    child: Center(
                      child: _Donut(
                        size: 60,
                        stroke: 7,
                        value: d.asis / 100,
                        center: Text(
                          '${d.asis}%',
                          style: const TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              if (_checks['Asistencia']!) const SizedBox(width: 10),
              Expanded(
                child: _MiniStat(
                  label: 'Sesiones',
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        '${d.ses}',
                        style: const TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _MiniStat(
            label: 'Evolución',
            child: SizedBox(
              height: 56,
              child: CustomPaint(
                size: Size.infinite,
                painter: _SparkPainter(d.spark),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ───────── PASO 2 ─────────
  Widget _step2() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.all(22),
          decoration: _box(_C.card2, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                runSpacing: 10,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Reporte $_tipo',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: _C.t1,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${_tipo == 'Grupal' ? 'Equipo completo' : _dep} · ${_fmtDisp(_from)} – ${_fmtDisp(_to)}',
                        style: const TextStyle(fontSize: 12, color: _C.t2),
                      ),
                    ],
                  ),
                  _SecButton(
                    icon: Icons.fullscreen,
                    label: 'Pantalla completa',
                    onTap: _showFullPreview,
                  ),
                ],
              ),
              const SizedBox(height: 18),
              _StatsGrid(stats: _stats),
              const SizedBox(height: 12),
              _MiniStat(
                label: 'Evolución del rendimiento',
                child: SizedBox(
                  height: 70,
                  child: CustomPaint(
                    size: Size.infinite,
                    painter: _SparkPainter(_d.spark),
                  ),
                ),
              ),
              if (_checks['Recomendaciones']!) ...[
                const SizedBox(height: 14),
                const _FieldLabel('Recomendaciones IA'),
                for (final r in _recs[_dep] ?? const <String>[])
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 9,
                    ),
                    decoration: BoxDecoration(
                      color: _C.hover,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.check_circle,
                          size: 13,
                          color: _C.green,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            r,
                            style: const TextStyle(
                              fontSize: 12.5,
                              color: _C.t1,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 18),
        Wrap(
          alignment: WrapAlignment.end,
          spacing: 10,
          runSpacing: 10,
          children: [
            _SecButton(
              icon: Icons.arrow_back,
              label: 'Volver',
              onTap: () => _goStep(1),
            ),
            _PriButton(
              icon: Icons.file_upload_outlined,
              label: 'Exportar',
              onTap: () => _goStep(3),
            ),
          ],
        ),
      ],
    );
  }

  void _showFullPreview() {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: _C.card2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: _C.border),
        ),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 540),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Reporte $_tipo',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: _C.t1,
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: () => Navigator.pop(ctx),
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: _C.hover,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.close, size: 16, color: _C.t2),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(_dep, style: const TextStyle(fontSize: 12, color: _C.t2)),
                const SizedBox(height: 16),
                _StatsGrid(stats: _stats),
                const SizedBox(height: 14),
                _MiniStat(
                  label: 'Evolución del rendimiento',
                  child: SizedBox(
                    height: 70,
                    child: CustomPaint(
                      size: Size.infinite,
                      painter: _SparkPainter(_d.spark),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ───────── PASO 3 ─────────
  Widget _step3() {
    const opts = [
      (
        'pdf',
        Icons.picture_as_pdf,
        Color(0xFFF87171),
        'PDF',
        'Documento portátil',
      ),
      ('csv', Icons.table_chart, Color(0xFF22D3A5), 'CSV', 'Hoja de cálculo'),
      ('json', Icons.code, Color(0xFF60A5FA), 'JSON', 'Datos estructurados'),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.all(22),
          decoration: _box(_C.card2, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Selecciona el formato de exportación',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: _C.t1,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                '$_tipo · $_dep · ${_fmtDisp(_from)} – ${_fmtDisp(_to)}',
                style: const TextStyle(fontSize: 12.5, color: _C.t2),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  for (var i = 0; i < opts.length; i++) ...[
                    Expanded(
                      child: InkWell(
                        onTap: () => setState(() => _fmt = opts[i].$1),
                        borderRadius: BorderRadius.circular(14),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            vertical: 18,
                            horizontal: 8,
                          ),
                          decoration: BoxDecoration(
                            color: _fmt == opts[i].$1
                                ? _C.purple2.withValues(alpha: 0.1)
                                : _C.card2,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: _fmt == opts[i].$1
                                  ? _C.purple2
                                  : _C.border,
                              width: 2,
                            ),
                          ),
                          child: Column(
                            children: [
                              Icon(opts[i].$2, size: 26, color: opts[i].$3),
                              const SizedBox(height: 8),
                              Text(
                                opts[i].$4,
                                style: const TextStyle(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w600,
                                  color: _C.t1,
                                ),
                              ),
                              Text(
                                opts[i].$5,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: _C.t3,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    if (i < opts.length - 1) const SizedBox(width: 12),
                  ],
                ],
              ),
              if (_exporting)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: Column(
                    children: [
                      Text(
                        _progressLabel.isEmpty
                            ? 'Generando reporte...'
                            : _progressLabel,
                        style: const TextStyle(fontSize: 13, color: _C.t2),
                      ),
                      const SizedBox(height: 12),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(99),
                        child: LinearProgressIndicator(
                          value: _progress / 100,
                          minHeight: 8,
                          backgroundColor: _C.hover,
                          valueColor: const AlwaysStoppedAnimation(_C.purple2),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        '$_progress%',
                        style: const TextStyle(fontSize: 12, color: _C.t3),
                      ),
                    ],
                  ),
                ),
              if (_exportDone)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: Center(
                    child: Column(
                      children: [
                        const Icon(
                          Icons.check_circle,
                          size: 36,
                          color: _C.green,
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          '¡Reporte exportado!',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: _C.t1,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '$_fileName listo',
                          style: const TextStyle(fontSize: 12.5, color: _C.t2),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        Wrap(
          alignment: WrapAlignment.end,
          spacing: 10,
          runSpacing: 10,
          children: [
            _SecButton(
              icon: Icons.arrow_back,
              label: 'Volver',
              onTap: () => _goStep(2),
            ),
            if (!_exportDone && !_exporting)
              _PriButton(
                icon: Icons.download,
                label: 'Exportar ahora',
                onTap: _doExport,
                colors: const [_C.green2, _C.green],
              ),
            if (_exportDone)
              _SecButton(
                label: '+ Nuevo reporte',
                onTap: () => setState(() {
                  _step = 1;
                  _exportDone = false;
                  _exporting = false;
                }),
              ),
          ],
        ),
      ],
    );
  }
}

// ───────── Helpers ─────────
BoxDecoration _box(Color c, double r) => BoxDecoration(
  color: c,
  borderRadius: BorderRadius.circular(r),
  border: Border.all(color: _C.border),
);

class _StepNum extends StatelessWidget {
  final int n;
  final bool active, done;
  const _StepNum({required this.n, required this.active, required this.done});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 26,
      height: 26,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: active
            ? const LinearGradient(colors: [_C.purple, _C.purple2])
            : null,
        color: active ? null : (done ? _C.green2 : _C.hover),
        border: Border.all(
          color: (active || done) ? Colors.transparent : _C.border,
          width: 1.5,
        ),
        boxShadow: active
            ? [
                BoxShadow(
                  color: const Color(0xFF7C3AED).withValues(alpha: 0.4),
                  blurRadius: 12,
                ),
              ]
            : null,
      ),
      child: Text(
        '$n',
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: (active || done) ? Colors.white : _C.t3,
        ),
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel(this.text);
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Text(
      text.toUpperCase(),
      style: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.8,
        color: _C.t2,
      ),
    ),
  );
}

class _RadioOpt extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _RadioOpt({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Row(
          children: [
            Container(
              width: 18,
              height: 18,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: selected ? _C.purple2 : _C.t3,
                  width: 2,
                ),
                boxShadow: selected
                    ? [
                        BoxShadow(
                          color: _C.purple2.withValues(alpha: 0.4),
                          blurRadius: 8,
                        ),
                      ]
                    : null,
              ),
              child: selected
                  ? Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: _C.purple2,
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 10),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                color: selected ? _C.t1 : _C.t2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CheckOpt extends StatelessWidget {
  final String label;
  final bool value;
  final VoidCallback onTap;
  const _CheckOpt({
    required this.label,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 9),
        child: Row(
          children: [
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: value ? _C.green2 : Colors.transparent,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: value ? _C.green2 : _C.t3, width: 2),
              ),
              child: value
                  ? const Icon(Icons.check, size: 13, color: Colors.white)
                  : null,
            ),
            const SizedBox(width: 10),
            Text(
              label,
              style: TextStyle(fontSize: 13, color: value ? _C.t1 : _C.t2),
            ),
          ],
        ),
      ),
    );
  }
}

class _DateBox extends StatelessWidget {
  final String text;
  final VoidCallback onTap;
  const _DateBox({required this.text, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
        decoration: BoxDecoration(
          color: _C.hover,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: _C.border),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                text,
                style: const TextStyle(fontSize: 12, color: _C.t1),
              ),
            ),
            const Icon(Icons.calendar_today, size: 13, color: _C.t2),
          ],
        ),
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final String label;
  final Widget child;
  const _MiniStat({required this.label, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: _box(_C.card2, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: const TextStyle(
              fontSize: 10.5,
              letterSpacing: 0.5,
              color: _C.t2,
            ),
          ),
          const SizedBox(height: 8),
          child,
        ],
      ),
    );
  }
}

class _StatsGrid extends StatelessWidget {
  final List<(String, String, Color)> stats;
  const _StatsGrid({required this.stats});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        final w = (c.maxWidth - 14) / 2;
        return Wrap(
          spacing: 14,
          runSpacing: 14,
          children: [
            for (final s in stats)
              SizedBox(
                width: w,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: _box(_C.card, 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        s.$1,
                        style: TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: s.$3,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        s.$2,
                        style: const TextStyle(fontSize: 11, color: _C.t2),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _SecButton extends StatelessWidget {
  final IconData? icon;
  final String label;
  final VoidCallback onTap;
  const _SecButton({this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        foregroundColor: _C.t2,
        side: const BorderSide(color: _C.border),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[Icon(icon, size: 15), const SizedBox(width: 7)],
          Text(label, style: const TextStyle(fontSize: 13)),
        ],
      ),
    );
  }
}

class _PriButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final List<Color> colors;
  const _PriButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.colors = const [_C.purple, _C.purple2],
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Ink(
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: colors,
            ),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 15, color: Colors.white),
              const SizedBox(width: 7),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ───────── Dona animada ─────────
class _Donut extends StatelessWidget {
  final double size, stroke, value;
  final Widget center;
  const _Donut({
    required this.size,
    required this.stroke,
    required this.value,
    required this.center,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: value),
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeOut,
      builder: (_, v, __) => SizedBox(
        width: size,
        height: size,
        child: Stack(
          alignment: Alignment.center,
          children: [
            CustomPaint(
              size: Size(size, size),
              painter: _DonutPainter(v, stroke),
            ),
            center,
          ],
        ),
      ),
    );
  }
}

class _DonutPainter extends CustomPainter {
  final double value, stroke;
  _DonutPainter(this.value, this.stroke);

  @override
  void paint(Canvas canvas, Size size) {
    final rect = (Offset.zero & size).deflate(stroke / 2);
    canvas.drawArc(
      rect,
      0,
      math.pi * 2,
      false,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.05)
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke,
    );
    final sweep = math.pi * 2 * value;
    if (sweep <= 0) return;
    canvas.drawArc(
      rect,
      -math.pi / 2,
      sweep,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke
        ..strokeCap = StrokeCap.round
        ..shader = SweepGradient(
          startAngle: 0,
          endAngle: math.max(0.01, sweep),
          colors: const [_C.mint, _C.blue],
          transform: const GradientRotation(-math.pi / 2),
        ).createShader(rect),
    );
  }

  @override
  bool shouldRepaint(covariant _DonutPainter o) =>
      o.value != value || o.stroke != stroke;
}

// ───────── Sparkline ─────────
class _SparkPainter extends CustomPainter {
  final List<double> pts;
  _SparkPainter(this.pts);

  @override
  void paint(Canvas canvas, Size size) {
    const pad = 4.0;
    final mn = pts.reduce(math.min);
    final mx = pts.reduce(math.max);
    double xp(int i) => pad + i * (size.width - pad * 2) / (pts.length - 1);
    double yp(double v) =>
        size.height -
        pad -
        (v - mn) / (mx - mn == 0 ? 1 : mx - mn) * (size.height - pad * 2);

    final line = Path()..moveTo(xp(0), yp(pts[0]));
    for (var i = 1; i < pts.length; i++) {
      line.lineTo(xp(i), yp(pts[i]));
    }
    final area = Path.from(line)
      ..lineTo(xp(pts.length - 1), size.height)
      ..lineTo(xp(0), size.height)
      ..close();

    canvas.drawPath(
      area,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            _C.blue.withValues(alpha: 0.4),
            _C.blue.withValues(alpha: 0),
          ],
        ).createShader(Offset.zero & size),
    );
    canvas.drawPath(
      line,
      Paint()
        ..color = _C.blue
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );
    for (var i = 0; i < pts.length; i++) {
      canvas.drawCircle(
        Offset(xp(i), yp(pts[i])),
        3,
        Paint()..color = _C.blue2,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _SparkPainter o) => o.pts != pts;
}
