import 'package:flutter/material.dart';

import '../../models/rutina_entrenador_data.dart';
import '../../services/api_service.dart';
import '../../theme/app_theme.dart';
import '../../theme/dash_colors.dart';
import '../../widgets/entrenador/gestion/gestion_athlete.dart';
import '../../widgets/entrenador/rutinas/rutinas_actions.dart';
import '../../widgets/entrenador/rutinas/rutinas_body.dart';
import '../../widgets/entrenador/rutinas/rutinas_catalog.dart';
import '../../widgets/entrenador/rutinas/rutinas_common_widgets.dart';
import '../../widgets/entrenador/rutinas/rutinas_delete_dialog.dart';
import '../../widgets/entrenador/rutinas/rutinas_form_card.dart';

/// Pantalla "Rutinas" del Panel de Entrenador (`/panel_entrenador/rutinas`).
class RutinasScreen extends StatefulWidget {
  const RutinasScreen({super.key});

  @override
  State<RutinasScreen> createState() => _RutinasScreenState();
}

class _RutinasScreenState extends State<RutinasScreen> {
  final _formKey = GlobalKey();

  List<EntrenadorDeportista> _deportistas = const [];
  List<RutinaEntrenador> _routines = const [];
  bool _cargando = true;
  String _error = '';

  String? _athlete;
  String? _type;
  String _nivel = 'intermedio';
  final _name = TextEditingController();
  final _objetivo = TextEditingController();
  final _hour = TextEditingController(text: '08');
  final _min = TextEditingController(text: '00');
  final _notes = TextEditingController();
  final _propio = TextEditingController();
  late String _fecha = rtIsoDate(DateTime.now());
  double _intensity = 6;
  List<RutinaEjercicio> _exs = [];
  String _selectedDur = '60 min';
  String _filter = 'Todas';
  String _verAtleta = '';
  int? _editingId;
  bool _guardando = false;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  @override
  void dispose() {
    _name.dispose();
    _objetivo.dispose();
    _hour.dispose();
    _min.dispose();
    _notes.dispose();
    _propio.dispose();
    super.dispose();
  }

  Future<void> _cargar({bool silent = false}) async {
    if (!silent && mounted) {
      setState(() {
        _cargando = true;
        _error = '';
      });
    }
    try {
      final res = await Future.wait([
        ApiService().listarDeportistasEntrenador(),
        ApiService().listarRutinasEntrenador(),
      ]);
      if (!mounted) return;
      setState(() {
        _deportistas = res[0] as List<EntrenadorDeportista>;
        _routines = res[1] as List<RutinaEntrenador>;
        _cargando = false;
        _error = '';
      });
    } on ApiException catch (e) {
      if (!mounted || e.isUnauthorized) return;
      setState(() {
        _cargando = false;
        _error = e.message;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _cargando = false;
        _error = 'No se pudieron cargar las rutinas.';
      });
    }
  }

  void _limpiarFormulario() {
    setState(() {
      _athlete = null;
      _type = null;
      _nivel = 'intermedio';
      _name.clear();
      _objetivo.clear();
      _hour.text = '08';
      _min.text = '00';
      _notes.clear();
      _propio.clear();
      _fecha = rtIsoDate(DateTime.now());
      _intensity = 6;
      _exs = [];
      _selectedDur = '60 min';
      _editingId = null;
    });
  }

  void _toggleEx(String nombre) {
    setState(() {
      _exs = _exs.any((e) => e.nombre == nombre)
          ? _exs.where((e) => e.nombre != nombre).toList()
          : [..._exs, RutinaEjercicio(nombre: nombre)];
    });
  }

  void _agregarPropio() {
    final n = _propio.text.trim();
    if (n.isEmpty) return;
    if (n.length > 150) {
      showAppToast(context, 'El nombre del ejercicio es demasiado largo.', type: 'error');
      return;
    }
    if (_exs.any((x) => x.nombre.toLowerCase() == n.toLowerCase())) {
      showAppToast(context, 'Ese ejercicio ya está en la lista.', type: 'error');
      return;
    }
    setState(() {
      _exs = [..._exs, RutinaEjercicio(nombre: n)];
      _propio.clear();
    });
  }

  Future<void> _saveRoutine() async {
    if (_guardando) return;
    setState(() => _guardando = true);
    final ok = await submitRutinaEntrenador(
      context: context,
      editingId: _editingId,
      athlete: _athlete,
      type: _type,
      nivel: _nivel,
      nombre: _name.text,
      objetivo: _objetivo.text,
      notas: _notes.text,
      hourText: _hour.text,
      minText: _min.text,
      fecha: _fecha,
      selectedDur: _selectedDur,
      intensidad: _intensity.round(),
      ejercicios: _exs,
      deportistas: _deportistas,
      onClearVerAtletaIfAll: () => _verAtleta = '',
    );
    if (!mounted) return;
    setState(() => _guardando = false);
    if (ok) {
      _limpiarFormulario();
      await _cargar(silent: true);
    }
  }

  void _editRoutine(RutinaEntrenador r) {
    if (r.progreso.completados > 0) {
      showAppToast(
        context,
        'El deportista ya tiene avance en esta rutina; no se puede editar. Crea una nueva.',
        type: 'error',
      );
      return;
    }
    final parts = (r.horaInicio ?? '08:00').split(':');
    final durKey = rtDurTexto(r.duracionMin);
    setState(() {
      _athlete = '${r.atleta.id}';
      _type = r.tipo.isEmpty ? null : r.tipo;
      _nivel = r.nivel;
      _name.text = r.nombre;
      _objetivo.text = r.objetivo ?? '';
      _hour.text = parts.isNotEmpty ? parts[0] : '08';
      _min.text = parts.length > 1 ? parts[1] : '00';
      _notes.text = r.notas ?? '';
      _fecha = r.fechaProgramada ?? rtIsoDate(DateTime.now());
      _intensity = r.intensidad.clamp(1, 10).toDouble();
      _exs = List.of(r.ejercicios);
      _selectedDur = kRutinaDuraciones.containsKey(durKey) ? durKey : '60 min';
      _editingId = r.id;
      _verAtleta = '${r.atleta.id}';
    });
    final ctx = _formKey.currentContext;
    if (ctx != null) {
      Scrollable.ensureVisible(ctx, duration: const Duration(milliseconds: 300));
    }
    showAppToast(context, 'Editando "${r.nombre}"', type: 'info');
  }

  Future<void> _confirmDelete(RutinaEntrenador r) async {
    final deleted = await showRutinaDeleteDialog(context, r);
    if (!deleted || !mounted) return;
    if (_editingId == r.id) _limpiarFormulario();
    await _cargar(silent: true);
  }

  RutinaAtleta? _findAtletaVisto() {
    if (_verAtleta.isEmpty) return null;
    for (final d in _deportistas) {
      if ('${d.id}' == _verAtleta) {
        return RutinaAtleta(id: d.id, nombre: d.nombre, apellido: d.apellido);
      }
    }
    return _routines.where((r) => '${r.atleta.id}' == _verAtleta).map((r) => r.atleta).firstOrNull;
  }

  @override
  Widget build(BuildContext context) {
    final hoy = rtIsoDate(DateTime.now());
    final now = DateTime.now();
    final monday = DateTime(now.year, now.month, now.day).subtract(Duration(days: now.weekday - 1));
    final monIso = rtIsoDate(monday);
    final sunIso = rtIsoDate(monday.add(const Duration(days: 6)));

    final visibles = _verAtleta.isEmpty ? _routines : _routines.where((r) => '${r.atleta.id}' == _verAtleta).toList();
    final filtered = _filter == 'Todas' ? visibles : visibles.where((r) => r.tipo == _filter).toList();
    final enSemana = visibles.where((r) => r.fechaProgramada != null && r.fechaProgramada!.compareTo(monIso) >= 0 && r.fechaProgramada!.compareTo(sunIso) <= 0).toList();
    final atletaVisto = _findAtletaVisto();
    final editando = _editingId == null ? null : _routines.where((r) => r.id == _editingId).firstOrNull;
    final emptyMsg = atletaVisto != null
        ? '${atletaVisto.nombreCompleto} no tiene rutinas${_filter != 'Todas' ? ' de tipo $_filter' : ''}'
        : _filter != 'Todas'
            ? 'Sin rutinas asignadas de tipo $_filter'
            : 'Sin rutinas asignadas';

    return LayoutBuilder(
      builder: (context, c) {
        if (_cargando) return const Center(child: CircularProgressIndicator(color: DashColors.coachPurple));
        if (_error.isNotEmpty) {
          return Center(
            child: Container(
              margin: const EdgeInsets.all(24),
              padding: const EdgeInsets.all(24),
              decoration: rtBox(DashColors.card, 14).copyWith(border: Border.all(color: DashColors.red.withValues(alpha: 0.35))),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(_error, textAlign: TextAlign.center, style: const TextStyle(color: DashColors.red)),
                  const SizedBox(height: 14),
                  ElevatedButton(onPressed: _cargar, child: const Text('Reintentar')),
                ],
              ),
            ),
          );
        }
        return RutinasBody(
          width: c.maxWidth,
          hoy: hoy,
          deportistas: _deportistas,
          visibles: visibles,
          filtered: filtered,
          enSemana: enSemana,
          atletaVisto: atletaVisto,
          verAtleta: _verAtleta,
          filter: _filter,
          emptyMsg: emptyMsg,
          resumen: rtResumenAtencion(visibles: visibles, enSemana: enSemana, atletaNombre: atletaVisto?.nombreCompleto, hoy: hoy),
          onRefresh: () => _cargar(silent: true),
          onLoadPreset: (p) {
            setState(() {
              _type = p.type;
              _name.text = p.name;
              _intensity = p.intensity.toDouble();
              _exs = [for (final n in p.exs) RutinaEjercicio(nombre: n)];
              _selectedDur = p.dur;
            });
            showAppToast(context, '"${p.name}" cargada');
          },
          onFilter: (t) => setState(() => _filter = t),
          onVerAtleta: (v) => setState(() => _verAtleta = v),
          onEdit: _editRoutine,
          onDelete: _confirmDelete,
          form: RutinasFormCard(
            key: _formKey,
            editing: _editingId != null,
            guardando: _guardando,
            deportistas: _deportistas,
            editandoAtleta: editando?.atleta,
            athlete: _athlete,
            type: _type,
            nivel: _nivel,
            nameCtrl: _name,
            objetivoCtrl: _objetivo,
            hourCtrl: _hour,
            minCtrl: _min,
            notesCtrl: _notes,
            propioCtrl: _propio,
            fecha: _fecha,
            intensity: _intensity,
            ejercicios: _exs,
            selectedDur: _selectedDur,
            onAthlete: (v) => setState(() {
              _athlete = v;
              if (v != null && v.isNotEmpty && v != 'todos') _verAtleta = v;
            }),
            onType: (v) => setState(() => _type = v),
            onNivel: (v) => setState(() => _nivel = v),
            onFecha: (v) => setState(() => _fecha = v),
            onDur: (v) => setState(() => _selectedDur = v),
            onIntensity: (v) => setState(() => _intensity = v),
            onToggleEx: _toggleEx,
            onAddPropio: _agregarPropio,
            onChangeEx: (nombre, {series, reps}) => setState(() {
              _exs = [for (final e in _exs) e.nombre == nombre ? e.copyWith(series: series, repeticiones: reps) : e];
            }),
            onSave: _saveRoutine,
            onCancelEdit: _limpiarFormulario,
          ),
        );
      },
    );
  }
}
