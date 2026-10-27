import 'package:flutter/material.dart';
import '../models/goals_data.dart';
import '../models/preferences_data.dart';
import '../models/profile_data.dart';
import '../theme/dash_colors.dart';
import '../utils/bottom_nav_router.dart';
import '../widgets/usuario/dashboard_bottom_nav.dart';
import '../widgets/usuario/goals_form.dart';
import '../widgets/usuario/menu_button.dart';
import '../widgets/usuario/personal_info_form.dart';
import '../widgets/usuario/preferences_form.dart';
import '../widgets/usuario/profile_section_tabs.dart';
import '../widgets/usuario/profile_summary_card.dart';
import '../widgets/usuario/security_form.dart';

/// Pantalla "Perfil de Usuario".
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key, this.userName = 'Agustin', this.photoPath});

  final String userName;

  /// Ruta de la foto (asset). Si es null o no existe, se muestran las iniciales.
  final String? photoPath;

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  ProfileSection _section = ProfileSection.personal;
  late ProfileData _profile;
  late GoalsData _goals;
  late PreferencesData _prefs;

  @override
  void initState() {
    super.initState();
    // TODO: cargar los datos reales del usuario desde tu backend.
    _profile = ProfileData(
      fullName: widget.userName,
      email: 'usuario@volleyscan.com',
      birthDate: DateTime(2002, 5, 15),
      level: 'Intermedio',
      weightKg: 72,
      heightM: 1.80,
      position: 'Opuesto',
    );
    _goals = const GoalsData(
      mainGoal: 'Mejorar técnica de remate',
      sessionsPerWeek: 4,
      minutesPerSession: 45,
      areas: ['Remate', 'Recepción'],
    );
    _prefs = const PreferencesData(
      sessionReminder: true,
      analysisCompleted: true,
      newContent: false,
      language: 'Español',
      units: 'Métrico (kg, m)',
    );
  }

  Future<void> _saveProfile(ProfileData data) async {
    // TODO: enviar `data` por HTTPS a tu backend.
    await Future.delayed(const Duration(seconds: 1));
    if (!mounted) return;
    setState(() => _profile = data);
  }

  Future<void> _saveGoals(GoalsData data) async {
    // TODO: enviar `data` por HTTPS a tu backend.
    await Future.delayed(const Duration(seconds: 1));
    if (!mounted) return;
    setState(() => _goals = data);
  }

  Future<void> _savePreferences(PreferencesData data) async {
    // TODO: enviar `data` por HTTPS a tu backend.
    await Future.delayed(const Duration(seconds: 1));
    if (!mounted) return;
    setState(() => _prefs = data);
  }

  Future<void> _changePassword(String current, String next) async {
    // TODO: enviar la contraseña actual y la nueva por HTTPS a tu backend.
    await Future.delayed(const Duration(seconds: 1));
  }

  Future<void> _deleteAccount() async {
    // TODO: pedir a tu backend que elimine la cuenta y cerrar la sesión.
    await Future.delayed(const Duration(seconds: 1));
    if (!mounted) return;
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  void _changePhoto() {
    // TODO: elegir una foto (por ejemplo con el paquete image_picker).
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Cambiar foto estará disponible pronto')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: DashColors.bg,
      drawer: UserDrawer(selectedId: 'perfil', userName: widget.userName),
      bottomNavigationBar: DashboardBottomNav(
        currentIndex: 4,
        onTap: (i) => goToTab(context, i, current: 4),
      ),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _header(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 520),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ProfileSummaryCard(
                          name: _profile.fullName,
                          level: _profile.level,
                          photoPath: widget.photoPath,
                        ),
                        const SizedBox(height: 14),
                        ProfileSectionTabs(
                          selected: _section,
                          onSelected: (s) => setState(() => _section = s),
                        ),
                        const SizedBox(height: 14),
                        _content(),
                      ],
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

  Widget _header() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.white.withOpacity(0.06)),
        ),
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
                border: Border.all(color: Colors.white.withOpacity(0.1)),
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
                color: Colors.white,
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
          initial: _profile,
          photoPath: widget.photoPath,
          onSave: _saveProfile,
          onChangePhoto: _changePhoto,
        );
      case ProfileSection.goals:
        return GoalsForm(initial: _goals, onSave: _saveGoals);
      case ProfileSection.preferences:
        return PreferencesForm(initial: _prefs, onSave: _savePreferences);
      case ProfileSection.security:
        return SecurityForm(
          onChangePassword: _changePassword,
          onDeleteAccount: _deleteAccount,
        );
    }
  }
}
