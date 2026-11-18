import 'package:flutter/material.dart';

import 'dashboard_models.dart';
import 'dashboard_player_row.dart';

/// Lista de la comparativa de jugadores.
class DashboardPlayersList extends StatelessWidget {
  final void Function(DashboardPlayerData player) onPlayerTap;

  const DashboardPlayersList({super.key, required this.onPlayerTap});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var i = 0; i < dashboardPlayers.length; i++)
          DashboardPlayerRow(
            rank: i + 1,
            player: dashboardPlayers[i],
            onTap: () => onPlayerTap(dashboardPlayers[i]),
          ),
      ],
    );
  }
}
