import 'package:flutter/material.dart';
import 'theme/app_theme.dart';
import 'screens/home_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/entrenador/entrenador_shell.dart';

void main() => runApp(const VolleyScanApp());

class VolleyScanApp extends StatelessWidget {
  const VolleyScanApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'VolleyScan AI',
      theme: buildTheme(),
      builder: (context, child) {
        return DecoratedBox(
          decoration: const BoxDecoration(gradient: AppGradients.background),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: child,
            ),
          ),
        );
      },
      home: const SelectorPanel(), // <- antes: DashboardScreen()
    );
  }
}

/// Pantalla temporal para elegir qué panel ver mientras desarrollas.
class SelectorPanel extends StatelessWidget {
  const SelectorPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'VolleyScan AI',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.person),
                  label: const Text('Panel de Usuario'),
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const DashboardScreen()),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.sports),
                  label: const Text('Panel de Entrenador'),
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const EntrenadorShell()),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
