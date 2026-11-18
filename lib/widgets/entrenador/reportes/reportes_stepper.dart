import 'package:flutter/material.dart';
import 'reportes_colors.dart';
import 'reportes_common_widget.dart';

/// Indicador de pasos: Filtros › Vista previa › Exportar.
class ReportesStepper extends StatelessWidget {
  final int step;
  final ValueChanged<int> onGo;
  const ReportesStepper({super.key, required this.step, required this.onGo});

  @override
  Widget build(BuildContext context) {
    const labels = ['Filtros', 'Vista previa', 'Exportar'];
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: repBox(RC.card2, 14),
      child: Row(
        children: [
          for (var i = 0; i < 3; i++) ...[
            Expanded(
              child: InkWell(
                onTap: () => onGo(i + 1),
                child: Row(
                  children: [
                    RepStepNum(
                      n: i + 1,
                      active: step == i + 1,
                      done: step > i + 1,
                    ),
                    const SizedBox(width: 9),
                    Flexible(
                      child: Text(
                        labels[i],
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: step == i + 1
                              ? RC.t1
                              : step > i + 1
                              ? RC.green
                              : RC.t3,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (i < 2)
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: Icon(Icons.chevron_right, size: 16, color: RC.t3),
              ),
          ],
        ],
      ),
    );
  }
}
