import 'package:flutter/material.dart';
import 'theme/app_theme.dart';
import 'screens/home_screen.dart';
import 'screens/dashboard_screen.dart';

void main() => runApp(const VolleyScanApp());

class VolleyScanApp extends StatelessWidget {
  const VolleyScanApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'VolleyScan AI',
      theme: buildTheme(),
      // Fondo con el degradado de la web y ancho máximo de móvil
      // (en Chrome se ve centrado como un teléfono).
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
      home: const DashboardScreen(),
    );
  }
}
