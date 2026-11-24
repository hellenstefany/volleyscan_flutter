import 'package:flutter/material.dart';

import '../../models/estadisticas_entrenador_data.dart';
import '../../services/api_service.dart';
import '../../theme/app_theme.dart';
import '../../theme/dash_colors.dart';
import '../../widgets/entrenador/equipos/equipos_common_widgets.dart';
import '../../widgets/entrenador/estadisticas/estadisticas_alertas_ranking.dart';
import '../../widgets/entrenador/estadisticas/estadisticas_evolucion_card.dart';
import '../../widgets/entrenador/estadisticas/estadisticas_kpis_grid.dart';
import '../../widgets/entrenador/estadisticas/estadisticas_tecnica_errores.dart';

/// Pantalla "Estadísticas" del Panel de Entrenador (`/panel_entrenador/estadisticas`).
class EstadisticasScreen extends StatefulWidget {
  const EstadisticasScreen({super.key});

  @override
  State<EstadisticasScreen> createState() => _EstadisticasScreenState();
}

class _EstadisticasScreenState extends State<EstadisticasScreen> {
  int _dias = 30;
  int? _equipoId;
  CoachStatsResponse? _datos;
  bool _cargando = true, _refrescando = false;
  String _error = '';
  int _reqToken = 0;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar({bool resetLoading = false}) async {
    final token = ++_reqToken;
    if (mounted) {
      setState(() {
        if (resetLoading || _datos == null) _cargando = true;
        _refrescando = true;
        _error = '';
      });
    }
    try {
      final res = await ApiService().estadisticasEntrenador(dias: _dias, equipoId: _equipoId);
      if (!mounted || token != _reqToken) return;
      setState(() {
        _datos = res;
        _cargando = false;
        _refrescando = false;
        _error = '';
      });
    } on ApiException catch (e) {
      if (!mounted || token != _reqToken || e.isUnauthorized) return;
      setState(() {
        _cargando = false;
        _refrescando = false;
        _error = e.message;
      });
      showAppToast(context, e.message, type: 'error');
    } catch (_) {
      if (!mounted || token != _reqToken) return;
      setState(() {
        _cargando = false;
        _refrescando = false;
        _error = 'No se pudieron cargar las estadísticas.';
      });
    }
  }

  void _cambiarPeriodo(int dias) {
    if (dias == _dias) return;
    setState(() => _dias = dias);
    _cargar();
  }

  void _cambiarEquipo(int? equipoId) {
    if (equipoId == _equipoId) return;
    setState(() => _equipoId = equipoId);
    _cargar();
  }

  @override
  Widget build(BuildContext context) {
    final datos = _datos, kpis = datos?.kpis;
    return Material(
      color: DashColors.bg,
      child: LayoutBuilder(
        builder: (context, c) {
          final w = c.maxWidth, mobile = w < 640, wide = w >= 1020;
          return RefreshIndicator(
            color: DashColors.blue,
            backgroundColor: DashColors.cardDark,
            onRefresh: () => _cargar(),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.fromLTRB(mobile ? 14 : 24, mobile ? 64 : 28, mobile ? 14 : 24, 90),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1240),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildHeader(datos),
                      const SizedBox(height: 20),
                      if (_error.isNotEmpty) EquipoAlertBanner(text: _error, isError: true, onRetry: () => _cargar(resetLoading: true)),
                      if (_cargando && datos == null)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 32),
                          child: Row(
                            children: [
                              SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2.2, color: DashColors.blueLight)),
                              SizedBox(width: 12),
                              Text('Cargando estadísticas…', style: TextStyle(fontSize: 14, color: DashColors.textMuted)),
                            ],
                          ),
                        )
                      else if (datos != null && kpis != null)
                        kpis.deportistas == 0 ? _buildEmptyState(datos) : _buildContent(datos, kpis, w - (mobile ? 28 : 48), wide),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildContent(CoachStatsResponse datos, CoachStatsKpis kpis, double contentW, bool wide) {
    final evo = EstadisticasEvolucionCard(puntos: datos.evolucion, media: kpis.puntuacionMedia);
    final tec = EstadisticasPorTecnicaCard(lista: datos.porTecnica);
    final ale = EstadisticasAlertasCard(lista: datos.alertas);
    final err = EstadisticasErroresCard(lista: datos.erroresFrecuentes);

    return Opacity(
      opacity: _refrescando ? 0.65 : 1.0,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          EstadisticasKpisGrid(kpis: kpis, evolucion: datos.evolucion, width: contentW),
          const SizedBox(height: 18),
          if (wide)
            Row(crossAxisAlignment: CrossAxisAlignment.start, children: [Expanded(flex: 8, child: evo), const SizedBox(width: 16), Expanded(flex: 4, child: tec)])
          else ...[evo, const SizedBox(height: 16), tec],
          const SizedBox(height: 16),
          EstadisticasRankingCard(lista: datos.ranking),
          const SizedBox(height: 16),
          if (wide)
            Row(crossAxisAlignment: CrossAxisAlignment.start, children: [Expanded(child: ale), const SizedBox(width: 16), Expanded(child: err)])
          else ...[ale, const SizedBox(height: 16), err],
        ],
      ),
    );
  }

  Widget _buildHeader(CoachStatsResponse? datos) {
    final per = kEstadisticasPeriodos.firstWhere((p) => p.dias == _dias, orElse: () => kEstadisticasPeriodos[1]);
    final sub = datos != null
        ? 'Rendimiento ${datos.equipo != null ? 'de ${datos.equipo!.nombre}' : 'de tus deportistas'} en ${per.largo} · ${formatStatsShortDate(datos.periodo.desde)} – ${formatStatsShortDate(datos.periodo.hasta)}'
        : 'Rendimiento de tus deportistas';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text('Estadísticas', style: TextStyle(fontSize: 30, fontWeight: FontWeight.w800, letterSpacing: -0.6, color: DashColors.text1)),
        const SizedBox(height: 4),
        Text(sub, style: const TextStyle(fontSize: 14, color: DashColors.textMuted)),
        const SizedBox(height: 14),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            if (datos != null && datos.equipos.isNotEmpty)
              Container(
                height: 38,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(color: DashColors.cardDark, borderRadius: BorderRadius.circular(12), border: Border.all(color: DashColors.coachBorder)),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<int?>(
                    value: datos.equipos.any((e) => e.id == _equipoId) ? _equipoId : null,
                    dropdownColor: DashColors.cardDark,
                    icon: const Icon(Icons.groups_rounded, size: 16, color: DashColors.textMuted),
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: DashColors.text1),
                    items: [
                      const DropdownMenuItem<int?>(value: null, child: Text('Todos mis deportistas')),
                      for (final e in datos.equipos) DropdownMenuItem<int?>(value: e.id, child: Text(e.nombre)),
                    ],
                    onChanged: _cambiarEquipo,
                  ),
                ),
              ),
            for (final p in kEstadisticasPeriodos)
              ChoiceChip(
                label: Text(p.corto),
                selected: _dias == p.dias,
                onSelected: (_) => _cambiarPeriodo(p.dias),
                selectedColor: DashColors.blue.withValues(alpha: 0.28),
                backgroundColor: DashColors.cardDark,
                labelStyle: TextStyle(fontSize: 12.2, fontWeight: FontWeight.w600, color: _dias == p.dias ? DashColors.accent2 : DashColors.textMuted),
                side: BorderSide(color: _dias == p.dias ? DashColors.blueLight : DashColors.coachBorder),
              ),
            EquipoSecButton(label: 'Exportar CSV', mini: true, onTap: () => showAppToast(context, 'Próximamente: Exportar CSV', type: 'info')),
            EquipoPrimButton(label: 'Imprimir reporte', mini: true, onTap: () => showAppToast(context, 'Próximamente: Imprimir reporte', type: 'info')),
          ],
        ),
      ],
    );
  }

  Widget _buildEmptyState(CoachStatsResponse datos) {
    final isTeam = datos.equipo != null;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 48),
      decoration: BoxDecoration(color: DashColors.coachCard2, borderRadius: BorderRadius.circular(22), border: Border.all(color: DashColors.coachBorder)),
      child: Column(
        children: [
          const Icon(Icons.groups_rounded, size: 34, color: DashColors.accent2),
          const SizedBox(height: 10),
          Text(
            isTeam ? '${datos.equipo!.nombre} no tiene deportistas vinculados' : 'Aún no tienes deportistas vinculados',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: DashColors.text1),
          ),
          const SizedBox(height: 6),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child: Text(
              isTeam
                  ? 'Aquí solo aparecen los deportistas del equipo con los que tienes vínculo aceptado. Elige otro equipo o invita deportistas.'
                  : 'Las estadísticas se calculan con los análisis y rutinas de los deportistas que aceptaste. Cuando tengas el primero, verás todo aquí.',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 13.5, color: DashColors.textMuted, height: 1.45),
            ),
          ),
          if (isTeam) ...[
            const SizedBox(height: 16),
            EquipoPrimButton(label: 'Ver todos mis deportistas', onTap: () => _cambiarEquipo(null)),
          ],
        ],
      ),
    );
  }
}
