import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// ── Colores (variables CSS) ──
const _bgPrimary = Color(0xFF0A0C14);
const _accent = Color(0xFF7C5CFC);
const _accentHover = Color(0xFF947CFF);
const _blue = Color(0xFF4F9DFC);
const _textPrimary = Color(0xFFF0F3FF);
const _textSecondary = Color(0xFF9AA1B9);
const _textMuted = Color(0xFF6A6F8A);
const _line = Color(0xFF252A3C);
const _lineStrong = Color(0xFF343B57);
const _success = Color(0xFF10B981);
const _surfaceTop = Color(0xFF181C2B);
const _surfaceBottom = Color(0xFF141723);

const _aiGradient = LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [_accent, _blue],
);

const _surfaceGradient = LinearGradient(
  begin: Alignment.topCenter,
  end: Alignment.bottomCenter,
  colors: [_surfaceTop, _surfaceBottom],
);

const _mono = TextStyle(fontFamily: 'monospace');

// ── Datos ──
const _perfilDeportista = [
  ('Posición', 'Armador'),
  ('Nivel', 'Intermedio'),
  ('Objetivo', 'Mejorar salto'),
];

const _welcome =
    """¡Hola! 👋 Soy tu entrenador personal de voleibol basado en IA.

Puedo ayudarte con:
✅ Rutinas de entrenamiento personalizadas
✅ Análisis técnico por posición
✅ Recomendaciones para mejorar rendimiento
✅ Respuesta a dudas tácticas

¿En qué puedo ayudarte hoy? 🏐""";

const _sugerencias = [
  ('01', 'Rutina de salto'),
  ('02', 'Mejorar recepción'),
  ('03', 'Plan semanal'),
  ('04', 'Errores en remate'),
];

const _maxCaracteres = 600;

class _Msg {
  final bool coach;
  final String texto;
  final String hora;
  const _Msg(this.coach, this.texto, this.hora);
}

String _horaActual() {
  final n = DateTime.now();
  return '${n.hour.toString().padLeft(2, '0')}:${n.minute.toString().padLeft(2, '0')}';
}

/// Respuesta de prueba. Reemplázala pasando `onSend` con tu llamada real a la API.
Future<String> _respuestaSimulada(String mensaje) async {
  await Future.delayed(const Duration(milliseconds: 1200));
  return '## Respuesta de prueba\n\n'
      'Recibí tu pregunta: **$mensaje**.\n\n'
      'Conecta el parámetro `onSend` de AnalisisScreen con tu API para ver respuestas reales.';
}

// ── Pantalla ──
class AnalisisScreen extends StatefulWidget {
  /// Función que envía el mensaje a tu API y devuelve la respuesta de la IA.
  final Future<String> Function(String mensaje)? onSend;

  const AnalisisScreen({super.key, this.onSend});

  @override
  State<AnalisisScreen> createState() => _AnalisisScreenState();
}

class _AnalisisScreenState extends State<AnalisisScreen> {
  final List<_Msg> _mensajes = [const _Msg(true, _welcome, 'Ahora')];
  final _controller = TextEditingController();
  final _scroll = ScrollController();
  final _focus = FocusNode();

  bool _escribiendo = false;
  int? _copiadoIndex;

  @override
  void initState() {
    super.initState();
    _focus.addListener(() => setState(() {}));
    _controller.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _controller.dispose();
    _scroll.dispose();
    _focus.dispose();
    super.dispose();
  }

  void _scrollAlFinal() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scroll.hasClients) return;
      _scroll.animateTo(
        _scroll.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  Future<void> _enviar(String texto) async {
    final mensaje = texto.trim();
    if (mensaje.isEmpty || _escribiendo) return;

    setState(() {
      _mensajes.add(_Msg(false, mensaje, _horaActual()));
      _controller.clear();
    });
    _focus.requestFocus();
    await _responder(mensaje);
  }

  Future<void> _responder(String mensaje) async {
    setState(() => _escribiendo = true);
    _scrollAlFinal();

    String respuesta;
    try {
      respuesta = await (widget.onSend ?? _respuestaSimulada)(mensaje);
    } catch (e) {
      debugPrint('Error al contactar la IA: $e');
      respuesta = '⚠️ No fue posible conectar con VolleyScan AI.';
    }

    if (!mounted) return;
    setState(() {
      _mensajes.add(_Msg(true, respuesta, _horaActual()));
      _escribiendo = false;
    });
    _scrollAlFinal();
  }

  Future<void> _copiar(String texto, int index) async {
    await Clipboard.setData(ClipboardData(text: texto.replaceAll('**', '')));
    if (!mounted) return;
    setState(() => _copiadoIndex = index);
    Future.delayed(const Duration(milliseconds: 1800), () {
      if (mounted && _copiadoIndex == index) {
        setState(() => _copiadoIndex = null);
      }
    });
  }

  void _regenerar() {
    final ultimoUsuario = _mensajes.lastWhere(
      (m) => !m.coach,
      orElse: () => const _Msg(false, '', ''),
    );
    if (ultimoUsuario.texto.isEmpty || _escribiendo) return;
    setState(() => _mensajes.removeLast());
    _responder(ultimoUsuario.texto);
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final narrow = w < 720;

    return Material(
      color: _bgPrimary,
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF14122A), _bgPrimary, _bgPrimary],
            stops: [0, 0.35, 1],
          ),
        ),
        child: Column(
          children: [
            _buildHeader(narrow),
            Expanded(child: _buildMessages(narrow)),
            _buildFooter(narrow),
          ],
        ),
      ),
    );
  }

  // ── Cabecera ──
  Widget _buildHeader(bool narrow) {
    final identity = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            gradient: _aiGradient,
            borderRadius: BorderRadius.circular(6),
            boxShadow: [
              BoxShadow(
                color: _accent.withOpacity(0.35),
                blurRadius: 22,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: const Icon(
            Icons.sports_volleyball,
            color: Colors.white,
            size: 28,
          ),
        ),
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
                style: TextStyle(fontSize: 13.5, color: _textMuted),
              ),
            ],
          ),
        ),
      ],
    );

    final status = Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
      decoration: BoxDecoration(
        color: _success.withOpacity(0.06),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: _success.withOpacity(0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: const [
          _PulseDot(),
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

    final context = Wrap(
      spacing: 10,
      runSpacing: 8,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.person_pin_outlined, size: 14, color: _accent),
            const SizedBox(width: 6),
            Text(
              'PERFIL ACTIVO',
              style: _mono.copyWith(
                fontSize: 10.8,
                letterSpacing: 1.2,
                color: _textMuted,
              ),
            ),
          ],
        ),
        for (final p in _perfilDeportista)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              gradient: _surfaceGradient,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: _line),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  p.$1.toUpperCase(),
                  style: _mono.copyWith(
                    fontSize: 10.5,
                    letterSpacing: 0.6,
                    color: _textMuted,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  p.$2,
                  style: const TextStyle(
                    fontSize: 12.8,
                    fontWeight: FontWeight.w700,
                    color: _textPrimary,
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
            _accent.withOpacity(0.09),
            Colors.transparent,
            _blue.withOpacity(0.08),
          ],
          stops: const [0, 0.4, 1],
        ),
        border: const Border(bottom: BorderSide(color: _line)),
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
          context,
        ],
      ),
    );
  }

  // ── Mensajes ──
  Widget _buildMessages(bool narrow) {
    final total = _mensajes.length + (_escribiendo ? 1 : 0);

    return LayoutBuilder(
      builder: (context, c) {
        final bubbleMax =
            (narrow ? 0.9 : 0.74) *
            (c.maxWidth - (narrow ? 32 : 64) - 54).clamp(0, 880);

        return ListView.builder(
          controller: _scroll,
          padding: EdgeInsets.fromLTRB(
            narrow ? 16 : 32,
            28,
            narrow ? 16 : 32,
            20,
          ),
          itemCount: total,
          itemBuilder: (_, i) {
            Widget child;
            if (i >= _mensajes.length) {
              child = _buildThinking();
            } else {
              child = _buildMessage(i, bubbleMax.toDouble().clamp(200, 640));
            }
            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 880),
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 26),
                  child: child,
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _avatar(bool coach) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        gradient: coach ? _aiGradient : null,
        color: coach ? null : const Color(0xFF151824),
        borderRadius: BorderRadius.circular(coach ? 6 : 12),
        border: coach ? null : Border.all(color: _lineStrong),
        boxShadow: coach
            ? [
                BoxShadow(
                  color: _accent.withOpacity(0.27),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: Icon(
        coach ? Icons.sports_volleyball : Icons.person_outline,
        size: coach ? 22 : 20,
        color: coach ? Colors.white : _textSecondary,
      ),
    );
  }

  Widget _sender(bool coach) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            coach ? 'VolleyAI Coach' : 'Tú',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: _textSecondary,
            ),
          ),
          if (coach) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [_accent.withOpacity(0.13), _blue.withOpacity(0.07)],
                ),
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: _accent.withOpacity(0.27)),
              ),
              child: Text(
                'IA',
                style: _mono.copyWith(
                  fontSize: 9.6,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                  color: const Color(0xFFB9A4FF),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMessage(int i, double bubbleMax) {
    final m = _mensajes[i];
    final coach = m.coach;
    final esUltimoCoach =
        coach && i == _mensajes.length - 1 && _mensajes.length > 1;

    final bubble = coach
        ? Container(
            constraints: BoxConstraints(maxWidth: bubbleMax),
            decoration: BoxDecoration(
              gradient: _surfaceGradient,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(4),
                topRight: Radius.circular(16),
                bottomLeft: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
              border: Border.all(color: _line),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x40000000),
                  blurRadius: 30,
                  offset: Offset(0, 10),
                ),
              ],
            ),
            child: Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(22, 15, 20, 15),
                  child: _MarkdownText(m.texto),
                ),
                Positioned(
                  left: 0,
                  top: 14,
                  bottom: 14,
                  child: Container(
                    width: 3,
                    decoration: BoxDecoration(
                      gradient: _aiGradient,
                      borderRadius: const BorderRadius.horizontal(
                        right: Radius.circular(3),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: _accent.withOpacity(0.4),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          )
        : Container(
            constraints: BoxConstraints(maxWidth: bubbleMax),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            decoration: BoxDecoration(
              gradient: _aiGradient,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(4),
                bottomLeft: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
              boxShadow: [
                BoxShadow(
                  color: _accent.withOpacity(0.25),
                  blurRadius: 22,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Text(
              m.texto,
              style: const TextStyle(
                fontSize: 14.9,
                height: 1.65,
                color: Colors.white,
              ),
            ),
          );

    final footer = Padding(
      padding: const EdgeInsets.only(top: 6, left: 4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            m.hora,
            style: _mono.copyWith(
              fontSize: 10.5,
              letterSpacing: 0.3,
              color: _textMuted,
            ),
          ),
          if (coach) ...[
            const SizedBox(width: 10),
            _ActionBtn(
              icon: _copiadoIndex == i ? Icons.check : Icons.copy_rounded,
              confirmed: _copiadoIndex == i,
              tooltip: 'Copiar',
              onTap: () => _copiar(m.texto, i),
            ),
            if (esUltimoCoach && !_escribiendo) ...[
              const SizedBox(width: 4),
              _ActionBtn(
                icon: Icons.refresh_rounded,
                tooltip: 'Regenerar',
                onTap: _regenerar,
              ),
            ],
          ],
        ],
      ),
    );

    final column = Flexible(
      child: Column(
        crossAxisAlignment: coach
            ? CrossAxisAlignment.start
            : CrossAxisAlignment.end,
        children: [_sender(coach), bubble, footer],
      ),
    );

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: coach
          ? MainAxisAlignment.start
          : MainAxisAlignment.end,
      children: coach
          ? [_avatar(true), const SizedBox(width: 14), column]
          : [column, const SizedBox(width: 14), _avatar(false)],
    );
  }

  Widget _buildThinking() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _avatar(true),
        const SizedBox(width: 14),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sender(true),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
              decoration: BoxDecoration(
                gradient: _surfaceGradient,
                border: Border.all(color: _line),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(4),
                  topRight: Radius.circular(16),
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'ANALIZANDO',
                    style: _mono.copyWith(
                      fontSize: 11.5,
                      letterSpacing: 0.6,
                      color: _textSecondary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const _ThinkingBar(),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ── Pie: consola de entrada ──
  Widget _buildFooter(bool narrow) {
    final len = _controller.text.length;
    final puedeEnviar = !_escribiendo && _controller.text.trim().isNotEmpty;
    final focused = _focus.hasFocus;

    final counterColor = len >= _maxCaracteres
        ? const Color(0xFFEF4444)
        : len >= _maxCaracteres * 0.9
        ? const Color(0xFFF59E0B)
        : _textMuted;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(narrow ? 16 : 32, 16, narrow ? 16 : 32, 20),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: _line)),
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xCC0D0F1A), Color(0xF20D0F1A)],
        ),
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 880),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.fromLTRB(6, 8, 8, 8),
                decoration: BoxDecoration(
                  gradient: _surfaceGradient,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: focused ? _accent : _lineStrong,
                    width: 1,
                  ),
                  boxShadow: [
                    if (focused)
                      BoxShadow(
                        color: _accent.withOpacity(0.2),
                        blurRadius: 0,
                        spreadRadius: 3,
                      ),
                    const BoxShadow(
                      color: Color(0x40000000),
                      blurRadius: 30,
                      offset: Offset(0, 10),
                    ),
                  ],
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(12, 10, 4, 10),
                      child: Text(
                        '›',
                        style: _mono.copyWith(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: _accent,
                        ),
                      ),
                    ),
                    Expanded(
                      // Enter envía, Shift+Enter hace salto de línea
                      child: Focus(
                        onKeyEvent: (node, event) {
                          if (event is KeyDownEvent &&
                              event.logicalKey == LogicalKeyboardKey.enter &&
                              !HardwareKeyboard.instance.isShiftPressed) {
                            _enviar(_controller.text);
                            return KeyEventResult.handled;
                          }
                          return KeyEventResult.ignored;
                        },
                        child: TextField(
                          controller: _controller,
                          focusNode: _focus,
                          minLines: 1,
                          maxLines: 5,
                          maxLength: _maxCaracteres,
                          keyboardType: TextInputType.multiline,
                          cursorColor: _accent,
                          style: const TextStyle(
                            fontSize: 15,
                            height: 1.5,
                            color: _textPrimary,
                          ),
                          decoration: const InputDecoration(
                            hintText:
                                "Escribe tu pregunta aquí... Ej: 'Cómo mejorar mi recepción'",
                            hintStyle: TextStyle(
                              fontSize: 15,
                              color: _textMuted,
                            ),
                            border: InputBorder.none,
                            counterText: '',
                            isCollapsed: true,
                            contentPadding: EdgeInsets.symmetric(vertical: 11),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Opacity(
                      opacity: puedeEnviar ? 1 : 0.35,
                      child: GestureDetector(
                        onTap: puedeEnviar
                            ? () => _enviar(_controller.text)
                            : null,
                        child: Container(
                          width: 42,
                          height: 42,
                          margin: const EdgeInsets.only(bottom: 2),
                          decoration: BoxDecoration(
                            gradient: _aiGradient,
                            borderRadius: BorderRadius.circular(11),
                            boxShadow: puedeEnviar
                                ? [
                                    BoxShadow(
                                      color: _accent.withOpacity(0.27),
                                      blurRadius: 14,
                                      offset: const Offset(0, 4),
                                    ),
                                  ]
                                : null,
                          ),
                          child: const Icon(
                            Icons.send_rounded,
                            size: 19,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(4, 6, 4, 0),
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    '$len/$_maxCaracteres',
                    style: _mono.copyWith(fontSize: 10.8, color: counterColor),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    for (final s in _sugerencias)
                      Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: _SuggestionChip(
                          glifo: s.$1,
                          texto: s.$2,
                          onTap: () => _enviar(s.$2),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Widgets auxiliares ──
class _ActionBtn extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;
  final bool confirmed;
  const _ActionBtn({
    required this.icon,
    required this.tooltip,
    required this.onTap,
    this.confirmed = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = confirmed ? _success : _textSecondary;
    return Tooltip(
      message: tooltip,
      child: InkWell(
        borderRadius: BorderRadius.circular(7),
        onTap: onTap,
        child: Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(7),
            border: Border.all(
              color: confirmed ? _success : Colors.transparent,
            ),
          ),
          child: Icon(icon, size: 15, color: color),
        ),
      ),
    );
  }
}

class _SuggestionChip extends StatelessWidget {
  final String glifo;
  final String texto;
  final VoidCallback onTap;
  const _SuggestionChip({
    required this.glifo,
    required this.texto,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(10),
      hoverColor: _accent.withOpacity(0.1),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.02),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: _lineStrong),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              glifo,
              style: _mono.copyWith(
                fontSize: 11.2,
                fontWeight: FontWeight.w700,
                color: _accent,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              texto,
              style: const TextStyle(fontSize: 12.8, color: _textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}

/// Punto verde que pulsa (equivale a .ai-status-dot).
class _PulseDot extends StatefulWidget {
  const _PulseDot();

  @override
  State<_PulseDot> createState() => _PulseDotState();
}

class _PulseDotState extends State<_PulseDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 2),
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
      builder: (_, __) {
        final t = _c.value;
        return Opacity(
          opacity: 1 - 0.6 * t,
          child: Transform.scale(
            scale: 1 - 0.15 * t,
            child: Container(
              width: 7,
              height: 7,
              decoration: const BoxDecoration(
                color: _success,
                shape: BoxShape.circle,
                boxShadow: [BoxShadow(color: _success, blurRadius: 10)],
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Barra de "analizando" con segmento que se desplaza.
class _ThinkingBar extends StatefulWidget {
  const _ThinkingBar();

  @override
  State<_ThinkingBar> createState() => _ThinkingBarState();
}

class _ThinkingBarState extends State<_ThinkingBar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1100),
  )..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const w = 72.0;
    return ClipRRect(
      borderRadius: BorderRadius.circular(4),
      child: Container(
        width: w,
        height: 4,
        color: _line,
        child: AnimatedBuilder(
          animation: _c,
          builder: (_, __) {
            final seg = w * 0.4;
            final dx = -seg + (w + seg) * Curves.easeInOut.transform(_c.value);
            return Stack(
              children: [
                Positioned(
                  left: dx,
                  width: seg,
                  top: 0,
                  bottom: 0,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: _aiGradient,
                      borderRadius: BorderRadius.circular(4),
                      boxShadow: [
                        BoxShadow(
                          color: _accent.withOpacity(0.53),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

/// Markdown mínimo: **negrita**, `## título`, `### subtítulo` y párrafos.
class _MarkdownText extends StatelessWidget {
  final String text;
  const _MarkdownText(this.text);

  static const _base = TextStyle(
    fontSize: 14.9,
    height: 1.7,
    color: _textPrimary,
  );

  List<InlineSpan> _inline(String line, TextStyle style) {
    final spans = <InlineSpan>[];
    final re = RegExp(r'\*\*(.*?)\*\*');
    var last = 0;
    for (final m in re.allMatches(line)) {
      if (m.start > last) {
        spans.add(TextSpan(text: line.substring(last, m.start), style: style));
      }
      spans.add(
        TextSpan(
          text: m.group(1),
          style: style.copyWith(
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      );
      last = m.end;
    }
    if (last < line.length) {
      spans.add(TextSpan(text: line.substring(last), style: style));
    }
    return spans;
  }

  @override
  Widget build(BuildContext context) {
    final paragraphs = text.split(RegExp(r'\n{2,}'));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var p = 0; p < paragraphs.length; p++)
          Padding(
            padding: EdgeInsets.only(top: p == 0 ? 0 : 14),
            child: Text.rich(
              TextSpan(children: _paragraph(paragraphs[p], p == 0)),
            ),
          ),
      ],
    );
  }

  List<InlineSpan> _paragraph(String para, bool first) {
    final lines = para.split('\n');
    final spans = <InlineSpan>[];
    for (var i = 0; i < lines.length; i++) {
      final line = lines[i];
      TextStyle style = first && i == 0
          ? _base.copyWith(fontWeight: FontWeight.w500)
          : _base;
      String content = line;

      if (line.startsWith('### ')) {
        content = line.substring(4);
        style = _base.copyWith(fontSize: 14.4, fontWeight: FontWeight.w700);
      } else if (line.startsWith('## ')) {
        content = line.substring(3);
        style = _base.copyWith(
          fontSize: 16.8,
          fontWeight: FontWeight.w700,
          color: _accentHover,
        );
      }

      spans.addAll(_inline(content, style));
      if (i < lines.length - 1) spans.add(const TextSpan(text: '\n'));
    }
    return spans;
  }
}
