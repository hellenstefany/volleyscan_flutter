enum DeviceKind { phone, laptop, tablet }

class ConnectedDevice {
  final String id;
  final String name;
  final DeviceKind kind;
  final String lastAccess; // "Hoy, 10:32 am · Bogotá, CO"
  final bool isCurrent;

  const ConnectedDevice({
    required this.id,
    required this.name,
    required this.kind,
    required this.lastAccess,
    this.isCurrent = false,
  });

  /// Datos de ejemplo. Reemplázalos por la respuesta de tu API.
  static const sample = [
    ConnectedDevice(
      id: '1',
      name: 'iPhone 14 Pro',
      kind: DeviceKind.phone,
      lastAccess: 'Hoy, 10:32 am · Bogotá, CO',
      isCurrent: true,
    ),
    ConnectedDevice(
      id: '2',
      name: 'MacBook Pro',
      kind: DeviceKind.laptop,
      lastAccess: 'Ayer, 08:15 pm · Cali, CO',
    ),
    ConnectedDevice(
      id: '3',
      name: 'iPad Air',
      kind: DeviceKind.tablet,
      lastAccess: 'Hace 3 días · Medellín, CO',
    ),
  ];
}
