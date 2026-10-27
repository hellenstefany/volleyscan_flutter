import 'package:flutter/material.dart';
import '../../models/preferences_data.dart';
import '../../theme/dash_colors.dart';
import 'dash_card.dart';
import 'form_action_buttons.dart';
import 'profile_field.dart';

/// Tarjeta "Preferencias": notificaciones (interruptores) y apariencia.
class PreferencesForm extends StatefulWidget {
  const PreferencesForm({
    super.key,
    required this.initial,
    required this.onSave,
  });

  final PreferencesData initial;
  final Future<void> Function(PreferencesData data) onSave;

  @override
  State<PreferencesForm> createState() => _PreferencesFormState();
}

class _PreferencesFormState extends State<PreferencesForm> {
  late bool _sessionReminder;
  late bool _analysisCompleted;
  late bool _newContent;
  late String _language;
  late String _units;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _fill(widget.initial);
  }

  @override
  void didUpdateWidget(covariant PreferencesForm old) {
    super.didUpdateWidget(old);
    if (old.initial != widget.initial) _fill(widget.initial);
  }

  void _fill(PreferencesData d) {
    _sessionReminder = d.sessionReminder;
    _analysisCompleted = d.analysisCompleted;
    _newContent = d.newContent;
    _language = d.language;
    _units = d.units;
  }

  void _cancel() => setState(() => _fill(widget.initial));

  Future<void> _save() async {
    if (_saving) return;

    final data = PreferencesData(
      sessionReminder: _sessionReminder,
      analysisCompleted: _analysisCompleted,
      newContent: _newContent,
      language: _language,
      units: _units,
    );

    setState(() => _saving = true);
    try {
      await widget.onSave(data);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Preferencias guardadas correctamente')),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'No se pudieron guardar las preferencias. Intenta de nuevo.',
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  // ---------- UI ----------

  Widget _sectionTitle(String text) {
    return Text(
      text.toUpperCase(),
      style: TextStyle(
        fontFamily: 'Poppins',
        fontSize: 10.5,
        fontWeight: FontWeight.w600,
        letterSpacing: 1,
        color: Colors.white.withOpacity(0.45),
      ),
    );
  }

  Widget _switchTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => onChanged(!value),
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 14, 12, 14),
        decoration: BoxDecoration(
          color: DashColors.cardDark,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withOpacity(0.07)),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 13.5,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 11,
                      color: Colors.white.withOpacity(0.45),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Switch(
              value: value,
              onChanged: onChanged,
              thumbColor: WidgetStateProperty.all(Colors.white),
              activeTrackColor: DashColors.blueLight,
              inactiveTrackColor: const Color(0xFF374151),
              trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
            ),
          ],
        ),
      ),
    );
  }

  Widget _pair(Widget a, Widget b, {double minWidth = 0}) {
    return LayoutBuilder(
      builder: (context, c) {
        if (c.maxWidth >= minWidth) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: a),
              const SizedBox(width: 12),
              Expanded(child: b),
            ],
          );
        }
        return Column(children: [a, const SizedBox(height: 14), b]);
      },
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
            'Preferencias',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 18),
          _sectionTitle('Notificaciones'),
          const SizedBox(height: 10),
          _switchTile(
            title: 'Recordatorio de sesión',
            subtitle: '30 min antes del entrenamiento',
            value: _sessionReminder,
            onChanged: (v) => setState(() => _sessionReminder = v),
          ),
          const SizedBox(height: 10),
          _switchTile(
            title: 'Análisis completado',
            subtitle: 'Cuando la IA termine un análisis',
            value: _analysisCompleted,
            onChanged: (v) => setState(() => _analysisCompleted = v),
          ),
          const SizedBox(height: 10),
          _switchTile(
            title: 'Nuevos contenidos',
            subtitle: 'Videos y ejercicios nuevos',
            value: _newContent,
            onChanged: (v) => setState(() => _newContent = v),
          ),
          const SizedBox(height: 22),
          _sectionTitle('Apariencia'),
          const SizedBox(height: 12),
          _pair(
            ProfileDropdown(
              label: 'Idioma',
              value: _language,
              items: PreferencesData.languages,
              showArrow: false,
              onChanged: (v) => setState(() => _language = v),
            ),
            ProfileDropdown(
              label: 'Unidades',
              value: _units,
              items: PreferencesData.unitSystems,
              showArrow: false,
              onChanged: (v) => setState(() => _units = v),
            ),
            minWidth: 330,
          ),
          const SizedBox(height: 24),
          FormActionButtons(saving: _saving, onCancel: _cancel, onSave: _save),
        ],
      ),
    );
  }
}
