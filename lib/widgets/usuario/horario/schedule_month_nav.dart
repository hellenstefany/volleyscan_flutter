import 'package:flutter/material.dart';
import '../../../models/schedule_data.dart';
import '../../../theme/app_theme.dart';
import '../../../theme/dash_colors.dart';

/// Navegación mensual (`←`, `Hoy`, `→`) y resumen de asistencia del mes.
class ScheduleMonthNav extends StatelessWidget {
  final DateTime month;
  final int attendedCount;
  final int totalAttendanceCount;
  final VoidCallback onPreviousMonth;
  final VoidCallback onToday;
  final VoidCallback onNextMonth;

  const ScheduleMonthNav({
    super.key,
    required this.month,
    required this.attendedCount,
    required this.totalAttendanceCount,
    required this.onPreviousMonth,
    required this.onToday,
    required this.onNextMonth,
  });

  @override
  Widget build(BuildContext context) {
    final pct = totalAttendanceCount > 0
        ? ((attendedCount / totalAttendanceCount) * 100).round()
        : 0;

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  formatScheduleMonth(month),
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: DashColors.text,
                  ),
                ),
              ),
              _NavButton(
                tooltip: 'Mes anterior',
                onPressed: onPreviousMonth,
                child: const Icon(Icons.chevron_left_rounded, size: 20),
              ),
              const SizedBox(width: 8),
              _NavButton(
                onPressed: onToday,
                child: const Text(
                  'Hoy',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              _NavButton(
                tooltip: 'Mes siguiente',
                onPressed: onNextMonth,
                child: const Icon(Icons.chevron_right_rounded, size: 20),
              ),
            ],
          ),
          if (totalAttendanceCount > 0) ...[
            const SizedBox(height: 10),
            Text.rich(
              TextSpan(
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 13.5,
                  color: DashColors.muted,
                ),
                children: [
                  TextSpan(
                    text: '$attendedCount de $totalAttendanceCount',
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      color: DashColors.text,
                    ),
                  ),
                  TextSpan(
                    text: ' eventos con asistencia este mes ($pct%)',
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  final Widget child;
  final VoidCallback onPressed;
  final String? tooltip;

  const _NavButton({
    required this.child,
    required this.onPressed,
    this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    final btn = OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        backgroundColor: DashColors.cardDark,
        foregroundColor: DashColors.textSecondary,
        side: const BorderSide(color: DashColors.coachBorder),
        minimumSize: const Size(40, 38),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.btn),
        ),
      ),
      child: child,
    );
    if (tooltip != null) {
      return Tooltip(message: tooltip!, child: btn);
    }
    return btn;
  }
}
