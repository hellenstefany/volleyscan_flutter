import 'package:flutter/material.dart';

import '../../models/equipo.dart';
import '../../models/registro_rutina_data.dart';
import '../../services/api_service.dart';
import '../../theme/app_theme.dart';
import '../../theme/dash_colors.dart';
import '../../widgets/entrenador/registro_rutinas/registro_header_tabs.dart';
import '../../widgets/entrenador/registro_rutinas/registro_nivel_dialog.dart';
import '../../widgets/entrenador/registro_rutinas/registro_niveles_tab.dart';
import '../../widgets/entrenador/registro_rutinas/registro_revision_dialog.dart';
import '../../widgets/entrenador/registro_rutinas/registro_rutinas_tab.dart';

/// Pantalla "Registro de rutinas" del Panel de Entrenador
/// (`/panel_entrenador/registro-rutinas`).
class RegistroRutinasScreen extends StatefulWidget {
  const RegistroRutinasScreen({super.key});

  @override
  State<RegistroRutinasScreen> createState() => _RegistroRutinasScreenState();
}

class _RegistroRutinasScreenState extends State<RegistroRutinasScreen> {
  String _pestana = 'registro';
  String _estado = 'pendientes';
  List<Equipo> _equipos = const [];
  int? _equipoId;
  int? _atletaId;
  String _desde = '';
  String _hasta = '';

  List<DeportistaNivelResumen>? _niveles;
  String _errorNiveles = '';
  RegistroRutinasResponse? _registro;
  bool _cargandoReg = true;
  String _errorReg = '';

  @override
  void initState() {
    super.initState();
    _cargarEquipos();
    _cargarNiveles();
    _cargarRegistro();
  }

  Future<void> _cargarEquipos() async {
    try {
      final list = await ApiService().listarEquiposEntrenador();
      if (mounted) setState(() => _equipos = list);
    } on ApiException catch (e) {
      if (!mounted || e.isUnauthorized) return;
    } catch (_) {}
  }

  Future<void> _cargarNiveles() async {
    if (mounted) setState(() => _errorNiveles = '');
    try {
      final list = await ApiService().nivelesDeportistasEntrenador(
        equipoId: _equipoId,
      );
      if (mounted) setState(() => _niveles = list);
    } on ApiException catch (e) {
      if (!mounted || e.isUnauthorized) return;
      setState(() {
        _errorNiveles = e.message;
        _niveles = const [];
      });
    } catch (_) {
      if (mounted) {
        setState(() {
          _errorNiveles = 'No se pudieron cargar los niveles.';
          _niveles = const [];
        });
      }
    }
  }

  Future<void> _cargarRegistro() async {
    if (mounted) {
      setState(() {
        _cargandoReg = true;
        _errorReg = '';
      });
    }
    try {
      final res = await ApiService().registroRutinasEntrenador(
        estado: _estado,
        atletaId: _atletaId,
        equipoId: _equipoId,
        desde: _desde,
        hasta: _hasta,
      );
      if (!mounted) return;
      setState(() {
        _registro = res;
        _cargandoReg = false;
        _errorReg = '';
      });
    } on ApiException catch (e) {
      if (!mounted || e.isUnauthorized) return;
      setState(() {
        _cargandoReg = false;
        _errorReg = e.message;
        _registro = null;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _cargandoReg = false;
        _errorReg = 'No se pudo cargar el registro de rutinas.';
        _registro = null;
      });
    }
  }

  Future<void> _refrescarTodo() => Future.wait([
        _cargarEquipos(),
        _cargarNiveles(),
        _cargarRegistro(),
      ]);

  Future<void> _abrirRevision(int rutinaId) async {
    final msg = await showRegistroRevisionDialog(context, rutinaId);
    if (!mounted || msg == null) return;
    showAppToast(context, msg);
    await Future.wait([_cargarNiveles(), _cargarRegistro()]);
  }

  Future<void> _abrirCambioNivel(DeportistaNivelResumen atleta) async {
    final msg = await showRegistroNivelDialog(context, atleta);
    if (!mounted || msg == null) return;
    showAppToast(context, msg);
    await Future.wait([_cargarNiveles(), _cargarRegistro()]);
  }

  @override
  Widget build(BuildContext context) {
    final listNiv = _niveles ?? const <DeportistaNivelResumen>[];
    final pendientesTotal = listNiv.fold<int>(
      0,
      (acc, d) => acc + d.pendientesRevision,
    );
    final sugeridos = listNiv.where((d) => d.avance.sugerencia != null).length;

    return LayoutBuilder(
      builder: (context, c) {
        final w = c.maxWidth - 32;
        return RefreshIndicator(
          color: DashColors.blueLight,
          onRefresh: _refrescarTodo,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 90),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                RegistroHeaderAndTabs(
                  equipos: _equipos,
                  equipoId: _equipoId,
                  pestana: _pestana,
                  pendientesTotal: pendientesTotal,
                  sugeridos: sugeridos,
                  onEquipoChanged: (v) {
                    setState(() {
                      _equipoId = v;
                      _atletaId = null;
                    });
                    _cargarNiveles();
                    _cargarRegistro();
                  },
                  onSelectRegistro: () {
                    setState(() {
                      _estado = 'pendientes';
                      _pestana = 'registro';
                    });
                    _cargarRegistro();
                  },
                  onSelectNiveles: () => setState(() => _pestana = 'niveles'),
                ),
                const SizedBox(height: 18),
                if (_pestana == 'registro')
                  RegistroRutinasTab(
                    width: w,
                    estado: _estado,
                    atletaId: _atletaId,
                    desde: _desde,
                    hasta: _hasta,
                    deportistas: listNiv,
                    datos: _registro,
                    cargando: _cargandoReg,
                    error: _errorReg,
                    onEstado: (v) {
                      setState(() => _estado = v);
                      _cargarRegistro();
                    },
                    onAtleta: (v) {
                      setState(() => _atletaId = v);
                      _cargarRegistro();
                    },
                    onDesde: (v) {
                      setState(() => _desde = v);
                      _cargarRegistro();
                    },
                    onHasta: (v) {
                      setState(() => _hasta = v);
                      _cargarRegistro();
                    },
                    onLimpiarFiltros: () {
                      setState(() {
                        _atletaId = null;
                        _desde = '';
                        _hasta = '';
                      });
                      _cargarRegistro();
                    },
                    onReintentar: _cargarRegistro,
                    onRevisar: _abrirRevision,
                  )
                else
                  RegistroNivelesTab(
                    width: w,
                    lista: _niveles,
                    error: _errorNiveles,
                    onReintentar: _cargarNiveles,
                    onCambiarNivel: _abrirCambioNivel,
                    onVerRegistro: (id) {
                      setState(() {
                        _atletaId = id;
                        _estado = 'todas';
                        _pestana = 'registro';
                      });
                      _cargarRegistro();
                    },
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
