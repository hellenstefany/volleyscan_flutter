import 'package:flutter/material.dart';

import 'analisis_composer.dart';
import 'analisis_models.dart';
import 'analisis_theme.dart';

/// Vista de Bienvenida (`vacio == true` en `page.jsx` / `.ai-welcome` en `Analisis.css`).
class AnalisisWelcomeView extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focus;
  final bool escribiendo;
  final bool narrow;
  final double bottomSafePadding;
  final void Function(String texto) onSend;

  const AnalisisWelcomeView({
    super.key,
    required this.controller,
    required this.focus,
    required this.escribiendo,
    required this.narrow,
    required this.onSend,
    this.bottomSafePadding = 0,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final content = Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const _AiOrb(),
            const SizedBox(height: 26),
            const Text(
              'ENTRENADOR VIRTUAL DE VOLEIBOL',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w500,
                letterSpacing: 3.7,
                color: AnalisisTheme.text2,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              '¿Listo para entrenar hoy?',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: narrow ? 22.4 : 27.2,
                fontWeight: FontWeight.w500,
                letterSpacing: 0.1,
                color: AnalisisTheme.text,
              ),
            ),
            const SizedBox(height: 30),
            AnalisisComposer(
              controller: controller,
              focus: focus,
              escribiendo: escribiendo,
              maxWidth: 760,
              onSend: onSend,
            ),
            const SizedBox(height: 20),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 760),
              child: narrow
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        for (var i = 0; i < AnalisisConfig.tarjetas.length; i++)
                          Padding(
                            padding: EdgeInsets.only(top: i == 0 ? 0 : 12),
                            child: _WelcomeCard(
                              data: AnalisisConfig.tarjetas[i],
                              onTap: () =>
                                  onSend(AnalisisConfig.tarjetas[i].pregunta),
                            ),
                          ),
                      ],
                    )
                  : IntrinsicHeight(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          for (
                            var i = 0;
                            i < AnalisisConfig.tarjetas.length;
                            i++
                          ) ...[
                            if (i > 0) const SizedBox(width: 12),
                            Expanded(
                              child: _WelcomeCard(
                                data: AnalisisConfig.tarjetas[i],
                                onTap: () =>
                                    onSend(AnalisisConfig.tarjetas[i].pregunta),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
            ),
          ],
        );

        final hPad = narrow ? 16.0 : 32.0;
        final topPad = narrow ? 16.0 : 20.0;
        final botPad = (narrow ? 24.0 : 36.0) + bottomSafePadding;

        return SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(hPad, topPad, hPad, botPad),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: (constraints.maxHeight - topPad - botPad).clamp(
                0.0,
                double.infinity,
              ),
            ),
            child: Align(
              alignment: narrow ? Alignment.topCenter : Alignment.center,
              child: content,
            ),
          ),
        );
      },
    );
  }
}

/// Esfera central `.ai-orb` con gradiente cian/verde/azul, reflejo superior y animación flotante.
class _AiOrb extends StatefulWidget {
  const _AiOrb();

  @override
  State<_AiOrb> createState() => _AiOrbState();
}

class _AiOrbState extends State<_AiOrb> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2500),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      builder: (_, child) {
        final dy = -5.0 * Curves.easeInOut.transform(_c.value);
        return Transform.translate(offset: Offset(0, dy), child: child);
      },
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: const RadialGradient(
            center: Alignment.center,
            radius: 0.55,
            colors: [
              Color(0xFF5EEAD4),
              Color(0xFF14B8A6),
              Color(0xFF0E7490),
              Color(0xFF0B3A78),
            ],
            stops: [0.0, 0.35, 0.65, 1.0],
          ),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.25),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF2DD4BF).withValues(alpha: 0.55),
              blurRadius: 34,
            ),
            BoxShadow(
              color: const Color(0xFF0EA5E9).withValues(alpha: 0.30),
              blurRadius: 80,
            ),
          ],
        ),
        child: Stack(
          children: [
            // Brillo superior izquierdo (`radial-gradient(circle at 32% 26%, rgba(255,255,255,0.85)...)`)
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    center: const Alignment(-0.36, -0.48),
                    radius: 0.45,
                    colors: [
                      Colors.white.withValues(alpha: 0.85),
                      Colors.white.withValues(alpha: 0.0),
                    ],
                  ),
                ),
              ),
            ),
            // Brillo cálido inferior derecho (`radial-gradient(circle at 72% 80%, rgba(250,204,21,0.55)...)`)
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    center: const Alignment(0.44, 0.60),
                    radius: 0.50,
                    colors: [
                      const Color(0xFFFACC15).withValues(alpha: 0.55),
                      const Color(0xFFFACC15).withValues(alpha: 0.0),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Tarjeta rápida `.ai-card` de la vista de bienvenida.
class _WelcomeCard extends StatefulWidget {
  final WelcomeCardData data;
  final VoidCallback onTap;

  const _WelcomeCard({required this.data, required this.onTap});

  @override
  State<_WelcomeCard> createState() => _WelcomeCardState();
}

class _WelcomeCardState extends State<_WelcomeCard> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(AnalisisTheme.radiusCard),
          onTap: widget.onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AnalisisTheme.surface,
              borderRadius: BorderRadius.circular(AnalisisTheme.radiusCard),
              border: Border.all(
                color: _hover
                    ? AnalisisTheme.accent.withValues(alpha: 0.55)
                    : AnalisisTheme.line,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.25),
                  blurRadius: 22,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: AnalisisTheme.surface2,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AnalisisTheme.lineStrong),
                      ),
                      child: Icon(
                        widget.data.icono,
                        size: 15,
                        color: AnalisisTheme.cardIconFg,
                      ),
                    ),
                    Icon(
                      Icons.north_east_rounded,
                      size: 16,
                      color: _hover
                          ? AnalisisTheme.accent
                          : AnalisisTheme.text3,
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Text(
                  widget.data.titulo,
                  style: const TextStyle(
                    fontSize: 13.1,
                    fontWeight: FontWeight.w700,
                    color: AnalisisTheme.text,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  widget.data.texto,
                  style: const TextStyle(
                    fontSize: 11.2,
                    height: 1.55,
                    color: AnalisisTheme.text3,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
