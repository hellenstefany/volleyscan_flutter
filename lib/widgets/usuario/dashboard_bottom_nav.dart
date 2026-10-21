import 'package:flutter/material.dart';
import '../../theme/dash_colors.dart';

/// Barra inferior: Inicio, Rutinas, Scan IA (botón central), Historial, Perfil.
/// Índices: 0 Inicio · 1 Rutinas · 2 Scan IA · 3 Historial · 4 Perfil.
class DashboardBottomNav extends StatelessWidget {
  const DashboardBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: DashColors.bg,
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 88,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // Barra
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                height: 66,
                child: Container(
                  decoration: BoxDecoration(
                    color: DashColors.bg,
                    border: Border(
                      top: BorderSide(color: Colors.white.withOpacity(0.08)),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(child: _item(0, Icons.home_rounded, 'Inicio')),
                      Expanded(
                        child: _item(1, Icons.layers_rounded, 'Rutinas'),
                      ),
                      Expanded(child: _scanLabel()),
                      Expanded(
                        child: _item(3, Icons.history_rounded, 'Historial'),
                      ),
                      Expanded(
                        child: _item(4, Icons.person_outline_rounded, 'Perfil'),
                      ),
                    ],
                  ),
                ),
              ),
              // Botón central elevado
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: Center(
                  child: GestureDetector(
                    onTap: () => onTap(2),
                    child: Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: DashColors.blue,
                        border: Border.all(color: DashColors.bg, width: 3),
                        boxShadow: [
                          BoxShadow(
                            color: DashColors.blue.withOpacity(0.45),
                            blurRadius: 18,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.photo_camera_rounded,
                        size: 26,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _item(int index, IconData icon, String label) {
    final active = currentIndex == index;
    final color = active ? DashColors.blueLight : DashColors.muted;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => onTap(index),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 24, color: color),
          const SizedBox(height: 3),
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 10.5,
              fontWeight: active ? FontWeight.w600 : FontWeight.w400,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _scanLabel() {
    final active = currentIndex == 2;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => onTap(2),
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 9),
          child: Text(
            'Scan IA',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 10.5,
              fontWeight: active ? FontWeight.w600 : FontWeight.w400,
              color: active ? DashColors.blueLight : DashColors.muted,
            ),
          ),
        ),
      ),
    );
  }
}
