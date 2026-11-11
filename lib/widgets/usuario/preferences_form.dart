import 'package:flutter/material.dart';
import '../../models/preferences_data.dart';
import '../../services/api_service.dart';
import '../../theme/app_theme.dart';
import '../../theme/dash_colors.dart';
import 'dash_card.dart';
import 'form_action_buttons.dart';
import 'profile_field.dart';

/// Tarjeta "Preferencias" (`SeccionPreferencias.jsx` en Next):
/// conectada a `GET | PUT /api/usuario/configuracion/`.
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
  late bool _notifSesion;
  late bool _notifAnalisis;
  late bool _notifContenido;
  late String _idioma;
  late String _unidadMedida;
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
    _notifSesion = d.notifSesion;
    _notifAnalisis = d.notifAnalisis;
    _notifContenido = d.notifContenido;
    _idioma = d.idioma;
    _unidadMedida = d.unidadMedida;
  }

  void _cancel() {
    setState(() => _fill(widget.initial));
    showAppToast(context, 'Cambios descartados.', type: 'info');
  }

  Future<void> _save() async {
    if (_saving) return;

    final data = PreferencesData(
      notifSesion: _notifSesion,
      notifAnalisis: _notifAnalisis,
      notifContenido: _notifContenido,
      idioma: _idioma,
      unidadMedida: _unidadMedida,
    );

    setState(() => _saving = true);
    try {
      await widget.onSave(data);
    } on ApiException catch (err) {
      if (mounted) showAppToast(context, err.message, type: 'error');
    } catch (_) {
      if (mounted) {
        showAppToast(
          context,
          'Error al guardar las preferencias.',
          type: 'error',
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Widget _sectionTitle(String text) {
    return Text(
      text.toUpperCase(),
      style: const TextStyle(
        fontFamily: 'Poppins',
        fontSize: 10.5,
        fontWeight: FontWeight.w600,
        letterSpacing: 1,
        color: DashColors.muted,
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
        padding: const EdgeInsets.fromLTRB(16, 13, 12, 13),
        decoration: BoxDecoration(
          color: DashColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: DashColors.border),
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
                      color: DashColors.text,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 11,
                      color: DashColors.muted,
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

  Widget _pair(Widget a, Widget b) {
    return LayoutBuilder(
      builder: (_, c) => c.maxWidth >= 330
          ? Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: a),
                const SizedBox(width: 12),
                Expanded(child: b),
              ],
            )
          : Column(children: [a, const SizedBox(height: 14), b]),
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
              color: DashColors.text,
            ),
          ),
          const SizedBox(height: 18),
          _sectionTitle('Notificaciones'),
          const SizedBox(height: 10),
          _switchTile(
            title: 'Recordatorio de sesión',
            subtitle: '30 min antes del entrenamiento',
            value: _notifSesion,
            onChanged: (v) => setState(() => _notifSesion = v),
          ),
          const SizedBox(height: 10),
          _switchTile(
            title: 'Análisis completado',
            subtitle: 'Cuando la IA termine un análisis',
            value: _notifAnalisis,
            onChanged: (v) => setState(() => _notifAnalisis = v),
          ),
          const SizedBox(height: 10),
          _switchTile(
            title: 'Nuevos contenidos',
            subtitle: 'Videos y ejercicios nuevos',
            value: _notifContenido,
            onChanged: (v) => setState(() => _notifContenido = v),
          ),
          const SizedBox(height: 22),
          _sectionTitle('Apariencia'),
          const SizedBox(height: 12),
          _pair(
            ProfileDropdown(
              label: 'Idioma',
              value: _idioma,
              items: PreferencesData.idiomaLabels.keys.toList(),
              itemLabels: PreferencesData.idiomaLabels,
              onChanged: (v) => setState(() => _idioma = v),
            ),
            ProfileDropdown(
              label: 'Unidades',
              value: _unidadMedida,
              items: PreferencesData.unidadLabels.keys.toList(),
              itemLabels: PreferencesData.unidadLabels,
              onChanged: (v) => setState(() => _unidadMedida = v),
            ),
          ),
          const SizedBox(height: 24),
          FormActionButtons(saving: _saving, onCancel: _cancel, onSave: _save),
        ],
      ),
    );
  }
}
