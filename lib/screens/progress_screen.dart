import 'package:flutter/material.dart';
import '../models/progress_data.dart';
import '../theme/routine_colors.dart';
import '../widgets/usuario/frequent_errors_card.dart';
import '../widgets/usuario/performance_chart_card.dart';
import '../widgets/usuario/progress_stat_cards.dart';
import '../widgets/usuario/technique_donut_card.dart';

class ProgressScreen extends StatefulWidget {
  const ProgressScreen({super.key});

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
  // TODO: reemplazar por datos reales según el periodo elegido.
  final ProgressData _data = ProgressData.sample;

  static const _periods = [
    'Últimos 7 días',
    'Últimos 30 días',
    'Últimos 90 días',
  ];
  String _period = 'Últimos 30 días';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: RoutineColors.background,
      appBar: AppBar(
        backgroundColor: RoutineColors.background,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Progreso',
          style: TextStyle(fontWeight: FontWeight.w800, color: Colors.white),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: RoutineColors.card,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: RoutineColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                const SizedBox(height: 16),
                ProgressStatCards(data: _data),
                const SizedBox(height: 16),
                PerformanceChartCard(values: _data.evolution),
                const SizedBox(height: 16),
                FrequentErrorsCard(errors: _data.errors),
                const SizedBox(height: 16),
                TechniqueDonutCard(techniques: _data.techniques),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        const Expanded(
          child: Text(
            'Resumen de progreso',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: RoutineColors.cardDark,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: RoutineColors.border),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _period,
              dropdownColor: RoutineColors.cardDark,
              iconEnabledColor: Colors.white,
              style: const TextStyle(color: Colors.white, fontSize: 13),
              items: _periods
                  .map((p) => DropdownMenuItem(value: p, child: Text(p)))
                  .toList(),
              onChanged: (v) {
                if (v != null) setState(() => _period = v);
              },
            ),
          ),
        ),
      ],
    );
  }
}
