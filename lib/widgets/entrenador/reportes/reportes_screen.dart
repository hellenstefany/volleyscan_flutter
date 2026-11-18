import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'reportes_colors.dart';
import 'reportes_model.dart';
import 'reportes_stepper.dart';
import 'reportes_step1.dart';
import 'reportes_step2.dart';
import 'reportes_step3.dart';

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

  Dep get _d => kData[_dep] ?? kData['Juan Pérez']!;
  String get _fileName =>
      'reporte_${_dep.replaceAll(' ', '_').toLowerCase()}.$_fmt';

  // ── Toast ──
  void _toast(String msg) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          duration: const Duration(milliseconds: 3200),
          behavior: SnackBarBehavior.floating,
          backgroundColor: RC.card2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: RC.border),
          ),
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: RC.green, size: 18),
              const SizedBox(width: 10),
              Expanded(
                child: Text(msg, style: const TextStyle(color: RC.t1)),
              ),
            ],
          ),
        ),
      );
  }

  // ── Navegación entre pasos ──
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

  // ── Exportación simulada ──
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

  // ── UI ──
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
              color: RC.t1,
            ),
          ),
          const SizedBox(height: 22),
          ReportesStepper(step: _step, onGo: _goStep),
          const SizedBox(height: 26),
          if (_step == 1)
            ReportesStep1(
              tipo: _tipo,
              dep: _dep,
              from: _from,
              to: _to,
              checks: _checks,
              d: _d,
              onTipo: (v) => setState(() => _tipo = v),
              onDep: (v) => setState(() => _dep = v),
              onToggleCheck: (k) => setState(() => _checks[k] = !_checks[k]!),
              onPickDate: _pickDate,
              onReset: _reset,
              onPreview: () => _goStep(2),
            ),
          if (_step == 2)
            ReportesStep2(
              tipo: _tipo,
              dep: _dep,
              from: _from,
              to: _to,
              checks: _checks,
              d: _d,
              onBack: () => _goStep(1),
              onExport: () => _goStep(3),
            ),
          if (_step == 3)
            ReportesStep3(
              tipo: _tipo,
              dep: _dep,
              from: _from,
              to: _to,
              fmt: _fmt,
              fileName: _fileName,
              progress: _progress,
              progressLabel: _progressLabel,
              exporting: _exporting,
              exportDone: _exportDone,
              onFmt: (v) => setState(() => _fmt = v),
              onBack: () => _goStep(2),
              onExport: _doExport,
              onNew: () => setState(() {
                _step = 1;
                _exportDone = false;
                _exporting = false;
              }),
            ),
        ],
      ),
    );
  }
}
