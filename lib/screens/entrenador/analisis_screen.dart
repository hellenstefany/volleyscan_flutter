import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:volleyscan_mobile/widgets/entrenador/analisis/analisis_header.dart';
import 'package:volleyscan_mobile/widgets/entrenador/analisis/analisis_input_footer.dart';
import 'package:volleyscan_mobile/widgets/entrenador/analisis/analisis_message_list.dart';
import 'package:volleyscan_mobile/widgets/entrenador/analisis/analisis_models.dart';
import 'package:volleyscan_mobile/widgets/entrenador/analisis/analisis_theme.dart';

class AnalisisScreen extends StatefulWidget {
  /// Función que envía el mensaje a tu API y devuelve la respuesta de la IA.
  final Future<String> Function(String mensaje)? onSend;

  const AnalisisScreen({super.key, this.onSend});

  @override
  State<AnalisisScreen> createState() => _AnalisisScreenState();
}

class _AnalisisScreenState extends State<AnalisisScreen> {
  final List<ChatMsg> _mensajes = [
    const ChatMsg(true, AnalisisTheme.welcome, 'Ahora'),
  ];
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
      _mensajes.add(ChatMsg(false, mensaje, horaActual()));
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
      respuesta = await (widget.onSend ?? respuestaSimulada)(mensaje);
    } catch (e) {
      debugPrint('Error al contactar la IA: $e');
      respuesta = '⚠️ No fue posible conectar con VolleyScan AI.';
    }

    if (!mounted) return;
    setState(() {
      _mensajes.add(ChatMsg(true, respuesta, horaActual()));
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
      orElse: () => const ChatMsg(false, '', ''),
    );
    if (ultimoUsuario.texto.isEmpty || _escribiendo) return;
    setState(() => _mensajes.removeLast());
    _responder(ultimoUsuario.texto);
  }

  @override
  Widget build(BuildContext context) {
    final narrow = MediaQuery.of(context).size.width < 720;

    return Material(
      color: AnalisisTheme.bgPrimary,
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF14122A),
              AnalisisTheme.bgPrimary,
              AnalisisTheme.bgPrimary,
            ],
            stops: [0, 0.35, 1],
          ),
        ),
        child: Column(
          children: [
            AnalisisHeader(narrow: narrow),
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
              onSend: _enviar,
            ),
          ],
        ),
      ),
    );
  }
}