import 'package:flutter/material.dart';
import '../../../theme/dash_colors.dart';
import 'rutinas_catalog.dart';
import 'rutinas_common_widgets.dart';

/// Dropdown estilizado del formulario de rutinas.
class RtDropdownField extends StatelessWidget {
  final String label;
  final String? value;
  final List<(String, String)> items;
  final ValueChanged<String?>? onChanged;

  const RtDropdownField({
    super.key,
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RtLabel(label),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: rtBox(DashColors.card2, 9),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: items.any((i) => i.$1 == value) ? value : null,
                isExpanded: true,
                hint: const Text(
                  'Seleccionar...',
                  style: TextStyle(color: DashColors.textMuted, fontSize: 13),
                ),
                dropdownColor: DashColors.card,
                style: const TextStyle(color: DashColors.text, fontSize: 13),
                icon: const Icon(
                  Icons.arrow_drop_down,
                  color: DashColors.textMuted,
                ),
                items: [
                  for (final i in items)
                    DropdownMenuItem(
                      value: i.$1,
                      child: Text(i.$2, overflow: TextOverflow.ellipsis),
                    ),
                ],
                onChanged: onChanged,
              ),
            ),
          ),
        ],
      );
}

/// Bloque de hora de inicio + selector de fecha programada.
class RtScheduleFields extends StatelessWidget {
  final TextEditingController hourCtrl;
  final TextEditingController minCtrl;
  final String fecha;
  final ValueChanged<String> onFecha;

  const RtScheduleFields({
    super.key,
    required this.hourCtrl,
    required this.minCtrl,
    required this.fecha,
    required this.onFecha,
  });

  Future<void> _pickDate(BuildContext context) async {
    final initial = DateTime.tryParse(fecha) ?? DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.dark(
            primary: DashColors.coachPurple,
            surface: DashColors.card,
            onSurface: DashColors.text,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) onFecha(rtIsoDate(picked));
  }

  @override
  Widget build(BuildContext context) {
    final timeCol = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const RtLabel('Hora de inicio'),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            RtTimeBox(label: 'HH', controller: hourCtrl, max: 23),
            const Padding(
              padding: EdgeInsets.only(left: 8, right: 8, bottom: 8),
              child: Text(
                ':',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: DashColors.coachPurple,
                ),
              ),
            ),
            RtTimeBox(label: 'MM', controller: minCtrl, max: 59),
          ],
        ),
      ],
    );

    final dateCol = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const RtLabel('Fecha'),
        InkWell(
          onTap: () => _pickDate(context),
          borderRadius: BorderRadius.circular(9),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: rtBox(DashColors.card2, 9),
            child: Row(
              children: [
                const Icon(
                  Icons.calendar_today_outlined,
                  size: 16,
                  color: DashColors.textMuted,
                ),
                const SizedBox(width: 8),
                Text(
                  fecha.isEmpty ? 'Seleccionar fecha' : fecha,
                  style: const TextStyle(fontSize: 13, color: DashColors.text),
                ),
              ],
            ),
          ),
        ),
      ],
    );

    return LayoutBuilder(
      builder: (_, c) {
        if (c.maxWidth >= 360) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: timeCol),
              const SizedBox(width: 10),
              Expanded(child: dateCol),
            ],
          );
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [timeCol, const SizedBox(height: 10), dateCol],
        );
      },
    );
  }
}

/// Slider de intensidad (1–10) con etiquetas y valor destacado.
class RtIntensitySlider extends StatelessWidget {
  final double intensity;
  final ValueChanged<double> onChanged;

  const RtIntensitySlider({
    super.key,
    required this.intensity,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final iv = intensity.round();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const RtLabel('Intensidad'),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            trackHeight: 5,
            activeTrackColor: rtIntensityColor(iv),
            thumbColor: DashColors.text,
            inactiveTrackColor: Colors.white12,
            overlayColor: DashColors.coachPurple.withValues(alpha: 0.2),
          ),
          child: Slider(
            min: 1,
            max: 10,
            divisions: 9,
            value: intensity,
            onChanged: onChanged,
          ),
        ),
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Suave', style: TextStyle(fontSize: 10, color: DashColors.textMuted)),
            Text('Moderado', style: TextStyle(fontSize: 10, color: DashColors.textMuted)),
            Text('Máximo', style: TextStyle(fontSize: 10, color: DashColors.textMuted)),
          ],
        ),
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
      ],
    );
  }
}
