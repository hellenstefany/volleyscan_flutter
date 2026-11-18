import 'package:flutter/material.dart';

import '../../../theme/dash_colors.dart';
import 'perfil_common_widgets.dart';
import 'perfil_model.dart';

/// Cabecera del Perfil del Entrenador (`.profile-header` en `Perfil.module.css`).
class PerfilHeader extends StatelessWidget {
  final bool ancho;
  final bool isEditing;
  final bool loading;
  final EntrenadorPerfilData? profile;
  final VoidCallback? onToggleEdit;

  const PerfilHeader({
    super.key,
    required this.ancho,
    required this.isEditing,
    required this.loading,
    required this.profile,
    required this.onToggleEdit,
  });

  @override
  Widget build(BuildContext context) {
    final p = profile;
    final initials = p?.iniciales ?? 'EN';
    final fullName = p?.nombreCompleto ?? 'Entrenador';
    final clubSuffix =
        (p != null && p.club.trim().isNotEmpty) ? ' · ${p.club.trim()}' : '';
    final badgeText = 'Entrenador principal$clubSuffix';
    final expText = (p != null && p.experiencia.trim().isNotEmpty)
        ? '${p.experiencia.trim()} años de experiencia'
        : '— años de experiencia';
    final levelText = p?.nivelEtiqueta ?? 'Sin nivel';

    final avatar = Container(
      width: 100,
      height: 100,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [DashColors.hover, DashColors.cardHover],
        ),
        border: Border.all(
          color: DashColors.blueLight.withValues(alpha: 0.3),
          width: 3,
        ),
        boxShadow: [
          BoxShadow(
            color: DashColors.blueLight.withValues(alpha: 0.2),
            blurRadius: 24,
          ),
        ],
      ),
      child: Text(
        initials,
        style: const TextStyle(
          fontSize: 40,
          fontWeight: FontWeight.bold,
          color: DashColors.accent2,
        ),
      ),
    );

    final info = Column(
      crossAxisAlignment:
          ancho ? CrossAxisAlignment.start : CrossAxisAlignment.center,
      children: [
        if (loading && p == null)
          Container(
            width: 220,
            height: 28,
            decoration: BoxDecoration(
              color: DashColors.hover,
              borderRadius: BorderRadius.circular(8),
            ),
          )
        else
          Text(
            fullName,
            textAlign: ancho ? TextAlign.start : TextAlign.center,
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: DashColors.text1,
            ),
          ),
        const SizedBox(height: 6),
        Text(
          badgeText,
          textAlign: ancho ? TextAlign.start : TextAlign.center,
          style: const TextStyle(fontSize: 14, color: DashColors.textMuted),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 8,
          alignment: ancho ? WrapAlignment.start : WrapAlignment.center,
          children: [
            PerfilTag(Icons.verified_rounded, levelText),
            PerfilTag(Icons.schedule_rounded, expText),
          ],
        ),
      ],
    );

    final boton = OutlinedButton.icon(
      onPressed: onToggleEdit,
      icon: Icon(
        isEditing ? Icons.visibility_rounded : Icons.edit_rounded,
        size: 16,
      ),
      label: Text(isEditing ? 'Ver perfil' : 'Editar perfil'),
      style: OutlinedButton.styleFrom(
        foregroundColor: DashColors.accent2,
        backgroundColor: DashColors.blueLight.withValues(alpha: 0.1),
        side: BorderSide(color: DashColors.blueLight.withValues(alpha: 0.3)),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 28),
      decoration: perfilCardDeco(),
      child: ancho
          ? Row(
              children: [
                avatar,
                const SizedBox(width: 24),
                Expanded(child: info),
                const SizedBox(width: 24),
                boton,
              ],
            )
          : Column(
              children: [
                avatar,
                const SizedBox(height: 20),
                info,
                const SizedBox(height: 20),
                boton,
              ],
            ),
    );
  }
}
