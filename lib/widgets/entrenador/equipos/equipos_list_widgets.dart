import 'package:flutter/material.dart';

import '../../../models/equipo.dart';
import '../../../models/my_teams_data.dart';
import '../../../theme/app_theme.dart';
import '../../../theme/dash_colors.dart';
import 'equipos_common_widgets.dart';

class EquiposListHeader extends StatelessWidget {
  final bool formOpen;
  final VoidCallback onToggleForm;

  const EquiposListHeader({super.key, required this.formOpen, required this.onToggleForm});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Wrap(
        alignment: WrapAlignment.spaceBetween,
        crossAxisAlignment: WrapCrossAlignment.end,
        spacing: 16,
        runSpacing: 16,
        children: [
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 620),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('MI CLUB', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, letterSpacing: 1.6, color: DashColors.accent2)),
                SizedBox(height: 4),
                Text('Equipos', style: TextStyle(fontSize: 32, fontWeight: FontWeight.w800, letterSpacing: -0.5, color: DashColors.text1)),
                SizedBox(height: 4),
                Text(
                  'Crea tus equipos, invita a deportistas y a otros entrenadores por correo, y lleva el registro de tus aprendices.',
                  style: TextStyle(fontSize: 14.5, height: 1.45, color: DashColors.textMuted),
                ),
              ],
            ),
          ),
          EquipoPrimButton(label: formOpen ? 'Cancelar' : '+ Nuevo equipo', onTap: onToggleForm),
        ],
      ),
    );
  }
}

class EquipoFormPanel extends StatelessWidget {
  final TextEditingController nombreCtrl, categoriaCtrl, temporadaCtrl;
  final String submitLabel, loadingLabel;
  final bool busy, isEdit;
  final VoidCallback onSubmit;

  const EquipoFormPanel({
    super.key,
    required this.nombreCtrl,
    required this.categoriaCtrl,
    required this.temporadaCtrl,
    required this.submitLabel,
    required this.loadingLabel,
    required this.busy,
    this.isEdit = false,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 26),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppGradients.coachCardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: DashColors.coachBorder),
      ),
      child: LayoutBuilder(
        builder: (context, c) {
          final fNombre = _field(isEdit ? 'NOMBRE' : 'NOMBRE DEL EQUIPO', nombreCtrl, isEdit ? null : 'Ej. Sub-17 Femenino', 100);
          final fCat = _field('CATEGORÍA', categoriaCtrl, isEdit ? null : 'Juvenil', 50);
          final fTemp = _field('TEMPORADA', temporadaCtrl, isEdit ? null : '2026', 20);
          final btn = ListenableBuilder(
            listenable: nombreCtrl,
            builder: (_, _) {
              final ok = !busy && (isEdit ? nombreCtrl.text.trim().isNotEmpty : nombreCtrl.text.trim().length >= 2);
              return EquipoPrimButton(label: busy ? loadingLabel : submitLabel, enabled: ok, onTap: onSubmit);
            },
          );
          if (c.maxWidth >= 780) {
            return Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(flex: 2, child: fNombre),
                const SizedBox(width: 12),
                Expanded(child: fCat),
                const SizedBox(width: 12),
                Expanded(child: fTemp),
                const SizedBox(width: 12),
                btn,
              ],
            );
          }
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [fNombre, const SizedBox(height: 12), fCat, const SizedBox(height: 12), fTemp, const SizedBox(height: 14), btn],
          );
        },
      ),
    );
  }

  Widget _field(String label, TextEditingController ctrl, String? hint, int max) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 11.8, fontWeight: FontWeight.w700, letterSpacing: 0.9, color: DashColors.textMuted)),
        const SizedBox(height: 6),
        TextField(
          controller: ctrl,
          maxLength: max,
          style: const TextStyle(color: DashColors.text1, fontSize: 14),
          decoration: InputDecoration(
            counterText: '',
            hintText: hint,
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
  }
}

class EquiposReceivedInvitations extends StatelessWidget {
  final List<TeamInvitation> invitaciones;
  final bool busy;
  final void Function(TeamInvitation inv, String accion) onResponder;

  const EquiposReceivedInvitations({super.key, required this.invitaciones, required this.busy, required this.onResponder});

  @override
  Widget build(BuildContext context) {
    if (invitaciones.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        children: [
          for (final inv in invitaciones)
            Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
              decoration: BoxDecoration(
                color: AppColors.blue.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppColors.blue.withValues(alpha: 0.45)),
              ),
              child: Wrap(
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 14,
                runSpacing: 12,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${inv.invitadoPor} te invita a ser entrenador de «${inv.equipo.nombre}»',
                        style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w700, color: DashColors.text1),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        [inv.equipo.categoria, inv.equipo.temporada].whereType<String>().where((s) => s.isNotEmpty).join(' · ').isNotEmpty
                            ? [inv.equipo.categoria, inv.equipo.temporada].whereType<String>().where((s) => s.isNotEmpty).join(' · ')
                            : 'Equipo',
                        style: const TextStyle(fontSize: 13.2, color: DashColors.textMuted),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      EquipoPrimButton(label: 'Aceptar', mini: true, enabled: !busy, onTap: () => onResponder(inv, 'aceptar')),
                      const SizedBox(width: 8),
                      EquipoSecButton(label: 'Rechazar', mini: true, enabled: !busy, onTap: () => onResponder(inv, 'rechazar')),
                    ],
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class EquiposEmptyState extends StatelessWidget {
  const EquiposEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 20),
      decoration: BoxDecoration(color: DashColors.cardDark, borderRadius: BorderRadius.circular(22), border: Border.all(color: DashColors.coachBorder)),
      child: const Column(
        children: [
          Text('Aún no tienes equipos', style: TextStyle(fontSize: 19, fontWeight: FontWeight.w700, color: DashColors.text1)),
          SizedBox(height: 6),
          Text('Crea el primero y empieza a invitar a tus deportistas.', textAlign: TextAlign.center, style: TextStyle(fontSize: 14, color: DashColors.textMuted)),
        ],
      ),
    );
  }
}

class EquiposGrid extends StatelessWidget {
  final List<Equipo> equipos;
  final ValueChanged<Equipo> onOpenEquipo;

  const EquiposGrid({super.key, required this.equipos, required this.onOpenEquipo});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        final w = c.maxWidth;
        final cols = w >= 1040 ? 3 : (w >= 660 ? 2 : 1);
        const gap = 16.0;
        final itemW = ((w - gap * (cols - 1)) / cols).clamp(0.0, w).toDouble();
        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: [
            for (final e in equipos)
              SizedBox(width: itemW, child: _EquipoCard(equipo: e, onTap: () => onOpenEquipo(e))),
          ],
        );
      },
    );
  }
}

class _EquipoCard extends StatelessWidget {
  final Equipo equipo;
  final VoidCallback onTap;

  const _EquipoCard({required this.equipo, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(22),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(22),
          onTap: onTap,
          child: Ink(
            decoration: BoxDecoration(
              gradient: AppGradients.coachCardBg,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: DashColors.coachBorder),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(height: 3, decoration: const BoxDecoration(gradient: AppGradients.coachPrimaryBtn)),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(equipo.nombre, style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w700, color: DashColors.text1)),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: [
                          EquipoChip(
                            text: equipo.esPropietario ? 'Propietario' : 'Co-entrenador',
                            tone: equipo.esPropietario ? EquipoChipTone.azul : EquipoChipTone.verde,
                          ),
                          if (equipo.categoria != null) EquipoChip(text: equipo.categoria!),
                          if (equipo.temporada != null) EquipoChip(text: equipo.temporada!),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          _cifra(equipo.deportistas, 'Deportistas'),
                          const SizedBox(width: 8),
                          _cifra(equipo.entrenadores, 'Entrenadores'),
                          const SizedBox(width: 8),
                          _cifra(equipo.invitacionesPendientes, 'Invitaciones'),
                        ],
                      ),
                      const SizedBox(height: 14),
                      const Text('Abrir equipo →', style: TextStyle(fontSize: 13.8, fontWeight: FontWeight.w600, color: DashColors.accent2)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _cifra(int value, String label) => Expanded(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(color: DashColors.textMuted.withValues(alpha: 0.07), borderRadius: BorderRadius.circular(12)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('$value', style: const TextStyle(fontSize: 21, fontWeight: FontWeight.w800, height: 1.1, color: DashColors.text1)),
              const SizedBox(height: 2),
              Text(label, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 11.8, color: DashColors.textMuted)),
            ],
          ),
        ),
      );
}
