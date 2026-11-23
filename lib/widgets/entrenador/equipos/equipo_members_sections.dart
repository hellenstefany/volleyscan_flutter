import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../models/equipo.dart';
import '../../../models/my_teams_data.dart';
import '../../../theme/dash_colors.dart';
import 'equipos_common_widgets.dart';

class EquipoDeportistasSection extends StatelessWidget {
  final List<EquipoDeportista> deportistas;
  final int? busyAtletaId;
  final Future<void> Function(EquipoDeportista dep, String posicion, int? numeroCamiseta) onGuardarDeportista;
  final ValueChanged<EquipoDeportista> onAbrirFicha, onQuitarDeportista;

  const EquipoDeportistasSection({
    super.key,
    required this.deportistas,
    required this.busyAtletaId,
    required this.onGuardarDeportista,
    required this.onAbrirFicha,
    required this.onQuitarDeportista,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 34),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 12,
            runSpacing: 4,
            children: [
              Text('Deportistas', style: TextStyle(fontSize: 18.5, fontWeight: FontWeight.w700, color: DashColors.text1)),
              Text('Posición y número de camiseta son de este equipo.', style: TextStyle(fontSize: 13.8, color: DashColors.textMuted)),
            ],
          ),
          const SizedBox(height: 12),
          if (deportistas.isEmpty)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 42, horizontal: 20),
              decoration: BoxDecoration(color: DashColors.cardDark, borderRadius: BorderRadius.circular(22), border: Border.all(color: DashColors.coachBorder)),
              child: const Column(
                children: [
                  Text('Todavía no hay deportistas', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: DashColors.text1)),
                  SizedBox(height: 6),
                  Text('Invítalos con su correo y aparecerán aquí cuando acepten.', textAlign: TextAlign.center, style: TextStyle(fontSize: 14, color: DashColors.textMuted)),
                ],
              ),
            )
          else
            for (final d in deportistas)
              _FilaDeportistaItem(
                key: ValueKey('dep-${d.id}-${d.posicion}-${d.numeroCamiseta}'),
                deportista: d,
                busy: busyAtletaId == d.id,
                onGuardar: (pos, num) => onGuardarDeportista(d, pos, num),
                onFicha: () => onAbrirFicha(d),
                onQuitar: () => onQuitarDeportista(d),
              ),
        ],
      ),
    );
  }
}

class _FilaDeportistaItem extends StatefulWidget {
  final EquipoDeportista deportista;
  final bool busy;
  final Future<void> Function(String posicion, int? numeroCamiseta) onGuardar;
  final VoidCallback onFicha, onQuitar;

  const _FilaDeportistaItem({
    super.key,
    required this.deportista,
    required this.busy,
    required this.onGuardar,
    required this.onFicha,
    required this.onQuitar,
  });

  @override
  State<_FilaDeportistaItem> createState() => _FilaDeportistaItemState();
}

class _FilaDeportistaItemState extends State<_FilaDeportistaItem> {
  late final TextEditingController _posCtrl = TextEditingController(text: widget.deportista.posicion ?? '');
  late final TextEditingController _numCtrl = TextEditingController(text: widget.deportista.numeroCamiseta?.toString() ?? '');

  @override
  void dispose() {
    _posCtrl.dispose();
    _numCtrl.dispose();
    super.dispose();
  }

  bool get _sucio =>
      _posCtrl.text.trim() != (widget.deportista.posicion ?? '').trim() ||
      _numCtrl.text.trim() != (widget.deportista.numeroCamiseta?.toString() ?? '');

  @override
  Widget build(BuildContext context) {
    final d = widget.deportista;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(color: DashColors.cardDark, borderRadius: BorderRadius.circular(18), border: Border.all(color: DashColors.coachBorder)),
      child: LayoutBuilder(
        builder: (context, c) {
          final persona = Row(
            children: [
              EquipoAvatar(fotoUrl: d.fotoUrl, iniciales: d.iniciales),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(d.nombreCompleto, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w700, color: DashColors.text1)),
                    Text('${d.nivelTexto} · desde ${formatTeamShortDate(d.desde)}', style: const TextStyle(fontSize: 13, color: DashColors.textMuted)),
                  ],
                ),
              ),
            ],
          );
          final posInput = _miniField('POSICIÓN', _posCtrl, 'Ej. Punta', 50, false);
          final numInput = _miniField('N.º', _numCtrl, '—', 2, true);
          final acciones = ListenableBuilder(
            listenable: Listenable.merge([_posCtrl, _numCtrl]),
            builder: (_, _) => Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                if (_sucio)
                  EquipoPrimButton(
                    label: widget.busy ? '…' : 'Guardar',
                    mini: true,
                    enabled: !widget.busy,
                    onTap: () {
                      final raw = _numCtrl.text.trim();
                      widget.onGuardar(_posCtrl.text.trim(), raw.isEmpty ? null : int.tryParse(raw));
                    },
                  ),
                EquipoSecButton(label: 'Ficha', mini: true, enabled: !widget.busy, onTap: widget.onFicha),
                EquipoDangerButton(label: 'Sacar', mini: true, enabled: !widget.busy, onTap: widget.onQuitar),
              ],
            ),
          );
          if (c.maxWidth >= 740) {
            return Row(
              children: [
                Expanded(flex: 4, child: persona),
                const SizedBox(width: 12),
                Expanded(flex: 2, child: posInput),
                const SizedBox(width: 10),
                SizedBox(width: 84, child: numInput),
                const SizedBox(width: 12),
                acciones,
              ],
            );
          }
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              persona,
              const SizedBox(height: 10),
              Row(children: [Expanded(flex: 2, child: posInput), const SizedBox(width: 10), Expanded(child: numInput)]),
              const SizedBox(height: 10),
              acciones,
            ],
          );
        },
      ),
    );
  }

  Widget _miniField(String label, TextEditingController ctrl, String hint, int max, bool isNum) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, letterSpacing: 0.8, color: DashColors.text3)),
        const SizedBox(height: 3),
        TextField(
          controller: ctrl,
          enabled: !widget.busy,
          maxLength: max,
          keyboardType: isNum ? TextInputType.number : TextInputType.text,
          inputFormatters: isNum ? [FilteringTextInputFormatter.digitsOnly] : null,
          style: const TextStyle(color: DashColors.text1, fontSize: 13.5),
          decoration: InputDecoration(
            counterText: '',
            hintText: hint,
            hintStyle: const TextStyle(color: DashColors.text3, fontSize: 13),
            filled: true,
            fillColor: DashColors.bg,
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: DashColors.coachBorder)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: DashColors.blueLight)),
          ),
        ),
      ],
    );
  }
}

class EquipoEntrenadoresAndInvitaciones extends StatelessWidget {
  final EquipoDetalle equipo;
  final bool busy;
  final ValueChanged<EquipoEntrenador> onQuitarCoach;
  final ValueChanged<EquipoInvitacionPendiente> onReenviar, onRevocar;

  const EquipoEntrenadoresAndInvitaciones({
    super.key,
    required this.equipo,
    required this.busy,
    required this.onQuitarCoach,
    required this.onReenviar,
    required this.onRevocar,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text('Entrenadores', style: TextStyle(fontSize: 18.5, fontWeight: FontWeight.w700, color: DashColors.text1)),
        const SizedBox(height: 12),
        for (final c in equipo.entrenadores)
          Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(color: DashColors.cardDark, borderRadius: BorderRadius.circular(18), border: Border.all(color: DashColors.coachBorder)),
            child: Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 12,
              runSpacing: 10,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    EquipoAvatar(fotoUrl: c.fotoUrl, iniciales: c.iniciales),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('${c.nombreCompleto}${c.soyYo ? ' (tú)' : ''}', style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w700, color: DashColors.text1)),
                        Text(c.email, style: const TextStyle(fontSize: 13, color: DashColors.textMuted)),
                      ],
                    ),
                  ],
                ),
                Wrap(
                  spacing: 8,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    EquipoChip(text: c.esPropietario ? 'Propietario' : 'Co-entrenador', tone: c.esPropietario ? EquipoChipTone.azul : EquipoChipTone.gris),
                    if (!c.esPropietario && (c.soyYo || equipo.esPropietario))
                      EquipoDangerButton(label: c.soyYo ? 'Salir' : 'Quitar', mini: true, enabled: !busy, onTap: () => onQuitarCoach(c)),
                  ],
                ),
              ],
            ),
          ),
        if (equipo.invitaciones.isNotEmpty) ...[
          const SizedBox(height: 24),
          const Wrap(
            alignment: WrapAlignment.spaceBetween,
            spacing: 12,
            runSpacing: 4,
            children: [
              Text('Invitaciones pendientes', style: TextStyle(fontSize: 18.5, fontWeight: FontWeight.w700, color: DashColors.text1)),
              Text('Para obtener el enlace otra vez, usa «Reenviar».', style: TextStyle(fontSize: 13.8, color: DashColors.textMuted)),
            ],
          ),
          const SizedBox(height: 12),
          for (final i in equipo.invitaciones)
            Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(color: DashColors.cardDark, borderRadius: BorderRadius.circular(18), border: Border.all(color: DashColors.coachBorder)),
              child: Wrap(
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 12,
                runSpacing: 10,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(i.email, style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w700, color: DashColors.text1)),
                      Text('Invitó ${i.invitadoPor} · ${formatTeamShortDate(i.creadaEn)}', style: const TextStyle(fontSize: 13, color: DashColors.textMuted)),
                    ],
                  ),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      EquipoChip(text: i.tipo == 'entrenador' ? 'Entrenador' : 'Deportista', tone: i.tipo == 'entrenador' ? EquipoChipTone.verde : EquipoChipTone.azul),
                      EquipoChip(text: i.vencida ? 'Vencida' : 'Vence ${formatTeamShortDate(i.venceEn)}', tone: i.vencida ? EquipoChipTone.naranja : EquipoChipTone.gris),
                    ],
                  ),
                  Wrap(
                    spacing: 8,
                    children: [
                      EquipoSecButton(label: 'Reenviar', mini: true, enabled: !busy, onTap: () => onReenviar(i)),
                      EquipoDangerButton(label: 'Cancelar', mini: true, enabled: !busy, onTap: () => onRevocar(i)),
                    ],
                  ),
                ],
              ),
            ),
        ],
      ],
    );
  }
}
