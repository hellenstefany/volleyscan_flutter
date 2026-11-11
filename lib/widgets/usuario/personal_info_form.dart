import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../models/profile_data.dart';
import '../../services/api_service.dart';
import '../../theme/app_theme.dart';
import '../../theme/dash_colors.dart';
import '../../utils/validators.dart';
import 'dash_card.dart';
import 'form_action_buttons.dart';
import 'profile_field.dart';
import 'profile_photo_panel.dart';

/// Tarjeta "Información personal" (`SeccionPersonal.jsx` en Next):
/// foto (cambiar y quitar), campos editables con errores por campo y botones.
class PersonalInfoForm extends StatefulWidget {
  const PersonalInfoForm({
    super.key,
    required this.initial,
    required this.onSave,
    required this.onChangePhoto,
    required this.onRemovePhoto,
    this.uploadingPhoto = false,
  });

  final ProfileData initial;
  final Future<void> Function(ProfileData data) onSave;
  final VoidCallback onChangePhoto;
  final VoidCallback onRemovePhoto;
  final bool uploadingPhoto;

  @override
  State<PersonalInfoForm> createState() => _PersonalInfoFormState();
}

class _PersonalInfoFormState extends State<PersonalInfoForm> {
  final _formKey = GlobalKey<FormState>();
  final _nombreCtrl = TextEditingController();
  final _apellidoCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _fechaCtrl = TextEditingController();
  final _pesoCtrl = TextEditingController();
  final _estaturaCtrl = TextEditingController();

  String _nivel = 'intermedio';
  String _posicion = '';
  bool _saving = false;
  Map<String, String> _apiErrors = {};

  static final _numFmt = <TextInputFormatter>[
    FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
    LengthLimitingTextInputFormatter(6),
  ];

  @override
  void initState() {
    super.initState();
    _fill(widget.initial);
  }

  @override
  void didUpdateWidget(covariant PersonalInfoForm old) {
    super.didUpdateWidget(old);
    if (old.initial != widget.initial) _fill(widget.initial);
  }

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _apellidoCtrl.dispose();
    _emailCtrl.dispose();
    _fechaCtrl.dispose();
    _pesoCtrl.dispose();
    _estaturaCtrl.dispose();
    super.dispose();
  }

  void _fill(ProfileData d) {
    _nombreCtrl.text = d.nombre;
    _apellidoCtrl.text = d.apellido;
    _emailCtrl.text = d.email;
    _fechaCtrl.text = d.fechaNac ?? '';
    _pesoCtrl.text = d.peso == null
        ? ''
        : (d.peso == d.peso!.roundToDouble()
              ? d.peso!.toInt().toString()
              : d.peso!.toStringAsFixed(2));
    _estaturaCtrl.text = d.estatura == null
        ? ''
        : d.estatura!.toStringAsFixed(2);
    _nivel = ProfileData.nivelLabels.containsKey(d.nivel)
        ? d.nivel!
        : 'intermedio';
    _posicion = ProfileData.posicionLabels.containsKey(d.posicion ?? '')
        ? (d.posicion ?? '')
        : '';
    _apiErrors = {};
  }

  double? _parseNum(String s) {
    final clean = s.trim().replaceAll(',', '.');
    return clean.isEmpty ? null : double.tryParse(clean);
  }

  void _clearFieldError(String key) {
    if (_apiErrors.containsKey(key)) {
      setState(() => _apiErrors = {..._apiErrors}..remove(key));
    }
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final initial =
        DateTime.tryParse(_fechaCtrl.text) ?? DateTime(now.year - 20, 1, 1);
    final picked = await showDatePicker(
      context: context,
      initialDate: initial.isAfter(now) ? now : initial,
      firstDate: DateTime(1930, 1, 1),
      lastDate: now,
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.dark(
            primary: DashColors.blueLight,
            surface: DashColors.card,
            onSurface: Colors.white,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      final y = picked.year.toString().padLeft(4, '0');
      final m = picked.month.toString().padLeft(2, '0');
      final d = picked.day.toString().padLeft(2, '0');
      setState(() {
        _fechaCtrl.text = '$y-$m-$d';
        _apiErrors.remove('fecha_nac');
      });
    }
  }

  void _cancel() {
    FocusScope.of(context).unfocus();
    setState(() => _fill(widget.initial));
    showAppToast(context, 'Cambios descartados.', type: 'info');
  }

  Future<void> _save() async {
    FocusScope.of(context).unfocus();
    if (_saving) return;
    setState(() => _apiErrors = {});
    if (!_formKey.currentState!.validate()) return;

    final updated = widget.initial.copyWith(
      nombre: _nombreCtrl.text.trim(),
      apellido: _apellidoCtrl.text.trim(),
      email: _emailCtrl.text.trim().toLowerCase(),
      nivel: _nivel,
      posicion: _posicion.isEmpty ? null : _posicion,
      clearPosicion: _posicion.isEmpty,
      peso: _parseNum(_pesoCtrl.text),
      clearPeso: _pesoCtrl.text.trim().isEmpty,
      estatura: _parseNum(_estaturaCtrl.text),
      clearEstatura: _estaturaCtrl.text.trim().isEmpty,
      fechaNac: _fechaCtrl.text.trim().isEmpty ? null : _fechaCtrl.text.trim(),
      clearFechaNac: _fechaCtrl.text.trim().isEmpty,
    );

    setState(() => _saving = true);
    try {
      await widget.onSave(updated);
    } on ApiException catch (err) {
      if (!mounted) return;
      final fieldErrs = <String, String>{};
      if (err.data is Map) {
        (err.data as Map).forEach((k, v) {
          if (v is List && v.isNotEmpty) {
            fieldErrs[k.toString()] = v.first.toString();
          } else if (v is String && v.isNotEmpty) {
            fieldErrs[k.toString()] = v;
          }
        });
      }
      if (fieldErrs.isNotEmpty) setState(() => _apiErrors = fieldErrs);
      showAppToast(context, err.message, type: 'error');
    } catch (_) {
      if (mounted) {
        showAppToast(context, 'Error al guardar los cambios.', type: 'error');
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
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
    final fullName = '${_nombreCtrl.text} ${_apellidoCtrl.text}'.trim();
    return DashCard(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: _formKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Información personal',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: DashColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            ProfilePhotoPanel(
              name: fullName.isEmpty ? widget.initial.fullName : fullName,
              photoUrl: widget.initial.fotoUrl,
              uploading: widget.uploadingPhoto,
              onChangePhoto: widget.onChangePhoto,
              onRemovePhoto: widget.onRemovePhoto,
            ),
            const SizedBox(height: 18),
            _pair(
              ProfileTextField(
                label: 'Nombre',
                controller: _nombreCtrl,
                textCapitalization: TextCapitalization.words,
                errorText: _apiErrors['nombre'],
                onChanged: (_) => _clearFieldError('nombre'),
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'El nombre es obligatorio.'
                    : null,
              ),
              ProfileTextField(
                label: 'Apellido',
                controller: _apellidoCtrl,
                textCapitalization: TextCapitalization.words,
                errorText: _apiErrors['apellido'],
                onChanged: (_) => _clearFieldError('apellido'),
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'El apellido es obligatorio.'
                    : null,
              ),
            ),
            const SizedBox(height: 14),
            ProfileTextField(
              label: 'Correo electrónico',
              controller: _emailCtrl,
              keyboardType: TextInputType.emailAddress,
              errorText: _apiErrors['email'],
              onChanged: (_) => _clearFieldError('email'),
              validator: Validators.email,
            ),
            const SizedBox(height: 14),
            _pair(
              ProfileDateField(
                label: 'Fecha de nacimiento',
                controller: _fechaCtrl,
                onTap: _pickDate,
                onClear: () => setState(() => _fechaCtrl.clear()),
                errorText: _apiErrors['fecha_nac'],
              ),
              ProfileDropdown(
                label: 'Nivel',
                value: _nivel,
                items: ProfileData.nivelLabels.keys.toList(),
                itemLabels: ProfileData.nivelLabels,
                errorText: _apiErrors['nivel'],
                onChanged: (v) => setState(() => _nivel = v),
              ),
            ),
            const SizedBox(height: 14),
            _pair(
              ProfileTextField(
                label: 'Peso',
                controller: _pesoCtrl,
                suffixText: 'kg',
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                inputFormatters: _numFmt,
                errorText: _apiErrors['peso'],
                onChanged: (_) => _clearFieldError('peso'),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return null;
                  final n = _parseNum(v);
                  if (n == null || n < 20 || n > 250) return '20 a 250 kg';
                  return null;
                },
              ),
              ProfileTextField(
                label: 'Estatura',
                controller: _estaturaCtrl,
                suffixText: 'm',
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                inputFormatters: _numFmt,
                errorText: _apiErrors['estatura'],
                onChanged: (_) => _clearFieldError('estatura'),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return null;
                  final n = _parseNum(v);
                  if (n == null || n < 1.0 || n > 2.5) return '1.00 a 2.50 m';
                  return null;
                },
              ),
            ),
            const SizedBox(height: 14),
            ProfileDropdown(
              label: 'Posición',
              value: _posicion,
              items: ProfileData.posicionLabels.keys.toList(),
              itemLabels: ProfileData.posicionLabels,
              errorText: _apiErrors['posicion'],
              onChanged: (v) => setState(() => _posicion = v),
            ),
            const SizedBox(height: 22),
            FormActionButtons(
              saving: _saving,
              onCancel: _cancel,
              onSave: _save,
            ),
          ],
        ),
      ),
    );
  }
}
