import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:volleyscan_mobile/services/api_service.dart';
import 'package:volleyscan_mobile/theme/app_theme.dart';
import 'package:volleyscan_mobile/widgets/entrenador/analisis/analisis_header.dart';
import 'package:volleyscan_mobile/widgets/entrenador/analisis/analisis_input_footer.dart';
import 'package:volleyscan_mobile/widgets/entrenador/analisis/analisis_message_list.dart';
import 'package:volleyscan_mobile/widgets/entrenador/analisis/analisis_models.dart';
import 'package:volleyscan_mobile/widgets/entrenador/analisis/analisis_theme.dart';
import 'package:volleyscan_mobile/widgets/entrenador/analisis/analisis_welcome_view.dart';

class AnalisisScreen extends StatefulWidget {
  /// Función opcional para inyectar respuesta (útil en tests).
  final Future<String> Function(String mensaje)? onSend;

  const AnalisisScreen({super.key, this.onSend});

  @override
  State<AnalisisScreen> createState() => _AnalisisScreenState();
}

class _AnalisisScreenState extends State<AnalisisScreen> {
  final List<ChatMsg> _mensajes = [];
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

  /// Réplica exacta de `enviar(texto)` en `VolleyScan_Next/src/app/panel_entrenador/analisis/page.jsx`.
  Future<void> _enviar(String texto) async {
    final mensaje = texto.trim();
    if (mensaje.isEmpty || _escribiendo) return;

    setState(() {
      _mensajes.add(ChatMsg(false, mensaje, horaActual()));
      _controller.clear();
      _escribiendo = true;
    });
    _focus.requestFocus();
    await _responder(mensaje);
  }

  Future<void> _responder(String mensaje) async {
    setState(() => _escribiendo = true);
    _scrollAlFinal();

    try {
      final sendFn = widget.onSend ?? ApiService().enviarMensajeChatIA;
      final respuesta = await sendFn(mensaje);
      if (!mounted) return;
      setState(() {
        _mensajes.add(ChatMsg(true, respuesta, horaActual()));
      });
    } catch (_) {
      if (!mounted) return;
      // En Next (`page.jsx`), cuando falla la petición a `:8010/chat`,
      // se agrega una burbuja de respuesta del coach con el aviso de desconexión
      // y NO se vuelve a copiar el texto al input ni quedan burbujas huérfanas.
      setState(() {
        _mensajes.add(
          ChatMsg(
            true,
            '⚠️ No fue posible conectar con VolleyScan AI.',
            horaActual(),
          ),
        );
      });
    } finally {
      if (mounted) {
        setState(() => _escribiendo = false);
        _scrollAlFinal();
      }
    }
  }

  Future<void> _copiar(String texto, int index) async {
    await Clipboard.setData(ClipboardData(text: texto.replaceAll('**', '')));
    if (!mounted) return;
    setState(() => _copiadoIndex = index);
    showAppToast(context, 'Respuesta copiada al portapapeles', type: 'success');
    Future.delayed(const Duration(milliseconds: 1800), () {
      if (mounted && _copiadoIndex == index) {
        setState(() => _copiadoIndex = null);
      }
    });
  }

  void _regenerar() {
    if (_escribiendo) return;
    final ultimoUsuario = _mensajes.lastWhere(
      (m) => !m.coach,
      orElse: () => const ChatMsg(false, '', ''),
    );
    if (ultimoUsuario.texto.isEmpty) return;
    setState(() => _mensajes.removeLast());
    _responder(ultimoUsuario.texto);
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final narrow = width < 720;
    final mobileShell = width < 900;
    // En móvil (`width < 900`), `EntrenadorShell` muestra un `FloatingActionButton`
    // centrado sobre la `BottomAppBar`. Reservamos espacio inferior para que el FAB
    // central (`chat IA`) nunca tape los chips `01`, `02`, `03`, `04` ni las tarjetas.
    final bottomSafePadding = mobileShell ? 28.0 : 0.0;
    final vacio = _mensajes.isEmpty && !_escribiendo;

    return Material(
      color: AnalisisTheme.bg,
      child: Stack(
        children: [
          // ── `.ai-panel::before`: Aurora turquesa superior ──
          const Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 380,
            child: IgnorePointer(child: _TopAuroraGlow()),
          ),
          // ── Contenido principal ──
          SafeArea(
            bottom: false,
            child: Column(
              children: [
                AnalisisHeader(
                  narrow: narrow,
                  hasMessages: _mensajes.isNotEmpty,
                  onReset: () => setState(() {
                    _mensajes.clear();
                    _escribiendo = false;
                  }),
                ),
                if (vacio)
                  Expanded(
                    child: AnalisisWelcomeView(
                      controller: _controller,
                      focus: _focus,
                      escribiendo: _escribiendo,
                      narrow: narrow,
                      bottomSafePadding: bottomSafePadding,
                      onSend: _enviar,
                    ),
                  )
                else ...[
                  Expanded(
                    child: AnalisisMessageList(
                      mensajes: _mensajes,
                      escribiendo: _escribiendo,
                      narrow: narrow,
                      controller: _scroll,
                      copiadoIndex: _copiadoIndex,
                      onCopy: _copiar,
                      onRegenerate: _regenerar,
                    ),
                  ),
                  AnalisisInputFooter(
                    controller: _controller,
                    focus: _focus,
                    escribiendo: _escribiendo,
                    narrow: narrow,
                    bottomSafePadding: bottomSafePadding,
                    onSend: _enviar,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Resplandor radial superior (`.ai-panel::before` en `Analisis.css`).
class _TopAuroraGlow extends StatelessWidget {
  const _TopAuroraGlow();

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Radial central: `radial-gradient(ellipse 60% 100% at 55% 0%, rgba(45, 212, 191, 0.55) 0%, rgba(14, 165, 233, 0.28) 42%, transparent 76%)`
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: const Alignment(0.10, -1.0),
              radius: 1.05,
              colors: [
                const Color(0xFF2DD4BF).withValues(alpha: 0.42),
                const Color(0xFF0EA5E9).withValues(alpha: 0.20),
                Colors.transparent,
              ],
              stops: const [0.0, 0.45, 0.85],
            ),
          ),
        ),
        // Radial izquierdo: `radial-gradient(ellipse 38% 90% at 12% 0%, rgba(56, 189, 248, 0.22), transparent 70%)`
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: const Alignment(-0.76, -1.0),
              radius: 0.85,
              colors: [
                const Color(0xFF38BDF8).withValues(alpha: 0.18),
                Colors.transparent,
              ],
              stops: const [0.0, 0.75],
            ),
          ),
        ),
        // Radial derecho: `radial-gradient(ellipse 34% 80% at 92% 0%, rgba(16, 185, 129, 0.22), transparent 70%)`
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: const Alignment(0.84, -1.0),
              radius: 0.80,
              colors: [
                const Color(0xFF10B981).withValues(alpha: 0.18),
                Colors.transparent,
              ],
              stops: const [0.0, 0.75],
            ),
          ),
        ),
      ],
    );
  }
}
