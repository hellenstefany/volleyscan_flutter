import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../models/registro_rutina_data.dart';
import '../../../theme/app_theme.dart';
import '../../../theme/dash_colors.dart';
import 'registro_nivel_card.dart';
import 'registro_rutinas_common.dart';

/// Pestaña "Niveles": distribución, reglas de ascenso y tarjetas por deportista.
class RegistroNivelesTab extends StatelessWidget {
  final double width;
  final List<DeportistaNivelResumen>? lista;
  final String error;
  final VoidCallback onReintentar;
  final ValueChanged<DeportistaNivelResumen> onCambiarNivel;
  final ValueChanged<int> onVerRegistro;

  const RegistroNivelesTab({
    super.key,
    required this.width,
    required this.lista,
    required this.error,
    required this.onReintentar,
    required this.onCambiarNivel,
    required this.onVerRegistro,
  });

  @override
  Widget build(BuildContext context) {
    if (error.isNotEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: DashColors.orange.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: DashColors.orange.withValues(alpha: 0.4)),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                error,
                style: const TextStyle(color: DashColors.warningText),
              ),
            ),
            TextButton(onPressed: onReintentar, child: const Text('Reintentar')),
          ],
        ),
      );
    }

    if (lista == null) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 32),
        child: Center(
          child: Column(
            children: [
              CircularProgressIndicator(color: DashColors.blueLight),
              SizedBox(height: 12),
              Text(
                'Cargando niveles…',
                style: TextStyle(color: DashColors.textMuted),
              ),
            ],
          ),
        ),
      );
    }

    if (lista!.isEmpty) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 46, horizontal: 20),
        decoration: BoxDecoration(
          color: DashColors.coachCard2,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: DashColors.coachBorder),
        ),
        child: const Column(
          children: [
            Icon(Icons.trending_up_rounded, size: 36, color: DashColors.accent2),
            SizedBox(height: 10),
            Text(
              'Aún no tienes deportistas',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: DashColors.text,
              ),
            ),
            SizedBox(height: 6),
            Text(
              'Cuando acepten tu vínculo o entren a uno de tus equipos, podrás seguir su nivel desde aquí.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13.5, color: DashColors.textMuted),
            ),
          ],
        ),
      );
    }

    final orden = List<DeportistaNivelResumen>.of(lista!)
      ..sort((a, b) {
        final sA = a.avance.sugerencia != null ? 1 : 0;
        final sB = b.avance.sugerencia != null ? 1 : 0;
        if (sB != sA) return sB - sA;
        if (b.pendientesRevision != a.pendientesRevision) {
          return b.pendientesRevision - a.pendientesRevision;
        }
        return a.nombre.compareTo(b.nombre);
      });

    final sugeridos = orden.where((d) => d.avance.sugerencia != null).length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildDistribucion(orden, sugeridos),
        const SizedBox(height: 12),
        const Text(
          'El sistema sugiere subir de nivel cuando, desde el último cambio (máximo 90 días), el deportista tiene al menos 5 rutinas revisadas a su nivel o superior, calificación promedio de 4,0 o más y cumple el 80 % de sus rutinas.',
          style: TextStyle(
            fontSize: 12.5,
            color: DashColors.textMuted,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 16),
        _buildGrid(orden),
      ],
    );
  }

  Widget _buildDistribucion(List<DeportistaNivelResumen> orden, int sugeridos) {
    final items = [
      for (final n in kNivelesOrden)
        (
          nombreNivelRegistro(n),
          orden.where((d) => d.nivel == n).length,
          regNivelColor(n),
        ),
      ('Listos para subir', sugeridos, DashColors.green),
    ];
    const gap = 10.0;
    final cols = width >= 850 ? 5 : (width >= 520 ? 3 : 2);
    final itemW = math.max(110.0, (width - gap * (cols - 1)) / cols);

    return Wrap(
      spacing: gap,
      runSpacing: gap,
      children: [
        for (final it in items)
          SizedBox(
            width: itemW,
            child: Container(
              decoration: BoxDecoration(
                gradient: AppGradients.coachCardBg,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: DashColors.coachBorder),
              ),
              clipBehavior: Clip.antiAlias,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(height: 3, color: it.$3),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${it.$2}',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            color: DashColors.text,
                            height: 1.1,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          it.$1.toUpperCase(),
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.8,
                            color: DashColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildGrid(List<DeportistaNivelResumen> orden) {
    const gap = 14.0;
    final cols = math.max(1, ((width + gap) / (340 + gap)).floor());
    final itemW = (width - gap * (cols - 1)) / cols;

    return Wrap(
      spacing: gap,
      runSpacing: gap,
      children: [
        for (final d in orden)
          SizedBox(
            width: itemW,
            child: RegistroNivelCard(
              d: d,
              onCambiarNivel: () => onCambiarNivel(d),
              onVerRegistro: () => onVerRegistro(d.id),
            ),
          ),
      ],
    );
  }
}
