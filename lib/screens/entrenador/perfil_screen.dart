import 'package:flutter/material.dart';
import '../../theme/entrenador_colors.dart';

// ───────── Modelos ─────────
class _Achievement {
  final int id;
  final String icon, title, description;
  const _Achievement(this.id, this.icon, this.title, this.description);
}

const _defaultProfile = {
  'fullName': 'Agustín Luligo',
  'email': 'agustin@volleyai.com',
  'phone': '+57 310 000 0000',
  'club': 'Club Atlético Popayán',
  'experience': '5',
  'level': 'Nivel 3',
};

const _niveles = ['Nivel 1', 'Nivel 2', 'Nivel 3', 'Nivel 4', 'Nivel 5'];

// (etiqueta, clave, teclado)
const _campos = [
  ('Nombre completo', 'fullName', TextInputType.text),
  ('Correo electrónico', 'email', TextInputType.emailAddress),
  ('Teléfono', 'phone', TextInputType.phone),
  ('Club', 'club', TextInputType.text),
  ('Años de experiencia', 'experience', TextInputType.number),
];

// ───────── Pantalla ─────────
class PerfilScreen extends StatefulWidget {
  const PerfilScreen({super.key});

  @override
  State<PerfilScreen> createState() => _PerfilScreenState();
}

class _PerfilScreenState extends State<PerfilScreen> {
  bool _isEditing = false;
  Map<String, String> _profile = Map.of(_defaultProfile);
  late final Map<String, TextEditingController> _ctrl;
  String _level = 'Nivel 3';

  List<_Achievement> _achievements = const [
    _Achievement(1, '🏆', 'Mejor entrenador', 'Torneo Regional 2024'),
    _Achievement(2, '📈', '+8% rendimiento', 'Esta semana'),
    _Achievement(3, '🎯', '100 sesiones', 'Completadas este año'),
  ];

  @override
  void initState() {
    super.initState();
    _ctrl = {
      for (final c in _campos)
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

  void _syncFormFromProfile() {
    for (final c in _campos) {
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
        for (final c in _campos) c.$2: _ctrl[c.$2]!.text,
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

  Future<void> _addAchievement() async {
    final result = await showDialog<_Achievement>(
      context: context,
      builder: (_) => const _LogroDialog(),
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

  String get _initials => _profile['fullName']!
      .split(' ')
      .where((s) => s.isNotEmpty)
      .map((s) => s[0])
      .join()
      .toUpperCase();

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
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _header(ancho),
                  const SizedBox(height: 32),
                  if (ancho)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: _infoCard()),
                        const SizedBox(width: 32),
                        SizedBox(width: 360, child: _achievementsCard()),
                      ],
                    )
                  else ...[
                    _infoCard(),
                    const SizedBox(height: 24),
                    _achievementsCard(),
                  ],
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  // ───────── Header ─────────
  Widget _header(bool ancho) {
    final avatar = Container(
      width: 100,
      height: 100,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1E293B), Color(0xFF334155)],
        ),
        border: Border.all(color: EC.accent.withOpacity(0.3), width: 3),
        boxShadow: [
          BoxShadow(color: EC.accent.withOpacity(0.2), blurRadius: 24),
        ],
      ),
      child: Text(
        _initials,
        style: const TextStyle(
          fontSize: 40,
          fontWeight: FontWeight.bold,
          color: EC.accent2,
        ),
      ),
    );

    final info = Column(
      crossAxisAlignment: ancho
          ? CrossAxisAlignment.start
          : CrossAxisAlignment.center,
      children: [
        Text(
          _profile['fullName']!,
          textAlign: ancho ? TextAlign.start : TextAlign.center,
          style: const TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: EC.text1,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Entrenador principal · ${_profile['club']}',
          textAlign: ancho ? TextAlign.start : TextAlign.center,
          style: const TextStyle(fontSize: 14, color: EC.text2),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 8,
          alignment: ancho ? WrapAlignment.start : WrapAlignment.center,
          children: [
            _Tag(Icons.verified, _profile['level']!),
            _Tag(
              Icons.schedule,
              '${_profile['experience']} años de experiencia',
            ),
          ],
        ),
      ],
    );

    final boton = OutlinedButton.icon(
      onPressed: _toggleEdit,
      icon: Icon(_isEditing ? Icons.visibility : Icons.edit, size: 16),
      label: Text(_isEditing ? 'Ver perfil' : 'Editar perfil'),
      style: OutlinedButton.styleFrom(
        foregroundColor: EC.accent2,
        backgroundColor: EC.accent.withOpacity(0.1),
        side: BorderSide(color: EC.accent.withOpacity(0.3)),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 28),
      decoration: _cardDeco(),
      child: ancho
          ? Row(
              children: [
                avatar,
                const SizedBox(width: 24),
                Expanded(child: info),
                const SizedBox(width: 24),
                boton,
              ],
            )
          : Column(
              children: [
                avatar,
                const SizedBox(height: 20),
                info,
                const SizedBox(height: 20),
                boton,
              ],
            ),
    );
  }

  // ───────── Información personal ─────────
  Widget _infoCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: _cardDeco(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _CardHeader(
            icon: Icons.info_outline,
            title: 'Información personal',
            trailing: _isEditing
                ? Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: EC.accent.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      '✎ Modo edición',
                      style: TextStyle(fontSize: 11, color: EC.accent2),
                    ),
                  )
                : null,
          ),
          for (final c in _campos)
            _FormGroup(
              label: c.$1,
              child: _isEditing
                  ? TextField(
                      controller: _ctrl[c.$2],
                      keyboardType: c.$3,
                      style: const TextStyle(color: EC.text1, fontSize: 14),
                      decoration: _inputDeco(),
                    )
                  : _ValueText(
                      c.$2 == 'experience'
                          ? '${_profile[c.$2]} años'
                          : _profile[c.$2]!,
                    ),
            ),
          _FormGroup(
            label: 'Nivel',
            child: _isEditing
                ? DropdownButtonFormField<String>(
                    value: _level,
                    dropdownColor: EC.bgCard2,
                    style: const TextStyle(color: EC.text1, fontSize: 14),
                    decoration: _inputDeco(),
                    items: [
                      for (final n in _niveles)
                        DropdownMenuItem(value: n, child: Text(n)),
                    ],
                    onChanged: (v) => setState(() => _level = v ?? _level),
                  )
                : _ValueText(_profile['level']!),
          ),
          if (_isEditing) ...[
            const SizedBox(height: 4),
            const Divider(color: EC.border, height: 1),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _GradientButton(
                  icon: Icons.check,
                  label: 'Guardar cambios',
                  onTap: _saveProfile,
                ),
                OutlinedButton.icon(
                  onPressed: _cancelEdit,
                  icon: const Icon(Icons.close, size: 16),
                  label: const Text('Cancelar'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: EC.text2,
                    backgroundColor: Colors.white.withOpacity(0.05),
                    side: const BorderSide(color: EC.border),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 14,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  // ───────── Logros ─────────
  Widget _achievementsCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: _cardDeco(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const _CardHeader(
            icon: Icons.emoji_events,
            title: 'Logros recientes',
          ),
          if (_achievements.isEmpty)
            const Padding(
              padding: EdgeInsets.all(20),
              child: Center(
                child: Text(
                  'No hay logros aún',
                  style: TextStyle(color: EC.text3),
                ),
              ),
            )
          else
            for (final a in _achievements)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _AchievementItem(
                  a: a,
                  onDelete: () => _deleteAchievement(a.id),
                ),
              ),
          const SizedBox(height: 8),
          InkWell(
            onTap: _addAchievement,
            borderRadius: BorderRadius.circular(10),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color: EC.accent.withOpacity(0.08),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: EC.border2),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add, size: 16, color: EC.accent2),
                  SizedBox(width: 8),
                  Text(
                    'Añadir logro',
                    style: TextStyle(
                      color: EC.accent2,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ───────── Helpers de estilo ─────────
BoxDecoration _cardDeco() => BoxDecoration(
  color: EC.bgCard,
  borderRadius: BorderRadius.circular(16),
  border: Border.all(color: EC.border),
);

InputDecoration _inputDeco({String? hint, String? error}) => InputDecoration(
  isDense: true,
  filled: true,
  fillColor: EC.bgCard2,
  hintText: hint,
  hintStyle: const TextStyle(color: EC.text3),
  errorText: error,
  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
  border: OutlineInputBorder(
    borderRadius: BorderRadius.circular(8),
    borderSide: const BorderSide(color: EC.border2),
  ),
  enabledBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(8),
    borderSide: const BorderSide(color: EC.border2),
  ),
  focusedBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(8),
    borderSide: const BorderSide(color: EC.accent),
  ),
);

// ───────── Widgets pequeños ─────────
class _Tag extends StatelessWidget {
  final IconData icon;
  final String text;
  const _Tag(this.icon, this.text);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: EC.bgHover,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: EC.accent2),
          const SizedBox(width: 6),
          Text(text, style: const TextStyle(fontSize: 12, color: EC.text2)),
        ],
      ),
    );
  }
}

class _CardHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  final Widget? trailing;
  const _CardHeader({required this.icon, required this.title, this.trailing});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.only(bottom: 12),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: EC.border)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: EC.accent2),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: EC.text1,
              ),
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

class _FormGroup extends StatelessWidget {
  final String label;
  final Widget child;
  const _FormGroup({required this.label, required this.child});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.6,
              color: EC.text3,
            ),
          ),
          const SizedBox(height: 6),
          child,
        ],
      ),
    );
  }
}

class _ValueText extends StatelessWidget {
  final String text;
  const _ValueText(this.text);

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 10),
    child: Text(text, style: const TextStyle(fontSize: 14, color: EC.text1)),
  );
}

class _GradientButton extends StatelessWidget {
  final IconData? icon;
  final String label;
  final VoidCallback onTap;
  const _GradientButton({this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Ink(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [EC.accent, EC.purple],
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 16, color: Colors.white),
                const SizedBox(width: 8),
              ],
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AchievementItem extends StatelessWidget {
  final _Achievement a;
  final VoidCallback onDelete;
  const _AchievementItem({required this.a, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: EC.bgCard2,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: EC.bgCard,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(a.icon, style: const TextStyle(fontSize: 26)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  a.title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: EC.text1,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  a.description,
                  style: const TextStyle(fontSize: 12, color: EC.text2),
                ),
              ],
            ),
          ),
          InkWell(
            onTap: onDelete,
            borderRadius: BorderRadius.circular(8),
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: EC.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.delete_outline, size: 16, color: EC.red),
            ),
          ),
        ],
      ),
    );
  }
}

// ───────── Modal "Nuevo logro" ─────────
class _LogroDialog extends StatefulWidget {
  const _LogroDialog();

  @override
  State<_LogroDialog> createState() => _LogroDialogState();
}

class _LogroDialogState extends State<_LogroDialog> {
  final _title = TextEditingController();
  final _desc = TextEditingController();
  final _icon = TextEditingController(text: '🏆');
  String? _titleError, _descError;

  @override
  void dispose() {
    _title.dispose();
    _desc.dispose();
    _icon.dispose();
    super.dispose();
  }

  void _guardar() {
    setState(() {
      _titleError = _title.text.trim().isEmpty
          ? 'El título es obligatorio'
          : null;
      _descError = _desc.text.trim().isEmpty
          ? 'La descripción es obligatoria'
          : null;
    });
    if (_titleError != null || _descError != null) return;
    Navigator.pop(
      context,
      _Achievement(
        DateTime.now().millisecondsSinceEpoch,
        _icon.text.trim().isEmpty ? '🏆' : _icon.text.trim(),
        _title.text.trim(),
        _desc.text.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: EC.bgCard2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: EC.border),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 20, 16, 16),
                child: Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Nuevo logro',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: EC.text1,
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: () => Navigator.pop(context),
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: EC.bgCard,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: EC.border),
                        ),
                        child: const Icon(
                          Icons.close,
                          size: 16,
                          color: EC.text2,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(color: EC.border, height: 1),
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _modalLabel('Título del logro'),
                    TextField(
                      controller: _title,
                      style: const TextStyle(color: EC.text1),
                      decoration: _inputDeco(
                        hint: 'Ej: Campeón invicto',
                        error: _titleError,
                      ),
                    ),
                    const SizedBox(height: 20),
                    _modalLabel('Descripción'),
                    TextField(
                      controller: _desc,
                      style: const TextStyle(color: EC.text1),
                      decoration: _inputDeco(
                        hint: 'Ej: Liga Departamental 2025',
                        error: _descError,
                      ),
                    ),
                    const SizedBox(height: 20),
                    _modalLabel('Icono (emoji)'),
                    TextField(
                      controller: _icon,
                      maxLength: 2,
                      style: const TextStyle(color: EC.text1),
                      decoration: _inputDeco(
                        hint: 'Ej: 🏆',
                      ).copyWith(counterText: ''),
                    ),
                  ],
                ),
              ),
              const Divider(color: EC.border, height: 1),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: EC.text2,
                        side: const BorderSide(color: EC.border),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 14,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text('Cancelar'),
                    ),
                    const SizedBox(width: 12),
                    _GradientButton(label: 'Guardar logro', onTap: _guardar),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _modalLabel(String t) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(
      t,
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: EC.text2,
      ),
    ),
  );
}
