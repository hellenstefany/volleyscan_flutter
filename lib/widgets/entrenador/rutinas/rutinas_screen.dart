import 'package:flutter/material.dart';
import 'rutinas_ai_card.dart';
import 'rutinas_colors.dart';
import 'rutinas_form_card.dart';
import 'rutinas_header.dart';
import 'rutinas_list_section.dart';
import 'rutinas_model.dart';
import 'rutinas_presets_card.dart';
import 'rutinas_progress_card.dart';
import 'rutinas_stats.dart';
import 'rutinas_week_card.dart';

class RutinasScreen extends StatefulWidget {
  const RutinasScreen({super.key});

  @override
  State<RutinasScreen> createState() => _RutinasScreenState();
}

class _RutinasScreenState extends State<RutinasScreen> {
  final _formKey = GlobalKey();

  List<Routine> _routines = sampleRoutines();

  // Estado del formulario
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
  void dispose() {
    _name.dispose();
    _hour.dispose();
    _min.dispose();
    _notes.dispose();
    super.dispose();
  }

  // ── Toast ──
  void _toast(String msg) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          duration: const Duration(seconds: 3),
          behavior: SnackBarBehavior.floating,
          backgroundColor: RtC.card,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
            side: const BorderSide(color: RtC.border),
          ),
          content: Row(
            children: [
              const Text('✅', style: TextStyle(fontSize: 18)),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  msg,
                  style: const TextStyle(color: RtC.text, fontSize: 13),
                ),
              ),
            ],
          ),
        ),
      );
  }

  // ── Formulario ──
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
    final r = Routine(
      id: _editingId ?? DateTime.now().microsecondsSinceEpoch.toString(),
      name: _name.text.trim(),
      athlete: _athlete!,
      type: _type!,
      hour: '${_hour.text.padLeft(2, '0')}:${_min.text.padLeft(2, '0')}',
      dur: _selectedDur,
      intensity: _intensity.round(),
      exs: List.of(_selectedExs),
      notes: _notes.text,
      date: isoDate(DateTime.now()),
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

  void _edit(Routine r) {
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

  void _loadPreset(Preset p) {
    setState(() {
      _type = p.type;
      _name.text = p.name;
      _intensity = p.intensity.toDouble();
      _selectedExs = List.of(p.exs);
      _selectedDur = p.dur;
    });
    _toast('"${p.name}" cargada');
  }

  void _toggleDone(Routine r) => setState(
    () => _routines = [
      for (final x in _routines) x.id == r.id ? x.copyWith(done: !x.done) : x,
    ],
  );

  void _delete(Routine r) {
    setState(() => _routines = _routines.where((x) => x.id != r.id).toList());
    _toast('"${r.name}" eliminada');
  }

  // ── UI ──
  @override
  Widget build(BuildContext context) {
    final today = isoDate(DateTime.now());
    final filtered = _filter == 'Todas'
        ? _routines
        : _routines.where((r) => r.type == _filter).toList();

    return LayoutBuilder(
      builder: (context, c) {
        final w = c.maxWidth;
        final ancho = w >= 700;

        final form = RutinasFormCard(
          key: _formKey,
          editing: _editingId != null,
          athlete: _athlete,
          type: _type,
          nameCtrl: _name,
          hourCtrl: _hour,
          minCtrl: _min,
          notesCtrl: _notes,
          intensity: _intensity,
          selectedExs: _selectedExs,
          selectedDur: _selectedDur,
          onAthlete: (v) => setState(() => _athlete = v),
          onType: (v) => setState(() {
            _type = v;
            _selectedExs = [];
          }),
          onDur: (v) => setState(() => _selectedDur = v),
          onIntensity: (v) => setState(() => _intensity = v),
          onToggleEx: (ex) => setState(() {
            _selectedExs.contains(ex)
                ? _selectedExs.remove(ex)
                : _selectedExs.add(ex);
          }),
          onSave: _save,
        );

        final right = Column(
          children: [
            RutinasPresetsCard(onLoad: _loadPreset),
            const SizedBox(height: 12),
            const RutinasProgressCard(),
            const SizedBox(height: 12),
            const RutinasAiCard(),
          ],
        );

        return SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 90),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const RutinasHeader(),
              const SizedBox(height: 18),
              RutinasStats(width: w, routines: _routines, today: today),
              const SizedBox(height: 10),
              RutinasWeekCard(routines: _routines, today: today),
              const SizedBox(height: 14),
              if (ancho)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: form),
                    const SizedBox(width: 14),
                    Expanded(child: right),
                  ],
                )
              else ...[
                form,
                const SizedBox(height: 14),
                right,
              ],
              const SizedBox(height: 22),
              const RutinasListDivider(),
              const SizedBox(height: 22),
              RutinasListHeader(
                count: filtered.length,
                filter: _filter,
                onFilter: (t) => setState(() => _filter = t),
              ),
              const SizedBox(height: 16),
              RutinasGrid(
                width: w,
                list: filtered,
                onToggleDone: _toggleDone,
                onEdit: _edit,
                onDelete: _delete,
              ),
            ],
          ),
        );
      },
    );
  }
}
