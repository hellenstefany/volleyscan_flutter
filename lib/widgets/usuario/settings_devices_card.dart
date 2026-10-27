import 'package:flutter/material.dart';
import '../../models/device_data.dart';
import '../../theme/routine_colors.dart';

/// Sección "Dispositivos" de Configuración.
class SettingsDevicesCard extends StatelessWidget {
  final List<ConnectedDevice> devices;
  final ValueChanged<ConnectedDevice> onLogoutDevice;
  final VoidCallback onLogoutAll;

  const SettingsDevicesCard({
    super.key,
    required this.devices,
    required this.onLogoutDevice,
    required this.onLogoutAll,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Dispositivos conectados',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 16),
        for (final d in devices)
          _DeviceTile(device: d, onLogout: () => onLogoutDevice(d)),
        const SizedBox(height: 8),
        Align(
          alignment: Alignment.centerRight,
          child: OutlinedButton(
            onPressed: onLogoutAll,
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: const Color(0xFF0A1022),
              side: const BorderSide(color: Color(0xFF7F1D1D)),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text(
              'Cerrar sesión en todos los dispositivos',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ],
    );
  }
}

class _DeviceTile extends StatelessWidget {
  final ConnectedDevice device;
  final VoidCallback onLogout;

  const _DeviceTile({required this.device, required this.onLogout});

  IconData get _icon {
    switch (device.kind) {
      case DeviceKind.phone:
        return Icons.smartphone_rounded;
      case DeviceKind.laptop:
        return Icons.laptop_mac_rounded;
      case DeviceKind.tablet:
        return Icons.tablet_mac_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: RoutineColors.cardDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: RoutineColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: RoutineColors.blue.withOpacity(0.18),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(_icon, color: RoutineColors.blue, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  device.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Último acceso: ${device.lastAccess}',
                  style: const TextStyle(
                    color: RoutineColors.textMuted,
                    fontSize: 12.5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          if (device.isCurrent)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
              decoration: BoxDecoration(
                color: const Color(0xFF22C55E).withOpacity(0.15),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: const Color(0xFF22C55E).withOpacity(0.5),
                ),
              ),
              child: const Text(
                'Este dispositivo',
                style: TextStyle(
                  color: Color(0xFF22C55E),
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
            )
          else
            OutlinedButton(
              onPressed: onLogout,
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: const Color(0xFF0A1022),
                side: const BorderSide(color: Color(0xFF7F1D1D)),
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                'Cerrar sesión',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
              ),
            ),
        ],
      ),
    );
  }
}
