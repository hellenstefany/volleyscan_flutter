import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../theme/dash_colors.dart';

const _fieldBg = Color(0xFF0A1022);

OutlineInputBorder _border(Color c) => OutlineInputBorder(
  borderRadius: BorderRadius.circular(12),
  borderSide: BorderSide(color: c),
);

/// Estilo común de los campos del perfil.
InputDecoration profileDecoration({
  String? hint,
  String? suffixText,
  Widget? suffixIcon,
}) {
  return InputDecoration(
    hintText: hint,
    hintStyle: TextStyle(
      fontFamily: 'Poppins',
      fontSize: 13.5,
      color: Colors.white.withOpacity(0.3),
    ),
    suffixText: suffixText,
    suffixStyle: TextStyle(
      fontFamily: 'Poppins',
      fontSize: 11.5,
      color: Colors.white.withOpacity(0.45),
    ),
    suffixIcon: suffixIcon,
    filled: true,
    fillColor: _fieldBg,
    isDense: true,
    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
    enabledBorder: _border(Colors.white.withOpacity(0.1)),
    border: _border(Colors.white.withOpacity(0.1)),
    focusedBorder: _border(DashColors.sky),
    errorBorder: _border(const Color(0xFFF87171)),
    focusedErrorBorder: _border(const Color(0xFFF87171)),
    errorStyle: const TextStyle(fontFamily: 'Poppins', fontSize: 10.5),
  );
}

const _inputStyle = TextStyle(
  fontFamily: 'Poppins',
  fontSize: 13.5,
  color: Colors.white,
);

/// Etiqueta en mayúsculas sobre cada campo.
class FieldLabel extends StatelessWidget {
  const FieldLabel(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: TextStyle(
        fontFamily: 'Poppins',
        fontSize: 10.5,
        fontWeight: FontWeight.w600,
        letterSpacing: 1,
        color: Colors.white.withOpacity(0.55),
      ),
    );
  }
}

class ProfileTextField extends StatelessWidget {
  const ProfileTextField({
    super.key,
    required this.label,
    required this.controller,
    this.hint,
    this.suffixText,
    this.keyboardType,
    this.textInputAction,
    this.textCapitalization = TextCapitalization.none,
    this.inputFormatters,
    this.validator,
    this.obscure = false,
    this.onToggleObscure,
  });

  final String label;
  final TextEditingController controller;
  final String? hint;
  final String? suffixText;
  final bool obscure;
  final VoidCallback? onToggleObscure;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final TextCapitalization textCapitalization;
  final List<TextInputFormatter>? inputFormatters;
  final FormFieldValidator<String>? validator;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FieldLabel(label),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          textCapitalization: textCapitalization,
          inputFormatters: inputFormatters,
          validator: validator,
          obscureText: obscure,
          enableSuggestions: !obscure,
          autocorrect: !obscure,
          style: _inputStyle,
          cursorColor: DashColors.sky,
          decoration: profileDecoration(
            hint: hint,
            suffixText: suffixText,
            suffixIcon: onToggleObscure == null
                ? null
                : IconButton(
                    onPressed: onToggleObscure,
                    icon: Icon(
                      obscure
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      size: 20,
                      color: Colors.white.withOpacity(0.6),
                    ),
                  ),
          ),
        ),
      ],
    );
  }
}

/// Campo de fecha: no se escribe, abre el selector de fecha al tocarlo.
class ProfileDateField extends StatelessWidget {
  const ProfileDateField({
    super.key,
    required this.label,
    required this.controller,
    required this.onTap,
    this.validator,
  });

  final String label;
  final TextEditingController controller;
  final VoidCallback onTap;
  final FormFieldValidator<String>? validator;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FieldLabel(label),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          readOnly: true,
          onTap: onTap,
          validator: validator,
          style: _inputStyle,
          decoration: profileDecoration(
            hint: 'dd/mm/aaaa',
            suffixIcon: Icon(
              Icons.calendar_today_outlined,
              size: 17,
              color: Colors.white.withOpacity(0.6),
            ),
          ),
        ),
      ],
    );
  }
}

class ProfileDropdown extends StatelessWidget {
  const ProfileDropdown({
    super.key,
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  final String label;
  final String value;
  final List<String> items;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FieldLabel(label),
        const SizedBox(height: 6),
        DropdownButtonFormField<String>(
          value: items.contains(value) ? value : null,
          isExpanded: true,
          dropdownColor: DashColors.card,
          borderRadius: BorderRadius.circular(12),
          style: _inputStyle,
          icon: Icon(
            Icons.keyboard_arrow_down_rounded,
            color: Colors.white.withOpacity(0.6),
          ),
          decoration: profileDecoration(),
          items: [
            for (final i in items)
              DropdownMenuItem<String>(value: i, child: Text(i)),
          ],
          onChanged: (v) {
            if (v != null) onChanged(v);
          },
        ),
      ],
    );
  }
}
