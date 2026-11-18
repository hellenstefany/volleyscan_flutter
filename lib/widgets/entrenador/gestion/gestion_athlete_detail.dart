import 'package:flutter/material.dart';

import '../../../services/api_service.dart';
import '../../../theme/app_theme.dart';
import 'gestion_athlete.dart';
import 'gestion_athlete_form_dialog.dart';
import 'gestion_colors.dart';
import 'gestion_common_widgets.dart';

/// Vista de ficha y análisis IA de un deportista (`/panel_entrenador/gestion/[id]` → `HistorialIA modo="entrenador"`).
class DeportistaFichaView extends StatefulWidget {
  final int atletaId;
  final EntrenadorDeportista? initialAtleta;
  final VoidCallback onBack;

  const DeportistaFichaView({
    super.key,
    required this.atletaId,
    required this.onBack,
    this.initialAtleta,
  });

  @override
  State<DeportistaFichaView> createState() => _DeportistaFichaViewState();
}

class _DeportistaFichaViewState extends State<DeportistaFichaView> {
  EntrenadorDeportista? _ficha;
  List<DeportistaSesionResumen> _sesiones = const [];
  bool _loading = true;
  String? _error;

  int? _seleccionId;
  DeportistaSesionDetalle? _detalle;
  bool _loadingDetalle = false;
  int? _repSel;
  bool _revisando = false;

  @override
  void initState() {
    super.initState();
    _ficha = widget.initialAtleta;
    _cargar();
  }

  Future<void> _cargar() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final results = await Future.wait([
        ApiService().fichaDeportistaEntrenador(widget.atletaId),
        ApiService().sesionesDeDeportistaEntrenador(widget.atletaId),
      ]);
      if (!mounted) return;
      final ficha = results[0] as EntrenadorDeportista;
      final sesiones = results[1] as List<DeportistaSesionResumen>;
      setState(() {
        _ficha = ficha;
        _sesiones = sesiones;
        _loading = false;
      });
      if (sesiones.isNotEmpty) {
        final inicial = sesiones.firstWhere(
          (s) => s.evaluada,
          orElse: () => sesiones.first,
        );
        await _abrirSesion(inicial.id);
      }
    } on ApiException catch (e) {
      if (!mounted) return;
      if (e.isUnauthorized) return;
      setState(() {
        _error = e.message;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _error = 'Ocurrió un error inesperado.';
        _loading = false;
      });
    }
  }

  Future<void> _abrirSesion(int sesionId) async {
    setState(() {
      _seleccionId = sesionId;
      _detalle = null;
      _repSel = null;
      _loadingDetalle = true;
    });
    try {
      final det = await ApiService().sesionDeDeportistaEntrenador(
        widget.atletaId,
        sesionId,
      );
      if (!mounted) return;
      setState(() {
        _detalle = det;
        _loadingDetalle = false;
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.message;
        _loadingDetalle = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _error = 'No se pudo cargar la sesión.';
        _loadingDetalle = false;
      });
    }
  }

  Future<void> _revisar(bool valor) async {
    final det = _detalle;
    if (det == null || _revisando) return;
    setState(() => _revisando = true);
    try {
      final actualizado = await ApiService().revisarSesionDeportistaEntrenador(
        widget.atletaId,
        det.id,
        valor,
      );
      if (!mounted) return;
      setState(() {
        _revisando = false;
        _error = null;
        _detalle = actualizado;
        _sesiones = _sesiones
            .map(
              (s) => s.id == actualizado.id
                  ? DeportistaSesionResumen(
                      id: s.id,
                      tecnica: s.tecnica,
                      puntuacion: s.puntuacion,
                      totalRepeticiones: s.totalRepeticiones,
                      repeticionesValidas: s.repeticionesValidas,
                      mejorPuntuacion: s.mejorPuntuacion,
                      duracionSeg: s.duracionSeg,
                      nivel: s.nivel,
                      creadoEn: s.creadoEn,
                      revisadoPorEntrenador: actualizado.revisadoPorEntrenador,
                      fechaRevision: actualizado.fechaRevision,
                    )
                  : s,
            )
            .toList();
      });
      showAppToast(
        context,
        valor ? 'Sesión marcada como revisada' : 'Revisión quitada',
        type: 'success',
      );
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _revisando = false;
        _error = e.message;
      });
      showAppToast(context, e.message, type: 'error');
    } catch (_) {
      if (!mounted) return;
      setState(() => _revisando = false);
      showAppToast(context, 'Ocurrió un error inesperado.', type: 'error');
    }
  }

  @override
  Widget build(BuildContext context) {
    final ficha = _ficha;
    final ev = _sesiones.where((x) => x.evaluada).toList();
    final totalRemates = _sesiones.fold<int>(
      0,
      (acc, x) => acc + x.repeticionesValidas,
    );
    final int? promedio = ev.isNotEmpty
        ? (ev.fold<int>(0, (a, x) => a + (x.puntuacion ?? 0)) / ev.length)
            .round()
        : null;
    final int? mejor = ev.isNotEmpty
        ? ev.fold<int>(
            0,
            (m, x) => (x.mejorPuntuacion ?? 0) > m ? (x.mejorPuntuacion ?? 0) : m,
          )
        : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: InkWell(
            onTap: widget.onBack,
            child: const Padding(
              padding: EdgeInsets.symmetric(vertical: 4),
              child: Text(
                '← Volver a Deportistas',
                style: TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w600,
                  color: GestionColors.blueLight,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'ANÁLISIS CON IA',
          style: TextStyle(
            fontSize: 11.5,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.6,
            color: GestionColors.blueLight,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          ficha != null ? 'Análisis de ${ficha.nombre}' : 'Historial de remates',
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w700,
            color: GestionColors.text,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Sus sesiones con lo que debe corregir, por qué y qué ejercicio hacer. Marca cada sesión como revisada.',
          style: TextStyle(fontSize: 14, color: GestionColors.muted),
        ),
        const SizedBox(height: 18),
        if (ficha != null) ...[
          _FichaHeaderCard(atleta: ficha),
          const SizedBox(height: 18),
        ],
        if (_error != null) DeportistaAlertBanner(text: _error!),
        if (_loading)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 20),
            child: Text(
              'Cargando historial…',
              style: TextStyle(fontSize: 14, color: GestionColors.muted),
            ),
          )
        else if (_sesiones.isEmpty)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 36),
            decoration: BoxDecoration(
              color: GestionColors.card,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: GestionColors.border),
            ),
            child: const Column(
              children: [
                Text(
                  'Este deportista aún no tiene sesiones',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: GestionColors.text,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  'Cuando practique con el análisis de IA, sus sesiones aparecerán aquí.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 13.5, color: GestionColors.muted),
                ),
              ],
            ),
          )
        else ...[
          // ── 4 KPIs ──
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _FichaKpi(label: 'SESIONES', value: '${_sesiones.length}'),
              _FichaKpi(label: 'REMATES MEDIDOS', value: '$totalRemates'),
              _FichaKpi(label: 'PROMEDIO', value: '${promedio ?? '—'}'),
              _FichaKpi(label: 'MEJOR SESIÓN', value: '${mejor ?? '—'}'),
            ],
          ),
          const SizedBox(height: 18),
          LayoutBuilder(
            builder: (context, c) {
              final wide = c.maxWidth >= 820;
              final listaWidget = Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (final x in _sesiones)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: _SesionListTile(
                        sesion: x,
                        selected: x.id == _seleccionId,
                        onTap: () => _abrirSesion(x.id),
                      ),
                    ),
                ],
              );
              final detalleWidget = _loadingDetalle
                  ? const Padding(
                      padding: EdgeInsets.all(20),
                      child: Text(
                        'Cargando sesión…',
                        style: TextStyle(
                          fontSize: 14,
                          color: GestionColors.muted,
                        ),
                      ),
                    )
                  : _detalle != null
                  ? DeportistaSesionDetailCard(
                      detalle: _detalle!,
                      repSeleccionada: _repSel,
                      revisando: _revisando,
                      onSelectRep: (n) => setState(() => _repSel = n),
                      onToggleRevision: _revisar,
                    )
                  : const SizedBox.shrink();

              if (wide) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(width: 300, child: listaWidget),
                    const SizedBox(width: 16),
                    Expanded(child: detalleWidget),
                  ],
                );
              }
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  listaWidget,
                  const SizedBox(height: 14),
                  detalleWidget,
                ],
              );
            },
          ),
        ],
      ],
    );
  }
}

class _FichaHeaderCard extends StatelessWidget {
  final EntrenadorDeportista atleta;

  const _FichaHeaderCard({required this.atleta});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: AppGradients.coachCardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: GestionColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              DeportistaAvatar(atleta: atleta, size: 60),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      atleta.nombreCompleto,
                      style: const TextStyle(
                        fontSize: 17.5,
                        fontWeight: FontWeight.w700,
                        color: GestionColors.text,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      atleta.email,
                      style: const TextStyle(
                        fontSize: 13.2,
                        color: GestionColors.muted,
                      ),
                    ),
                    const SizedBox(height: 6),
                    DeportistaChips(atleta: atleta),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          DeportistaPerfilGrid(atleta: atleta),
        ],
      ),
    );
  }
}

class _FichaKpi extends StatelessWidget {
  final String label;
  final String value;

  const _FichaKpi({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minWidth: 130),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        gradient: AppGradients.coachCardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: GestionColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              letterSpacing: 0.8,
              color: GestionColors.muted,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: GestionColors.text,
            ),
          ),
        ],
      ),
    );
  }
}

class _SesionListTile extends StatelessWidget {
  final DeportistaSesionResumen sesion;
  final bool selected;
  final VoidCallback onTap;

  const _SesionListTile({
    required this.sesion,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final eval = sesion.evaluada;
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: selected
              ? GestionColors.blue.withValues(alpha: 0.14)
              : GestionColors.card,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? GestionColors.blue : GestionColors.border,
          ),
        ),
        child: Row(
          children: [
            DeportistaScoreRing(
              valor: sesion.puntuacion,
              size: 46,
              sinDato: !eval,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    formatFechaHoraDeportista(sesion.creadoEn),
                    style: const TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                      color: GestionColors.text,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${eval ? '${sesion.repeticionesValidas} de ${sesion.totalRepeticiones} remates medidos' : 'Ningún remate se pudo medir'}'
                    '${sesion.revisadoPorEntrenador ? ' · ✓ Revisada' : ''}',
                    style: TextStyle(
                      fontSize: 12.2,
                      color: eval ? GestionColors.muted : GestionColors.faint,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
