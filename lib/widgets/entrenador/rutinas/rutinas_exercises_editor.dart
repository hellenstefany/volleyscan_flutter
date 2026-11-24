import 'package:flutter/material.dart';
import '../../../models/rutina_entrenador_data.dart';
import '../../../theme/dash_colors.dart';
import 'rutinas_catalog.dart';
import 'rutinas_common_widgets.dart';

/// Selector de ejercicios sugeridos, campo de ejercicio propio y lista ordenada
/// con series y repeticiones (1..99).
class RutinasExercisesEditor extends StatelessWidget {
  final String? type;
  final List<RutinaEjercicio> ejercicios;
  final TextEditingController propioCtrl;
  final ValueChanged<String> onToggleEx;
  final VoidCallback onAddPropio;
  final void Function(String nombre, {int? series, int? reps}) onChangeEx;

  const RutinasExercisesEditor({
    super.key,
    required this.type,
    required this.ejercicios,
    required this.propioCtrl,
    required this.onToggleEx,
    required this.onAddPropio,
    required this.onChangeEx,
  });

  @override
  Widget build(BuildContext context) {
    final pool = kRutinaExercises[type] ?? const <String>[];
    final elegidos = ejercicios.map((e) => e.nombre).toSet();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (pool.isNotEmpty) ...[
          const RtLabel('Ejercicios sugeridos'),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final ex in pool)
                RtPill(
                  text: ex,
                  selected: elegidos.contains(ex),
                  onTap: () => onToggleEx(ex),
                ),
            ],
          ),
          const SizedBox(height: 10),
        ],
        const RtLabel('Agregar ejercicio propio'),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: propioCtrl,
                maxLength: 150,
                style: const TextStyle(color: DashColors.text, fontSize: 13),
                decoration: rtInputDeco('Ej: Saque desde zona 5').copyWith(
                  counterText: '',
                ),
                onSubmitted: (_) => onAddPropio(),
              ),
            ),
            const SizedBox(width: 8),
            OutlinedButton(
              onPressed: onAddPropio,
              style: OutlinedButton.styleFrom(
                backgroundColor: DashColors.card2,
                foregroundColor: DashColors.text,
                side: const BorderSide(color: DashColors.border),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                'Agregar',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        RtLabel('Ejercicios de la rutina (${ejercicios.length})'),
        if (ejercicios.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Text(
              'Elige ejercicios de arriba o agrega uno propio.',
              style: TextStyle(fontSize: 12, color: DashColors.textMuted),
            ),
          )
        else
          Column(
            children: [
              for (var i = 0; i < ejercicios.length; i++)
                _EjercicioRow(
                  index: i + 1,
                  ejercicio: ejercicios[i],
                  onSeriesChanged: (v) => onChangeEx(
                    ejercicios[i].nombre,
                    series: v,
                  ),
                  onRepsChanged: (v) => onChangeEx(
                    ejercicios[i].nombre,
                    reps: v,
                  ),
                  onRemove: () => onToggleEx(ejercicios[i].nombre),
                ),
            ],
          ),
      ],
    );
  }
}

class _EjercicioRow extends StatelessWidget {
  final int index;
  final RutinaEjercicio ejercicio;
  final ValueChanged<int> onSeriesChanged;
  final ValueChanged<int> onRepsChanged;
  final VoidCallback onRemove;

  const _EjercicioRow({
    required this.index,
    required this.ejercicio,
    required this.onSeriesChanged,
    required this.onRepsChanged,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: rtBox(DashColors.card2, 10),
      child: Row(
        children: [
          Container(
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              color: DashColors.coachPurple.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(6),
            ),
            alignment: Alignment.center,
            child: Text(
              '$index',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: DashColors.coachPurple,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              ejercicio.nombre,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 13, color: DashColors.text),
            ),
          ),
          const SizedBox(width: 6),
          _NumField(
            key: ValueKey('s_${ejercicio.nombre}_${ejercicio.series}'),
            initialValue: ejercicio.series,
            suffix: 'series',
            onChanged: onSeriesChanged,
          ),
          const SizedBox(width: 6),
          _NumField(
            key: ValueKey('r_${ejercicio.nombre}_${ejercicio.repeticiones}'),
            initialValue: ejercicio.repeticiones,
            suffix: 'reps',
            onChanged: onRepsChanged,
          ),
          const SizedBox(width: 6),
          InkWell(
            onTap: onRemove,
            borderRadius: BorderRadius.circular(6),
            child: Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: DashColors.border),
              ),
              alignment: Alignment.center,
              child: const Text(
                '✕',
                style: TextStyle(fontSize: 11, color: DashColors.textMuted),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NumField extends StatelessWidget {
  final int initialValue;
  final String suffix;
  final ValueChanged<int> onChanged;

  const _NumField({
    super.key,
    required this.initialValue,
    required this.suffix,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 42,
          child: TextFormField(
            initialValue: '$initialValue',
            textAlign: TextAlign.center,
            keyboardType: TextInputType.number,
            maxLength: 2,
            style: const TextStyle(
              color: DashColors.text,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
            decoration: rtInputDeco('').copyWith(
              counterText: '',
              fillColor: DashColors.bg,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 2,
                vertical: 6,
              ),
            ),
            onChanged: (v) {
              final n = int.tryParse(v);
              if (n != null && n >= 1 && n <= 99) onChanged(n);
            },
          ),
        ),
        const SizedBox(width: 3),
        Text(
          suffix,
          style: const TextStyle(fontSize: 11, color: DashColors.textMuted),
        ),
      ],
    );
  }
}
