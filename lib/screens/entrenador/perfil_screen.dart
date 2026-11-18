import 'package:flutter/material.dart';

import 'package:volleyscan_mobile/services/api_service.dart';
import 'package:volleyscan_mobile/theme/app_theme.dart';
import 'package:volleyscan_mobile/theme/dash_colors.dart';
import 'package:volleyscan_mobile/widgets/entrenador/perfil/perfil_achievements_card.dart';
import 'package:volleyscan_mobile/widgets/entrenador/perfil/perfil_header.dart';
import 'package:volleyscan_mobile/widgets/entrenador/perfil/perfil_info_card.dart';
import 'package:volleyscan_mobile/widgets/entrenador/perfil/perfil_logro_dialog.dart';
import 'package:volleyscan_mobile/widgets/entrenador/perfil/perfil_model.dart';

class PerfilScreen extends StatefulWidget {
  const PerfilScreen({super.key});

  @override
  State<PerfilScreen> createState() => _PerfilScreenState();
}

class _PerfilScreenState extends State<PerfilScreen> {
  EntrenadorPerfilData? _profile;
  bool _loading = true;
  bool _saving = false;
  bool _isEditing = false;
  String? _error;

  final _nombreCtrl = TextEditingController();
  final _apellidoCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _clubCtrl = TextEditingController();
  final _experienceCtrl = TextEditingController();
  String _level = 'intermedio';

  List<Achievement> _achievements = const [];

  @override
  void initState() {
    super.initState();
    _cargarPerfil();
  }

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _apellidoCtrl.dispose();
    _phoneCtrl.dispose();
    _clubCtrl.dispose();
    _experienceCtrl.dispose();
    super.dispose();
  }

  void _syncFormFromProfile(EntrenadorPerfilData p) {
    _nombreCtrl.text = p.nombre;
    _apellidoCtrl.text = p.apellido;
    _phoneCtrl.text = p.telefono;
    _clubCtrl.text = p.club;
    _experienceCtrl.text = p.experiencia;
    _level = normalizeCoachNivelValue(p.nivel);
  }

  Future<void> _cargarPerfil() async {
    final guardado = await ApiService.getUsuario();
    if (mounted && guardado != null && _profile == null) {
      final cached = EntrenadorPerfilData.fromJson(guardado);
      setState(() {
        _profile = cached;
        _syncFormFromProfile(cached);
      });
    }

    if (mounted) {
      setState(() {
        _loading = true;
        _error = null;
      });
    }

    try {
      final remoto = await ApiService().obtenerPerfilEntrenador();
      if (!mounted) return;
      final merged = remoto.copyWith(
        telefono: remoto.telefono.isNotEmpty
            ? remoto.telefono
            : (_profile?.telefono ?? ''),
        club: remoto.club.isNotEmpty ? remoto.club : (_profile?.club ?? ''),
        experiencia: remoto.experiencia.isNotEmpty
            ? remoto.experiencia
            : (_profile?.experiencia ?? ''),
      );
      setState(() {
        _profile = merged;
        _syncFormFromProfile(merged);
        _loading = false;
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      if (e.isUnauthorized) return;
      const fallback = 'No se pudo cargar la información del perfil';
      final msg = e.message.isNotEmpty ? e.message : fallback;
      setState(() {
        _error = msg;
        _loading = false;
      });
      showAppToast(context, fallback, type: 'error');
    } catch (_) {
      if (!mounted) return;
      const msg = 'No se pudo cargar la información del perfil';
      setState(() {
        _error = msg;
        _loading = false;
      });
      showAppToast(context, msg, type: 'error');
    }
  }

  void _toggleEdit() {
    if (_profile == null || _saving) return;
    setState(() {
      _syncFormFromProfile(_profile!);
      _isEditing = !_isEditing;
    });
  }

  Future<void> _saveProfile() async {
    if (_saving) return;
    final nombre = _nombreCtrl.text.trim();
    final apellido = _apellidoCtrl.text.trim();
    if (nombre.isEmpty) {
      showAppToast(context, 'El nombre no puede estar vacío', type: 'error');
      return;
    }

    setState(() => _saving = true);
    try {
      // Mismo cuerpo que `page.jsx`:
      // `{ nombre, apellido, telefono, club, experiencia, nivel }`
      final actualizado = await ApiService().actualizarPerfilEntrenador({
        'nombre': nombre,
        'apellido': apellido,
        'telefono': _phoneCtrl.text.trim(),
        'club': _clubCtrl.text.trim(),
        'experiencia': _experienceCtrl.text.trim(),
        'nivel': _level,
      });
      if (!mounted) return;
      final merged = actualizado.copyWith(
        nombre: actualizado.nombre.isNotEmpty ? actualizado.nombre : nombre,
        apellido:
            actualizado.apellido.isNotEmpty ? actualizado.apellido : apellido,
        email: actualizado.email.isNotEmpty
            ? actualizado.email
            : (_profile?.email ?? ''),
        telefono: actualizado.telefono.isNotEmpty
            ? actualizado.telefono
            : _phoneCtrl.text.trim(),
        club: actualizado.club.isNotEmpty
            ? actualizado.club
            : _clubCtrl.text.trim(),
        experiencia: actualizado.experiencia.isNotEmpty
            ? actualizado.experiencia
            : _experienceCtrl.text.trim(),
        nivel: (actualizado.nivel != null && actualizado.nivel!.isNotEmpty)
            ? actualizado.nivel
            : _level,
      );
      setState(() {
        _profile = merged;
        _syncFormFromProfile(merged);
        _isEditing = false;
        _saving = false;
      });
      showAppToast(context, 'Perfil actualizado correctamente', type: 'success');
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
      if (e.isUnauthorized) return;
      showAppToast(
        context,
        e.message.isNotEmpty ? e.message : 'Error al actualizar el perfil',
        type: 'error',
      );
    } catch (_) {
      if (!mounted) return;
      setState(() => _saving = false);
      showAppToast(context, 'Error al actualizar el perfil', type: 'error');
    }
  }

  void _cancelEdit() {
    if (_profile != null) {
      _syncFormFromProfile(_profile!);
    }
    setState(() => _isEditing = false);
    showAppToast(context, 'Edición cancelada', type: 'info');
  }

  Future<void> _addAchievement() async {
    final result = await showDialog<Achievement>(
      context: context,
      barrierColor: DashColors.modalOverlay,
      builder: (_) => const LogroDialog(),
    );
    if (result == null || !mounted) return;
    setState(() => _achievements = [result, ..._achievements]);
    showAppToast(context, '"${result.title}" añadido', type: 'success');
  }

  Future<void> _deleteAchievement(int id) async {
    final ok = await showDialog<bool>(
      context: context,
      barrierColor: DashColors.modalOverlay,
      builder: (ctx) => AlertDialog(
        backgroundColor: DashColors.card2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.md),
          side: const BorderSide(color: DashColors.border2),
        ),
        title: const Text(
          'Eliminar logro',
          style: TextStyle(color: DashColors.text1, fontSize: 18),
        ),
        content: const Text(
          '¿Eliminar este logro?',
          style: TextStyle(color: DashColors.textMuted),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text(
              'Cancelar',
              style: TextStyle(color: DashColors.textMuted),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text(
              'Eliminar',
              style: TextStyle(color: DashColors.red),
            ),
          ),
        ],
      ),
    );
    if (ok == true && mounted) {
      setState(
        () => _achievements = _achievements.where((a) => a.id != id).toList(),
      );
      showAppToast(context, 'Logro eliminado', type: 'success');
    }
  }

  @override
  Widget build(BuildContext context) {
    final narrow = MediaQuery.of(context).size.width < 900;

    return Material(
      color: DashColors.bg,
      child: RefreshIndicator(
        color: DashColors.blueLight,
        backgroundColor: DashColors.cardDark,
        onRefresh: _cargarPerfil,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.fromLTRB(20, narrow ? 64 : 24, 20, 100),
          child: Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1100),
              child: LayoutBuilder(
                builder: (context, c) {
                  final ancho = c.maxWidth > 900;

                  final info = PerfilInfoCard(
                    isEditing: _isEditing,
                    loading: _loading,
                    saving: _saving,
                    profile: _profile,
                    nombreCtrl: _nombreCtrl,
                    apellidoCtrl: _apellidoCtrl,
                    phoneCtrl: _phoneCtrl,
                    clubCtrl: _clubCtrl,
                    experienceCtrl: _experienceCtrl,
                    level: _level,
                    onLevel: (v) => setState(() => _level = v),
                    onSave: _saveProfile,
                    onCancel: _cancelEdit,
                  );
                  final logros = PerfilAchievementsCard(
                    achievements: _achievements,
                    onAdd: _addAchievement,
                    onDelete: _deleteAchievement,
                  );

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (_error != null) ...[
                        Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: DashColors.cardDark,
                            borderRadius: BorderRadius.circular(AppRadii.panel),
                            border: Border.all(
                              color: DashColors.dangerOutlineBorder,
                            ),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.error_outline_rounded,
                                color: DashColors.red,
                                size: 20,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  _error!,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: DashColors.text1,
                                  ),
                                ),
                              ),
                              TextButton(
                                onPressed: _cargarPerfil,
                                child: const Text(
                                  'Reintentar',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: DashColors.accent2,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                      PerfilHeader(
                        ancho: ancho,
                        isEditing: _isEditing,
                        loading: _loading,
                        profile: _profile,
                        onToggleEdit: _profile == null ? null : _toggleEdit,
                      ),
                      const SizedBox(height: 32),
                      if (ancho)
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(child: info),
                            const SizedBox(width: 32),
                            SizedBox(width: 360, child: logros),
                          ],
                        )
                      else ...[
                        info,
                        const SizedBox(height: 24),
                        logros,
                      ],
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
