import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../theme/app_theme.dart';

/// Campo de texto reutilizable que replica `.form-group` de VolleyScan_Next (`login/page.css`):
/// - Label: `#e2e8f0`, `14px`, `fontWeight: 500`, `marginBottom: 6px`
/// - Input: fondo `#0f1629`, borde `1px solid #333`, `borderRadius: 10px`, `padding: 12px`
/// - Focus: borde `#0d6efd` + halo `0 0 0 3px rgba(13, 110, 253, .2)`
/// - Error (`.input-error` + `.field-error-msg`): borde `#ef4444` + halo `0 0 0 3px rgba(239, 68, 68, .2)`
///   y texto `#ef4444` (`12px`, `marginTop: 5px`).
class AuthTextField extends StatefulWidget {
  final String label;
  final String hint;
  final TextEditingController controller;
  final bool isPassword;
  final bool obscure;
  final VoidCallback? onToggleObscure;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;
  final String? errorText;
  final List<TextInputFormatter>? inputFormatters;
  final Iterable<String>? autofillHints;
  final TextInputAction? textInputAction;
  final TextCapitalization textCapitalization;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onFieldSubmitted;

  const AuthTextField({
    super.key,
    required this.label,
    required this.hint,
    required this.controller,
    this.isPassword = false,
    this.obscure = false,
    this.onToggleObscure,
    this.keyboardType = TextInputType.text,
    this.validator,
    this.errorText,
    this.inputFormatters,
    this.autofillHints,
    this.textInputAction,
    this.textCapitalization = TextCapitalization.none,
    this.onChanged,
    this.onFieldSubmitted,
  });

  @override
  State<AuthTextField> createState() => _AuthTextFieldState();
}

class _AuthTextFieldState extends State<AuthTextField> {
  final FocusNode _focusNode = FocusNode();
  bool _hasFocus = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_onFocusChange);
  }

  void _onFocusChange() {
    if (mounted) {
      setState(() => _hasFocus = _focusNode.hasFocus);
    }
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FormField<String>(
      initialValue: widget.controller.text,
      validator: widget.validator != null
          ? (_) => widget.validator!(widget.controller.text)
          : null,
      builder: (fieldState) {
        final effectiveError = widget.errorText?.isNotEmpty == true
            ? widget.errorText
            : fieldState.errorText;
        final hasError = effectiveError != null && effectiveError.isNotEmpty;

        final Color borderColor = hasError
            ? AppColors.errorRed
            : (_hasFocus ? AppColors.loginAccentBlue : AppColors.inputBorder);

        final List<BoxShadow>? focusRing = hasError
            ? const [
                BoxShadow(
                  color: AppColors.errorGlow,
                  blurRadius: 0,
                  spreadRadius: 3,
                ),
              ]
            : (_hasFocus
                ? const [
                    BoxShadow(
                      color: AppColors.loginFocusGlow,
                      blurRadius: 0,
                      spreadRadius: 3,
                    ),
                  ]
                : null);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.label,
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.textLabel,
              ),
            ),
            const SizedBox(height: 6),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              decoration: BoxDecoration(
                color: AppColors.inputBg,
                borderRadius: BorderRadius.circular(AppRadii.sm),
                border: Border.all(color: borderColor, width: 1),
                boxShadow: focusRing,
              ),
              child: TextField(
                controller: widget.controller,
                focusNode: _focusNode,
                obscureText: widget.isPassword && widget.obscure,
                keyboardType: widget.keyboardType,
                inputFormatters: widget.inputFormatters,
                autofillHints: widget.autofillHints,
                textInputAction: widget.textInputAction,
                textCapitalization: widget.textCapitalization,
                onSubmitted: widget.onFieldSubmitted,
                onChanged: (value) {
                  fieldState.didChange(value);
                  widget.onChanged?.call(value);
                },
                enableSuggestions: !widget.isPassword,
                autocorrect: !widget.isPassword,
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 12.5,
                  color: AppColors.textPrimary,
                ),
                decoration: InputDecoration(
                  isDense: true,
                  hintText: widget.hint,
                  hintStyle: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 12.5,
                    color: AppColors.loginTextMuted.withValues(alpha: 0.65),
                  ),
                  filled: false,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12,
                  ),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  errorBorder: InputBorder.none,
                  focusedErrorBorder: InputBorder.none,
                  suffixIconConstraints: const BoxConstraints(
                    minWidth: 38,
                    minHeight: 38,
                  ),
                  suffixIcon: widget.isPassword
                      ? IconButton(
                          iconSize: 18,
                          padding: const EdgeInsets.only(right: 10),
                          constraints: const BoxConstraints(
                            minWidth: 36,
                            minHeight: 36,
                          ),
                          tooltip: widget.obscure
                              ? 'Mostrar contraseña'
                              : 'Ocultar contraseña',
                          icon: Icon(
                            widget.obscure
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                            color: AppColors.loginTextMuted,
                          ),
                          onPressed: widget.onToggleObscure,
                        )
                      : null,
                ),
              ),
            ),
            if (hasError) ...[
              const SizedBox(height: 5),
              Text(
                effectiveError,
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 12,
                  color: AppColors.errorRed,
                ),
              ),
            ],
          ],
        );
      },
    );
  }
}

