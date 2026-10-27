import 'package:flutter/material.dart';
import '../theme/routine_colors.dart';
import '../widgets/usuario/empty_history_card.dart';
import 'analysis_screen.dart';
import '../widgets/usuario/menu_button.dart';

class AiHistoryScreen extends StatefulWidget {
  const AiHistoryScreen({super.key});

  @override
  State<AiHistoryScreen> createState() => _AiHistoryScreenState();
}

class _AiHistoryScreenState extends State<AiHistoryScreen> {
  // TODO: cargar las sesiones guardadas del usuario (de la más reciente a la
  // más antigua). Mientras la lista esté vacía se muestra el estado vacío.
  final List<Object> _sessions = [];

  void _goToAnalysis() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AnalysisScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: RoutineColors.background,
      appBar: AppBar(
        backgroundColor: RoutineColors.background,
        elevation: 0,
        automaticallyImplyLeading: false,
        leading: const MenuButton(),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      drawer: const UserDrawer(
        selectedId: 'historial_ia',
      ), // cambia el id en cada archivo
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Historial de remates',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 30,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Tus sesiones de análisis, de la más reciente a la más antigua.',
                style: TextStyle(
                  color: RoutineColors.textMuted,
                  fontSize: 15,
                  height: 1.35,
                ),
              ),
              const SizedBox(height: 24),
              if (_sessions.isEmpty)
                EmptyHistoryCard(
                  title: 'Aún no tienes sesiones guardadas',
                  message:
                      'Analiza un remate y la sesión aparecerá aquí al terminar.',
                  buttonLabel: 'Ir a analizar',
                  onPressed: _goToAnalysis,
                )
              else
                // TODO: lista de sesiones guardadas.
                const SizedBox.shrink(),
            ],
          ),
        ),
      ),
    );
  }
}
