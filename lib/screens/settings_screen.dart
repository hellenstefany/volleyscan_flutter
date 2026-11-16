import 'package:flutter/material.dart';
import '../models/preferences_data.dart';
import '../screens/login_screen.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';
import '../theme/dash_colors.dart';
import '../widgets/usuario/shared/dash_card.dart';
import '../widgets/usuario/drawer/menu_button.dart';
import '../widgets/usuario/configuracion/settings_analysis_card.dart';
import '../widgets/usuario/configuracion/settings_devices_card.dart';
import '../widgets/usuario/configuracion/settings_general_card.dart';
import '../widgets/usuario/configuracion/settings_help_card.dart';
import '../widgets/usuario/configuracion/settings_notifications_card.dart';
import '../widgets/usuario/configuracion/settings_privacy_card.dart';
import '../widgets/usuario/configuracion/settings_privacy_detail_card.dart';
import '../widgets/usuario/configuracion/settings_section_tabs.dart';

/// Pantalla de Configuración alineada con `VolleyScan_Next/src/app/usuario/configuracion/page.jsx`.
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  /// `_saved` es `null` hasta que `GET /api/usuario/configuracion/` responda con éxito.
  /// Mientras sea `null`, el botón "Guardar cambios" permanece deshabilitado para nunca
  /// sobreescribir la BD con valores por defecto locales.
  PreferencesData? _saved;
  PreferencesData _draft = PreferencesData.defaults;
  LocalAnalysisSettings _analysis = LocalAnalysisSettings.defaults;

  String _section = 'general';
  bool _loadingConfig = true;
  String? _loadError;
  bool _saving = false;

  bool get _canSave => _saved != null && !_loadingConfig && !_saving;

  @override
  void initState() {
    super.initState();
    _loadConfig();
  }

  Future<void> _loadConfig() async {
    setState(() {
      _loadingConfig = true;
      _loadError = null;
    });
    try {
      final cfg = await ApiService().obtenerConfiguracion();
      if (!mounted) return;
      setState(() {
        _saved = cfg;
        _draft = cfg;
        _loadingConfig = false;
      });
    } on ApiException catch (err) {
      if (!mounted) return;
      setState(() {
        _loadError = err.message;
        _loadingConfig = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loadError = 'No se pudo cargar tu configuración.';
        _loadingConfig = false;
      });
    }
  }

  void _cancel() {
    if (_saved == null) return;
    setState(() => _draft = _saved!);
    showAppToast(context, 'Cambios descartados.', type: 'info');
  }

  Future<void> _save() async {
    if (!_canSave) return;
    setState(() => _saving = true);
    try {
      final updated = await ApiService().actualizarConfiguracion(_draft);
      if (!mounted) return;
      setState(() {
        _saved = updated;
        _draft = updated;
        _saving = false;
      });
      showAppToast(context, 'Configuración guardada correctamente');
    } on ApiException catch (err) {
      if (!mounted) return;
      setState(() => _saving = false);
      showAppToast(context, err.message, type: 'error');
    } catch (_) {
      if (!mounted) return;
      setState(() => _saving = false);
      showAppToast(
        context,
        'Error al guardar la configuración.',
        type: 'error',
      );
    }
  }

  Future<void> _confirmLogout() async {
    await showSettingsDangerConfirmModal(
      context: context,
      title: 'Cerrar sesión',
      body: '¿Seguro que quieres cerrar sesión en VolleyScan?',
      confirmLabel: 'Cerrar sesión',
      onConfirm: () async {
        final nav =
            ApiService.navigatorKey.currentState ?? Navigator.of(context);
        await ApiService().cerrarSesionCompleta();
        nav.pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const LoginScreen()),
          (route) => false,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: DashColors.bg,
      drawer: const UserDrawer(selectedId: 'configuracion'),
      body: DecoratedBox(
        decoration: const BoxDecoration(gradient: AppGradients.userPanelBg),
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              _buildHeader(),
              Expanded(
                child: RefreshIndicator(
                  color: DashColors.blueLight,
                  backgroundColor: DashColors.card,
                  onRefresh: _loadConfig,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 960),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (_loadingConfig || _loadError != null) ...[
                              _buildStatusBanner(),
                              const SizedBox(height: 14),
                            ],
                            SettingsSectionTabs(
                              selectedId: _section,
                              onSelect: (id) => setState(() => _section = id),
                            ),
                            const SizedBox(height: 16),
                            _buildSectionContent(),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: DashColors.border)),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => _scaffoldKey.currentState?.openDrawer(),
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: DashColors.card,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: DashColors.border),
              ),
              child: const Icon(
                Icons.menu_rounded,
                size: 22,
                color: DashColors.textPrimary,
              ),
            ),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Configuración',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: DashColors.textPrimary,
                  ),
                ),
                Text(
                  'Personaliza tu experiencia en VolleyScan',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 12,
                    color: DashColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBanner() {
    return DashCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          if (_loadingConfig) ...[
            const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: DashColors.blueLight,
              ),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'Cargando tu configuración…',
                style: TextStyle(color: DashColors.textSecondary, fontSize: 13),
              ),
            ),
          ] else ...[
            const Icon(Icons.error_outline_rounded, color: DashColors.red, size: 18),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'No se pudo cargar tu configuración: $_loadError',
                style: const TextStyle(color: DashColors.red, fontSize: 13),
              ),
            ),
            const SizedBox(width: 10),
            OutlinedButton(
              onPressed: _loadConfig,
              style: OutlinedButton.styleFrom(
                foregroundColor: DashColors.textSecondary,
                backgroundColor: DashColors.surface,
                side: const BorderSide(color: DashColors.border2),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              child: const Text('Reintentar', style: TextStyle(fontSize: 12.5)),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSectionContent() {
    switch (_section) {
      case 'general':
        return LayoutBuilder(
          builder: (context, constraints) {
            final generalCard = SettingsGeneralCard(
              data: _draft,
              saving: _saving,
              canSave: _canSave,
              onChanged: (d) => setState(() => _draft = d),
              onCancel: _cancel,
              onSave: _save,
            );
            final privacyCard = SettingsPrivacyCard(
              data: _draft,
              onChanged: (d) => setState(() => _draft = d),
              onLogout: _confirmLogout,
            );
            if (constraints.maxWidth >= 740) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: generalCard),
                  const SizedBox(width: 16),
                  SizedBox(width: 280, child: privacyCard),
                ],
              );
            }
            return Column(
              children: [generalCard, const SizedBox(height: 16), privacyCard],
            );
          },
        );
      case 'analisis':
        return SettingsAnalysisCard(
          data: _analysis,
          onChanged: (a) => setState(() => _analysis = a),
        );
      case 'notificaciones':
        return SettingsNotificationsCard(
          data: _draft,
          saving: _saving,
          canSave: _canSave,
          onChanged: (d) => setState(() => _draft = d),
          onCancel: _cancel,
          onSave: _save,
        );
      case 'privacidad':
        return SettingsPrivacyDetailCard(
          data: _draft,
          saving: _saving,
          canSave: _canSave,
          onChanged: (d) => setState(() => _draft = d),
          onCancel: _cancel,
          onSave: _save,
        );
      case 'dispositivos':
        return const SettingsDevicesCard();
      case 'ayuda':
        return const SettingsHelpCard();
      default:
        return const SizedBox.shrink();
    }
  }
}
