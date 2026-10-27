import 'package:flutter/material.dart';
import '../utils/bottom_nav_router.dart';
import '../widgets/usuario/dashboard_bottom_nav.dart';
import '../models/analysis_data.dart';
import '../theme/routine_colors.dart';
import '../widgets/usuario/analysis_camera_panel.dart';
import '../widgets/usuario/analysis_measure_panel.dart';
import '../widgets/usuario/menu_button.dart';

class AnalysisScreen extends StatefulWidget {
  const AnalysisScreen({super.key});

  @override
  State<AnalysisScreen> createState() => _AnalysisScreenState();
}

class _AnalysisScreenState extends State<AnalysisScreen> {
  final AnalysisData _data = AnalysisData.empty();
  bool _cameraOn = false;

  void _toggleCamera() {
    // TODO: pedir permiso de cámara, iniciar/detener el stream y la
    // detección de pose. Cada frame debe llamar, por ejemplo:
    //   _data.joints[0].left.update(anguloCodoIzq);
    //   setState(() {});
    setState(() => _cameraOn = !_cameraOn);
  }

  void _resetRanges() => setState(_data.resetRanges);

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
        title: const Text(
          'Análisis de remate',
          style: TextStyle(fontWeight: FontWeight.w800, color: Colors.white),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: ElevatedButton(
              onPressed: _toggleCamera,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3B82F6),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(
                _cameraOn ? 'Detener cámara' : 'Activar cámara',
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ],
      ),
      drawer: const UserDrawer(selectedId: 'analisis_ia'),
      bottomNavigationBar: DashboardBottomNav(
        currentIndex: 2,
        onTap: (i) => goToTab(context, i, current: 2),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              AnalysisCameraPanel(cameraOn: _cameraOn),
              const SizedBox(height: 16),
              AnalysisMeasurePanel(data: _data, onResetRanges: _resetRanges),
            ],
          ),
        ),
      ),
    );
  }
}
