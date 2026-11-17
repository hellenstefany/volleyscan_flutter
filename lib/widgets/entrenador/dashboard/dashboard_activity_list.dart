import 'package:flutter/material.dart';

import 'dashboard_activity_row.dart';
import 'dashboard_models.dart';

class DashboardActivityList extends StatelessWidget {
  final List<DashboardActivity> activities;

  const DashboardActivityList({super.key, required this.activities});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: activities
          .map((a) => DashboardActivityRow(activity: a))
          .toList(),
    );
  }
}
