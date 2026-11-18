import 'package:flutter/material.dart';

import 'package:volleyscan_mobile/widgets/entrenador/estadisticas/estadisticas_bar_chart.dart';
import 'package:volleyscan_mobile/widgets/entrenador/estadisticas/estadisticas_card.dart';
import 'package:volleyscan_mobile/widgets/entrenador/estadisticas/estadisticas_donut.dart';
import 'package:volleyscan_mobile/widgets/entrenador/estadisticas/estadisticas_errors_list.dart';
import 'package:volleyscan_mobile/widgets/entrenador/estadisticas/estadisticas_exercises_list.dart';
import 'package:volleyscan_mobile/widgets/entrenador/estadisticas/estadisticas_filters.dart';
import 'package:volleyscan_mobile/widgets/entrenador/estadisticas/estadisticas_line_chart.dart';
import 'package:volleyscan_mobile/widgets/entrenador/estadisticas/estadisticas_mini_cards.dart';
import 'package:volleyscan_mobile/widgets/entrenador/estadisticas/estadisticas_models.dart';
import 'package:volleyscan_mobile/widgets/entrenador/estadisticas/estadisticas_theme.dart';

class EstadisticasScreen extends StatefulWidget {
  const EstadisticasScreen({super.key});

  @override
  State<EstadisticasScreen> createState() => _EstadisticasScreenState();
}

class _EstadisticasScreenState extends State<EstadisticasScreen> {
  String _deportista = 'all';
  String _ejercicio = 'all';
  final _searchCtrl = TextEditingController();
  final Set<String> _hidden = {};
  String? _chartTip;

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  String get _search => _searchCtrl.text.trim().toLowerCase();

  List<EstadisticasPlayer> get _filteredPlayers => estadisticasPlayers
      .where(
        (p) =>
            (_deportista == 'all' || p.name == _deportista) &&
            (_search.isEmpty || p.name.toLowerCase().contains(_search)),
      )
      .toList();

  List<EstadisticasItem> get _filteredExercises {
    final base =
        estadisticasExerciseOverrides[_deportista] ?? estadisticasExercisesAll;
    return _ejercicio == 'all'
        ? base
        : base.where((e) => e.name == _ejercicio).toList();
  }

  List<EstadisticasSeries> get _filteredSeries => estadisticasEvolution
      .where(
        (s) =>
            (_deportista == 'all' || s.name == _deportista) &&
            (_search.isEmpty || s.name.toLowerCase().contains(_search)),
      )
      .toList();

  void _reset() {
    setState(() {
      _deportista = 'all';
      _ejercicio = 'all';
      _searchCtrl.clear();
      _chartTip = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final players = _filteredPlayers;
    final exercises = _filteredExercises;
    final series = _filteredSeries;

    final avgPerf = players.isEmpty
        ? 0
        : (players.fold<int>(0, (a, p) => a + p.perf) / players.length).round();
    final avgAtt = players.isEmpty
        ? 0
        : (players.fold<int>(0, (a, p) => a + p.attendance) / players.length)
              .round();

    final screenW = MediaQuery.of(context).size.width;
    // En móvil dejamos espacio para el botón flotante del menú
    final topPad = screenW < 900 ? 60.0 : 30.0;

    return Material(
      color: EstadisticasTheme.bg,
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
          screenW < 900 ? 12 : 32,
          topPad,
          screenW < 900 ? 12 : 32,
          24,
        ),
        child: LayoutBuilder(
          builder: (context, c) {
            final w = c.maxWidth;
            final wide = w >= 1100;
            final mid = w >= 700;

            final barCard = EstadisticasCard(
              title: 'Rendimiento promedio',
              child: EstadisticasBarChart(players: players),
            );
            final lineCard = EstadisticasCard(
              title: 'Evolución de rendimiento',
              child: EstadisticasLineChart(
                series: series,
                hidden: _hidden,
                chartTip: _chartTip,
                onTip: (t) => setState(() => _chartTip = t),
                onToggleSeries: (name) => setState(() {
                  _hidden.contains(name)
                      ? _hidden.remove(name)
                      : _hidden.add(name);
                }),
              ),
            );
            final donutCard = EstadisticasCard(
              title: 'Asistencia',
              child: EstadisticasDonut(avgAtt: avgAtt),
            );
            final exCard = EstadisticasCard(
              title: 'Tipos de ejercicios',
              child: EstadisticasExercisesList(exercises: exercises),
            );
            final errCard = EstadisticasCard(
              title: 'Errores comunes',
              child: EstadisticasErrorsList(
                offset: estadisticasErrorOffsets[_deportista] ?? 0,
              ),
            );

            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'ESTADÍSTICAS AVANZADAS',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: screenW < 900 ? 18 : 26,
                    fontWeight: FontWeight.w700,
                    letterSpacing: screenW < 900 ? 0 : 2,
                    color: EstadisticasTheme.text,
                  ),
                ),
                const SizedBox(height: 24),
                EstadisticasFilters(
                  width: w,
                  deportista: _deportista,
                  ejercicio: _ejercicio,
                  searchCtrl: _searchCtrl,
                  onDeportista: (v) => setState(() => _deportista = v),
                  onEjercicio: (v) => setState(() => _ejercicio = v),
                  onSearchChanged: () => setState(() {}),
                  onReset: _reset,
                ),
                const SizedBox(height: 26),
                EstadisticasMiniCards(
                  width: w,
                  avgPerf: avgPerf,
                  avgAtt: avgAtt,
                  active: players.length,
                ),
                const SizedBox(height: 18),

                // grid-top
                if (wide)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(flex: 10, child: barCard),
                      const SizedBox(width: 18),
                      Expanded(flex: 14, child: lineCard),
                    ],
                  )
                else ...[
                  barCard,
                  const SizedBox(height: 14),
                  lineCard,
                ],
                const SizedBox(height: 18),

                // grid-bottom
                if (wide)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(flex: 10, child: donutCard),
                      const SizedBox(width: 18),
                      Expanded(flex: 11, child: exCard),
                      const SizedBox(width: 18),
                      Expanded(flex: 13, child: errCard),
                    ],
                  )
                else if (mid) ...[
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: donutCard),
                      const SizedBox(width: 14),
                      Expanded(child: exCard),
                    ],
                  ),
                  const SizedBox(height: 14),
                  errCard,
                ] else ...[
                  donutCard,
                  const SizedBox(height: 14),
                  exCard,
                  const SizedBox(height: 14),
                  errCard,
                ],
              ],
            );
          },
        ),
      ),
    );
  }
}
