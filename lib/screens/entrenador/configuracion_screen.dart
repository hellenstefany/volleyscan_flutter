import 'package:flutter/material.dart';

// ── Colores (variables CSS) ──
const _bg = Color(0xFF0D0F1A);
const _panel = Color(0xFF131629);
const _panel2 = Color(0xFF181C30);
const _border = Color(0x12FFFFFF);
const _accent = Color(0xFF7C5CFC);
const _accent2 = Color(0xFF00D4FF);
const _danger = Color(0xFFFF6B6B);
const _accent5 = Color(0xFF26DE81);
const _text = Color(0xFFE8EAF6);
const _muted = Color(0xFF7A7F9A);

// ── Datos ──
class _ThemeOpt {
  final String id;
  final String name;
  final List<Color> colors;
  const _ThemeOpt(this.id, this.name, this.colors);
}

const _themes = [
  _ThemeOpt('dark', 'Oscuro', [
    Color(0xFF0D0F1A),
    Color(0xFF131629),
    Color(0xFF7C5CFC),
  ]),
  _ThemeOpt('amoled', 'AMOLED', [
    Color(0xFF000000),
    Color(0xFF0A0A0A),
    Color(0xFF7C5CFC),
  ]),
  _ThemeOpt('navy', 'Navy', [
    Color(0xFF0F1923),
    Color(0xFF162032),
    Color(0xFF00D4FF),
  ]),
  _ThemeOpt('midnight', 'Midnight', [
    Color(0xFF12111A),
    Color(0xFF1A1828),
    Color(0xFFE056FD),
  ]),
];

const _accentColors = [
  ('Violeta', Color(0xFF7C5CFC)),
  ('Cian', Color(0xFF00D4FF)),
  ('Verde', Color(0xFF26DE81)),
  ('Naranja', Color(0xFFFF9F43)),
  ('Rojo', Color(0xFFFF6B6B)),
  ('Rosa', Color(0xFFE056FD)),
];

const _notifTypes = [
  'Nuevas rutinas asignadas',
  'Recordatorio de sesión (30 min antes)',
  'Reportes generados por IA',
  'Inasistencias de deportistas',
  'Actualizaciones del sistema',
  'Consejos de entrenamiento semanales',
];

const _navItems = [
  ('General', 'General', Icons.tune_rounded),
  ('seguridad', 'Seguridad', Icons.lock_outline_rounded),
  ('tema', 'Tema', Icons.palette_outlined),
  ('notificaciones', 'Notificaciones', Icons.notifications_none_rounded),
  ('equipo', 'Equipo', Icons.groups_outlined),
  ('peligro', 'Eliminar', Icons.warning_amber_rounded),
];

const _members = [
  ('Agustín Luligo', 'agustin@volleyai.com', 'Admin', Color(0xFF7C5CFC)),
  ('Carla Ríos', 'carla@volleyai.com', 'Entrenador', Color(0xFF26DE81)),
  ('Pedro Gómez', 'pedro@volleyai.com', 'Analista', Color(0xFFF7B731)),
];

Map<String, dynamic> _defaults() => {
  'unidad': 'Métrico (kg, cm)',
  'idioma': 'Español',
  'tema': 'Oscuro',
  'video': 'Baja',
  'autoVideo': true,
  'privacidad': 'Solo yo',
  'comentarios': false,
  'compartir': true,
  '2fa': false,
  '2faSms': true,
  'push': true,
  'email': true,
  'sms': false,
  for (final n in _notifTypes) 'n:$n': true,
  'themeId': 'dark',
  'accent': 0xFF7C5CFC,
};

// ── Pantalla ──
class ConfiguracionScreen extends StatefulWidget {
  /// Se llama al pulsar "Cerrar sesión". Úsalo para ir a tu LoginScreen.
  final VoidCallback? onLogout;

  const ConfiguracionScreen({super.key, this.onLogout});

  @override
  State<ConfiguracionScreen> createState() => _ConfiguracionScreenState();
}

class _ConfiguracionScreenState extends State<ConfiguracionScreen> {
  String _section = 'General';
  bool _dirty = false;

  Map<String, dynamic> _v = _defaults();
  Map<String, dynamic> _saved = _defaults();

  void _set(String key, dynamic value) {
    setState(() {
      _v[key] = value;
      _dirty = true;
    });
  }

  void _toast(String icon, String msg, [Color color = _accent]) {
    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
        backgroundColor: _panel2,
        margin: const EdgeInsets.all(20),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: color.withValues(alpha: 0.6)),
        ),
        content: Row(
          children: [
            if (icon.isNotEmpty) ...[
              Text(icon, style: const TextStyle(fontSize: 18)),
              const SizedBox(width: 10),
            ],
            Expanded(
              child: Text(
                msg,
                style: const TextStyle(color: _text, fontSize: 13),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _saveAll() {
    setState(() {
      _saved = Map.of(_v);
      _dirty = false;
    });
    _toast('✅', 'Configuración guardada correctamente', _accent5);
  }

  void _discard() {
    setState(() {
      _v = Map.of(_saved);
      _dirty = false;
    });
    _toast('↩', 'Cambios descartados', _muted);
  }

  void _logout() {
    _toast('👋', 'Sesión cerrada', _danger);
    if (widget.onLogout != null) {
      widget.onLogout!();
    } else {
      Navigator.of(context).popUntil((r) => r.isFirst);
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, outer) {
        // Ancho REAL disponible (respeta el límite de 480 px de main.dart)
        final narrow = outer.maxWidth < 900;

        return Material(
          color: _bg,
          child: Column(
            children: [
              _buildTopbar(narrow),
              Expanded(
                child: LayoutBuilder(
                  builder: (context, c) {
                    final wideLayout = c.maxWidth >= 760;
                    final pad = narrow ? 16.0 : 28.0;

                    if (wideLayout) {
                      return Padding(
                        padding: EdgeInsets.all(pad),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(width: 180, child: _buildNavVertical()),
                            const SizedBox(width: 20),
                            Expanded(
                              child: SingleChildScrollView(
                                child: _buildSection(c.maxWidth),
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    return SingleChildScrollView(
                      // abajo: espacio para la barra inferior
                      padding: EdgeInsets.fromLTRB(pad, pad, pad, 110),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _buildNavHorizontal(),
                          const SizedBox(height: 16),
                          _buildSection(c.maxWidth),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ── Topbar ──
  Widget _buildTopbar(bool narrow) {
    final title = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text('⚙', style: TextStyle(fontSize: 22, color: _accent)),
        const SizedBox(width: 8),
        const Text(
          'Configuración',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            letterSpacing: 1,
            color: _text,
          ),
        ),
        if (_dirty) ...[
          const SizedBox(width: 14),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFF7B731).withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(99),
              border: Border.all(
                color: const Color(0xFFF7B731).withValues(alpha: 0.35),
              ),
            ),
            child: const Text(
              'Cambios sin guardar',
              style: TextStyle(fontSize: 11, color: Color(0xFFF7B731)),
            ),
          ),
        ],
      ],
    );

    final actions = Wrap(
      spacing: 10,
      runSpacing: 8,
      children: [
        _Btn(label: '↺ Descartar', style: _BtnStyle.ghost, onTap: _discard),
        _Btn(
          label: 'Guardar cambios',
          style: _BtnStyle.primary,
          onTap: _saveAll,
        ),
      ],
    );

    return Container(
      width: double.infinity,
      // En móvil dejamos espacio para el botón flotante del menú
      padding: EdgeInsets.fromLTRB(narrow ? 64 : 28, 18, narrow ? 16 : 28, 18),
      decoration: const BoxDecoration(
        color: _panel,
        border: Border(bottom: BorderSide(color: _border)),
      ),
      child: narrow
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: title,
                ),
                const SizedBox(height: 12),
                actions,
              ],
            )
          : Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 16,
              runSpacing: 12,
              children: [title, actions],
            ),
    );
  }

  // ── Navegación lateral ──
  Widget _buildNavVertical() {
    return Column(
      children: [
        for (final n in _navItems)
          _NavTile(
            icon: n.$3,
            label: n.$2,
            active: _section == n.$1,
            onTap: () => setState(() => _section = n.$1),
          ),
      ],
    );
  }

  Widget _buildNavHorizontal() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (final n in _navItems)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: _NavTile(
                icon: n.$3,
                label: n.$2,
                active: _section == n.$1,
                compact: true,
                onTap: () => setState(() => _section = n.$1),
              ),
            ),
        ],
      ),
    );
  }

  // ── Secciones ──
  Widget _buildSection(double w) {
    switch (_section) {
      case 'seguridad':
        return _seguridad();
      case 'tema':
        return _tema();
      case 'notificaciones':
        return _notificaciones();
      case 'equipo':
        return _equipo();
      case 'peligro':
        return _peligro();
      default:
        return _general(w);
    }
  }

  Widget _header(String title, String desc) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: _text,
            ),
          ),
          const SizedBox(height: 4),
          Text(desc, style: const TextStyle(fontSize: 13, color: _muted)),
        ],
      ),
    );
  }

  Widget _select(String key, List<String> options, {double width = 170}) {
    return Container(
      width: width,
      height: 38,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: _panel2,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _border),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _v[key] as String,
          isExpanded: true,
          dropdownColor: const Color(0xFF1A1E30),
          icon: const Icon(Icons.keyboard_arrow_down, size: 18, color: _muted),
          style: const TextStyle(color: _text, fontSize: 13),
          items: options
              .map((o) => DropdownMenuItem(value: o, child: Text(o)))
              .toList(),
          onChanged: (x) {
            if (x != null) _set(key, x);
          },
        ),
      ),
    );
  }

  Widget _toggle(String key) =>
      _Toggle(value: _v[key] as bool, onChanged: (x) => _set(key, x));

  // GENERAL
  Widget _general(double w) {
    final main = _Card(
      children: [
        _FieldRow(
          name: 'Unidad de medida',
          trailing: _select('unidad', const [
            'Métrico (kg, cm)',
            'Imperial (lb, in)',
          ]),
        ),
        _FieldRow(
          name: 'Idioma',
          trailing: _select('idioma', const [
            'Español',
            'English',
            'Português',
          ]),
        ),
        _FieldRow(
          name: 'Tema',
          trailing: _select('tema', const [
            'Oscuro',
            'AMOLED',
            'Navy',
            'Midnight',
          ]),
        ),
        _FieldRow(
          name: 'Calidad de video para análisis',
          trailing: _select('video', const ['Baja', 'Media', 'Alta']),
        ),
        _FieldRow(
          name: 'Guardar videos automáticamente',
          desc: 'Los videos de análisis se guardan en tu historial',
          trailing: _toggle('autoVideo'),
          last: true,
        ),
      ],
    );

    final side = _Card(
      title: 'Privacidad rápida',
      children: [
        const Padding(
          padding: EdgeInsets.only(bottom: 8),
          child: Text(
            'Quién puede ver mis análisis',
            style: TextStyle(fontSize: 12, color: _muted),
          ),
        ),
        _select('privacidad', const [
          'Solo yo',
          'Mi equipo',
          'Todos',
        ], width: double.infinity),
        const SizedBox(height: 14),
        _FieldRow(
          name: 'Permitir comentarios',
          small: true,
          trailing: _toggle('comentarios'),
        ),
        _FieldRow(
          name: 'Compartir progreso',
          small: true,
          trailing: _toggle('compartir'),
          last: true,
        ),
        const SizedBox(height: 16),
        _Btn(
          label: 'Cerrar sesión',
          style: _BtnStyle.danger,
          expand: true,
          onTap: _logout,
        ),
      ],
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _header('General', 'Ajusta las preferencias generales de tu cuenta.'),
        if (w >= 900)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: main),
              const SizedBox(width: 16),
              SizedBox(width: 220, child: side),
            ],
          )
        else ...[
          main,
          side,
        ],
      ],
    );
  }

  // SEGURIDAD
  Widget _seguridad() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _header('Seguridad', 'Protege tu cuenta con contraseñas seguras.'),
        _Card(
          title: 'Contraseña',
          children: [
            for (final l in const [
              'CONTRASEÑA ACTUAL',
              'NUEVA CONTRASEÑA',
              'CONFIRMAR CONTRASEÑA',
            ])
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l,
                      style: const TextStyle(fontSize: 11, color: _muted),
                    ),
                    const SizedBox(height: 5),
                    Container(
                      height: 40,
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      decoration: BoxDecoration(
                        color: _panel2,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: _border),
                      ),
                      child: TextField(
                        obscureText: true,
                        onChanged: (_) {
                          if (!_dirty) setState(() => _dirty = true);
                        },
                        cursorColor: _accent,
                        style: const TextStyle(color: _text, fontSize: 13),
                        decoration: const InputDecoration(
                          hintText: '••••••••',
                          hintStyle: TextStyle(color: _muted),
                          border: InputBorder.none,
                          isCollapsed: true,
                          contentPadding: EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 4),
            Align(
              alignment: Alignment.centerLeft,
              child: _Btn(
                label: 'Cambiar contraseña',
                style: _BtnStyle.success,
                onTap: () => _toast(
                  '🔑',
                  'Contraseña actualizada correctamente',
                  _accent5,
                ),
              ),
            ),
          ],
        ),
        _Card(
          title: '📱 Autenticación de dos factores',
          children: [
            _FieldRow(
              name: 'Activar 2FA',
              desc: 'Protección adicional al iniciar sesión',
              trailing: _toggle('2fa'),
            ),
            _FieldRow(
              name: '2FA por SMS',
              desc: 'Código vía mensaje de texto',
              trailing: _toggle('2faSms'),
              last: true,
            ),
          ],
        ),
      ],
    );
  }

  // TEMA
  Widget _tema() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _header(
          'Tema & Apariencia',
          'Personaliza la apariencia visual de VolleyAI.',
        ),
        _Card(
          title: 'Modo de pantalla',
          children: [
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                for (final t in _themes)
                  _ThemeCard(
                    theme: t,
                    selected: _v['themeId'] == t.id,
                    onTap: () {
                      _set('themeId', t.id);
                      _toast('', 'Tema "${t.name}" aplicado');
                    },
                  ),
              ],
            ),
          ],
        ),
        _Card(
          title: 'Color de acento',
          children: [
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                for (final a in _accentColors)
                  Tooltip(
                    message: a.$1,
                    child: GestureDetector(
                      onTap: () {
                        _set('accent', a.$2.toARGB32());
                        _toast('', 'Acento: ${a.$1}');
                      },
                      child: Container(
                        width: 36,
                        height: 36,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: a.$2,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: _v['accent'] == a.$2.toARGB32()
                                ? Colors.white
                                : Colors.transparent,
                            width: 2,
                          ),
                        ),
                        child: _v['accent'] == a.$2.toARGB32()
                            ? const Icon(
                                Icons.check,
                                size: 18,
                                color: Colors.white,
                              )
                            : null,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  // NOTIFICACIONES
  Widget _notificaciones() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _header(
          'Notificaciones',
          'Controla qué alertas recibes y por qué canal.',
        ),
        _Card(
          title: 'Canales',
          children: [
            _FieldRow(
              name: 'Notificaciones push',
              desc: 'Alertas en el navegador',
              trailing: _toggle('push'),
            ),
            _FieldRow(
              name: 'Email',
              desc: 'Resumen diario',
              trailing: _toggle('email'),
            ),
            _FieldRow(
              name: 'SMS',
              desc: 'Solo alertas críticas',
              trailing: _toggle('sms'),
              last: true,
            ),
          ],
        ),
        _Card(
          title: 'Tipo de alertas',
          children: [
            for (var i = 0; i < _notifTypes.length; i++)
              _FieldRow(
                name: _notifTypes[i],
                trailing: _toggle('n:${_notifTypes[i]}'),
                last: i == _notifTypes.length - 1,
              ),
          ],
        ),
      ],
    );
  }

  // EQUIPO
  Widget _equipo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _header('Equipo', 'Gestiona los miembros y roles del equipo técnico.'),
        _Card(
          title: 'Miembros del equipo',
          children: [
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SizedBox(
                width: 620,
                child: Column(
                  children: [
                    _memberHeader(),
                    for (final m in _members) _memberRow(m),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _memberHeader() {
    Widget h(String t, double w) => SizedBox(
      width: w,
      child: Text(
        t.toUpperCase(),
        style: const TextStyle(
          fontSize: 11,
          letterSpacing: 0.8,
          fontWeight: FontWeight.w600,
          color: _muted,
        ),
      ),
    );
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: _border)),
      ),
      child: Row(
        children: [
          h('Miembro', 190),
          h('Email', 200),
          h('Rol', 120),
          h('Acciones', 90),
        ],
      ),
    );
  }

  Widget _memberRow((String, String, String, Color) m) {
    final initials = m.$1.split(' ').map((p) => p[0]).join();
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: _border)),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 190,
            child: Row(
              children: [
                Container(
                  width: 30,
                  height: 30,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: m.$4.withValues(alpha: 0.13),
                    shape: BoxShape.circle,
                    border: Border.all(color: m.$4.withValues(alpha: 0.19)),
                  ),
                  child: Text(
                    initials,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: m.$4,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    m.$1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 13, color: _text),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            width: 200,
            child: Text(
              m.$2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 13, color: _muted),
            ),
          ),
          SizedBox(
            width: 120,
            child: Align(
              alignment: Alignment.centerLeft,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 3,
                ),
                decoration: BoxDecoration(
                  color: m.$4.withValues(alpha: 0.09),
                  borderRadius: BorderRadius.circular(99),
                  border: Border.all(color: m.$4.withValues(alpha: 0.19)),
                ),
                child: Text(
                  m.$3,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: m.$4,
                  ),
                ),
              ),
            ),
          ),
          SizedBox(
            width: 90,
            child: m.$3 != 'Admin'
                ? Align(
                    alignment: Alignment.centerLeft,
                    child: _Btn(
                      label: 'Editar',
                      style: _BtnStyle.ghost,
                      small: true,
                      onTap: () =>
                          _toast('✏️', 'Editando rol de ${m.$1}', _accent2),
                    ),
                  )
                : const Text(
                    '—',
                    style: TextStyle(fontSize: 12, color: _muted),
                  ),
          ),
        ],
      ),
    );
  }

  // PELIGRO
  Widget _peligro() {
    const items = [
      (
        'Eliminar todos los reportes',
        'Borra permanentemente todos los reportes generados',
        'Eliminar',
      ),
      (
        'Restablecer configuración',
        'Vuelve a los valores predeterminados',
        '↺ Restablecer',
      ),
      (
        'Desactivar cuenta',
        'Pausa tu cuenta — tus datos se conservan',
        '⏸ Desactivar',
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _header(
          'Zona peligrosa',
          'Acciones irreversibles. Procede con extrema cautela.',
        ),
        _Card(
          title: 'Acciones irreversibles',
          titleColor: _danger,
          borderColor: _danger.withValues(alpha: 0.3),
          children: [
            for (var i = 0; i < items.length; i++)
              _FieldRow(
                name: items[i].$1,
                desc: items[i].$2,
                last: i == items.length - 1,
                trailing: _Btn(
                  label: items[i].$3,
                  style: _BtnStyle.danger,
                  onTap: () {
                    if (items[i].$1 == 'Restablecer configuración') {
                      setState(() {
                        _v = _defaults();
                        _dirty = true;
                      });
                    }
                    _toast(
                      '⚠️',
                      'Acción: ${items[i].$1}',
                      const Color(0xFFFF6B6B),
                    );
                  },
                ),
              ),
          ],
        ),
      ],
    );
  }
}

// ── Widgets auxiliares ──
class _Card extends StatelessWidget {
  final String? title;
  final Color titleColor;
  final Color borderColor;
  final List<Widget> children;

  const _Card({
    this.title,
    this.titleColor = _text,
    this.borderColor = _border,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _panel2,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null) ...[
            Text(
              title!,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
                color: titleColor,
              ),
            ),
            const SizedBox(height: 14),
          ],
          ...children,
        ],
      ),
    );
  }
}

class _FieldRow extends StatelessWidget {
  final String name;
  final String? desc;
  final Widget? trailing;
  final bool last;
  final bool small;

  const _FieldRow({
    required this.name,
    this.desc,
    this.trailing,
    this.last = false,
    this.small = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        border: last ? null : const Border(bottom: BorderSide(color: _border)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(
                    fontSize: small ? 12 : 13.5,
                    fontWeight: FontWeight.w500,
                    color: _text,
                  ),
                ),
                if (desc != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    desc!,
                    style: const TextStyle(fontSize: 12, color: _muted),
                  ),
                ],
              ],
            ),
          ),
          if (trailing != null) ...[const SizedBox(width: 12), trailing!],
        ],
      ),
    );
  }
}

class _Toggle extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;
  const _Toggle({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: 42,
        height: 24,
        padding: const EdgeInsets.all(3),
        alignment: value ? Alignment.centerRight : Alignment.centerLeft,
        decoration: BoxDecoration(
          color: value ? _accent : Colors.white.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(99),
        ),
        child: Container(
          width: 18,
          height: 18,
          decoration: const BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }
}

enum _BtnStyle { ghost, primary, danger, success }

class _Btn extends StatelessWidget {
  final String label;
  final _BtnStyle style;
  final VoidCallback onTap;
  final bool expand;
  final bool small;

  const _Btn({
    required this.label,
    required this.style,
    required this.onTap,
    this.expand = false,
    this.small = false,
  });

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color fg;
    Color bd;
    switch (style) {
      case _BtnStyle.primary:
        bg = _accent;
        fg = Colors.white;
        bd = _accent;
        break;
      case _BtnStyle.danger:
        bg = _danger.withValues(alpha: 0.1);
        fg = _danger;
        bd = _danger.withValues(alpha: 0.35);
        break;
      case _BtnStyle.success:
        bg = _accent5.withValues(alpha: 0.12);
        fg = _accent5;
        bd = _accent5.withValues(alpha: 0.35);
        break;
      case _BtnStyle.ghost:
        bg = Colors.transparent;
        fg = _muted;
        bd = _border;
        break;
    }

    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: onTap,
      child: Container(
        width: expand ? double.infinity : null,
        padding: EdgeInsets.symmetric(
          horizontal: small ? 10 : 18,
          vertical: small ? 5 : 10,
        ),
        alignment: expand ? Alignment.center : null,
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: bd),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: small ? 11 : 13,
            fontWeight: FontWeight.w600,
            color: fg,
          ),
        ),
      ),
    );
  }
}

class _NavTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;
  final bool compact;
  final VoidCallback onTap;

  const _NavTile({
    required this.icon,
    required this.label,
    required this.active,
    required this.onTap,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: compact ? 0 : 4),
      child: InkWell(
        borderRadius: BorderRadius.circular(9),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: active
                ? _accent.withValues(alpha: 0.15)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(9),
            border: Border.all(
              color: active
                  ? _accent.withValues(alpha: 0.4)
                  : Colors.transparent,
            ),
          ),
          child: Row(
            mainAxisSize: compact ? MainAxisSize.min : MainAxisSize.max,
            children: [
              Icon(icon, size: 16, color: active ? _accent : _muted),
              const SizedBox(width: 10),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                  color: active ? _text : _muted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ThemeCard extends StatelessWidget {
  final _ThemeOpt theme;
  final bool selected;
  final VoidCallback onTap;

  const _ThemeCard({
    required this.theme,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 120,
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: _panel,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? _accent : _border,
            width: selected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Stack(
              children: [
                Container(
                  height: 60,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [theme.colors[0], theme.colors[1]],
                    ),
                  ),
                ),
                Positioned(
                  left: 8,
                  right: 8,
                  bottom: 6,
                  child: Container(
                    height: 4,
                    decoration: BoxDecoration(
                      color: theme.colors[2].withValues(alpha: 0.7),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
                if (selected)
                  Positioned(
                    top: 4,
                    right: 4,
                    child: Container(
                      width: 18,
                      height: 18,
                      decoration: const BoxDecoration(
                        color: _accent,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check,
                        size: 12,
                        color: Colors.white,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              theme.name,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: _text,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
