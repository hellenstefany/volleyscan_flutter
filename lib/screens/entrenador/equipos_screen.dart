import 'package:flutter/material.dart';
import 'package:volleyscan_mobile/models/equipo.dart';
import 'package:volleyscan_mobile/services/equipos_service.dart';

const _bg = Color(0xFF070B14);
const _panel = Color(0xFF0E1423);
const _line = Color(0x14FFFFFF);
const _text = Colors.white;
const _muted = Color(0xFF94A3B8);
const _blue = Color(0xFF4F8CFF);
const _violet = Color(0xFF6C63FF);

enum _Estado { cargando, error, listo }

class EquiposScreen extends StatefulWidget {
  const EquiposScreen({super.key});

  @override
  State<EquiposScreen> createState() => _EquiposScreenState();
}

class _EquiposScreenState extends State<EquiposScreen> {
  final _service = EquiposService();

  _Estado _estado = _Estado.cargando;
  String _error = '';
  String _aviso = '';
  List<Equipo> _equipos = [];
  List<Invitacion> _recibidas = [];
  bool _abierto = false;
  bool _ocupado = false;

  final _nombre = TextEditingController();
  final _categoria = TextEditingController();
  final _temporada = TextEditingController(text: '${DateTime.now().year}');

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  @override
  void dispose() {
    _nombre.dispose();
    _categoria.dispose();
    _temporada.dispose();
    super.dispose();
  }

  Future<void> _cargar() async {
    final res = await Future.wait([
      _service.listarEquipos(),
      _service.misInvitaciones(),
    ]);
    if (!mounted) return;

    final a = res[0] as ApiResult<List<Equipo>>;
    final b = res[1] as ApiResult<List<Invitacion>>;

    if (!a.ok) {
      setState(() {
        _error = a.error;
        _estado = _Estado.error;
      });
      return;
    }
    setState(() {
      _equipos = a.data ?? [];
      _recibidas = b.ok ? (b.data ?? []) : [];
      _error = '';
      _estado = _Estado.listo;
    });
  }

  Future<void> _crear() async {
    if (_ocupado || _nombre.text.trim().length < 2) return;
    setState(() {
      _ocupado = true;
      _error = '';
      _aviso = '';
    });
    final r = await _service.crearEquipo(
      nombre: _nombre.text,
      categoria: _categoria.text,
      temporada: _temporada.text,
    );
    if (!mounted) return;
    setState(() => _ocupado = false);

    if (!r.ok) {
      setState(() => _error = r.error);
      return;
    }
    _nombre.clear();
    _categoria.clear();
    setState(() {
      _abierto = false;
      _aviso = 'Equipo creado.';
    });
    _cargar();
  }

  Future<void> _responder(Invitacion inv, String accion) async {
    if (_ocupado) return;
    setState(() {
      _ocupado = true;
      _error = '';
      _aviso = '';
    });
    final r = await _service.responderInvitacion(inv.id, accion);
    if (!mounted) return;
    setState(() => _ocupado = false);

    if (!r.ok) {
      setState(() => _error = r.error);
      return _cargar();
    }
    setState(() {
      _aviso = accion == 'aceptar'
          ? 'Ahora eres entrenador de «${inv.equipoNombre}».'
          : 'Invitación rechazada.';
    });
    _cargar();
  }

  @override
  Widget build(BuildContext context) {
    // El botón de menú flotante del shell ocupa la esquina superior izquierda
    final top = MediaQuery.paddingOf(context).top + 64;

    return Container(
      color: _bg,
      child: RefreshIndicator(
        onRefresh: _cargar,
        child: ListView(
          padding: EdgeInsets.fromLTRB(20, top, 20, 32),
          children: [
            _encabezado(),
            const SizedBox(height: 16),
            if (_error.isNotEmpty) _alerta(_error, mal: true),
            if (_aviso.isNotEmpty) _alerta(_aviso, mal: false),
            if (_abierto) _formulario(),
            for (final inv in _recibidas) _tarjetaInvitacion(inv),
            if (_estado == _Estado.cargando)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 32),
                child: Center(
                  child: Text(
                    'Cargando equipos…',
                    style: TextStyle(color: _muted),
                  ),
                ),
              ),
            if (_estado == _Estado.listo && _equipos.isEmpty) _vacio(),
            if (_equipos.isNotEmpty) _grid(),
          ],
        ),
      ),
    );
  }

  // ── Encabezado ──────────────────────────────────────────────
  Widget _encabezado() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'MI CLUB',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w800,
            letterSpacing: 2,
            color: Color(0xFF60A5FA),
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'Equipos',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w800,
            color: _text,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Crea tus equipos, invita a deportistas y a otros entrenadores por correo, y lleva el registro de tus aprendices.',
          style: TextStyle(fontSize: 15, height: 1.4, color: _muted),
        ),
        const SizedBox(height: 18),
        _BotonPrimario(
          label: _abierto ? 'Cancelar' : '+ Nuevo equipo',
          onTap: () => setState(() => _abierto = !_abierto),
        ),
      ],
    );
  }

  // ── Alertas ─────────────────────────────────────────────────
  Widget _alerta(String msg, {required bool mal}) {
    final color = mal ? const Color(0xFFEF4444) : const Color(0xFF22C55E);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(msg, style: TextStyle(color: color, fontSize: 13.5)),
    );
  }

  // ── Formulario nuevo equipo ─────────────────────────────────
  Widget _formulario() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _panel,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _campo(
            'Nombre del equipo',
            _nombre,
            hint: 'Ej. Sub-17 Femenino',
            max: 100,
            autofocus: true,
          ),
          _campo('Categoría', _categoria, hint: 'Juvenil', max: 50),
          _campo('Temporada', _temporada, hint: '2026', max: 20),
          const SizedBox(height: 4),
          ListenableBuilder(
            listenable: _nombre,
            builder: (_, __) => _BotonPrimario(
              label: _ocupado ? 'Creando…' : 'Crear equipo',
              enabled: !_ocupado && _nombre.text.trim().length >= 2,
              onTap: _crear,
            ),
          ),
        ],
      ),
    );
  }

  Widget _campo(
    String label,
    TextEditingController c, {
    String? hint,
    int? max,
    bool autofocus = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: _muted,
            ),
          ),
          const SizedBox(height: 6),
          TextField(
            controller: c,
            maxLength: max,
            autofocus: autofocus,
            style: const TextStyle(color: _text),
            decoration: InputDecoration(
              counterText: '',
              hintText: hint,
              hintStyle: const TextStyle(color: Color(0xFF4A5568)),
              filled: true,
              fillColor: const Color(0xFF0A0F1C),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 14,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: _line),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: _blue),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Invitaciones recibidas ──────────────────────────────────
  Widget _tarjetaInvitacion(Invitacion inv) {
    final sub = [
      inv.equipoCategoria,
      inv.equipoTemporada,
    ].whereType<String>().join(' · ');
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _blue.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _blue.withValues(alpha: 0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${inv.invitadoPor} te invita a ser entrenador de «${inv.equipoNombre}»',
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              color: _text,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            sub.isEmpty ? 'Equipo' : sub,
            style: const TextStyle(color: _muted, fontSize: 13),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _BotonPrimario(
                label: 'Aceptar',
                mini: true,
                enabled: !_ocupado,
                onTap: () => _responder(inv, 'aceptar'),
              ),
              const SizedBox(width: 10),
              _BotonSecundario(
                label: 'Rechazar',
                enabled: !_ocupado,
                onTap: () => _responder(inv, 'rechazar'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Estado vacío ────────────────────────────────────────────
  Widget _vacio() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 44, horizontal: 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: _line),
      ),
      child: const Column(
        children: [
          Text(
            'Aún no tienes equipos',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: _text,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Crea el primero y empieza a invitar a tus deportistas.',
            textAlign: TextAlign.center,
            style: TextStyle(color: _muted, fontSize: 14.5),
          ),
        ],
      ),
    );
  }

  // ── Tarjetas de equipos ─────────────────────────────────────
  Widget _grid() {
    return LayoutBuilder(
      builder: (context, c) {
        final cols = c.maxWidth >= 1000 ? 3 : (c.maxWidth >= 640 ? 2 : 1);
        const gap = 14.0;
        final w = (c.maxWidth - gap * (cols - 1)) / cols;
        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: [
            for (final e in _equipos)
              SizedBox(width: w, child: _tarjetaEquipo(e)),
          ],
        );
      },
    );
  }

  Widget _tarjetaEquipo(Equipo e) {
    return Material(
      color: _panel,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () => ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Detalle de «${e.nombre}»: próximamente')),
        ),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: _line),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                e.nombre,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: _text,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  e.esPropietario
                      ? const _Chip('Propietario', _ChipTono.azul)
                      : const _Chip('Co-entrenador', _ChipTono.verde),
                  if (e.categoria != null) _Chip(e.categoria!, _ChipTono.gris),
                  if (e.temporada != null) _Chip(e.temporada!, _ChipTono.gris),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  _cifra(e.deportistas, 'Deportistas'),
                  _cifra(e.entrenadores, 'Entrenadores'),
                  _cifra(e.invitacionesPendientes, 'Invitaciones'),
                ],
              ),
              const SizedBox(height: 14),
              const Text(
                'Abrir equipo →',
                style: TextStyle(
                  color: Color(0xFF60A5FA),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _cifra(int n, String label) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$n',
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: _text,
            ),
          ),
          Text(label, style: const TextStyle(fontSize: 11.5, color: _muted)),
        ],
      ),
    );
  }
}

// ── Widgets pequeños ──────────────────────────────────────────
enum _ChipTono { azul, verde, gris }

class _Chip extends StatelessWidget {
  final String texto;
  final _ChipTono tono;
  const _Chip(this.texto, this.tono);

  @override
  Widget build(BuildContext context) {
    final (bg, fg) = switch (tono) {
      _ChipTono.azul => (const Color(0x333B82F6), const Color(0xFF60A5FA)),
      _ChipTono.verde => (const Color(0x3322C55E), const Color(0xFF4ADE80)),
      _ChipTono.gris => (const Color(0x14FFFFFF), const Color(0xFF9CA3AF)),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(99),
      ),
      child: Text(
        texto,
        style: TextStyle(
          fontSize: 11.5,
          fontWeight: FontWeight.w700,
          color: fg,
        ),
      ),
    );
  }
}

class _BotonPrimario extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final bool enabled;
  final bool mini;
  const _BotonPrimario({
    required this.label,
    required this.onTap,
    this.enabled = true,
    this.mini = false,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: enabled ? 1 : 0.5,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(mini ? 10 : 16),
          gradient: const LinearGradient(colors: [_blue, _violet]),
          boxShadow: [
            BoxShadow(
              color: _violet.withValues(alpha: 0.35),
              blurRadius: 18,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(mini ? 10 : 16),
            onTap: enabled ? onTap : null,
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: mini ? 16 : 22,
                vertical: mini ? 10 : 16,
              ),
              child: Text(
                label,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: mini ? 13.5 : 16,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _BotonSecundario extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final bool enabled;
  const _BotonSecundario({
    required this.label,
    required this.onTap,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: enabled ? 1 : 0.5,
      child: OutlinedButton(
        onPressed: enabled ? onTap : null,
        style: OutlinedButton.styleFrom(
          foregroundColor: _text,
          side: const BorderSide(color: Color(0x33FFFFFF)),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: Text(label, style: const TextStyle(fontSize: 13.5)),
      ),
    );
  }
}
