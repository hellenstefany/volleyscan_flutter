import 'package:flutter/material.dart';
import '../../../theme/entrenador_colors.dart'; // ✅
import 'perfil_achievements_card.dart';
import 'perfil_header.dart';
import 'perfil_info_card.dart';
import 'perfil_logro_dialog.dart';
import 'perfil_model.dart';

class PerfilScreen extends StatefulWidget {
  const PerfilScreen({super.key});

  @override
  State<PerfilScreen> createState() => _PerfilScreenState();
}

class _PerfilScreenState extends State<PerfilScreen> {
  bool _isEditing = false;
  Map<String, String> _profile = Map.of(kDefaultProfile);
  late final Map<String, TextEditingController> _ctrl;
  String _level = 'Nivel 3';
  List<Achievement> _achievements = kInitialAchievements;

  @override
  void initState() {
    super.initState();
    _ctrl = {
      for (final c in kCampos)
        c.$2: TextEditingController(text: _profile[c.$2]),
    };
  }

  @override
  void dispose() {
    for (final c in _ctrl.values) {
      c.dispose();
    }
    super.dispose();
  }

  // ── Toast ──
  void _toast(String msg) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          duration: const Duration(seconds: 3),
          behavior: SnackBarBehavior.floating,
          backgroundColor: EC.bgCard2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: EC.border2),
          ),
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: EC.green, size: 18),
              const SizedBox(width: 10),
              Expanded(
                child: Text(msg, style: const TextStyle(color: EC.text1)),
              ),
            ],
          ),
        ),
      );
  }

  // ── Perfil ──
  void _syncFormFromProfile() {
    for (final c in kCampos) {
      _ctrl[c.$2]!.text = _profile[c.$2] ?? '';
    }
    _level = _profile['level']!;
  }

  void _toggleEdit() {
    setState(() {
      _syncFormFromProfile();
      _isEditing = !_isEditing;
    });
  }

  void _saveProfile() {
    if (_ctrl['fullName']!.text.trim().isEmpty) {
      _toast('El nombre no puede estar vacío');
      return;
    }
    if (!_ctrl['email']!.text.contains('@')) {
      _toast('Correo electrónico inválido');
      return;
    }
    setState(() {
      _profile = {
        for (final c in kCampos) c.$2: _ctrl[c.$2]!.text,
        'level': _level,
      };
      _isEditing = false;
    });
    _toast('Perfil actualizado correctamente');
  }

  void _cancelEdit() {
    setState(() {
      _syncFormFromProfile();
      _isEditing = false;
    });
    _toast('Edición cancelada');
  }

  // ── Logros ──
  Future<void> _addAchievement() async {
    final result = await showDialog<Achievement>(
      context: context,
      builder: (_) => const LogroDialog(),
    );
    if (result == null) return;
    setState(() => _achievements = [result, ..._achievements]);
    _toast('"${result.title}" añadido');
  }

  Future<void> _deleteAchievement(int id) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: EC.bgCard2,
        title: const Text(
          'Eliminar logro',
          style: TextStyle(color: EC.text1, fontSize: 18),
        ),
        content: const Text(
          '¿Eliminar este logro?',
          style: TextStyle(color: EC.text2),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar', style: TextStyle(color: EC.text2)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Eliminar', style: TextStyle(color: EC.red)),
          ),
        ],
      ),
    );
    if (ok == true) {
      setState(
        () => _achievements = _achievements.where((a) => a.id != id).toList(),
      );
      _toast('Logro eliminado');
    }
  }

  // ── UI ──
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
      child: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1100),
          child: LayoutBuilder(
            builder: (context, c) {
              final ancho = c.maxWidth > 900;

              final info = PerfilInfoCard(
                isEditing: _isEditing,
                profile: _profile,
                ctrl: _ctrl,
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
                  PerfilHeader(
                    ancho: ancho,
                    isEditing: _isEditing,
                    profile: _profile,
                    onToggleEdit: _toggleEdit,
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
    );
  }
}
