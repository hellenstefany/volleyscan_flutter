import 'package:flutter/material.dart';
import '../../../models/registro_rutina_data.dart';
import '../../../theme/app_theme.dart';
import '../../../theme/dash_colors.dart';
import 'registro_rutinas_common.dart';

/// Barra de filtros de la pestaña "Registro" (estado, deportista y rango de fechas).
class RegistroFiltersBar extends StatelessWidget {
  final String estado;
  final int? atletaId;
  final String desde;
  final String hasta;
  final bool hayFiltro;
  final List<DeportistaNivelResumen> deportistas;
  final ValueChanged<String> onEstado;
  final ValueChanged<int?> onAtleta;
  final ValueChanged<String> onDesde;
  final ValueChanged<String> onHasta;
  final VoidCallback onLimpiarFiltros;

  const RegistroFiltersBar({
    super.key,
    required this.estado,
    required this.atletaId,
    required this.desde,
    required this.hasta,
    required this.hayFiltro,
    required this.deportistas,
    required this.onEstado,
    required this.onAtleta,
    required this.onDesde,
    required this.onHasta,
    required this.onLimpiarFiltros,
  });

  Future<void> _pickDate(
    BuildContext context,
    String current,
    ValueChanged<String> onPicked, {
    DateTime? firstDate,
    DateTime? lastDate,
  }) async {
    final init = DateTime.tryParse(current) ?? DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: init,
      firstDate: firstDate ?? DateTime(2020),
      lastDate: lastDate ?? DateTime(2035),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.dark(
            primary: DashColors.blueLight,
            surface: DashColors.cardDark,
            onSurface: DashColors.text,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) onPicked(regIsoDate(picked));
  }

  @override
  Widget build(BuildContext context) {
    const estados = [
      ('pendientes', 'Por revisar'),
      ('revisadas', 'Revisadas'),
      ('todas', 'Todas'),
    ];
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: DashColors.cardDark,
            borderRadius: BorderRadius.circular(13),
            border: Border.all(color: DashColors.coachBorder),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final e in estados)
                InkWell(
                  onTap: () => onEstado(e.$1),
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 13,
                      vertical: 7,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      gradient: estado == e.$1
                          ? AppGradients.sidebarActiveItem
                          : null,
                    ),
                    child: Text(
                      e.$2,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: estado == e.$1
                            ? DashColors.text
                            : DashColors.textMuted,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
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
              value: deportistas.any((d) => d.id == atletaId) ? atletaId : null,
              dropdownColor: DashColors.cardDark,
              style: const TextStyle(
                color: DashColors.text,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
              icon: const Icon(
                Icons.filter_alt_outlined,
                size: 16,
                color: DashColors.textMuted,
              ),
              items: [
                const DropdownMenuItem<int?>(
                  value: null,
                  child: Text('Todos los deportistas'),
                ),
                for (final d in deportistas)
                  DropdownMenuItem<int?>(
                    value: d.id,
                    child: Text(d.nombreCompleto),
                  ),
              ],
              onChanged: onAtleta,
            ),
          ),
        ),
        _dateBtn(
          context,
          'Desde',
          desde,
          () => _pickDate(
            context,
            desde,
            onDesde,
            lastDate: hasta.isNotEmpty ? DateTime.tryParse(hasta) : null,
          ),
        ),
        _dateBtn(
          context,
          'Hasta',
          hasta,
          () => _pickDate(
            context,
            hasta,
            onHasta,
            firstDate: desde.isNotEmpty ? DateTime.tryParse(desde) : null,
          ),
        ),
        if (hayFiltro)
          OutlinedButton(
            onPressed: onLimpiarFiltros,
            style: OutlinedButton.styleFrom(
              foregroundColor: DashColors.textSecondary,
              side: const BorderSide(color: DashColors.coachBorder),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text('Quitar filtros'),
          ),
      ],
    );
  }

  Widget _dateBtn(
    BuildContext context,
    String label,
    String value,
    VoidCallback onTap,
  ) =>
      InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          height: 40,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: DashColors.cardDark,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: DashColors.coachBorder),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '$label: ',
                style: const TextStyle(
                  fontSize: 12.5,
                  color: DashColors.textMuted,
                ),
              ),
              Text(
                value.isEmpty ? 'Todas' : value,
                style: const TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  color: DashColors.text,
                ),
              ),
            ],
          ),
        ),
      );
}
