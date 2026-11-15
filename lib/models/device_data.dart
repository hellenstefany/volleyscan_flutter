enum DeviceKind { phone, laptop, tablet }

/// Modelo tipado para `GET /api/usuario/dispositivos/` (`SeccionDispositivos.jsx` en Next).
class ConnectedDevice {
  const ConnectedDevice({
    required this.id,
    required this.nombre,
    this.tipo = 'escritorio',
    this.ip,
    this.ultimoAcceso,
    this.actual = false,
  });

  final int id;
  final String nombre;
  final String tipo; // 'movil' | 'tablet' | 'escritorio'
  final String? ip;
  final DateTime? ultimoAcceso;
  final bool actual;

  /// Getters de compatibilidad para los widgets de UI.
  String get name => nombre;
  bool get isCurrent => actual;
  String get lastAccess => subtitle;

  DeviceKind get kind {
    switch (tipo.toLowerCase()) {
      case 'movil':
        return DeviceKind.phone;
      case 'tablet':
        return DeviceKind.tablet;
      default:
        return DeviceKind.laptop;
    }
  }

  /// Replica `"Último acceso: ${hace(d.ultimo_acceso)}${d.ip ? ' · IP ' + d.ip : ''}"` de Next.
  String get subtitle {
    final rel = formatRelativeAccess(ultimoAcceso);
    final cleanIp = (ip ?? '').trim();
    if (cleanIp.isNotEmpty) {
      return 'Último acceso: $rel · IP $cleanIp';
    }
    return 'Último acceso: $rel';
  }

  factory ConnectedDevice.fromJson(Map<String, dynamic> json) {
    final rawId = json['id'];
    final id = rawId is int ? rawId : int.tryParse('$rawId') ?? 0;
    final nombre = (json['nombre'] ?? 'Dispositivo').toString().trim();
    final tipo = (json['tipo'] ?? 'escritorio').toString().trim().toLowerCase();
    final ip = json['ip']?.toString().trim();
    final rawFecha = json['ultimo_acceso']?.toString();
    final ultimoAcceso = rawFecha != null && rawFecha.isNotEmpty
        ? DateTime.tryParse(rawFecha)?.toLocal()
        : null;
    final actual = json['actual'] == true;

    return ConnectedDevice(
      id: id,
      nombre: nombre.isEmpty ? 'Dispositivo' : nombre,
      tipo: tipo,
      ip: (ip == null || ip.isEmpty) ? null : ip,
      ultimoAcceso: ultimoAcceso,
      actual: actual,
    );
  }

  /// Replica la función `hace(iso)` de `SeccionDispositivos.jsx`.
  static String formatRelativeAccess(DateTime? fecha) {
    if (fecha == null) return 'Sin registro';
    final diff = DateTime.now().difference(fecha);
    final min = diff.inMinutes;
    if (min < 1) return 'Hace un momento';
    if (min < 60) return 'Hace $min min';
    final hrs = min ~/ 60;
    if (hrs < 24) return 'Hace $hrs h';
    final dias = hrs ~/ 24;
    if (dias < 7) return 'Hace $dias d';

    const meses = [
      'ene',
      'feb',
      'mar',
      'abr',
      'may',
      'jun',
      'jul',
      'ago',
      'sep',
      'oct',
      'nov',
      'dic',
    ];
    final diaStr = fecha.day.toString().padLeft(2, '0');
    final mesStr = meses[(fecha.month - 1).clamp(0, 11)];
    return '$diaStr $mesStr';
  }
}
