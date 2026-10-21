import 'package:flutter/material.dart';
import '../models/routine_data.dart';
import '../theme/routine_colors.dart';
import '../widgets/usuario/routine_exercise_tile.dart';
import '../widgets/usuario/routine_info_cards.dart';
import '../widgets/usuario/routine_progress_card.dart';

class RoutinesScreen extends StatefulWidget {
  const RoutinesScreen({super.key});

  @override
  State<RoutinesScreen> createState() => _RoutinesScreenState();
}

class _RoutinesScreenState extends State<RoutinesScreen> {
  RoutineData _routine = RoutineData.sample;

  void _startExercise(RoutineExercise exercise) {
    // TODO: navegar a la pantalla del ejercicio / cámara de análisis.
    // Por ahora lo marcamos como completado para probar el progreso.
    setState(() {
      _routine = _routine.copyWith(
        exercises: _routine.exercises
            .map((e) => e.id == exercise.id ? e.copyWith(completed: true) : e)
            .toList(),
      );
    });
  }

  void _viewFullRoutine() {
    // TODO: navegar al detalle de la rutina completa.
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: RoutineColors.background,
      appBar: AppBar(
        backgroundColor: RoutineColors.background,
        elevation: 0,
        title: const Text(
          'Rutinas',
          style: TextStyle(fontWeight: FontWeight.w800, color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      // drawer: const DashboardDrawer(),               // tu drawer existente
      // bottomNavigationBar: const DashboardBottomNav(), // tu bottom nav
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
                const SizedBox(height: 20),
                WeeklyGoalCard(goal: _routine.weeklyGoal),
                const SizedBox(height: 12),
                DifficultyCard(
                  label: _capitalize(_routine.levelLabel),
                  level: _routine.levelIndex,
                ),
                const SizedBox(height: 24),
                const Text(
                  'EJERCICIOS DE HOY',
                  style: TextStyle(
                    color: Color(0xFFCBD5E1),
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.6,
                  ),
                ),
                const SizedBox(height: 12),
                ..._routine.exercises.asMap().entries.map(
                  (entry) => RoutineExerciseTile(
                    number: entry.key + 1,
                    exercise: entry.value,
                    onStart: () => _startExercise(entry.value),
                  ),
                ),
                const SizedBox(height: 8),
                RoutineProgressCard(
                  progress: _routine.progress,
                  completed: _routine.completedCount,
                  total: _routine.exercises.length,
                  onViewFull: _viewFullRoutine,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 12,
          runSpacing: 6,
          children: [
            Text(
              _routine.title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.w800,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: RoutineColors.amber.withOpacity(0.12),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: RoutineColors.amber.withOpacity(0.6)),
              ),
              child: Text(
                _routine.levelLabel,
                style: const TextStyle(
                  color: RoutineColors.amber,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.8,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          _routine.subtitle,
          style: const TextStyle(color: RoutineColors.textMuted, fontSize: 14),
        ),
      ],
    );
  }

  String _capitalize(String s) =>
      s.isEmpty ? s : s[0].toUpperCase() + s.substring(1).toLowerCase();
}
