import 'package:flutter/material.dart';

import '../../../theme/dash_colors.dart';
import '../equipos/equipos_common_widgets.dart';
import '../gestion/gestion_athlete.dart';
import 'horario_colors.dart';
import 'horario_controls.dart';
import 'horario_model.dart';

/// Selector de mes/año. Devuelve `DateTime(año, mes, 1)`.
class MonthPickerDialog extends StatefulWidget {
  final int initialYear;
  final DateTime selected;
  const MonthPickerDialog({super.key, required this.initialYear, required this.selected});

  @override
  State<MonthPickerDialog> createState() => _MonthPickerDialogState();
}

class _MonthPickerDialogState extends State<MonthPickerDialog> {
  late int _year = widget.initialYear;

  bool _isSel(int i) => widget.selected.month == i + 1 && widget.selected.year == _year;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: HC.card2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18), side: const BorderSide(color: HC.border2)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 320),
        child: Padding(
          padding: const EdgeInsets.all(26),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  const Expanded(child: Text('Seleccionar mes', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: HC.t1))),
                  CloseBtn(onTap: () => Navigator.pop(context)),
                ],
              ),
              const SizedBox(height: 20),
              GridView.count(
                crossAxisCount: 3,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
                childAspectRatio: 2.2,
                children: [
                  for (var i = 0; i < 12; i++)
                    InkWell(
                      onTap: () => Navigator.pop(context, DateTime(_year, i + 1, 1)),
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          gradient: _isSel(i) ? HC.activeGrad : null,
                          color: _isSel(i) ? null : HC.card3,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: HC.border),
                        ),
                        child: Text(
                          kMonthNames[i].substring(0, 3),
                          style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: _isSel(i) ? DashColors.textPrimary : HC.t2),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CtrlBtn(icon: Icons.chevron_left, onTap: () => setState(() => _year--)),
                  const SizedBox(width: 12),
                  Text('$_year', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: HC.t1)),
                  const SizedBox(width: 12),
                  CtrlBtn(icon: Icons.chevron_right, onTap: () => setState(() => _year++)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Selector múltiple con buscador y chips para citar deportistas individuales en un evento.
class HorarioAthletesSelector extends StatefulWidget {
  final List<EntrenadorDeportista> deportistas;
  final List<CoachScheduleAthleteRef> citados;
  final ValueChanged<List<CoachScheduleAthleteRef>> onChanged;

  const HorarioAthletesSelector({
    super.key,
    required this.deportistas,
    required this.citados,
    required this.onChanged,
  });

  @override
  State<HorarioAthletesSelector> createState() => _HorarioAthletesSelectorState();
}

class _HorarioAthletesSelectorState extends State<HorarioAthletesSelector> {
  final TextEditingController _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  List<EntrenadorDeportista> get _visibles {
    final q = _searchCtrl.text.trim().toLowerCase();
    if (q.isEmpty) return widget.deportistas;
    return widget.deportistas.where((d) => d.nombreCompleto.toLowerCase().contains(q)).toList();
  }

  @override
  Widget build(BuildContext context) {
    final citados = widget.citados;
    final ids = citados.map((c) => c.id).toSet();
    final vis = _visibles;
    final todosMarcados = vis.isNotEmpty && vis.every((d) => ids.contains(d.id));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (citados.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                for (final c in citados)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(color: HC.card3, borderRadius: BorderRadius.circular(99), border: Border.all(color: HC.border2)),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(c.nombre, style: const TextStyle(fontSize: 11.8, color: HC.t1)),
                        const SizedBox(width: 6),
                        InkWell(
                          onTap: () => widget.onChanged(citados.where((x) => x.id != c.id).toList()),
                          child: const Icon(Icons.close, size: 13, color: HC.t2),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _searchCtrl,
                onChanged: (_) => setState(() {}),
                style: const TextStyle(color: HC.t1, fontSize: 12.5),
                decoration: InputDecoration(
                  isDense: true,
                  filled: true,
                  fillColor: HC.card3,
                  hintText: 'Buscar deportista…',
                  hintStyle: const TextStyle(color: HC.t3, fontSize: 12.5),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 11, vertical: 9),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(9), borderSide: const BorderSide(color: HC.border2)),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(9), borderSide: const BorderSide(color: HC.blue)),
                ),
              ),
            ),
            const SizedBox(width: 8),
            EquipoSecButton(
              label: todosMarcados ? 'Quitar a todos' : (_searchCtrl.text.trim().isNotEmpty ? 'Marcar encontrados' : 'Marcar a todos'),
              mini: true,
              enabled: vis.isNotEmpty,
              onTap: () {
                if (todosMarcados) {
                  final fuera = vis.map((d) => d.id).toSet();
                  widget.onChanged(citados.where((c) => !fuera.contains(c.id)).toList());
                } else {
                  final next = List.of(citados);
                  for (final d in vis) {
                    if (!ids.contains(d.id)) next.add(CoachScheduleAthleteRef(id: d.id, nombre: d.nombreCompleto));
                  }
                  widget.onChanged(next);
                }
              },
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          constraints: const BoxConstraints(maxHeight: 150),
          decoration: BoxDecoration(color: HC.card, borderRadius: BorderRadius.circular(10), border: Border.all(color: HC.border)),
          child: vis.isEmpty
              ? Padding(
                  padding: const EdgeInsets.all(12),
                  child: Text(
                    widget.deportistas.isEmpty ? 'Aún no tienes deportistas vinculados.' : 'Nadie coincide con la búsqueda.',
                    style: const TextStyle(fontSize: 12, color: HC.t2),
                  ),
                )
              : ListView.builder(
                  shrinkWrap: true,
                  itemCount: vis.length,
                  itemBuilder: (_, i) {
                    final d = vis[i];
                    final on = ids.contains(d.id);
                    return InkWell(
                      onTap: () {
                        if (on) {
                          widget.onChanged(citados.where((c) => c.id != d.id).toList());
                        } else {
                          widget.onChanged([...citados, CoachScheduleAthleteRef(id: d.id, nombre: d.nombreCompleto)]);
                        }
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                        child: Row(
                          children: [
                            Icon(on ? Icons.check_box_rounded : Icons.check_box_outline_blank_rounded, size: 17, color: on ? HC.blue2 : HC.t3),
                            const SizedBox(width: 8),
                            Expanded(child: Text(d.nombreCompleto, style: const TextStyle(fontSize: 12.8, color: HC.t1))),
                            if (d.posicion != null && d.posicion!.isNotEmpty)
                              Text(d.posicion!, style: const TextStyle(fontSize: 11.2, color: DashColors.textMuted)),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
