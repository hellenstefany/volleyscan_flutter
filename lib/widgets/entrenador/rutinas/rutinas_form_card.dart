import 'package:flutter/material.dart';
import '../../../models/rutina_entrenador_data.dart';
import '../../../theme/app_theme.dart';
import '../../../theme/dash_colors.dart';
import '../gestion/gestion_athlete.dart';
import 'rutinas_catalog.dart';
import 'rutinas_common_widgets.dart';
import 'rutinas_exercises_editor.dart';
import 'rutinas_form_fields.dart';

/// Formulario "Nueva / Editar rutina" alineado 1:1 con Next.
class RutinasFormCard extends StatelessWidget {
  final bool editing;
  final bool guardando;
  final List<EntrenadorDeportista> deportistas;
  final RutinaAtleta? editandoAtleta;
  final String? athlete;
  final String? type;
  final String nivel;
  final TextEditingController nameCtrl;
  final TextEditingController objetivoCtrl;
  final TextEditingController hourCtrl;
  final TextEditingController minCtrl;
  final TextEditingController notesCtrl;
  final TextEditingController propioCtrl;
  final String fecha;
  final double intensity;
  final List<RutinaEjercicio> ejercicios;
  final String selectedDur;
  final ValueChanged<String?> onAthlete;
  final ValueChanged<String?> onType;
  final ValueChanged<String> onNivel;
  final ValueChanged<String> onFecha;
  final ValueChanged<String> onDur;
  final ValueChanged<double> onIntensity;
  final ValueChanged<String> onToggleEx;
  final VoidCallback onAddPropio;
  final void Function(String nombre, {int? series, int? reps}) onChangeEx;
  final VoidCallback onSave;
  final VoidCallback? onCancelEdit;

  const RutinasFormCard({
    super.key,
    required this.editing,
    required this.guardando,
    required this.deportistas,
    this.editandoAtleta,
    required this.athlete,
    required this.type,
    required this.nivel,
    required this.nameCtrl,
    required this.objetivoCtrl,
    required this.hourCtrl,
    required this.minCtrl,
    required this.notesCtrl,
    required this.propioCtrl,
    required this.fecha,
    required this.intensity,
    required this.ejercicios,
    required this.selectedDur,
    required this.onAthlete,
    required this.onType,
    required this.onNivel,
    required this.onFecha,
    required this.onDur,
    required this.onIntensity,
    required this.onToggleEx,
    required this.onAddPropio,
    required this.onChangeEx,
    required this.onSave,
    this.onCancelEdit,
  });

  @override
  Widget build(BuildContext context) {
    final sinDeportistas = deportistas.isEmpty && !editing;
    final athleteItems = <(String, String)>[
      for (final d in deportistas) ('${d.id}', d.nombreCompleto),
      if (editandoAtleta != null &&
          !deportistas.any((d) => d.id == editandoAtleta!.id))
        ('${editandoAtleta!.id}', editandoAtleta!.nombreCompleto),
      if (deportistas.length > 1 && !editing)
        ('todos', 'Todos mis deportistas (${deportistas.length})'),
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: rtBox(DashColors.card, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RtCardTitle(
            icon: editing ? '✏️' : '➕',
            title: '${editing ? 'Editar' : 'Nueva'} rutina',
          ),
          if (sinDeportistas)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: DashColors.amber.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: DashColors.amber.withValues(alpha: 0.3),
                ),
              ),
              child: const Text(
                'Aún no tienes deportistas vinculados, así que no hay a quién asignar rutinas. Ve a Gestión para aceptar o vincular deportistas.',
                style: TextStyle(
                  fontSize: 13,
                  color: DashColors.amber,
                  height: 1.5,
                ),
              ),
            )
          else ...[
            LayoutBuilder(
              builder: (_, c) {
                final a = RtDropdownField(
                  label: 'Deportista',
                  value: athlete,
                  items: athleteItems,
                  onChanged: editing ? null : onAthlete,
                );
                final b = RtDropdownField(
                  label: 'Tipo de entrenamiento',
                  value: type,
                  items: [for (final t in kRutinaExercises.keys) (t, t)],
                  onChanged: onType,
                );
                if (c.maxWidth >= 380) {
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: a),
                      const SizedBox(width: 10),
                      Expanded(child: b),
                    ],
                  );
                }
                return Column(children: [a, const SizedBox(height: 10), b]);
              },
            ),
            const SizedBox(height: 10),
            const RtLabel('Nivel de la rutina'),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final n in kRutinaNiveles)
                  RtPill(
                    text: n.$2,
                    selected: nivel == n.$1,
                    onTap: () => onNivel(n.$1),
                  ),
              ],
            ),
            const SizedBox(height: 10),
            const RtLabel('Nombre de la rutina'),
            TextField(
              controller: nameCtrl,
              maxLength: 150,
              style: const TextStyle(color: DashColors.text, fontSize: 13),
              decoration: rtInputDeco('Ej: Entrenamiento de saque explosivo…')
                  .copyWith(counterText: ''),
            ),
            const SizedBox(height: 10),
            const RtLabel('Objetivo (lo ve el deportista)'),
            TextField(
              controller: objetivoCtrl,
              maxLength: 255,
              style: const TextStyle(color: DashColors.text, fontSize: 13),
              decoration: rtInputDeco('Ej: Ganar precisión en el saque flotante')
                  .copyWith(counterText: ''),
            ),
            const SizedBox(height: 10),
            RtScheduleFields(
              hourCtrl: hourCtrl,
              minCtrl: minCtrl,
              fecha: fecha,
              onFecha: onFecha,
            ),
            const SizedBox(height: 10),
            const RtLabel('Duración'),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final d in kRutinaDuraciones.keys)
                  RtPill(
                    text: d,
                    selected: selectedDur == d,
                    onTap: () => onDur(d),
                  ),
              ],
            ),
            const SizedBox(height: 10),
            RtIntensitySlider(
              intensity: intensity,
              onChanged: onIntensity,
            ),
            const SizedBox(height: 10),
            RutinasExercisesEditor(
              type: type,
              ejercicios: ejercicios,
              propioCtrl: propioCtrl,
              onToggleEx: onToggleEx,
              onAddPropio: onAddPropio,
              onChangeEx: onChangeEx,
            ),
            const SizedBox(height: 12),
            const RtLabel('Notas / Observaciones'),
            TextField(
              controller: notesCtrl,
              maxLines: 3,
              maxLength: 2000,
              style: const TextStyle(color: DashColors.text, fontSize: 13),
              decoration: rtInputDeco('Indicaciones especiales…')
                  .copyWith(counterText: ''),
            ),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: Opacity(
                opacity: guardando ? 0.65 : 1.0,
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: guardando ? null : onSave,
                    borderRadius: BorderRadius.circular(10),
                    child: Ink(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        gradient: AppGradients.sidebarLogoIcon,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (guardando) ...[
                            const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(width: 10),
                          ],
                          Text(
                            guardando
                                ? 'GUARDANDO…'
                                : editing
                                    ? '✏️ ACTUALIZAR RUTINA'
                                    : '⚡ ASIGNAR RUTINA',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            if (editing && onCancelEdit != null) ...[
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: guardando ? null : onCancelEdit,
                  style: OutlinedButton.styleFrom(
                    backgroundColor: DashColors.card2,
                    foregroundColor: DashColors.text,
                    side: const BorderSide(color: DashColors.border),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text('Cancelar edición'),
                ),
              ),
            ],
          ],
        ],
      ),
    );
  }
}
