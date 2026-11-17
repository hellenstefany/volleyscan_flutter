import 'package:flutter/material.dart';

import 'analisis_logo.dart';
import 'analisis_pulse_dot.dart';
import 'analisis_theme.dart';

class AnalisisHeader extends StatelessWidget {
  final bool narrow;
  const AnalisisHeader({super.key, required this.narrow});

  @override
  Widget build(BuildContext context) {
    final identity = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const AnalisisLogo(size: 52, radius: 12),
        const SizedBox(width: 16),
        Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ShaderMask(
                shaderCallback: (r) => const LinearGradient(
                  colors: [Colors.white, Color(0xFFC9BDFF), Color(0xFF8FC4FF)],
                  stops: [0, 0.6, 1],
                ).createShader(r),
                child: Text(
                  'Análisis IA',
                  style: TextStyle(
                    fontSize: narrow ? 22 : 27,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.4,
                    height: 1.1,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 3),
              const Text(
                'Entrenador virtual especializado en voleibol',
                style: TextStyle(
                  fontSize: 13.5,
                  color: AnalisisTheme.textMuted,
                ),
              ),
            ],
          ),
        ),
      ],
    );

    final status = Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
      decoration: BoxDecoration(
        color: AnalisisTheme.success.withOpacity(0.06),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: AnalisisTheme.success.withOpacity(0.25)),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnalisisPulseDot(),
          SizedBox(width: 9),
          Text(
            'IA CONECTADA',
            style: TextStyle(
              fontSize: 11.8,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
              color: Color(0xFF6EE7B7),
            ),
          ),
        ],
      ),
    );

    final perfil = Wrap(
      spacing: 10,
      runSpacing: 8,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.person_pin_outlined,
              size: 14,
              color: AnalisisTheme.accent,
            ),
            const SizedBox(width: 6),
            Text(
              'PERFIL ACTIVO',
              style: AnalisisTheme.mono.copyWith(
                fontSize: 10.8,
                letterSpacing: 1.2,
                color: AnalisisTheme.textMuted,
              ),
            ),
          ],
        ),
        for (final p in AnalisisTheme.perfilDeportista)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              gradient: AnalisisTheme.surfaceGradient,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AnalisisTheme.line),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  p.$1.toUpperCase(),
                  style: AnalisisTheme.mono.copyWith(
                    fontSize: 10.5,
                    letterSpacing: 0.6,
                    color: AnalisisTheme.textMuted,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  p.$2,
                  style: const TextStyle(
                    fontSize: 12.8,
                    fontWeight: FontWeight.w700,
                    color: AnalisisTheme.textPrimary,
                  ),
                ),
              ],
            ),
          ),
      ],
    );

    return Container(
      width: double.infinity,
      // En móvil dejamos espacio para el botón flotante del menú
      padding: EdgeInsets.fromLTRB(narrow ? 64 : 32, 20, narrow ? 16 : 32, 18),
      decoration: BoxDecoration(
        color: const Color(0xFF101322),
        gradient: LinearGradient(
          colors: [
            AnalisisTheme.accent.withOpacity(0.09),
            Colors.transparent,
            AnalisisTheme.blue.withOpacity(0.08),
          ],
          stops: const [0, 0.4, 1],
        ),
        border: const Border(bottom: BorderSide(color: AnalisisTheme.line)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x40000000),
            blurRadius: 24,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (narrow) ...[
            identity,
            const SizedBox(height: 12),
            status,
          ] else
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(child: identity),
                status,
              ],
            ),
          const SizedBox(height: 16),
          perfil,
        ],
      ),
    );
  }
}
