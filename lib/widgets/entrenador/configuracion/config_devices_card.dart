import 'package:flutter/material.dart';
import '../../../models/device_data.dart';
import '../../../services/api_service.dart';
import '../../../theme/app_theme.dart';
import '../../../theme/dash_colors.dart';
import 'config_card.dart';
import 'config_confirm_dialog.dart';

/// Tarjeta "Dispositivos conectados" conectada a `/api/usuario/dispositivos/`.
class ConfigDevicesCard extends StatelessWidget {
  final List<ConnectedDevice> devices;
  final bool loading;
  final String error;
  final int? closingId;
  final bool closingOthers;
  final VoidCallback onRetry;
  final Future<void> Function(ConnectedDevice device) onCloseDevice;
  final Future<void> Function() onCloseOthers;

  const ConfigDevicesCard({
    super.key,
    required this.devices,
    required this.loading,
    required this.error,
    required this.closingId,
    required this.closingOthers,
    required this.onRetry,
    required this.onCloseDevice,
    required this.onCloseOthers,
  });

  IconData _iconFor(DeviceKind kind) {
    switch (kind) {
      case DeviceKind.phone:
        return Icons.smartphone_rounded;
      case DeviceKind.tablet:
        return Icons.tablet_mac_rounded;
      case DeviceKind.laptop:
        return Icons.laptop_mac_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final othersCount = devices.where((d) => !d.actual).length;

    return ConfigCard(
      title: 'Dispositivos conectados',
      children: [
        if (loading && devices.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 20),
            child: Center(
              child: CircularProgressIndicator(color: DashColors.coachPurple),
            ),
          )
        else if (error.isNotEmpty && devices.isEmpty)
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: DashColors.red.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: DashColors.red.withValues(alpha: 0.35),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    error,
                    style: const TextStyle(
                      fontSize: 13,
                      color: DashColors.errorText,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: onRetry,
                  child: const Text('Reintentar'),
                ),
              ],
            ),
          )
        else if (devices.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Text(
              'No hay sesiones activas registradas.',
              style: TextStyle(fontSize: 13, color: DashColors.textMuted),
            ),
          )
        else ...[
          for (final d in devices)
            _DeviceRow(
              device: d,
              icon: _iconFor(d.kind),
              busy: closingId == d.id || closingOthers,
              onClose: () async {
                final ok = await showConfigConfirmDialog(
                  context,
                  title: 'Cerrar sesión en dispositivo',
                  message:
                      '¿Deseas cerrar la sesión activa en "${d.nombre}"?',
                  confirmLabel: 'Cerrar sesión',
                );
                if (ok) await onCloseDevice(d);
              },
            ),
          if (othersCount > 0) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: closingOthers
                    ? null
                    : () async {
                        final ok = await showConfigConfirmDialog(
                          context,
                          title: 'Cerrar otras sesiones',
                          message:
                              'Se cerrarán $othersCount sesión${othersCount > 1 ? 'es' : ''} activa${othersCount > 1 ? 's' : ''} en otros dispositivos.',
                          confirmLabel: 'Cerrar todas las demás',
                        );
                        if (ok) await onCloseOthers();
                      },
                icon: closingOthers
                    ? const SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: DashColors.red,
                        ),
                      )
                    : const Icon(Icons.logout_rounded, size: 16),
                label: Text(
                  closingOthers
                      ? 'Cerrando sesiones…'
                      : 'Cerrar sesión en otros dispositivos ($othersCount)',
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: DashColors.red,
                  side: BorderSide(
                    color: DashColors.red.withValues(alpha: 0.45),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
          ],
        ],
      ],
    );
  }
}

class _DeviceRow extends StatelessWidget {
  final ConnectedDevice device;
  final IconData icon;
  final bool busy;
  final VoidCallback onClose;

  const _DeviceRow({
    required this.device,
    required this.icon,
    required this.busy,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: DashColors.coachCard2,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: device.actual
              ? DashColors.greenBadgeBorder
              : DashColors.coachBorder,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: DashColors.coachPurple.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: DashColors.coachPurple, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        device.nombre,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w700,
                          color: DashColors.text,
                        ),
                      ),
                    ),
                    if (device.actual) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: DashColors.green.withValues(alpha: 0.14),
                          borderRadius: BorderRadius.circular(99),
                          border: Border.all(
                            color: DashColors.greenBadgeBorder,
                          ),
                        ),
                        child: const Text(
                          'Actual',
                          style: TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w700,
                            color: DashColors.successBadgeText,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  device.subtitle,
                  style: const TextStyle(
                    fontSize: 12,
                    color: DashColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
          if (!device.actual)
            IconButton(
              onPressed: busy ? null : onClose,
              tooltip: 'Cerrar sesión',
              icon: busy
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: DashColors.red,
                      ),
                    )
                  : const Icon(
                      Icons.close_rounded,
                      size: 18,
                      color: DashColors.red,
                    ),
            ),
        ],
      ),
    );
  }
}

/// Helper para mostrar errores de `ApiService` en toast.
void showConfigApiError(BuildContext context, Object err, String fallback) {
  if (err is ApiException) {
    if (err.isUnauthorized) return;
    showAppToast(context, err.message, type: 'error');
    return;
  }
  showAppToast(context, fallback, type: 'error');
}
