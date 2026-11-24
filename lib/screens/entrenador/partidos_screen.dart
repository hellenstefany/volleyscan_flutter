import 'package:flutter/material.dart';

import '../../models/equipo.dart';
import '../../models/my_matches_data.dart';
import '../../services/api_service.dart';
import '../../theme/app_theme.dart';
import '../../theme/dash_colors.dart';
import '../../widgets/entrenador/equipos/equipos_common_widgets.dart';
import '../../widgets/entrenador/partidos/partido_detail_dialog.dart';
import '../../widgets/entrenador/partidos/partido_form_dialog.dart';
import '../../widgets/entrenador/partidos/partidos_widgets.dart';

/// Pantalla "Partidos" del Panel de Entrenador (`/panel_entrenador/partidos`).
class PartidosScreen extends StatefulWidget {
  const PartidosScreen({super.key});

  @override
  State<PartidosScreen> createState() => _PartidosScreenState();
}

class _PartidosScreenState extends State<PartidosScreen> {
  List<Equipo> _equipos = const <Equipo>[];
  int? _equipoId;
  CoachMatchesListResponse? _datos;

  bool _cargando = true, _abriendoDetalle = false;
  String _error = '', _aviso = '';
  int _reqToken = 0;

  @override
  void initState() {
    super.initState();
    _cargarEquipos();
    _cargarPartidos();
  }

  Future<void> _cargarEquipos() async {
    try {
      final list = await ApiService().listarEquiposEntrenador();
      if (mounted) setState(() => _equipos = list);
    } catch (_) {}
  }

  Future<void> _cargarPartidos() async {
    final token = ++_reqToken;
    if (mounted) {
      setState(() {
        _cargando = true;
        _error = '';
      });
    }
    try {
      final res = await ApiService().listarPartidosEntrenador(equipoId: _equipoId);
      if (!mounted || token != _reqToken) return;
      setState(() {
        _datos = res;
        _cargando = false;
        _error = '';
      });
    } on ApiException catch (e) {
      if (!mounted || token != _reqToken || e.isUnauthorized) return;
      setState(() {
        _cargando = false;
        _error = e.message;
      });
    } catch (_) {
      if (!mounted || token != _reqToken) return;
      setState(() {
        _cargando = false;
        _error = 'No se pudieron cargar los partidos.';
      });
    }
  }

  Future<void> _refrescarTodo() => Future.wait([_cargarEquipos(), _cargarPartidos()]);

  void _cambiarEquipo(int? nuevoId) {
    if (nuevoId == _equipoId) return;
    setState(() {
      _equipoId = nuevoId;
      _aviso = '';
    });
    _cargarPartidos();
  }

  Future<void> _abrirDetalle(int partidoId) async {
    if (_abriendoDetalle) return;
    setState(() {
      _abriendoDetalle = true;
      _error = '';
    });
    try {
      final det = await ApiService().detallePartidoEntrenador(partidoId);
      if (!mounted) return;
      setState(() => _abriendoDetalle = false);
      final outcome = await showDialog<PartidoDetailOutcome>(
        context: context,
        barrierColor: DashColors.modalOverlay,
        builder: (_) => PartidoDetailDialog(partido: det),
      );
      if (!mounted || outcome == null) return;
      if (outcome == PartidoDetailOutcome.deleted) {
        setState(() => _aviso = 'Partido eliminado.');
        await _cargarPartidos();
      } else if (outcome == PartidoDetailOutcome.edit) {
        await _abrirFormulario(det);
      }
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _abriendoDetalle = false;
        _error = e.message;
      });
      showAppToast(context, e.message, type: 'error');
    } catch (_) {
      if (!mounted) return;
      const msg = 'No se pudo cargar el detalle del partido.';
      setState(() {
        _abriendoDetalle = false;
        _error = msg;
      });
      showAppToast(context, msg, type: 'error');
    }
  }

  Future<void> _abrirFormulario([CoachMatchDetail? inicial]) async {
    if (_equipos.isEmpty) return;
    final msg = await showDialog<String>(
      context: context,
      barrierColor: DashColors.modalOverlay,
      builder: (_) => PartidoFormDialog(equipos: _equipos, inicial: inicial),
    );
    if (!mounted || msg == null || msg.isEmpty) return;
    setState(() => _aviso = msg);
    await _cargarPartidos();
  }

  @override
  Widget build(BuildContext context) {
    final datos = _datos;
    final resumen = datos?.resumen;
    return Material(
      color: DashColors.bg,
      child: LayoutBuilder(
        builder: (context, c) {
          final narrow = c.maxWidth < 860;
          final mobile = c.maxWidth < 600;
          return RefreshIndicator(
            color: DashColors.blue,
            backgroundColor: DashColors.cardDark,
            onRefresh: _refrescarTodo,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.fromLTRB(mobile ? 14 : 24, mobile ? 64 : 28, mobile ? 14 : 24, 90),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1200),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildHeader(mobile),
                      const SizedBox(height: 22),
                      if (_aviso.isNotEmpty) EquipoAlertBanner(text: _aviso, isError: false),
                      if (_error.isNotEmpty) EquipoAlertBanner(text: _error, isError: true, onRetry: _refrescarTodo),
                      if (_cargando)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 28),
                          child: Row(
                            children: [
                              SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2.2, color: DashColors.blueLight)),
                              SizedBox(width: 12),
                              Text('Cargando partidos…', style: TextStyle(fontSize: 14, color: DashColors.textMuted)),
                            ],
                          ),
                        )
                      else if (datos != null && resumen != null) ...[
                        if (resumen.jugados > 0) ...[
                          PartidosRecordSection(resumen: resumen, narrow: narrow),
                          const SizedBox(height: 24),
                        ],
                        if (datos.partidos.isEmpty)
                          PartidosEmptyState(
                            hasTeams: _equipos.isNotEmpty,
                            isFiltered: _equipoId != null,
                            onRegister: () => _abrirFormulario(),
                          )
                        else
                          Column(
                            children: [
                              for (var i = 0; i < datos.partidos.length; i++) ...[
                                if (i > 0) const SizedBox(height: 12),
                                PartidoListCard(
                                  partido: datos.partidos[i],
                                  narrow: narrow,
                                  onTap: () => _abrirDetalle(datos.partidos[i].id),
                                ),
                              ],
                            ],
                          ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(bool mobile) {
    final actions = Wrap(
      spacing: 10,
      runSpacing: 10,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        if (_equipos.length > 1)
          Container(
            height: 40,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: DashColors.cardDark,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: DashColors.coachBorder),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<int?>(
                value: _equipos.any((e) => e.id == _equipoId) ? _equipoId : null,
                dropdownColor: DashColors.cardDark,
                icon: const Icon(Icons.filter_list_rounded, size: 16, color: DashColors.textMuted),
                style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600, color: DashColors.text1),
                items: [
                  const DropdownMenuItem<int?>(value: null, child: Text('Todos mis equipos')),
                  for (final eq in _equipos) DropdownMenuItem<int?>(value: eq.id, child: Text(eq.nombre)),
                ],
                onChanged: _cambiarEquipo,
              ),
            ),
          ),
        EquipoPrimButton(label: '+ Registrar partido', enabled: _equipos.isNotEmpty, onTap: () => _abrirFormulario()),
      ],
    );

    const titles = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('COMPETENCIA', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, letterSpacing: 1.6, color: DashColors.accent2)),
        SizedBox(height: 4),
        Text('Partidos', style: TextStyle(fontSize: 30, fontWeight: FontWeight.w800, letterSpacing: -0.6, color: DashColors.text1)),
        SizedBox(height: 4),
        Text(
          'Registra el resultado y las estadísticas de cada jugador. Ellos reciben un aviso y ven solo sus propias cifras.',
          style: TextStyle(fontSize: 14, color: DashColors.textMuted, height: 1.45),
        ),
      ],
    );

    if (mobile) {
      return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [titles, const SizedBox(height: 14), actions]);
    }
    return Row(crossAxisAlignment: CrossAxisAlignment.end, children: [const Expanded(child: titles), const SizedBox(width: 16), actions]);
  }
}
