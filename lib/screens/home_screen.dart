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
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // El degradado de fondo lo pone main.dart.
      backgroundColor: Colors.transparent,
      appBar: const TopBar(),
      body: const SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(16, 16, 16, 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            HeroSection(),
            SizedBox(height: 28),
            StatsSection(),
            SizedBox(height: 28),
            FeaturesSection(),
            SizedBox(height: 28),
            PlansSection(),
            SizedBox(height: 28),
            FooterSection(),
          ],
        ),
      ),
    );
  }
}
