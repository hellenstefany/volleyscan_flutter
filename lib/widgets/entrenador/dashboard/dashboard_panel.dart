import 'package:flutter/material.dart';

import 'dashboard_theme.dart';

class DashboardPanel extends StatelessWidget {
  final String title;
  final Widget child;

  const DashboardPanel({super.key, required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: DashboardTheme.bgCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: DashboardTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: DashboardTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}
