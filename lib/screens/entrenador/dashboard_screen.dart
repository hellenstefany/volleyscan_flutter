import 'package:flutter/material.dart';

// ── Colores (variables CSS) ──

const _bgSecondary = Color(0xFF0F1425);

const _bgCard = Color(0xFF131829);

const _blue = Color(0xFF4F6EF7);

const _purple = Color(0xFF7C3AED);

const _teal = Color(0xFF0FB8A0);

const _gold = Color(0xFFF59E0B);

const _green = Color(0xFF22C55E);

const _textPrimary = Color(0xFFE8EAF6);

const _textSecondary = Color(0xFF8892B0);

const _textMuted = Color(0xFF4A5568);

const _border = Color(0x12FFFFFF);

// ── Modelos / datos ──

class _PlayerData {
  final String name;

  final int pct;

  final Color color;

  final String initials;

  final Color bg;

  const _PlayerData(this.name, this.pct, this.color, this.initials, this.bg);
}

class _Activity {
  final String name;

  final String action;

  final String time;

  final String initials;

  final Color bg;

  final bool icon;

  const _Activity(
    this.name,

    this.action,

    this.time,

    this.initials,

    this.bg, {

    this.icon = false,
  });
}

const _players = [
  _PlayerData('Juan Pérez', 85, _blue, 'JP', Color(0xFF1E3A8A)),

  _PlayerData('María González', 78, Color(0xFFEF4444), 'MG', Color(0xFF7F1D1D)),

  _PlayerData('Carlos Ramírez', 72, _blue, 'CR', Color(0xFF1E40AF)),

  _PlayerData('Sofía Ortega', 68, _green, 'SO', Color(0xFF14532D)),

  _PlayerData('Andrés López', 65, _green, 'AL', Color(0xFF166534)),
];

const _initialActivities = [
  _Activity(
    'Juan Pérez',

    'Completó entrenamiento',

    'Hoy, 10:30 AM',

    'JP',

    Color(0xFF1E3A8A),
  ),

  _Activity(
    'María González',

    'Error técnico detectado',

    'Hoy, 09:15 AM',

    'MG',

    Color(0xFF7F1D1D),
  ),

  _Activity(
    'Carlos Ramírez',

    'Mejora en saque',

    'Ayer, 07:45 PM',

    'CR',

    Color(0xFF1E40AF),
  ),

  _Activity(
    'Nueva sesión',

    'Entrenamiento de defensa',

    'Ayer, 06:30 PM',

    '📹',

    Color(0xFF312E81),

    icon: true,
  ),
];

const _chartLabels = ['14 Abr', '21 Abr', '28 Abr', '5 May', '12 May'];

const _chartValues = [48.0, 55.0, 62.0, 68.0, 78.0];

const _dateOptions = [
  '12 - 18 Mayo, 2025',

  '5 - 11 Mayo, 2025',

  '28 Abr - 4 Mayo, 2025',

  'Abril 2025',

  'Mayo 2025',
];

const _sessionTypes = [
  'Entrenamiento general',

  'Entrenamiento de defensa',

  'Entrenamiento de ataque',

  'Entrenamiento de saque',

  'Partido amistoso',

  'Análisis táctico',
];

// ── Pantalla ──

// Nota: se llama DashboardScreen para coincidir con el shell

// (que la importa con \`as entrenador\`).

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  List<_Activity> _activities = List.of(_initialActivities);

  int _sessionCount = 15;

  String _dateLabel = 'Fechas';

  String? _chartTip;

  void _toast(String msg) {
    final messenger = ScaffoldMessenger.of(context);

    messenger.hideCurrentSnackBar();

    messenger.showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,

        duration: const Duration(milliseconds: 2800),

        backgroundColor: _bgCard,

        margin: const EdgeInsets.all(20),

        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),

          side: const BorderSide(color: _green),
        ),

        content: Row(
          children: [
            const Text('✓', style: TextStyle(color: _green, fontSize: 16)),

            const SizedBox(width: 10),

            Expanded(
              child: Text(
                msg,

                style: const TextStyle(
                  color: _textPrimary,

                  fontSize: 13,

                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _nowLabel() {
    final now = DateTime.now();

    final h12 = now.hour % 12 == 0 ? 12 : now.hour % 12;

    final mm = now.minute.toString().padLeft(2, '0');

    final ampm = now.hour >= 12 ? 'PM' : 'AM';

    return 'Hoy, ${h12.toString().padLeft(2, '0')}:$mm $ampm';
  }

  Future<void> _openNewSession() async {
    final type = await showDialog<String>(
      context: context,

      barrierColor: Colors.black.withOpacity(0.7),

      builder: (_) => const _SessionDialog(),
    );

    if (type == null) return;

    setState(() {
      _activities = [
        _Activity(
          'Nueva sesión',

          type,

          _nowLabel(),

          '📹',

          const Color(0xFF312E81),

          icon: true,
        ),

        ..._activities.take(3),
      ];

      _sessionCount++;
    });

    _toast('Sesión "$type" creada exitosamente');
  }

  @override
  Widget build(BuildContext context) {
    final screenW = MediaQuery.of(context).size.width;

    final narrow = screenW < 760;

    return Material(
      color: _bgSecondary,

      child: Column(
        children: [
          _buildTopbar(narrow),

          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(narrow ? 16 : 28),

              child: LayoutBuilder(
                builder: (context, c) {
                  final w = c.maxWidth;

                  final threeCols = w >= 1000;

                  final chartPanel = _Panel(
                    title: 'Rendimiento por semana',

                    child: _buildChart(narrow),
                  );

                  final playersPanel = _Panel(
                    title: 'Comparativa de jugadores',

                    child: _buildPlayers(),
                  );

                  final activityPanel = _Panel(
                    title: 'Actividad reciente',

                    child: _buildActivities(),
                  );

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,

                    children: [
                      _buildKpis(w, narrow),

                      SizedBox(height: narrow ? 16 : 22),

                      if (threeCols)
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,

                          children: [
                            Expanded(child: chartPanel),

                            const SizedBox(width: 16),

                            Expanded(child: playersPanel),

                            const SizedBox(width: 16),

                            Expanded(child: activityPanel),
                          ],
                        )
                      else ...[
                        chartPanel,

                        const SizedBox(height: 14),

                        playersPanel,

                        const SizedBox(height: 14),

                        activityPanel,
                      ],
                    ],
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Topbar ──

  Widget _buildTopbar(bool narrow) {
    final title = Column(
      crossAxisAlignment: CrossAxisAlignment.start,

      mainAxisSize: MainAxisSize.min,

      children: const [
        Text(
          'Dashboard',

          style: TextStyle(
            fontSize: 24,

            fontWeight: FontWeight.w700,

            color: _textPrimary,
          ),
        ),

        SizedBox(height: 2),

        Text(
          'Resumen general de tu equipo',

          style: TextStyle(fontSize: 13, color: _textSecondary),
        ),
      ],
    );

    final actions = Wrap(
      spacing: 12,

      runSpacing: 10,

      crossAxisAlignment: WrapCrossAlignment.center,

      children: [_buildDatePicker(), _buildNewSessionButton()],
    );

    return Container(
      width: double.infinity,

      // En móvil dejamos espacio para el botón flotante del menú
      padding: EdgeInsets.fromLTRB(narrow ? 76 : 28, 20, narrow ? 16 : 28, 20),

      decoration: const BoxDecoration(
        color: _bgSecondary,

        border: Border(bottom: BorderSide(color: _border)),
      ),

      child: narrow
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [title, const SizedBox(height: 14), actions],
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

  Widget _buildDatePicker() {
    return PopupMenuButton<String>(
      color: _bgCard,

      offset: const Offset(0, 46),

      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),

        side: const BorderSide(color: _border),
      ),

      onSelected: (d) {
        setState(() => _dateLabel = d);

        _toast('Período: $d');
      },

      itemBuilder: (_) => _dateOptions
          .map(
            (d) => PopupMenuItem(
              value: d,

              child: Text(
                d,

                style: TextStyle(
                  fontSize: 13,

                  color: d == _dateLabel ? _blue : _textSecondary,
                ),
              ),
            ),
          )
          .toList(),

      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),

        decoration: BoxDecoration(
          color: _bgCard,

          borderRadius: BorderRadius.circular(10),

          border: Border.all(color: _border),
        ),

        child: Row(
          mainAxisSize: MainAxisSize.min,

          children: [
            Text(
              _dateLabel,

              style: const TextStyle(fontSize: 13, color: _textPrimary),
            ),

            const SizedBox(width: 8),

            const Icon(
              Icons.keyboard_arrow_down,

              size: 16,

              color: _textSecondary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNewSessionButton() {
    return GestureDetector(
      onTap: _openNewSession,

      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 11),

        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [_purple, Color(0xFF5B21B6)],

            begin: Alignment.topLeft,

            end: Alignment.bottomRight,
          ),

          borderRadius: BorderRadius.circular(10),

          boxShadow: [
            BoxShadow(
              color: _purple.withOpacity(0.35),

              blurRadius: 15,

              offset: const Offset(0, 4),
            ),
          ],
        ),

        child: const Row(
          mainAxisSize: MainAxisSize.min,

          children: [
            Icon(Icons.add, size: 16, color: Colors.white),

            SizedBox(width: 6),

            Text(
              'Nueva sesión',

              style: TextStyle(
                fontSize: 13,

                fontWeight: FontWeight.w600,

                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── KPIs ──

  Widget _buildKpis(double w, bool narrow) {
    final kpis = [
      _Kpi(
        Color(0xFF4F6EF7),

        '👥',

        'Total Deportistas',

        24,

        '',

        sub: 'Activos',
      ),

      _Kpi(
        _teal,

        '✅',

        'Sesiones esta semana',

        _sessionCount,

        '',

        sub: 'Completadas',
      ),

      _Kpi(
        _green,

        '⏱',

        'Asistencia promedio',

        87,

        '%',

        delta: '▲ +5% vs semana pasada',
      ),

      _Kpi(
        _gold,

        '📈',

        'Rendimiento promedio',

        78,

        '%',

        delta: '▲ +8% vs semana pasada',
      ),
    ];

    // Decide the grid from the available content width, not the whole device width.
    final cols = w < 600 ? 2 : (w < 1000 ? 3 : 4);
    final gap = w < 600 ? 12.0 : 16.0;
    final itemW = ((w - gap * (cols - 1)) / cols).clamp(0.0, w).toDouble();
    final compactCards = itemW < 220;

    return Wrap(
      spacing: gap,

      runSpacing: gap,

      children: kpis
          .map(
            (k) => SizedBox(
              width: itemW,

              child: _KpiCard(kpi: k, narrow: compactCards),
            ),
          )
          .toList(),
    );
  }

  // ── Gráfica ──

  Widget _buildChart(bool narrow) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,

      children: [
        LayoutBuilder(
          builder: (context, c) {
            final painter = _PerformancePainter(_chartLabels, _chartValues);

            final size = Size(c.maxWidth, narrow ? 220 : 200);

            return GestureDetector(
              onTapDown: (d) {
                setState(
                  () => _chartTip = painter.findPoint(d.localPosition, size),
                );
              },

              child: CustomPaint(size: size, painter: painter),
            );
          },
        ),

        if (_chartTip != null)
          Padding(
            padding: const EdgeInsets.only(top: 8),

            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),

              decoration: BoxDecoration(
                color: const Color(0xFF1E2235),

                borderRadius: BorderRadius.circular(8),

                border: Border.all(color: _border),
              ),

              child: Text(
                _chartTip!,

                style: const TextStyle(fontSize: 12, color: _textPrimary),
              ),
            ),
          ),
      ],
    );
  }

  // ── Comparativa de jugadores ──

  Widget _buildPlayers() {
    return Column(
      children: [
        for (var i = 0; i < _players.length; i++)
          _PlayerRow(
            rank: i + 1,

            player: _players[i],

            onTap: () => _toast('Ver estadísticas de ${_players[i].name}'),
          ),
      ],
    );
  }

  // ── Actividad reciente ──

  Widget _buildActivities() {
    return Column(
      children: _activities.map((a) => _ActivityRow(activity: a)).toList(),
    );
  }
}

// ── Widgets auxiliares ──

class _Kpi {
  final Color color;

  final String icon;

  final String label;

  final int value;

  final String suffix;

  final String? sub;

  final String? delta;

  _Kpi(
    this.color,

    this.icon,

    this.label,

    this.value,

    this.suffix, {

    this.sub,

    this.delta,
  });
}

class _KpiCard extends StatelessWidget {
  final _Kpi kpi;
  final bool narrow;

  const _KpiCard({required this.kpi, required this.narrow});

  @override
  Widget build(BuildContext context) {
    final iconSize = narrow ? 34.0 : 44.0;

    final icon = Container(
      width: iconSize,
      height: iconSize,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: kpi.color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(kpi.icon, style: TextStyle(fontSize: narrow ? 17 : 20)),
    );

    final details = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          kpi.label,
          maxLines: narrow ? 2 : 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: _textSecondary,
          ),
        ),
        const SizedBox(height: 6),
        TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: kpi.value.toDouble()),
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeOut,
          builder: (_, value, __) => Text(
            '${value.floor()}${kpi.suffix}',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: narrow ? 25 : 28,
              fontWeight: FontWeight.w700,
              height: 1.05,
              color: _textPrimary,
            ),
          ),
        ),
        if (kpi.sub != null) ...[
          const SizedBox(height: 4),
          Text(
            kpi.sub!,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 11, color: _textMuted),
          ),
        ],
        if (kpi.delta != null) ...[
          const SizedBox(height: 5),
          Text(
            kpi.delta!,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: _green,
            ),
          ),
        ],
      ],
    );

    return Container(
      constraints: BoxConstraints(minHeight: narrow ? 150 : 120),
      padding: EdgeInsets.all(narrow ? 12 : 18),
      decoration: BoxDecoration(
        color: _bgCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _border),
      ),
      child: narrow
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [icon, const SizedBox(height: 10), details],
            )
          : Row(
              children: [
                icon,
                const SizedBox(width: 14),
                Expanded(child: details),
              ],
            ),
    );
  }
}

class _Panel extends StatelessWidget {
  final String title;

  final Widget child;

  const _Panel({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),

      decoration: BoxDecoration(
        color: _bgCard,

        borderRadius: BorderRadius.circular(14),

        border: Border.all(color: _border),
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          Text(
            title,

            style: const TextStyle(
              fontSize: 15,

              fontWeight: FontWeight.w700,

              color: _textPrimary,
            ),
          ),

          const SizedBox(height: 16),

          child,
        ],
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  final String text;

  final Color bg;

  final double size;

  final double fontSize;

  const _Avatar({
    required this.text,

    required this.bg,

    required this.size,

    required this.fontSize,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,

      height: size,

      alignment: Alignment.center,

      decoration: BoxDecoration(color: bg, shape: BoxShape.circle),

      child: Text(
        text,

        style: TextStyle(
          fontSize: fontSize,

          fontWeight: FontWeight.w700,

          color: Colors.white,
        ),
      ),
    );
  }
}

class _PlayerRow extends StatelessWidget {
  final int rank;

  final _PlayerData player;

  final VoidCallback onTap;

  const _PlayerRow({
    required this.rank,

    required this.player,

    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),

      child: InkWell(
        borderRadius: BorderRadius.circular(10),

        hoverColor: Colors.white.withOpacity(0.04),

        onTap: onTap,

        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),

          child: Row(
            children: [
              SizedBox(
                width: 16,

                child: Text(
                  '$rank',

                  textAlign: TextAlign.center,

                  style: const TextStyle(
                    fontSize: 12,

                    fontWeight: FontWeight.w600,

                    color: _textMuted,
                  ),
                ),
              ),

              const SizedBox(width: 10),

              _Avatar(
                text: player.initials,

                bg: player.bg,

                size: 32,

                fontSize: 13,
              ),

              const SizedBox(width: 10),

              Expanded(
                child: Text(
                  player.name,

                  overflow: TextOverflow.ellipsis,

                  style: const TextStyle(
                    fontSize: 13,

                    fontWeight: FontWeight.w500,

                    color: _textPrimary,
                  ),
                ),
              ),

              const SizedBox(width: 10),

              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),

                  child: Container(
                    height: 5,

                    color: Colors.white.withOpacity(0.08),

                    alignment: Alignment.centerLeft,

                    child: TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0, end: player.pct / 100),

                      duration: const Duration(seconds: 1),

                      curve: Curves.easeOut,

                      builder: (_, v, __) => FractionallySizedBox(
                        widthFactor: v,

                        child: Container(color: player.color),
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 10),

              SizedBox(
                width: 38,

                child: Text(
                  '${player.pct}%',

                  textAlign: TextAlign.right,

                  style: TextStyle(
                    fontSize: 12,

                    fontWeight: FontWeight.w700,

                    color: player.color,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActivityRow extends StatelessWidget {
  final _Activity activity;

  const _ActivityRow({required this.activity});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),

      child: InkWell(
        borderRadius: BorderRadius.circular(10),

        hoverColor: Colors.white.withOpacity(0.04),

        onTap: () {},

        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),

          child: Row(
            children: [
              _Avatar(
                text: activity.initials,

                bg: activity.bg,

                size: 36,

                fontSize: activity.icon ? 18 : 13,
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [
                    Text(
                      activity.name,

                      overflow: TextOverflow.ellipsis,

                      style: const TextStyle(
                        fontSize: 13,

                        fontWeight: FontWeight.w600,

                        color: _textPrimary,
                      ),
                    ),

                    const SizedBox(height: 1),

                    Text(
                      activity.action,

                      overflow: TextOverflow.ellipsis,

                      style: const TextStyle(
                        fontSize: 11,

                        color: _textSecondary,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 8),

              Text(
                activity.time,

                style: const TextStyle(fontSize: 11, color: _textMuted),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Diálogo "Nueva sesión" ──

class _SessionDialog extends StatefulWidget {
  const _SessionDialog();

  @override
  State<_SessionDialog> createState() => _SessionDialogState();
}

class _SessionDialogState extends State<_SessionDialog> {
  String _type = _sessionTypes.first;

  DateTime _date = DateTime.now();

  TimeOfDay _time = const TimeOfDay(hour: 10, minute: 0);

  final _durationCtrl = TextEditingController(text: '90');

  final _notesCtrl = TextEditingController();

  @override
  void dispose() {
    _durationCtrl.dispose();

    _notesCtrl.dispose();

    super.dispose();
  }

  String get _dateText =>
      '${_date.day.toString().padLeft(2, '0')}/${_date.month.toString().padLeft(2, '0')}/${_date.year}';

  Future<void> _pickDate() async {
    final d = await showDatePicker(
      context: context,

      initialDate: _date,

      firstDate: DateTime(2020),

      lastDate: DateTime(2100),
    );

    if (d != null) setState(() => _date = d);
  }

  Future<void> _pickTime() async {
    final t = await showTimePicker(context: context, initialTime: _time);

    if (t != null) setState(() => _time = t);
  }

  InputDecoration get _inputDeco => InputDecoration(
    isDense: true,

    filled: true,

    fillColor: _bgSecondary,

    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),

    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),

      borderSide: const BorderSide(color: _border),
    ),

    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),

      borderSide: const BorderSide(color: _blue),
    ),
  );

  Widget _label(String t) => Padding(
    padding: const EdgeInsets.only(bottom: 6),

    child: Text(
      t.toUpperCase(),

      style: const TextStyle(
        fontSize: 12,

        fontWeight: FontWeight.w600,

        letterSpacing: 0.6,

        color: _textSecondary,
      ),
    ),
  );

  Widget _tapField(String text, VoidCallback onTap) => InkWell(
    borderRadius: BorderRadius.circular(10),

    onTap: onTap,

    child: Container(
      width: double.infinity,

      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),

      decoration: BoxDecoration(
        color: _bgSecondary,

        borderRadius: BorderRadius.circular(10),

        border: Border.all(color: _border),
      ),

      child: Text(
        text,

        style: const TextStyle(fontSize: 14, color: _textPrimary),
      ),
    ),
  );

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: _bgCard,

      insetPadding: const EdgeInsets.all(16),

      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),

        side: const BorderSide(color: _border),
      ),

      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),

        child: SingleChildScrollView(
          padding: const EdgeInsets.all(28),

          child: Column(
            mainAxisSize: MainAxisSize.min,

            crossAxisAlignment: CrossAxisAlignment.stretch,

            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,

                children: [
                  const Text(
                    'Nueva Sesión',

                    style: TextStyle(
                      fontSize: 18,

                      fontWeight: FontWeight.w700,

                      color: _textPrimary,
                    ),
                  ),

                  InkWell(
                    borderRadius: BorderRadius.circular(8),

                    onTap: () => Navigator.pop(context),

                    child: Container(
                      width: 30,

                      height: 30,

                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),

                        border: Border.all(color: _border),
                      ),

                      child: const Icon(
                        Icons.close,

                        size: 16,

                        color: _textSecondary,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 22),

              _label('Tipo de sesión'),

              DropdownButtonFormField<String>(
                initialValue: _type,

                isExpanded: true,

                dropdownColor: _bgCard,

                style: const TextStyle(fontSize: 14, color: _textPrimary),

                decoration: _inputDeco,

                items: _sessionTypes
                    .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                    .toList(),

                onChanged: (v) {
                  if (v != null) setState(() => _type = v);
                },
              ),

              const SizedBox(height: 16),

              Row(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,

                      children: [
                        _label('Fecha'),

                        _tapField(_dateText, _pickDate),
                      ],
                    ),
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,

                      children: [
                        _label('Hora'),

                        _tapField(_time.format(context), _pickTime),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              _label('Duración (minutos)'),

              TextField(
                controller: _durationCtrl,

                keyboardType: TextInputType.number,

                style: const TextStyle(fontSize: 14, color: _textPrimary),

                cursorColor: _blue,

                decoration: _inputDeco,
              ),

              const SizedBox(height: 16),

              _label('Notas'),

              TextField(
                controller: _notesCtrl,

                style: const TextStyle(fontSize: 14, color: _textPrimary),

                cursorColor: _blue,

                decoration: _inputDeco,
              ),

              const SizedBox(height: 22),

              Row(
                children: [
                  Expanded(
                    flex: 1,

                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),

                      style: OutlinedButton.styleFrom(
                        foregroundColor: _textSecondary,

                        side: const BorderSide(color: _border),

                        padding: const EdgeInsets.symmetric(vertical: 14),

                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),

                      child: const Text(
                        'Cancelar',

                        style: TextStyle(
                          fontSize: 14,

                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 10),

                  Expanded(
                    flex: 2,

                    child: GestureDetector(
                      onTap: () => Navigator.pop(context, _type),

                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 14),

                        alignment: Alignment.center,

                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [_blue, _purple],
                          ),

                          borderRadius: BorderRadius.circular(10),

                          boxShadow: [
                            BoxShadow(
                              color: _blue.withOpacity(0.3),

                              blurRadius: 15,

                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),

                        child: const Text(
                          'Crear sesión',

                          style: TextStyle(
                            fontSize: 14,

                            fontWeight: FontWeight.w600,

                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Painter: gráfica de rendimiento (línea suave con área) ──

class _PerformancePainter extends CustomPainter {
  final List<String> labels;

  final List<double> values;

  static const padL = 40.0, padR = 12.0, padT = 12.0, padB = 28.0;

  _PerformancePainter(this.labels, this.values);

  Offset _point(int i, Size s) {
    final cW = s.width - padL - padR;

    final cH = s.height - padT - padB;

    final x = padL + (i / (values.length - 1)) * cW;

    final y = padT + cH - (values[i] / 100) * cH; // eje Y fijo 0..100

    return Offset(x, y);
  }

  void _drawText(Canvas canvas, String t, Offset pos, TextAlign align) {
    final tp = TextPainter(
      text: TextSpan(
        text: t,

        style: const TextStyle(color: _textSecondary, fontSize: 11),
      ),

      textDirection: TextDirection.ltr,
    )..layout();

    double dx = pos.dx;

    if (align == TextAlign.right) dx -= tp.width;

    if (align == TextAlign.center) dx -= tp.width / 2;

    tp.paint(canvas, Offset(dx, pos.dy - tp.height / 2));
  }

  @override
  void paint(Canvas canvas, Size size) {
    final cH = size.height - padT - padB;

    // Rejilla + etiquetas Y (0, 25, 50, 75, 100)

    final grid = Paint()
      ..color = Colors.white.withOpacity(0.04)
      ..strokeWidth = 1;

    for (final v in [0, 25, 50, 75, 100]) {
      final y = padT + cH - (v / 100) * cH;

      canvas.drawLine(Offset(padL, y), Offset(size.width - padR, y), grid);

      _drawText(canvas, '$v%', Offset(padL - 8, y), TextAlign.right);
    }

    // Etiquetas X

    for (var i = 0; i < labels.length; i++) {
      _drawText(
        canvas,

        labels[i],

        Offset(_point(i, size).dx, size.height - 8),

        TextAlign.center,
      );
    }

    // Curva suave (Catmull-Rom → Bézier)

    final pts = [for (var i = 0; i < values.length; i++) _point(i, size)];

    final line = Path()..moveTo(pts.first.dx, pts.first.dy);

    for (var i = 0; i < pts.length - 1; i++) {
      final p0 = i > 0 ? pts[i - 1] : pts[i];

      final p1 = pts[i];

      final p2 = pts[i + 1];

      final p3 = i + 2 < pts.length ? pts[i + 2] : p2;

      const k = 0.45 / 3; // equivale a tension 0.45

      final c1 = Offset(
        p1.dx + (p2.dx - p0.dx) * k * 1.5,

        p1.dy + (p2.dy - p0.dy) * k * 1.5,
      );

      final c2 = Offset(
        p2.dx - (p3.dx - p1.dx) * k * 1.5,

        p2.dy - (p3.dy - p1.dy) * k * 1.5,
      );

      line.cubicTo(c1.dx, c1.dy, c2.dx, c2.dy, p2.dx, p2.dy);
    }

    // Área degradada

    final area = Path.from(line)
      ..lineTo(pts.last.dx, padT + cH)
      ..lineTo(pts.first.dx, padT + cH)
      ..close();

    canvas.drawPath(
      area,

      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,

          end: Alignment.bottomCenter,

          colors: [_blue.withOpacity(0.35), _blue.withOpacity(0.01)],
        ).createShader(Rect.fromLTWH(0, padT, size.width, cH)),
    );

    // Línea

    canvas.drawPath(
      line,

      Paint()
        ..color = _blue
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );

    // Puntos

    for (final p in pts) {
      canvas.drawCircle(p, 5, Paint()..color = _blue);

      canvas.drawCircle(
        p,

        5,

        Paint()
          ..color = _bgSecondary
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );
    }
  }

  /// Devuelve el texto del punto más cercano al toque (o null).

  String? findPoint(Offset pos, Size size) {
    double best = 22;

    String? result;

    for (var i = 0; i < values.length; i++) {
      final d = (_point(i, size) - pos).distance;

      if (d < best) {
        best = d;

        result = '${labels[i]}: ${values[i].round()}%';
      }
    }

    return result;
  }

  @override
  bool shouldRepaint(covariant _PerformancePainter old) => false;
}
