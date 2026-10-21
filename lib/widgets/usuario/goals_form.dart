import 'package:flutter/material.dart';
import '../../models/goals_data.dart';
import '../../theme/dash_colors.dart';
import 'dash_card.dart';
import 'form_action_buttons.dart';
import 'profile_field.dart';

/// Tarjeta "Objetivos": objetivo principal, sesiones, duración y áreas.
class GoalsForm extends StatefulWidget {
  const GoalsForm({super.key, required this.initial, required this.onSave});

  final GoalsData initial;
  final Future<void> Function(GoalsData data) onSave;

  @override
  State<GoalsForm> createState() => _GoalsFormState();
}

class _GoalsFormState extends State<GoalsForm> {
  late String _mainGoal;
  late int _sessions;
  late int _minutes;
  late Set<String> _areas;
  bool _saving = false;
  bool _areaError = false;

  @override
  void initState() {
    super.initState();
    _fill(widget.initial);
  }

  @override
  void didUpdateWidget(covariant GoalsForm old) {
    super.didUpdateWidget(old);
    if (old.initial != widget.initial) _fill(widget.initial);
  }

  void _fill(GoalsData d) {
    _mainGoal = d.mainGoal;
    _sessions = d.sessionsPerWeek;
    _minutes = d.minutesPerSession;
    _areas = {...d.areas};
    _areaError = false;
  }

  void _cancel() => setState(() => _fill(widget.initial));

  Future<void> _save() async {
    if (_saving) return;
    if (_areas.isEmpty) {
      setState(() => _areaError = true);
      return;
    }

    final data = GoalsData(
      mainGoal: _mainGoal,
      sessionsPerWeek: _sessions,
      minutesPerSession: _minutes,
      // Se conserva el orden original de las opciones.
      areas: GoalsData.areaOptions.where(_areas.contains).toList(),
    );

    setState(() => _saving = true);
    try {
      await widget.onSave(data);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Objetivos guardados correctamente')),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'No se pudieron guardar los objetivos. Intenta de nuevo.',
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _toggleArea(String name) {
    setState(() {
      if (_areas.contains(name)) {
        _areas.remove(name);
      } else {
        _areas.add(name);
      }
      _areaError = false;
    });
  }

  // ---------- UI ----------

  Widget _sliderRow({
    required String label,
    required String valueText,
    required double value,
    required double min,
    required double max,
    required int divisions,
    required ValueChanged<double> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            FieldLabel(label),
            const Spacer(),
            Text(
              valueText,
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: DashColors.blueLight,
              ),
            ),
          ],
        ),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            trackHeight: 4,
            activeTrackColor: DashColors.blueLight,
            inactiveTrackColor: Colors.white.withOpacity(0.1),
            thumbColor: DashColors.blueLight,
            overlayColor: DashColors.blueLight.withOpacity(0.15),
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 9),
            trackShape: const RoundedRectSliderTrackShape(),
          ),
          child: Slider(
            value: value,
            min: min,
            max: max,
            divisions: divisions,
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }

  Widget _areaChip(String name) {
    final on = _areas.contains(name);
    return GestureDetector(
      onTap: () => _toggleArea(name),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: on ? DashColors.blue.withOpacity(0.15) : DashColors.cardDark,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: on
                ? DashColors.blueLight.withOpacity(0.5)
                : Colors.white.withOpacity(0.1),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              on
                  ? Icons.check_box_rounded
                  : Icons.check_box_outline_blank_rounded,
              size: 20,
              color: on ? DashColors.blueLight : Colors.white.withOpacity(0.5),
            ),
            const SizedBox(width: 8),
            Text(
              name,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 13,
                color: on ? Colors.white : Colors.white.withOpacity(0.8),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DashCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Objetivos',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 18),
          ProfileDropdown(
            label: 'Objetivo principal',
            value: _mainGoal,
            items: GoalsData.mainGoals,
            onChanged: (v) => setState(() => _mainGoal = v),
          ),
          const SizedBox(height: 18),
          _sliderRow(
            label: 'Sesiones por semana',
            valueText: _sessions == 1 ? '1 sesión' : '$_sessions sesiones',
            value: _sessions.toDouble(),
            min: GoalsData.minSessions.toDouble(),
            max: GoalsData.maxSessions.toDouble(),
            divisions: GoalsData.maxSessions - GoalsData.minSessions,
            onChanged: (v) => setState(() => _sessions = v.round()),
          ),
          const SizedBox(height: 10),
          _sliderRow(
            label: 'Duración por sesión',
            valueText: '$_minutes minutos',
            value: _minutes.toDouble(),
            min: GoalsData.minMinutes.toDouble(),
            max: GoalsData.maxMinutes.toDouble(),
            divisions:
                (GoalsData.maxMinutes - GoalsData.minMinutes) ~/
                GoalsData.minutesStep,
            onChanged: (v) => setState(() => _minutes = v.round()),
          ),
          const SizedBox(height: 10),
          const FieldLabel('Áreas de mejora'),
          const SizedBox(height: 10),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [for (final a in GoalsData.areaOptions) _areaChip(a)],
          ),
          if (_areaError)
            const Padding(
              padding: EdgeInsets.only(top: 8),
              child: Text(
                'Selecciona al menos un área',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 10.5,
                  color: Color(0xFFF87171),
                ),
              ),
            ),
          const SizedBox(height: 24),
          FormActionButtons(saving: _saving, onCancel: _cancel, onSave: _save),
        ],
      ),
    );
  }
}
