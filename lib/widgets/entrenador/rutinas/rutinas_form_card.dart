import 'package:flutter/material.dart';
import 'rutinas_colors.dart';
import 'rutinas_common_widgets.dart';
import 'rutinas_model.dart';

/// Formulario "Nueva / Editar rutina".
/// El estado vive en la pantalla; este widget solo lo muestra y avisa cambios.
class RutinasFormCard extends StatelessWidget {
  final bool editing;
  final String? athlete, type;
  final TextEditingController nameCtrl, hourCtrl, minCtrl, notesCtrl;
  final double intensity;
  final List<String> selectedExs;
  final String selectedDur;
  final ValueChanged<String?> onAthlete, onType;
  final ValueChanged<String> onDur, onToggleEx;
  final ValueChanged<double> onIntensity;
  final VoidCallback onSave;

  const RutinasFormCard({
    super.key, // aquí se pasa la GlobalKey para hacer scroll al editar
    required this.editing,
    required this.athlete,
    required this.type,
    required this.nameCtrl,
    required this.hourCtrl,
    required this.minCtrl,
    required this.notesCtrl,
    required this.intensity,
    required this.selectedExs,
    required this.selectedDur,
    required this.onAthlete,
    required this.onType,
    required this.onDur,
    required this.onToggleEx,
    required this.onIntensity,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    final pool = kExercises[type] ?? const <String>[];
    final iv = intensity.round();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: rtBox(RtC.card, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RtCardTitle(
            icon: '➕',
            title: '${editing ? 'Editar' : 'Nueva'} rutina',
          ),
          LayoutBuilder(
            builder: (context, c) {
              final dep = _dropdown(
                'Deportista',
                athlete,
                kAthletes,
                onAthlete,
              );
              final tipo = _dropdown(
                'Tipo de entrenamiento',
                type,
                kExercises.keys.toList(),
                onType,
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
          const RtLabel('Nombre de la rutina'),
          TextField(
            controller: nameCtrl,
            style: const TextStyle(color: RtC.text, fontSize: 13),
            decoration: rtInputDeco('Ej: Entrenamiento de saque explosivo…'),
          ),
          const SizedBox(height: 10),
          const RtLabel('Hora de inicio'),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              RtTimeBox(label: 'HH', controller: hourCtrl, max: 23),
              const Padding(
                padding: EdgeInsets.only(left: 10, right: 10, bottom: 8),
                child: Text(
                  ':',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: RtC.accent,
                  ),
                ),
              ),
              RtTimeBox(label: 'MM', controller: minCtrl, max: 59),
            ],
          ),
          const SizedBox(height: 10),
          const RtLabel('Duración'),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final d in kDurations)
                RtPill(
                  text: d,
                  selected: selectedDur == d,
                  onTap: () => onDur(d),
                ),
            ],
          ),
          const SizedBox(height: 10),
          const RtLabel('Intensidad'),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              trackHeight: 5,
              activeTrackColor: rtIntensityColor(iv),
              thumbColor: RtC.text,
              inactiveTrackColor: Colors.white12,
              overlayColor: RtC.accent.withValues(alpha: 0.2),
            ),
            child: Slider(
              min: 1,
              max: 10,
              divisions: 9,
              value: intensity,
              onChanged: onIntensity,
            ),
          ),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Suave', style: TextStyle(fontSize: 10, color: RtC.muted)),
              Text(
                'Moderado',
                style: TextStyle(fontSize: 10, color: RtC.muted),
              ),
              Text('Máximo', style: TextStyle(fontSize: 10, color: RtC.muted)),
            ],
          ),
          const SizedBox(height: 6),
          Center(
            child: Text(
              '$iv / 10',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: rtIntensityColor(iv),
              ),
            ),
          ),
          if (pool.isNotEmpty) ...[
            const SizedBox(height: 10),
            const RtLabel('Ejercicios incluidos'),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final ex in pool)
                  RtPill(
                    text: ex,
                    selected: selectedExs.contains(ex),
                    onTap: () => onToggleEx(ex),
                  ),
              ],
            ),
          ],
          const SizedBox(height: 12),
          const RtLabel('Notas / Observaciones'),
          TextField(
            controller: notesCtrl,
            maxLines: 3,
            style: const TextStyle(color: RtC.text, fontSize: 13),
            decoration: rtInputDeco('Indicaciones especiales…'),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onSave,
                borderRadius: BorderRadius.circular(10),
                child: Ink(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [RtC.accent, Color(0xFFA078FF)],
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Text(
                      editing ? '✏️ ACTUALIZAR RUTINA' : '⚡ GUARDAR RUTINA',
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
  ) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      RtLabel(label),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: RtC.card2,
          borderRadius: BorderRadius.circular(9),
          border: Border.all(color: RtC.border),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: value,
            isExpanded: true,
            hint: const Text(
              'Seleccionar...',
              style: TextStyle(color: RtC.muted, fontSize: 13),
            ),
            dropdownColor: const Color(0xFF1A1E30),
            style: const TextStyle(color: RtC.text, fontSize: 13),
            icon: const Icon(Icons.arrow_drop_down, color: RtC.muted),
            items: [
              for (final i in items) DropdownMenuItem(value: i, child: Text(i)),
            ],
            onChanged: onChanged,
          ),
        ),
      ),
    ],
  );
}
