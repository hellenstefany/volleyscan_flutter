import 'package:flutter/material.dart';
import '../../utils/drawer_router.dart';
import 'dashboard_drawer.dart';

class MenuButton extends StatelessWidget {
  const MenuButton({super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.menu_rounded, color: Colors.white),
      tooltip: 'Menú',
      onPressed: () => Scaffold.of(context).openDrawer(),
    );
  }
}

class UserDrawer extends StatelessWidget {
  const UserDrawer({
    super.key,
    required this.selectedId,
    this.userName = 'Agustin',
  });

  final String selectedId;
  final String userName;

  @override
  Widget build(BuildContext context) {
    return DashboardDrawer(
      userName: userName,
      selectedId: selectedId,
      onSelect: (id) =>
          goToMenuItem(context, id, current: selectedId, userName: userName),
    );
  }
}
