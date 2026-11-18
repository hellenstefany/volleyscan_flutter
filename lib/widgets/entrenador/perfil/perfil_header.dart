import 'package:flutter/material.dart';
import '../../../theme/entrenador_colors.dart';
import 'perfil_common_widgets.dart';
import 'perfil_model.dart';

/// Cabecera: avatar, nombre, club, etiquetas y botón Editar/Ver perfil.
class PerfilHeader extends StatelessWidget {
  final bool ancho, isEditing;
  final Map<String, String> profile;
  final VoidCallback onToggleEdit;

  const PerfilHeader({
    super.key,
    required this.ancho,
    required this.isEditing,
    required this.profile,
    required this.onToggleEdit,
  });

  @override
  Widget build(BuildContext context) {
    final avatar = Container(
      width: 100,
      height: 100,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1E293B), Color(0xFF334155)],
        ),
        border: Border.all(color: EC.accent.withOpacity(0.3), width: 3),
        boxShadow: [
          BoxShadow(color: EC.accent.withOpacity(0.2), blurRadius: 24),
        ],
      ),
      child: Text(
        perfilInitials(profile['fullName']!),
        style: const TextStyle(
          fontSize: 40,
          fontWeight: FontWeight.bold,
          color: EC.accent2,
        ),
      ),
    );

    final info = Column(
      crossAxisAlignment: ancho
          ? CrossAxisAlignment.start
          : CrossAxisAlignment.center,
      children: [
        Text(
          profile['fullName']!,
          textAlign: ancho ? TextAlign.start : TextAlign.center,
          style: const TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: EC.text1,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Entrenador principal · ${profile['club']}',
          textAlign: ancho ? TextAlign.start : TextAlign.center,
          style: const TextStyle(fontSize: 14, color: EC.text2),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 8,
          alignment: ancho ? WrapAlignment.start : WrapAlignment.center,
          children: [
            PerfilTag(Icons.verified, profile['level']!),
            PerfilTag(
              Icons.schedule,
              '${profile['experience']} años de experiencia',
            ),
          ],
        ),
      ],
    );

    final boton = OutlinedButton.icon(
      onPressed: onToggleEdit,
      icon: Icon(isEditing ? Icons.visibility : Icons.edit, size: 16),
      label: Text(isEditing ? 'Ver perfil' : 'Editar perfil'),
      style: OutlinedButton.styleFrom(
        foregroundColor: EC.accent2,
        backgroundColor: EC.accent.withOpacity(0.1),
        side: BorderSide(color: EC.accent.withOpacity(0.3)),
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
