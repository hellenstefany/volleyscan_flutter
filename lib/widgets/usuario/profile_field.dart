import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../theme/dash_colors.dart';

OutlineInputBorder _border(Color c) => OutlineInputBorder(
  borderRadius: BorderRadius.circular(10),
  borderSide: BorderSide(color: c),
);

/// Estilo común de los campos del perfil (`var(--superficie)` = `DashColors.surface`).
InputDecoration profileDecoration({
  String? hint,
  String? suffixText,
  Widget? suffixIcon,
  String? errorText,
}) {
  return InputDecoration(
    hintText: hint,
    hintStyle: TextStyle(
      fontFamily: 'Poppins',
      fontSize: 13.5,
      color: Colors.white.withValues(alpha: 0.3),
    ),
    suffixText: suffixText,
    suffixStyle: TextStyle(
      fontFamily: 'Poppins',
      fontSize: 11.5,
      color: DashColors.muted,
    ),
    suffixIcon: suffixIcon,
    errorText: (errorText != null && errorText.isNotEmpty) ? errorText : null,
    errorMaxLines: 2,
    filled: true,
    fillColor: DashColors.surface,
    isDense: true,
    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
    enabledBorder: _border(DashColors.border),
    border: _border(DashColors.border),
    focusedBorder: _border(DashColors.blueLight),
    errorBorder: _border(DashColors.red),
    focusedErrorBorder: _border(DashColors.red),
    errorStyle: const TextStyle(
      fontFamily: 'Poppins',
      fontSize: 11,
      color: DashColors.red,
    ),
  );
}

const _inputStyle = TextStyle(
  fontFamily: 'Poppins',
  fontSize: 13.5,
  color: DashColors.text,
);

/// Etiqueta en mayúsculas sobre cada campo (`.pf-label` en Next).
class FieldLabel extends StatelessWidget {
  const FieldLabel(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: const TextStyle(
        fontFamily: 'Poppins',
        fontSize: 11,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.7,
        color: DashColors.muted,
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
    this.errorText,
    this.keyboardType,
    this.textInputAction,
    this.textCapitalization = TextCapitalization.none,
    this.inputFormatters,
    this.validator,
    this.onChanged,
    this.obscure = false,
    this.onToggleObscure,
  });

  final String label;
  final TextEditingController controller;
  final String? hint;
  final String? suffixText;
  final String? errorText;
  final bool obscure;
  final VoidCallback? onToggleObscure;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final TextCapitalization textCapitalization;
  final List<TextInputFormatter>? inputFormatters;
  final FormFieldValidator<String>? validator;
  final ValueChanged<String>? onChanged;

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
          onChanged: onChanged,
          obscureText: obscure,
          enableSuggestions: !obscure,
          autocorrect: !obscure,
          style: _inputStyle,
          cursorColor: DashColors.blueLight,
          decoration: profileDecoration(
            hint: hint,
            suffixText: suffixText,
            errorText: errorText,
            suffixIcon: onToggleObscure == null
                ? null
                : IconButton(
                    onPressed: onToggleObscure,
                    icon: Icon(
                      obscure
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      size: 20,
                      color: DashColors.muted,
                    ),
                  ),
          ),
        ),
      ],
    );
  }
}

/// Campo de fecha en formato `YYYY-MM-DD`: abre el selector de fecha al tocarlo.
class ProfileDateField extends StatelessWidget {
  const ProfileDateField({
    super.key,
    required this.label,
    required this.controller,
    required this.onTap,
    this.onClear,
    this.errorText,
    this.validator,
  });

  final String label;
  final TextEditingController controller;
  final VoidCallback onTap;
  final VoidCallback? onClear;
  final String? errorText;
  final FormFieldValidator<String>? validator;

  @override
  Widget build(BuildContext context) {
    final hasValue = controller.text.trim().isNotEmpty;
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
            hint: 'YYYY-MM-DD',
            errorText: errorText,
            suffixIcon: hasValue && onClear != null
                ? IconButton(
                    onPressed: onClear,
                    tooltip: 'Limpiar fecha',
                    icon: const Icon(
                      Icons.close_rounded,
                      size: 17,
                      color: DashColors.muted,
                    ),
                  )
                : const Icon(
                    Icons.calendar_today_outlined,
                    size: 17,
                    color: DashColors.muted,
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
    this.itemLabels,
    this.errorText,
    this.showArrow = true,
  });

  final bool showArrow;
  final String label;
  final String value;
  final List<String> items;
  final Map<String, String>? itemLabels;
  final String? errorText;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FieldLabel(label),
        const SizedBox(height: 6),
        DropdownButtonFormField<String>(
          initialValue: items.contains(value) ? value : null,
          isExpanded: true,
          dropdownColor: DashColors.card,
          borderRadius: BorderRadius.circular(10),
          style: _inputStyle,
          icon: showArrow
              ? const Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: DashColors.muted,
                )
              : const SizedBox.shrink(),
          decoration: profileDecoration(errorText: errorText),
          items: [
            for (final i in items)
              DropdownMenuItem<String>(
                value: i,
                child: Text(itemLabels?[i] ?? i),
              ),
          ],
          onChanged: (v) {
            if (v != null) onChanged(v);
          },
        ),
      ],
    );
  }
}
