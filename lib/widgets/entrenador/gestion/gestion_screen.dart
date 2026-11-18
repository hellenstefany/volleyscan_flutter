import 'package:flutter/material.dart';
import 'gestion_athlete.dart';
import 'gestion_colors.dart';
import 'gestion_athlete_detail.dart';
import 'gestion_athlete_form_dialog.dart';
import 'gestion_athletes_table.dart';
import 'gestion_delete_dialog.dart';

class GestionScreen extends StatefulWidget {
  const GestionScreen({super.key});

  @override
  State<GestionScreen> createState() => _GestionScreenState();
}

class _GestionScreenState extends State<GestionScreen> {
  List<Athlete> _athletes = initialAthletes;
  int _nextId = 6;
  int? _selectedId;
  String _search = '', _cat = '', _estado = '';

  // ── Datos derivados ──
  List<Athlete> get _filtered => _athletes.where((a) {
    final q = _search.toLowerCase();
    return (q.isEmpty ||
            a.nombre.toLowerCase().contains(q) ||
            a.pos.toLowerCase().contains(q)) &&
        (_cat.isEmpty || a.cat == _cat) &&
        (_estado.isEmpty || a.estado == _estado);
  }).toList();

  Athlete? get _selected {
    for (final a in _athletes) {
      if (a.id == _selectedId) return a;
    }
    return null;
  }

  // ── Acciones ──
  void _toast(String msg, {bool error = false}) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          duration: const Duration(seconds: 3),
          behavior: SnackBarBehavior.floating,
          backgroundColor: GC.card2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: GC.border),
          ),
          content: Row(
            children: [
              Icon(
                error ? Icons.cancel : Icons.check_circle,
                color: error ? GC.red : GC.green,
                size: 18,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(msg, style: const TextStyle(color: GC.t1)),
              ),
            ],
          ),
        ),
      );
  }

  Future<void> _openForm([Athlete? editing]) async {
    final res = await showDialog<Athlete>(
      context: context,
      builder: (_) => AthleteFormDialog(editing: editing, nextId: _nextId),
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

  Future<void> _askDelete(Athlete a) async {
    if (await confirmDelete(context) != true) return;
    setState(() {
      _athletes = _athletes.where((x) => x.id != a.id).toList();
      if (_selectedId == a.id) _selectedId = null;
    });
    _toast('${a.nombre} eliminado');
  }

  // ── UI ──
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        final narrow = c.maxWidth < 950;
        final sel = _selected;

        final table = AthletesPanel(
          athletes: _filtered,
          selectedId: _selectedId,
          narrow: narrow,
          cat: _cat,
          estado: _estado,
          onSearch: (v) => setState(() => _search = v),
          onCat: (v) => setState(() => _cat = v),
          onEstado: (v) => setState(() => _estado = v),
          onSelect: (a) => setState(() => _selectedId = a.id),
          onEdit: _openForm,
          onDelete: _askDelete,
          onAdd: _openForm,
        );
        final detail = AthleteDetail(
          athlete: sel,
          onProfile: () =>
              _toast('Perfil de ${sel?.nombre} — función próximamente 🚀'),
        );

        return SingleChildScrollView(
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
                  color: GC.t1,
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
}
