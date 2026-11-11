import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/preferences_data.dart';
import '../models/profile_data.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';
import '../theme/dash_colors.dart';
import '../utils/bottom_nav_router.dart';
import '../widgets/usuario/dash_card.dart';
import '../widgets/usuario/dashboard_bottom_nav.dart';
import '../widgets/usuario/menu_button.dart';
import '../widgets/usuario/personal_info_form.dart';
import '../widgets/usuario/preferences_form.dart';
import '../widgets/usuario/profile_section_tabs.dart';
import '../widgets/usuario/profile_summary_card.dart';
import '../widgets/usuario/security_form.dart';

/// Pantalla "Perfil de Usuario" alineada con `VolleyScan_Next/src/app/usuario/perfil/page.jsx`.
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key, this.userName = '', this.photoPath});

  final String userName;
  final String? photoPath;

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _picker = ImagePicker();

  ProfileSection _section = ProfileSection.personal;
  bool _loading = true;
  String? _error;
  bool _uploadingPhoto = false;

  ProfileData? _profile;
  PreferencesData _prefs = PreferencesData.defaults;

  static const _maxPhotoBytes = 2 * 1024 * 1024; // 2 MB
  static const _allowedExts = {'jpg', 'jpeg', 'png', 'webp'};
  static const _allowedMimes = {'image/jpeg', 'image/png', 'image/webp'};

  @override
  void initState() {
    super.initState();
    _cargarPerfil();
  }

  Future<void> _cargarPerfil() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    final api = ApiService();
    await Future.wait([
      api.obtenerPerfil().then((data) {
        if (mounted) {
          setState(() {
            _profile = data;
            _loading = false;
          });
        }
      }).catchError((Object err) {
        if (mounted) {
          setState(() {
            _loading = false;
            _error = err is ApiException
                ? err.message
                : 'No se pudo cargar la información del perfil.';
          });
        }
      }),
      api.obtenerConfiguracion().then((cfg) {
        if (mounted) setState(() => _prefs = cfg);
      }).catchError((_) {}),
    ]);
  }

  Future<void> _saveProfile(ProfileData updated) async {
    final current = _profile;
    if (current == null) return;
    final cambios = updated.diffFrom(current);
    if (cambios.isEmpty) {
      showAppToast(context, 'No hay cambios para guardar.', type: 'info');
      return;
    }
    final saved = await ApiService().actualizarPerfil(cambios);
    if (!mounted) return;
    setState(() => _profile = saved);
    showAppToast(context, '✓ Información personal guardada.', type: 'ok');
  }

  Future<void> _savePreferences(PreferencesData data) async {
    final saved = await ApiService().actualizarConfiguracion(data);
    if (!mounted) return;
    setState(() => _prefs = saved);
    showAppToast(context, '✓ Preferencias guardadas.', type: 'ok');
  }

  Future<String> _changePassword(String current, String next) {
    return ApiService().cambiarPasswordPerfil(
      passwordActual: current,
      passwordNueva: next,
    );
  }

  Future<void> _changePhoto() async {
    if (_uploadingPhoto || _profile == null) return;
    final XFile? file = await _picker.pickImage(source: ImageSource.gallery);
    if (file == null || !mounted) return;

    final ext = file.name.contains('.')
        ? file.name.split('.').last.toLowerCase()
        : '';
    final mime = (file.mimeType ?? '').toLowerCase();
    final validType =
        _allowedExts.contains(ext) ||
        (mime.isNotEmpty && _allowedMimes.contains(mime));
    if (!validType) {
      showAppToast(
        context,
        'Formato no permitido. Usa JPG, PNG o WEBP.',
        type: 'error',
      );
      return;
    }

    final bytes = await file.readAsBytes();
    if (!mounted) return;
    if (bytes.length > _maxPhotoBytes) {
      showAppToast(context, 'La imagen no puede superar 2 MB.', type: 'error');
      return;
    }

    setState(() => _uploadingPhoto = true);
    try {
      final fname = file.name.isNotEmpty ? file.name : 'foto.jpg';
      final nuevaUrl = await ApiService().subirFotoPerfil(
        bytes: bytes,
        filename: fname,
      );
      if (!mounted) return;
      setState(() => _profile = _profile!.copyWith(fotoUrl: nuevaUrl));
      showAppToast(context, '✓ Foto actualizada.', type: 'ok');
    } on ApiException catch (err) {
      if (mounted) showAppToast(context, err.message, type: 'error');
    } catch (_) {
      if (mounted) {
        showAppToast(context, 'Error al subir la foto.', type: 'error');
      }
    } finally {
      if (mounted) setState(() => _uploadingPhoto = false);
    }
  }

  Future<void> _removePhoto() async {
    if (_uploadingPhoto || _profile == null) return;
    setState(() => _uploadingPhoto = true);
    try {
      await ApiService().eliminarFotoPerfil();
      if (!mounted) return;
      setState(() => _profile = _profile!.copyWith(clearFotoUrl: true));
      showAppToast(context, 'Foto eliminada.', type: 'info');
    } on ApiException catch (err) {
      if (mounted) showAppToast(context, err.message, type: 'error');
    } catch (_) {
      if (mounted) {
        showAppToast(context, 'No se pudo quitar la foto.', type: 'error');
      }
    } finally {
      if (mounted) setState(() => _uploadingPhoto = false);
    }
  }

  String get _effectiveName {
    if (_profile != null) return _profile!.fullName;
    if (widget.userName.trim().isNotEmpty) return widget.userName.trim();
    return 'Atleta';
  }

  String? get _effectivePhoto => _profile?.fotoUrl ?? widget.photoPath;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: DashColors.bg,
      drawer: UserDrawer(
        selectedId: 'perfil',
        userName: _effectiveName,
        photoUrl: _effectivePhoto,
      ),
      bottomNavigationBar: DashboardBottomNav(
        currentIndex: 4,
        onTap: (i) => goToTab(context, i, current: 4, userName: _effectiveName),
      ),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _header(),
            Expanded(
              child: RefreshIndicator(
                color: DashColors.blueLight,
                backgroundColor: DashColors.card,
                onRefresh: _cargarPerfil,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 520),
                      child: _buildBody(),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 80),
        child: Center(
          child: CircularProgressIndicator(color: DashColors.blueLight),
        ),
      );
    }
    if (_error != null || _profile == null) {
      return DashCard(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Icon(
              Icons.error_outline_rounded,
              color: DashColors.red,
              size: 38,
            ),
            const SizedBox(height: 12),
            Text(
              _error ?? 'No se pudo cargar el perfil.',
              textAlign: TextAlign.center,
              style: const TextStyle(color: DashColors.text, fontSize: 13.5),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _cargarPerfil,
              style: ElevatedButton.styleFrom(
                backgroundColor: DashColors.blueLight,
                foregroundColor: Colors.white,
              ),
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text('Reintentar'),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ProfileSummaryCard(
          name: _profile!.fullName,
          level: _profile!.nivel,
          role: _profile!.rolLabel,
          photoPath: _profile!.fotoUrl,
        ),
        const SizedBox(height: 14),
        ProfileSectionTabs(
          selected: _section,
          onSelected: (s) => setState(() => _section = s),
        ),
        const SizedBox(height: 14),
        _content(),
      ],
    );
  }

  Widget _header() {
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
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Text(
              'Perfil de Usuario',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: DashColors.text,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _content() {
    switch (_section) {
      case ProfileSection.personal:
        return PersonalInfoForm(
          initial: _profile!,
          uploadingPhoto: _uploadingPhoto,
          onSave: _saveProfile,
          onChangePhoto: _changePhoto,
          onRemovePhoto: _removePhoto,
        );
      case ProfileSection.preferences:
        return PreferencesForm(initial: _prefs, onSave: _savePreferences);
      case ProfileSection.security:
        return SecurityForm(onChangePassword: _changePassword);
    }
  }
}
