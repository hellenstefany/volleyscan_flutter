import 'package:flutter/material.dart';
import '../../models/coach_link_data.dart';
import '../../theme/app_theme.dart';
import '../../theme/dash_colors.dart';
import 'coach_status_widgets.dart';

/// Sección "Entrenadores disponibles" con buscador sin tildes, estados vacíos y grid de tarjetas.
class CoachDirectorySection extends StatelessWidget {
  final List<CoachPerson> allCoaches;
  final List<CoachPerson> visibleCoaches;
  final TextEditingController searchController;
  final ValueChanged<String> onSearchChanged;
  final bool busy;
  final ValueChanged<CoachPerson> onSelectCoach;

  const CoachDirectorySection({
    super.key,
    required this.allCoaches,
    required this.visibleCoaches,
    required this.searchController,
    required this.onSearchChanged,
    required this.busy,
    required this.onSelectCoach,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Wrap(
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 12,
          runSpacing: 12,
          children: [
            const Text(
              'Entrenadores disponibles',
              style: TextStyle(fontFamily: 'Poppins', fontSize: 18.5, fontWeight: FontWeight.w700, color: DashColors.text),
            ),
            ConstrainedBox(
              constraints: const BoxConstraints(minWidth: 240, maxWidth: 320),
              child: TextField(
                controller: searchController,
                onChanged: onSearchChanged,
                style: const TextStyle(fontFamily: 'Poppins', fontSize: 13.5, color: DashColors.text),
                decoration: InputDecoration(
                  hintText: 'Buscar por nombre…',
                  hintStyle: const TextStyle(fontFamily: 'Poppins', fontSize: 13.5, color: DashColors.muted),
                  prefixIcon: const Icon(Icons.search_rounded, size: 18, color: DashColors.muted),
                  suffixIcon: searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.close_rounded, size: 16, color: DashColors.muted),
                          onPressed: () {
                            searchController.clear();
                            onSearchChanged('');
                          },
                        )
                      : null,
                  filled: true,
                  fillColor: DashColors.cardDark,
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppRadii.btn),
                    borderSide: const BorderSide(color: DashColors.coachBorder),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppRadii.btn),
                    borderSide: const BorderSide(color: DashColors.blueLight, width: 1.8),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (allCoaches.isEmpty)
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: DashColors.cardDark,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: DashColors.coachBorder),
            ),
            alignment: Alignment.center,
            child: const Text(
              'Todavía no hay entrenadores registrados.',
              textAlign: TextAlign.center,
              style: TextStyle(fontFamily: 'Poppins', fontSize: 14, color: DashColors.muted),
            ),
          )
        else if (visibleCoaches.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Text(
              'Ningún entrenador coincide con esa búsqueda.',
              style: TextStyle(fontFamily: 'Poppins', fontSize: 14, color: DashColors.muted),
            ),
          )
        else
          LayoutBuilder(
            builder: (context, constraints) {
              final cols = constraints.maxWidth >= 740 ? 3 : (constraints.maxWidth >= 480 ? 2 : 1);
              const spacing = 14.0;
              final itemWidth = (constraints.maxWidth - spacing * (cols - 1)) / cols;
              return Wrap(
                spacing: spacing,
                runSpacing: spacing,
                children: [
                  for (final p in visibleCoaches)
                    SizedBox(
                      width: itemWidth,
                      child: _CoachGridCard(coach: p, busy: busy, onChoose: () => onSelectCoach(p)),
                    ),
                ],
              );
            },
          ),
      ],
    );
  }
}

class _CoachGridCard extends StatelessWidget {
  final CoachPerson coach;
  final bool busy;
  final VoidCallback onChoose;

  const _CoachGridCard({required this.coach, required this.busy, required this.onChoose});

  @override
  Widget build(BuildContext context) {
    final depLabel = coach.deportistas == 1 ? '1 deportista' : '${coach.deportistas} deportistas';
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppGradients.coachCardBg,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: DashColors.coachBorder),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CoachSquareAvatar(person: coach, size: 64),
          const SizedBox(height: 10),
          Text(
            coach.fullName.isNotEmpty ? coach.fullName : 'Entrenador',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: const TextStyle(fontFamily: 'Poppins', fontSize: 15, fontWeight: FontWeight.w700, color: DashColors.text),
          ),
          const SizedBox(height: 4),
          Text(depLabel, style: const TextStyle(fontFamily: 'Poppins', fontSize: 13.5, color: DashColors.muted)),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: Opacity(
              opacity: busy ? 0.5 : 1.0,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: AppGradients.coachPrimaryBtn,
                  borderRadius: BorderRadius.circular(AppRadii.btn),
                ),
                child: ElevatedButton(
                  onPressed: busy ? null : onChoose,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    disabledBackgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    foregroundColor: DashColors.textPrimary,
                    disabledForegroundColor: DashColors.textPrimary,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadii.btn)),
                  ),
                  child: const Text(
                    'Elegir como entrenador',
                    style: TextStyle(fontFamily: 'Poppins', fontSize: 13.5, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Modal de confirmación para acciones que modifican el vínculo (`solicitar`, `cancelar`, `desvincular`).
Future<bool> showCoachConfirmModal(
  BuildContext context, {
  required String title,
  required String message,
  required String confirmLabel,
  bool isDanger = false,
}) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      backgroundColor: DashColors.cardDark,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadii.authCard),
        side: const BorderSide(color: DashColors.coachBorder),
      ),
      title: Text(
        title,
        style: const TextStyle(fontFamily: 'Poppins', fontSize: 17, fontWeight: FontWeight.w700, color: DashColors.text),
      ),
      content: Text(
        message,
        style: const TextStyle(fontFamily: 'Poppins', fontSize: 13.5, height: 1.5, color: DashColors.textSecondary),
      ),
      actions: [
        OutlinedButton(
          onPressed: () => Navigator.of(ctx).pop(false),
          style: OutlinedButton.styleFrom(
            foregroundColor: DashColors.textSecondary,
            side: const BorderSide(color: DashColors.coachBorder),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadii.btn)),
          ),
          child: const Text('No', style: TextStyle(fontFamily: 'Poppins', fontSize: 13.5)),
        ),
        ElevatedButton(
          onPressed: () => Navigator.of(ctx).pop(true),
          style: ElevatedButton.styleFrom(
            backgroundColor: isDanger ? DashColors.orange : DashColors.blueLight,
            foregroundColor: isDanger ? DashColors.bg : DashColors.textPrimary,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadii.btn)),
          ),
          child: Text(confirmLabel, style: const TextStyle(fontFamily: 'Poppins', fontSize: 13.5, fontWeight: FontWeight.w700)),
        ),
      ],
    ),
  );
  return result == true;
}
