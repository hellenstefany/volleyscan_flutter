import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../models/profile_data.dart';
import '../../theme/dash_colors.dart';
import '../../utils/validators.dart';
import 'dash_card.dart';
import 'form_action_buttons.dart';
import 'profile_avatar.dart';
import 'profile_field.dart';

/// Tarjeta "Información personal": foto, campos editables y botones.
class PersonalInfoForm extends StatefulWidget {
  const PersonalInfoForm({
    super.key,
    required this.initial,
    required this.onSave,
    this.photoPath,
    this.onChangePhoto,
  });

  final ProfileData initial;
  final Future<void> Function(ProfileData data) onSave;
  final String? photoPath;
  final VoidCallback? onChangePhoto;

  @override
  State<PersonalInfoForm> createState() => _PersonalInfoFormState();
}

class _PersonalInfoFormState extends State<PersonalInfoForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _birthCtrl = TextEditingController();
  final _weightCtrl = TextEditingController();
  final _heightCtrl = TextEditingController();

  DateTime? _birthDate;
  String _level = ProfileData.levels.first;
  String _position = ProfileData.positions.first;
  bool _saving = false;

  static final _nameFormatters = <TextInputFormatter>[
    FilteringTextInputFormatter.allow(RegExp(r"[A-Za-zÁÉÍÓÚÜÑáéíóúüñ '\-]")),
    LengthLimitingTextInputFormatter(60),
  ];
  static final _emailFormatters = <TextInputFormatter>[
    FilteringTextInputFormatter.deny(RegExp(r'\s')),
    LengthLimitingTextInputFormatter(254),
  ];
  static final _weightFormatters = <TextInputFormatter>[
    FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
    LengthLimitingTextInputFormatter(5),
  ];
  static final _heightFormatters = <TextInputFormatter>[
    FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
    LengthLimitingTextInputFormatter(4),
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
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _birthCtrl.dispose();
    _weightCtrl.dispose();
    _heightCtrl.dispose();
    super.dispose();
  }

  // ---------- helpers ----------

  String _two(int n) => n.toString().padLeft(2, '0');

  String _fmtDate(DateTime d) => '${_two(d.day)}/${_two(d.month)}/${d.year}';

  String _fmtWeight(double v) => v == v.roundToDouble()
      ? v.toInt().toString()
      : v.toString().replaceAll('.', ',');

  String _fmtHeight(double v) => v.toStringAsFixed(2).replaceAll('.', ',');

  double? _parse(String s) => double.tryParse(s.trim().replaceAll(',', '.'));

  void _fill(ProfileData d) {
    _nameCtrl.text = d.fullName;
    _emailCtrl.text = d.email;
    _birthDate = d.birthDate;
    _birthCtrl.text = _fmtDate(d.birthDate);
    _weightCtrl.text = _fmtWeight(d.weightKg);
    _heightCtrl.text = _fmtHeight(d.heightM);
    _level = d.level;
    _position = d.position;
  }

  // ---------- validaciones ----------

  String? _validateName(String? v) {
    final t = (v ?? '').trim();
    if (t.isEmpty) return 'Ingresa tu nombre completo';
    if (t.length < 2) return 'Nombre muy corto';
    return null;
  }

  String? _validateWeight(String? v) {
    final n = _parse(v ?? '');
    if (n == null) return 'Ingresa tu peso';
    if (n < 30 || n > 250) return 'Entre 30 y 250 kg';
    return null;
  }

  String? _validateHeight(String? v) {
    final n = _parse(v ?? '');
    if (n == null) return 'Ingresa tu estatura';
    if (n < 1 || n > 2.5) return 'Entre 1,00 y 2,50 m';
    return null;
  }

  // ---------- acciones ----------

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _birthDate ?? DateTime(now.year - 20, 1, 1),
      firstDate: DateTime(now.year - 90),
      lastDate: now,
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.dark(
            primary: DashColors.blue,
            surface: DashColors.card,
            onSurface: Colors.white,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() {
        _birthDate = picked;
        _birthCtrl.text = _fmtDate(picked);
      });
    }
  }

  void _cancel() {
    FocusScope.of(context).unfocus();
    setState(() => _fill(widget.initial));
  }

  Future<void> _save() async {
    FocusScope.of(context).unfocus();
    if (_saving) return;
    if (!_formKey.currentState!.validate()) return;

    final data = ProfileData(
      fullName: _nameCtrl.text.trim(),
      email: _emailCtrl.text.trim().toLowerCase(),
      birthDate: _birthDate!,
      level: _level,
      weightKg: _parse(_weightCtrl.text)!,
      heightM: _parse(_heightCtrl.text)!,
      position: _position,
    );

    setState(() => _saving = true);
    try {
      await widget.onSave(data);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cambios guardados correctamente')),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'No se pudieron guardar los cambios. Intenta de nuevo.',
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  // ---------- UI ----------

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

  Widget _photoRow() {
    return Row(
      children: [
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Colors.white.withOpacity(0.15)),
          ),
          child: ProfileAvatar(
            name: _nameCtrl.text,
            photoPath: widget.photoPath,
            size: 76,
            cornerRadius: 17,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const FieldLabel('Foto de perfil'),
              const SizedBox(height: 10),
              SizedBox(
                height: 34,
                child: ElevatedButton(
                  onPressed: widget.onChangePhoto,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: DashColors.blueLight,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'Cambiar foto',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
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
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            _photoRow(),
            const SizedBox(height: 20),
            ProfileTextField(
              label: 'Nombre completo',
              controller: _nameCtrl,
              textCapitalization: TextCapitalization.words,
              textInputAction: TextInputAction.next,
              inputFormatters: _nameFormatters,
              validator: _validateName,
            ),
            const SizedBox(height: 14),
            ProfileTextField(
              label: 'Correo electrónico',
              controller: _emailCtrl,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              inputFormatters: _emailFormatters,
              validator: Validators.email,
            ),
            const SizedBox(height: 14),
            _pair(
              ProfileDateField(
                label: 'Fecha de nacimiento',
                controller: _birthCtrl,
                onTap: _pickDate,
                validator: (_) =>
                    _birthDate == null ? 'Selecciona tu fecha' : null,
              ),
              ProfileDropdown(
                label: 'Nivel',
                value: _level,
                items: ProfileData.levels,
                onChanged: (v) => setState(() => _level = v),
              ),
              minWidth: 330,
            ),
            const SizedBox(height: 14),
            _pair(
              ProfileTextField(
                label: 'Peso',
                controller: _weightCtrl,
                suffixText: 'kg',
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                textInputAction: TextInputAction.next,
                inputFormatters: _weightFormatters,
                validator: _validateWeight,
              ),
              ProfileTextField(
                label: 'Estatura',
                controller: _heightCtrl,
                suffixText: 'm',
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                textInputAction: TextInputAction.done,
                inputFormatters: _heightFormatters,
                validator: _validateHeight,
              ),
            ),
            const SizedBox(height: 14),
            ProfileDropdown(
              label: 'Posición',
              value: _position,
              items: ProfileData.positions,
              onChanged: (v) => setState(() => _position = v),
            ),
            const SizedBox(height: 24),
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
