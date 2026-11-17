import 'package:flutter/material.dart';

import 'dashboard_date_picker.dart';
import 'dashboard_new_session_button.dart';
import 'dashboard_theme.dart';

class DashboardTopbar extends StatelessWidget {
  final bool narrow;
  final String dateLabel;
  final ValueChanged<String> onDateSelected;
  final VoidCallback onNewSession;

  const DashboardTopbar({
    super.key,
    required this.narrow,
    required this.dateLabel,
    required this.onDateSelected,
    required this.onNewSession,
  });

  @override
  Widget build(BuildContext context) {
    const title = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Dashboard',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: DashboardTheme.textPrimary,
          ),
        ),
        SizedBox(height: 2),
        Text(
          'Resumen general de tu equipo',
          style: TextStyle(fontSize: 13, color: DashboardTheme.textSecondary),
        ),
      ],
    );

    final actions = Wrap(
      spacing: 12,
      runSpacing: 10,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        DashboardDatePicker(label: dateLabel, onSelected: onDateSelected),
        DashboardNewSessionButton(onTap: onNewSession),
      ],
    );

    return Container(
      width: double.infinity,
      // En móvil dejamos espacio para el botón flotante del menú
      padding: EdgeInsets.fromLTRB(narrow ? 76 : 28, 20, narrow ? 16 : 28, 20),
      decoration: const BoxDecoration(
        color: DashboardTheme.bgSecondary,
        border: Border(bottom: BorderSide(color: DashboardTheme.border)),
      ),
      child: narrow
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [title, const SizedBox(height: 14), actions],
            )
          : Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 16,
              runSpacing: 12,
              children: [title, actions],
            ),
    );
  }
}
