import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../theme/dash_colors.dart';

/// Vista de carga para el panel de contenido educativo.
class ContentLoadingView extends StatelessWidget {
  const ContentLoadingView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 48),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(color: DashColors.blueLight),
            SizedBox(height: 12),
            Text(
              'Cargando…',
              style: TextStyle(
                fontFamily: 'Poppins',
                color: DashColors.textMuted,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Vista de error con botón de reintento.
class ContentErrorView extends StatelessWidget {
  final String? error;
  final VoidCallback onRetry;

  const ContentErrorView({
    super.key,
    required this.error,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 12),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              color: DashColors.red,
              size: 38,
            ),
            const SizedBox(height: 12),
            Text(
              error ?? 'No se pudo cargar el contenido.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'Poppins',
                color: DashColors.red,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(
                backgroundColor: DashColors.blueLight,
                foregroundColor: DashColors.textPrimary,
              ),
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text('Reintentar'),
            ),
          ],
        ),
      ),
    );
  }
}

/// Estado vacío cuando no hay videos para la categoría seleccionada (`.empty-state`).
class ContentEmptyView extends StatelessWidget {
  const ContentEmptyView({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 50, horizontal: 20),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.movie_creation_outlined,
              size: 40,
              color: DashColors.textMuted.withValues(alpha: 0.35),
            ),
            const SizedBox(height: 12),
            const Text(
              'No hay videos para esta categoría.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Poppins',
                color: DashColors.textMuted,
                fontSize: 14.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Botón "Ver más contenido" con paginación local (`.btn-load-more`).
class ContentLoadMoreButton extends StatelessWidget {
  final bool loading;
  final VoidCallback onPressed;

  const ContentLoadMoreButton({
    super.key,
    required this.loading,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: loading ? null : onPressed,
      icon: loading
          ? const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: DashColors.textPrimary,
              ),
            )
          : const Icon(Icons.play_circle_fill_rounded, size: 20),
      label: Text(
        loading ? 'Cargando…' : 'Ver más contenido',
        style: const TextStyle(
          fontFamily: 'Poppins',
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: DashColors.blueLight,
        disabledBackgroundColor: DashColors.blueLight.withValues(alpha: 0.65),
        foregroundColor: DashColors.textPrimary,
        disabledForegroundColor: DashColors.textPrimary,
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.md),
        ),
      ),
    );
  }
}
