import 'package:flutter/material.dart';
import '../../../models/equipo.dart';
import '../../../theme/dash_colors.dart';

/// Cabecera y pestañas ("Registro" / "Niveles") de `RegistroRutinasScreen`.
class RegistroHeaderAndTabs extends StatelessWidget {
  final List<Equipo> equipos;
  final int? equipoId;
  final String pestana;
  final int pendientesTotal;
  final int sugeridos;
  final ValueChanged<int?> onEquipoChanged;
  final VoidCallback onSelectRegistro;
  final VoidCallback onSelectNiveles;

  const RegistroHeaderAndTabs({
    super.key,
    required this.equipos,
    required this.equipoId,
    required this.pestana,
    required this.pendientesTotal,
    required this.sugeridos,
    required this.onEquipoChanged,
    required this.onSelectRegistro,
    required this.onSelectNiveles,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Wrap(
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.end,
          spacing: 16,
          runSpacing: 12,
          children: [
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'SEGUIMIENTO',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.5,
                    color: DashColors.accent2,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Registro de rutinas',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    color: DashColors.text,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Observa las rutinas que tus deportistas ya completaron y decide cuándo suben de nivel.',
                  style: TextStyle(fontSize: 13.5, color: DashColors.textMuted),
                ),
              ],
            ),
            if (equipos.isNotEmpty)
              Container(
                height: 40,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: DashColors.cardDark,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: DashColors.coachBorder),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<int?>(
                    value: equipos.any((e) => e.id == equipoId)
                        ? equipoId
                        : null,
                    dropdownColor: DashColors.cardDark,
                    style: const TextStyle(
                      color: DashColors.text,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                    items: [
                      const DropdownMenuItem<int?>(
                        value: null,
                        child: Text('Todos mis equipos'),
                      ),
                      for (final e in equipos)
                        DropdownMenuItem<int?>(
                          value: e.id,
                          child: Text(e.nombre),
                        ),
                    ],
                    onChanged: onEquipoChanged,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 18),
        Container(
          decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: DashColors.coachBorder)),
          ),
          child: Row(
            children: [
              _tabBtn(
                'Registro',
                pestana == 'registro',
                badge: pendientesTotal,
                badgeBg: DashColors.orange.withValues(alpha: 0.18),
                badgeFg: DashColors.warningText,
                onTap: onSelectRegistro,
              ),
              _tabBtn(
                'Niveles',
                pestana == 'niveles',
                badge: sugeridos,
                badgeBg: DashColors.green.withValues(alpha: 0.18),
                badgeFg: DashColors.successBadgeText,
                onTap: onSelectNiveles,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _tabBtn(
    String label,
    bool active, {
    required int badge,
    required Color badgeBg,
    required Color badgeFg,
    required VoidCallback onTap,
  }) =>
      InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 11),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: active ? DashColors.blueLight : Colors.transparent,
                width: 2,
              ),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: active ? DashColors.text : DashColors.textMuted,
                ),
              ),
              if (badge > 0) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 7,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: badgeBg,
                    borderRadius: BorderRadius.circular(99),
                  ),
                  child: Text(
                    '$badge',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: badgeFg,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      );
}
