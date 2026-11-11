import 'package:flutter/material.dart';
import '../widgets/top_bar.dart';
import '../widgets/hero_section.dart';
import '../widgets/stats_section.dart';
import '../widgets/features_section.dart';
import '../widgets/plans_section.dart';
import '../widgets/footer_section.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Llaves para que el menú del TopBar haga scroll a cada sección.
  final _keys = <String, GlobalKey>{
    'inicio': GlobalKey(),
    'tecnologia': GlobalKey(),
    'metricas': GlobalKey(),
    'planes': GlobalKey(),
  };

  void _goTo(String id) {
    final ctx = _keys[id]?.currentContext;
    if (ctx != null) {
      Scrollable.ensureVisible(
        ctx,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // El degradado de fondo lo pone main.dart (usa VS.bgGradient).
      backgroundColor: Colors.transparent,
      appBar: TopBar(onNavigate: _goTo),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              key: _keys['inicio'],
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: const HeroSection(),
            ),
            const SizedBox(height: 28),
            const TickerBar(), // cinta animada, a ancho completo
            const SizedBox(height: 40),
            Padding(
              key: _keys['tecnologia'],
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: const FeaturesSection(),
            ),
            const SizedBox(height: 28),
            Padding(
              key: _keys['metricas'],
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: const StatsSection(),
            ),
            const SizedBox(height: 28),
            Padding(
              key: _keys['planes'],
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: const PlansSection(),
            ),
            const SizedBox(height: 12),
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: FooterSection(),
            ),
          ],
        ),
      ),
    );
  }
}
