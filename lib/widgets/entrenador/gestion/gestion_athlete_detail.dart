import 'package:flutter/material.dart';
import 'gestion_athlete.dart';
import 'gestion_colors.dart';
import 'gestion_common_widgets.dart';

class AthleteDetail extends StatelessWidget {
  final Athlete? athlete;
  final VoidCallback onProfile;
  const AthleteDetail({
    super.key,
    required this.athlete,
    required this.onProfile,
  });

  @override
  Widget build(BuildContext context) {
    final s = athlete;
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: boxDeco(GC.card2, 18),
      child: s == null ? _empty() : _content(s),
    );
  }

  Widget _empty() => const Padding(
    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 60),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.person_off_outlined, size: 28, color: GC.t3),
        SizedBox(height: 10),
        Text(
          'Selecciona un deportista para ver su información',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 13, color: GC.t3),
        ),
      ],
    ),
  );

  Widget _content(Athlete s) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      _header(s),
      Padding(padding: const EdgeInsets.all(18), child: _stats(s)),
      Padding(
        padding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
        child: GradientButton(
          label: 'Ver perfil completo',
          radius: 11,
          padding: const EdgeInsets.all(12),
          onTap: onProfile,
        ),
      ),
    ],
  );

  Widget _header(Athlete s) => Container(
    padding: const EdgeInsets.fromLTRB(18, 22, 18, 18),
    decoration: const BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [GC.card, GC.hover],
      ),
      border: Border(bottom: BorderSide(color: GC.border)),
    ),
    child: Column(
      children: [
        Container(
          width: 72,
          height: 72,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: colorFor(s.id),
            border: Border.all(
              color: GC.accent.withValues(alpha: 0.35),
              width: 3,
            ),
            boxShadow: [
              BoxShadow(
                color: GC.accent.withValues(alpha: 0.18),
                blurRadius: 20,
              ),
            ],
          ),
          child: Text(
            initials(s.nombre),
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          s.nombre,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: GC.t1,
          ),
        ),
        const SizedBox(height: 3),
        Text(s.pos, style: const TextStyle(fontSize: 12, color: GC.t2)),
        const SizedBox(height: 4),
        Text(
          '${s.edad} años · Categoría: ${s.cat}',
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 11.5, color: GC.t3),
        ),
      ],
    ),
  );

  Widget _stats(Athlete s) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text(
        'RENDIMIENTO PROMEDIO',
        style: TextStyle(
          fontSize: 10.5,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.6,
          color: GC.t3,
        ),
      ),
      const SizedBox(height: 4),
      Row(
        crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.alphabetic,
        children: [
          Text(
            '${s.perf}%',
            style: const TextStyle(
              fontFamily: 'monospace',
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: GC.t1,
            ),
          ),
          const SizedBox(width: 10),
          Text(
            '${s.trend >= 0 ? '↑' : '↓'} ${s.trend.abs()}%',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: s.trend >= 0 ? GC.green : GC.red,
            ),
          ),
        ],
      ),
      const SizedBox(height: 14),
      StatLine('Asistencia', '${s.asis}%'),
      StatLine('Sesiones completadas', '${s.ses}'),
      StatLine('Nivel', s.nivel, last: true),
    ],
  );
}
