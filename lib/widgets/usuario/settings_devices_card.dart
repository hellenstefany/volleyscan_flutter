import 'package:flutter/material.dart';
import '../../models/device_data.dart';
import '../../services/api_service.dart';
import '../../theme/app_theme.dart';
import '../../theme/dash_colors.dart';
import 'dash_card.dart';

/// Modal de confirmación peligroso (`.modal` con `.btn--danger` en `configuracion.css`).
Future<void> showSettingsDangerConfirmModal({
  required BuildContext context,
  required String title,
  required String body,
  required String confirmLabel,
  required Future<void> Function() onConfirm,
  String loadingLabel = 'Cerrando…',
}) async {
  var busy = false;
  await showDialog<void>(
    context: context,
    barrierColor: DashColors.modalOverlay,
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setModalState) => Dialog(
        backgroundColor: DashColors.card,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.md),
          side: const BorderSide(color: DashColors.border2),
        ),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 380),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: DashColors.textPrimary, fontSize: 17, fontWeight: FontWeight.w700)),
                const SizedBox(height: 10),
                Text(body, style: const TextStyle(color: DashColors.textSecondary, fontSize: 13.5, height: 1.5)),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    OutlinedButton(
                      onPressed: busy ? null : () => Navigator.of(ctx).pop(),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: DashColors.textSecondary,
                        backgroundColor: DashColors.surface,
                        side: const BorderSide(color: DashColors.border2),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadii.sm)),
                      ),
                      child: const Text('Cancelar'),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: busy
                          ? null
                          : () async {
                              setModalState(() => busy = true);
                              try {
                                await onConfirm();
                                if (ctx.mounted) Navigator.of(ctx).pop();
                              } finally {
                                if (ctx.mounted) setModalState(() => busy = false);
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: DashColors.red,
                        disabledBackgroundColor: DashColors.red.withValues(alpha: 0.6),
                        foregroundColor: DashColors.textPrimary,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadii.sm)),
                      ),
                      child: Text(busy ? loadingLabel : confirmLabel),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}

/// Sección "Dispositivos" (`SeccionDispositivos.jsx` en Next).
class SettingsDevicesCard extends StatefulWidget {
  const SettingsDevicesCard({super.key});
  @override
  State<SettingsDevicesCard> createState() => _SettingsDevicesCardState();
}

class _SettingsDevicesCardState extends State<SettingsDevicesCard> {
  List<ConnectedDevice> _devices = const [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadDevices();
  }

  Future<void> _loadDevices() async {
    setState(() { _loading = true; _error = null; });
    try {
      final list = await ApiService().listarDispositivos();
      if (mounted) setState(() { _devices = list; _loading = false; });
    } on ApiException catch (err) {
      if (mounted) setState(() { _error = err.message; _loading = false; });
    } catch (_) {
      if (mounted) setState(() { _error = 'No se pudieron cargar los dispositivos.'; _loading = false; });
    }
  }

  Future<void> _confirmCloseOne(ConnectedDevice d) => showSettingsDangerConfirmModal(
        context: context,
        title: 'Cerrar sesión en dispositivo',
        body: '¿Cerrar sesión en ${d.nombre}? Tendrás que volver a iniciar sesión ahí.',
        confirmLabel: 'Cerrar sesión',
        onConfirm: () async {
          try {
            await ApiService().cerrarDispositivo(d.id);
            if (!mounted) return;
            showAppToast(context, 'Sesión cerrada en ${d.nombre}.');
            await _loadDevices();
          } on ApiException catch (err) {
            if (!mounted) return;
            showAppToast(context, err.message, type: 'error');
            if (err.statusCode == 404) await _loadDevices();
          }
        },
      );

  Future<void> _confirmCloseOthers() => showSettingsDangerConfirmModal(
        context: context,
        title: 'Cerrar todas las demás sesiones',
        body: '¿Cerrar sesión en todos los demás dispositivos? Solo quedará abierta esta sesión.',
        confirmLabel: 'Cerrar todas',
        onConfirm: () async {
          try {
            final n = await ApiService().cerrarOtrosDispositivos();
            if (!mounted) return;
            showAppToast(context, n == 1 ? 'Se cerró 1 sesión activa.' : 'Se cerraron $n sesiones activas.');
            await _loadDevices();
          } on ApiException catch (err) {
            if (mounted) showAppToast(context, err.message, type: 'error');
          }
        },
      );

  @override
  Widget build(BuildContext context) {
    final hayOtros = _devices.any((d) => !d.actual);
    return DashCard(
      padding: const EdgeInsets.all(22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Dispositivos conectados', style: TextStyle(color: DashColors.textPrimary, fontSize: 17, fontWeight: FontWeight.w700)),
          const SizedBox(height: 16),
          if (_loading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Center(child: Text('Cargando dispositivos…', style: TextStyle(color: DashColors.textMuted, fontSize: 13.5))),
            )
          else if (_error != null)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Center(
                child: Column(
                  children: [
                    Text(_error!, textAlign: TextAlign.center, style: const TextStyle(color: DashColors.red, fontSize: 13.5)),
                    const SizedBox(height: 12),
                    OutlinedButton(
                      onPressed: _loadDevices,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: DashColors.textSecondary,
                        backgroundColor: DashColors.surface,
                        side: const BorderSide(color: DashColors.border2),
                      ),
                      child: const Text('Reintentar'),
                    ),
                  ],
                ),
              ),
            )
          else if (_devices.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Center(child: Text('No hay dispositivos con sesión activa.', style: TextStyle(color: DashColors.textMuted, fontSize: 13.5))),
            )
          else ...[
            for (final d in _devices) _DeviceTile(device: d, onLogout: () => _confirmCloseOne(d)),
            if (hayOtros) ...[
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: OutlinedButton(
                  onPressed: _confirmCloseOthers,
                  style: _dangerOutlineStyle(const EdgeInsets.symmetric(horizontal: 16, vertical: 12)),
                  child: const Text('Cerrar sesión en los demás dispositivos', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                ),
              ),
            ],
          ],
        ],
      ),
    );
  }
}

ButtonStyle _dangerOutlineStyle(EdgeInsets padding) => OutlinedButton.styleFrom(
      foregroundColor: DashColors.red,
      backgroundColor: Colors.transparent,
      side: const BorderSide(color: DashColors.dangerOutlineBorder),
      padding: padding,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadii.sm)),
    );

class _DeviceTile extends StatelessWidget {
  const _DeviceTile({required this.device, required this.onLogout});
  final ConnectedDevice device;
  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    final icon = switch (device.kind) {
      DeviceKind.phone => Icons.smartphone_rounded,
      DeviceKind.tablet => Icons.tablet_mac_rounded,
      DeviceKind.laptop => Icons.laptop_mac_rounded,
    };
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: DashColors.surface,
        borderRadius: BorderRadius.circular(AppRadii.md),
        border: Border.all(color: DashColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(color: DashColors.blueGlow, borderRadius: BorderRadius.circular(AppRadii.sm)),
            child: Icon(icon, color: DashColors.blueLight, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(device.nombre, style: const TextStyle(color: DashColors.textPrimary, fontSize: 14, fontWeight: FontWeight.w600)),
                const SizedBox(height: 2),
                Text(device.subtitle, style: const TextStyle(color: DashColors.textMuted, fontSize: 12)),
              ],
            ),
          ),
          const SizedBox(width: 8),
          if (device.actual)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: DashColors.greenGlow,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: DashColors.greenBadgeBorder),
              ),
              child: const Text('Este dispositivo', style: TextStyle(color: DashColors.green, fontSize: 11, fontWeight: FontWeight.w700)),
            )
          else
            OutlinedButton(
              onPressed: onLogout,
              style: _dangerOutlineStyle(const EdgeInsets.symmetric(horizontal: 12, vertical: 8)),
              child: const Text('Cerrar sesión', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12.5)),
            ),
        ],
      ),
    );
  }
}
