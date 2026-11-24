import 'package:flutter/material.dart';
import '../../../models/my_level_data.dart';
import '../../../models/registro_rutina_data.dart';
import '../../../theme/dash_colors.dart';
import 'registro_rutinas_common.dart';

/// Peldaño seleccionable de la escalera de niveles en `RegistroNivelDialog`.
class RegistroNivelPeldano extends StatelessWidget {
  final String nivel;
  final String actual;
  final String seleccionado;
  final bool sube;
  final VoidCallback onTap;

  const RegistroNivelPeldano({
    super.key,
    required this.nivel,
    required this.actual,
    required this.seleccionado,
    required this.sube,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final col = regNivelColor(nivel);
    final selected = seleccionado == nivel;
    final esActual = actual == nivel;
    final subTxt = esActual
        ? 'Actual'
        : selected
            ? (sube ? 'Subir aquí' : 'Bajar aquí')
            : '';

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        width: 126,
        decoration: BoxDecoration(
          color: esActual ? col.withValues(alpha: 0.1) : DashColors.coachCard2,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? col : DashColors.coachBorder,
            width: selected ? 1.8 : 1,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(height: 3, color: col.withValues(alpha: 0.65)),
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    nombreNivelRegistro(nivel),
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: DashColors.text,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subTxt,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: selected ? col : DashColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Lista del historial de cambios de nivel del deportista.
class RegistroNivelHistorialList extends StatelessWidget {
  final DeportistaNivelDetalle? detalle;

  const RegistroNivelHistorialList({super.key, required this.detalle});

  @override
  Widget build(BuildContext context) {
    if (detalle == null) {
      return const Text(
        'Cargando…',
        style: TextStyle(color: DashColors.textMuted),
      );
    }
    if (detalle!.historial.isEmpty) {
      return const Text(
        'Aún no ha cambiado de nivel desde que lo sigues.',
        style: TextStyle(color: DashColors.textMuted),
      );
    }
    return Column(
      children: [
        for (final LevelHistoryItem h in detalle!.historial)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: (h.sube ? DashColors.green : DashColors.orange)
                        .withValues(alpha: 0.18),
                  ),
                  child: Icon(
                    h.sube ? Icons.arrow_upward : Icons.arrow_downward,
                    size: 14,
                    color: h.sube
                        ? DashColors.badgeRecepcionText
                        : DashColors.warningText,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${nombreNivelRegistro(h.anterior)} → ${nombreNivelRegistro(h.nuevo)}',
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          color: DashColors.text,
                          fontSize: 13.5,
                        ),
                      ),
                      Text(
                        '${regFormatFecha(h.fecha)}${h.entrenador != null ? ' · ${h.entrenador}' : ''}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: DashColors.textMuted,
                        ),
                      ),
                      if (h.motivo != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 3),
                          child: Text(
                            h.motivo!,
                            style: const TextStyle(
                              fontSize: 12.5,
                              color: DashColors.textSecondary,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
