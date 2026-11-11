import 'package:flutter/material.dart';
import '../theme/vs_colors.dart';
import 'section_head.dart';

class StatsSection extends StatefulWidget {
  const StatsSection({super.key});
  @override
  State<StatsSection> createState() => _StatsSectionState();
}

class _StatsSectionState extends State<StatsSection> {
  static const _stats = [
    [38, '%+', 'Mejora promedio', VS.gold],
    [120, '+', 'Atletas analizados', VS.cyan],
    [95, '%', 'Satisfacción', VS.gold],
    [10000, '+', 'Sesiones procesadas', VS.cyan],
  ];

  bool _visible = false;
  ScrollPosition? _pos;

  String _miles(int n) => n.toString().replaceAllMapped(
    RegExp(r'\B(?=(\d{3})+(?!\d))'),
    (_) => '.',
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _pos?.removeListener(_check);
    _pos = Scrollable.maybeOf(context)?.position;
    _pos?.addListener(_check);
    WidgetsBinding.instance.addPostFrameCallback((_) => _check());
  }

  void _check() {
    if (_visible || !mounted) return;
    final box = context.findRenderObject() as RenderBox?;
    if (box == null || !box.attached) return;
    final y = box.localToGlobal(Offset.zero).dy;
    if (y < MediaQuery.of(context).size.height * 0.8) {
      setState(() => _visible = true);
    }
  }

  @override
  void dispose() {
    _pos?.removeListener(_check);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHead(
          title: 'Resultados que hablan',
          subtitle: 'Mejoras significativas en atletas profesionales.',
        ),
        Container(
          decoration: BoxDecoration(
            color: VS.panel,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: VS.line),
          ),
          child: GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 1.35,
            children: [
              for (var i = 0; i < _stats.length; i++)
                Container(
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    border: Border(
                      left: i.isOdd
                          ? const BorderSide(color: VS.line)
                          : BorderSide.none,
                      top: i >= 2
                          ? const BorderSide(color: VS.line)
                          : BorderSide.none,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0, end: _visible ? 1 : 0),
                        duration: const Duration(milliseconds: 1200),
                        curve: Curves.easeOutCubic,
                        builder: (_, v, __) => FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            '${_miles(((_stats[i][0] as int) * v).round())}${_stats[i][1]}',
                            style: TextStyle(
                              fontFamily: VS.font,
                              color: _stats[i][3] as Color,
                              fontSize: 32,
                              height: 1,
                              letterSpacing: -1,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _stats[i][2] as String,
                        style: const TextStyle(
                          fontFamily: VS.font,
                          color: VS.muted,
                          fontSize: 13.5,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
