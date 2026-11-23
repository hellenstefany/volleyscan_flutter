import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../models/equipo.dart';
import '../../../theme/app_theme.dart';
import '../../../theme/dash_colors.dart';
import 'equipos_common_widgets.dart';

class EquipoInvitePanel extends StatelessWidget {
  final String tipo;
  final ValueChanged<String> onTipoChanged;
  final TextEditingController emailCtrl;
  final bool busy;
  final VoidCallback onSubmit;
  final EquipoInvitacionCreada? resultado;

  const EquipoInvitePanel({
    super.key,
    required this.tipo,
    required this.onTipoChanged,
    required this.emailCtrl,
    required this.busy,
    required this.onSubmit,
    this.resultado,
  });

  @override
  Widget build(BuildContext context) {
    final esDep = tipo == 'deportista';
    return Container(
      margin: const EdgeInsets.only(bottom: 26),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppGradients.coachCardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: DashColors.coachBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              color: DashColors.bg,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: DashColors.coachBorder),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _tab('Invitar deportista', esDep, () => onTipoChanged('deportista')),
                _tab('Invitar entrenador', !esDep, () => onTipoChanged('entrenador')),
              ],
            ),
          ),
          const SizedBox(height: 14),
          LayoutBuilder(
            builder: (context, c) {
              final emailField = Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    esDep ? 'CORREO DE LA PERSONA' : 'CORREO DE TU COLEGA',
                    style: const TextStyle(fontSize: 11.8, fontWeight: FontWeight.w700, letterSpacing: 0.9, color: DashColors.textMuted),
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: emailCtrl,
                    keyboardType: TextInputType.emailAddress,
                    onSubmitted: (_) => onSubmit(),
                    style: const TextStyle(color: DashColors.text1, fontSize: 14),
                    decoration: InputDecoration(
                      hintText: 'nombre@correo.com',
                      hintStyle: const TextStyle(color: DashColors.text3, fontSize: 13.5),
                      filled: true,
                      fillColor: DashColors.bg,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: DashColors.coachBorder)),
                      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: DashColors.blueLight)),
                    ),
                  ),
                ],
              );
              final btn = ListenableBuilder(
                listenable: emailCtrl,
                builder: (_, _) => EquipoPrimButton(
                  label: busy ? 'Enviando…' : 'Enviar invitación',
                  enabled: !busy && emailCtrl.text.trim().isNotEmpty,
                  onTap: onSubmit,
                ),
              );
              if (c.maxWidth >= 600) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [Expanded(child: emailField), const SizedBox(width: 12), btn],
                );
              }
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [emailField, const SizedBox(height: 12), btn],
              );
            },
          ),
          const SizedBox(height: 10),
          Text(
            esDep
                ? 'Recibirá un correo con un enlace. Al aceptar entra al equipo y tú podrás ver sus rutinas, progreso y estadísticas.'
                : 'Tu colega tendrá las mismas competencias dentro del equipo (menos archivarlo o quitar a otros entrenadores).',
            style: const TextStyle(fontSize: 13.4, color: DashColors.textMuted),
          ),
          if (resultado != null) ...[
            const SizedBox(height: 14),
            EquipoCajaEnlace(resultado: resultado!),
          ],
        ],
      ),
    );
  }

  Widget _tab(String label, bool active, VoidCallback onTap) => GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
          decoration: BoxDecoration(
            gradient: active ? AppGradients.coachPrimaryBtn : null,
            borderRadius: BorderRadius.circular(9),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13.4,
              fontWeight: FontWeight.w600,
              color: active ? DashColors.textPrimary : DashColors.textMuted,
            ),
          ),
        ),
      );
}

class EquipoCajaEnlace extends StatefulWidget {
  final EquipoInvitacionCreada resultado;
  const EquipoCajaEnlace({super.key, required this.resultado});

  @override
  State<EquipoCajaEnlace> createState() => _EquipoCajaEnlaceState();
}

class _EquipoCajaEnlaceState extends State<EquipoCajaEnlace> {
  bool _copiado = false;

  Future<void> _copiar() async {
    await Clipboard.setData(ClipboardData(text: widget.resultado.enlace));
    if (!mounted) return;
    setState(() => _copiado = true);
    showAppToast(context, 'Enlace copiado al portapapeles.', type: 'info');
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _copiado = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final r = widget.resultado;
    final c = r.emailEnviado ? DashColors.green : DashColors.orange;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: c.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: c.withValues(alpha: r.emailEnviado ? 0.35 : 0.45)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            r.emailEnviado
                ? '✓ Correo enviado a ${r.email}'
                : 'No se pudo enviar el correo a ${r.email}. Copia el enlace y mándaselo por WhatsApp o donde prefieras.',
            style: const TextStyle(fontSize: 13.8, fontWeight: FontWeight.w700, color: DashColors.text1),
          ),
          const SizedBox(height: 4),
          const Text(
            'El enlace funciona 7 días, solo con la cuenta de ese correo.',
            style: TextStyle(fontSize: 13, color: DashColors.textMuted),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
                  decoration: BoxDecoration(
                    color: DashColors.bg,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: DashColors.coachBorder),
                  ),
                  child: SelectableText(
                    r.enlace,
                    maxLines: 1,
                    style: const TextStyle(fontSize: 12.8, color: DashColors.text1),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              EquipoSecButton(label: _copiado ? '¡Copiado!' : 'Copiar', mini: true, onTap: _copiar),
            ],
          ),
        ],
      ),
    );
  }
}
