import 'package:flutter/material.dart';

import 'package:volleyscan_mobile/services/api_service.dart';
import 'package:volleyscan_mobile/theme/app_theme.dart';
import 'package:volleyscan_mobile/widgets/entrenador/gestion/gestion_athlete.dart';
import 'package:volleyscan_mobile/widgets/entrenador/gestion/gestion_athlete_detail.dart';
import 'package:volleyscan_mobile/widgets/entrenador/gestion/gestion_athletes_table.dart';
import 'package:volleyscan_mobile/widgets/entrenador/gestion/gestion_athletes_toolbar.dart';
import 'package:volleyscan_mobile/widgets/entrenador/gestion/gestion_colors.dart';
import 'package:volleyscan_mobile/widgets/entrenador/gestion/gestion_common_widgets.dart';

/// Pantalla "Deportistas" del Panel de Entrenador (`/panel_entrenador/gestion` y `/panel_entrenador/gestion/[id]`).
class GestionScreen extends StatefulWidget {
  const GestionScreen({super.key});

  @override
  State<GestionScreen> createState() => _GestionScreenState();
}

class _GestionScreenState extends State<GestionScreen> {
  List<EntrenadorDeportista> _deportistas = const [];
  List<EntrenadorDeportista> _solicitudes = const [];
  String _estado = 'cargando'; // 'cargando' | 'error' | 'listo'
  String _error = '';
  String _aviso = '';

  final _searchCtrl = TextEditingController();
  String _q = '';
  String _pos = 'todas';

  int? _ocupadoVinculoId;
  int? _retirandoAtletaId;
  EntrenadorDeportista? _fichaAtleta;

  @override
  void initState() {
    super.initState();
    _searchCtrl.addListener(() {
      if (_q != _searchCtrl.text) {
        setState(() => _q = _searchCtrl.text);
      }
    });
    _cargar();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _cargar() async {
    try {
      final res = await Future.wait([
        ApiService().listarDeportistasEntrenador(),
        ApiService().listarSolicitudesEntrenador(),
      ]);
      if (!mounted) return;
      setState(() {
        _deportistas = res[0];
        _solicitudes = res[1];
        _error = '';
        _estado = 'listo';
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      if (e.isUnauthorized) return;
      final msg = e.message.isNotEmpty
          ? e.message
          : 'Ocurrió un error inesperado.';
      setState(() {
        _error = msg;
        _estado = 'error';
      });
      showAppToast(context, msg, type: 'error');
    } catch (_) {
      if (!mounted) return;
      const msg = 'Ocurrió un error inesperado.';
      setState(() {
        _error = msg;
        _estado = 'error';
      });
      showAppToast(context, msg, type: 'error');
    }
  }

  Future<void> _responder(EntrenadorDeportista a, String accion) async {
    setState(() {
      _ocupadoVinculoId = a.vinculoId;
      _aviso = '';
    });
    try {
      await ApiService().responderSolicitudEntrenador(a.vinculoId, accion);
      if (!mounted) return;
      final msg = accion == 'aceptar'
          ? '${a.nombre} ya es parte de tus deportistas.'
          : 'Rechazaste la solicitud de ${a.nombre}.';
      setState(() {
        _ocupadoVinculoId = null;
        _aviso = msg;
      });
      showAppToast(context, msg, type: 'success');
      await _cargar();
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _ocupadoVinculoId = null;
        _error = e.message;
      });
      showAppToast(context, e.message, type: 'error');
      await _cargar();
    } catch (_) {
      if (!mounted) return;
      const msg = 'Ocurrió un error inesperado.';
      setState(() {
        _ocupadoVinculoId = null;
        _error = msg;
      });
      showAppToast(context, msg, type: 'error');
      await _cargar();
    }
  }

  Future<void> _retirar(EntrenadorDeportista a) async {
    setState(() => _ocupadoVinculoId = a.vinculoId);
    try {
      await ApiService().retirarDeportistaEntrenador(a.id);
      if (!mounted) return;
      final msg = '${a.nombre} ${a.apellido} ya no está en tu lista.';
      setState(() {
        _ocupadoVinculoId = null;
        _retirandoAtletaId = null;
        _aviso = msg;
      });
      showAppToast(context, msg, type: 'success');
      await _cargar();
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _ocupadoVinculoId = null;
        _retirandoAtletaId = null;
        _error = e.message;
      });
      showAppToast(context, e.message, type: 'error');
    } catch (_) {
      if (!mounted) return;
      const msg = 'Ocurrió un error inesperado.';
      setState(() {
        _ocupadoVinculoId = null;
        _retirandoAtletaId = null;
        _error = msg;
      });
      showAppToast(context, msg, type: 'error');
    }
  }

  List<EntrenadorDeportista> get _visibles {
    final t = sinTildesDeportista(_q.trim());
    return _deportistas.where((a) {
      final okPos = _pos == 'todas' || a.posicion == _pos;
      final okName = t.isEmpty ||
          sinTildesDeportista('${a.nombre} ${a.apellido}').contains(t);
      return okPos && okName;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final narrow = MediaQuery.of(context).size.width < 900;

    return Material(
      color: GestionColors.bg,
      child: RefreshIndicator(
        color: GestionColors.blue,
        backgroundColor: GestionColors.card,
        onRefresh: _cargar,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.fromLTRB(
            narrow ? 12 : 20,
            narrow ? 64 : 28,
            narrow ? 12 : 20,
            80,
          ),
          child: Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1240),
              child: _fichaAtleta != null
                  ? DeportistaFichaView(
                      atletaId: _fichaAtleta!.id,
                      initialAtleta: _fichaAtleta,
                      onBack: () async {
                        setState(() => _fichaAtleta = null);
                        await _cargar();
                      },
                    )
                  : _buildListado(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildListado() {
    final visibles = _visibles;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        DeportistasHeaderAndFilters(
          totalDeportistas: _deportistas.length,
          totalSolicitudes: _solicitudes.length,
          mostrarContadores: _estado == 'listo',
          searchCtrl: _searchCtrl,
          posicionSeleccionada: _pos,
          onPosicionChanged: (v) => setState(() => _pos = v),
        ),
        const SizedBox(height: 22),
        if (_error.isNotEmpty)
          DeportistaAlertBanner(text: _error, isError: true),
        if (_aviso.isNotEmpty)
          DeportistaAlertBanner(text: _aviso, isError: false),
        if (_estado == 'cargando')
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 18),
            child: Text(
              'Cargando deportistas…',
              style: TextStyle(fontSize: 14, color: GestionColors.muted),
            ),
          ),
        if (_estado == 'error')
          Align(
            alignment: Alignment.centerLeft,
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () {
                setState(() => _estado = 'cargando');
                _cargar();
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: GestionColors.card,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: GestionColors.border),
                ),
                child: const Text(
                  'Reintentar',
                  style: TextStyle(fontSize: 13.5, color: GestionColors.text2),
                ),
              ),
            ),
          ),
        if (_estado == 'listo') ...[
          DeportistasSolicitudesSection(
            solicitudes: _solicitudes,
            ocupadoVinculoId: _ocupadoVinculoId,
            onResponder: _responder,
          ),
          DeportistasFilterBar(
            searchCtrl: _searchCtrl,
            posicionSeleccionada: _pos,
            onPosicionChanged: (v) => setState(() => _pos = v),
          ),
          if (_deportistas.isEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
              decoration: BoxDecoration(
                color: GestionColors.card,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: GestionColors.border),
              ),
              child: Column(
                children: [
                  const Text(
                    'Aún no tienes deportistas',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: GestionColors.text,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 460),
                    child: const Text(
                      'Cuando un atleta te elija como entrenador, su solicitud aparecerá arriba. Al aceptarla, entrará en esta lista con todo su perfil.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: GestionColors.muted,
                      ),
                    ),
                  ),
                ],
              ),
            )
          else if (visibles.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 18),
              child: Text(
                'Ningún deportista coincide con ese filtro.',
                style: TextStyle(fontSize: 14, color: GestionColors.muted),
              ),
            )
          else
            LayoutBuilder(
              builder: (context, c) {
                final w = c.maxWidth;
                final cols = w < 640 ? 1 : (w < 980 ? 2 : 3);
                const gap = 16.0;
                final itemW = ((w - gap * (cols - 1)) / cols)
                    .clamp(0.0, w)
                    .toDouble();

                return Wrap(
                  spacing: gap,
                  runSpacing: gap,
                  children: [
                    for (final a in visibles)
                      SizedBox(
                        width: itemW,
                        child: DeportistaCard(
                          atleta: a,
                          confirmandoRetiro: _retirandoAtletaId == a.id,
                          busy: _ocupadoVinculoId == a.vinculoId,
                          onVerAnalisis: () =>
                              setState(() => _fichaAtleta = a),
                          onPedirRetirar: () =>
                              setState(() => _retirandoAtletaId = a.id),
                          onCancelarRetiro: () =>
                              setState(() => _retirandoAtletaId = null),
                          onConfirmarRetiro: () => _retirar(a),
                        ),
                      ),
                  ],
                );
              },
            ),
        ],
      ],
    );
  }
}
