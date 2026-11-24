import 'package:flutter/material.dart';
import '../../../models/rutina_entrenador_data.dart';
import '../../../services/api_service.dart';
import '../../../theme/app_theme.dart';
import '../gestion/gestion_athlete.dart';
import 'rutinas_catalog.dart';

/// Valida el formulario y envía la creación o edición de rutina al backend.
/// Devuelve `true` si se guardó correctamente.
Future<bool> submitRutinaEntrenador({
  required BuildContext context,
  required int? editingId,
  required String? athlete,
  required String? type,
  required String nivel,
  required String nombre,
  required String objetivo,
  required String notas,
  required String hourText,
  required String minText,
  required String fecha,
  required String selectedDur,
  required int intensidad,
  required List<RutinaEjercicio> ejercicios,
  required List<EntrenadorDeportista> deportistas,
  required VoidCallback onClearVerAtletaIfAll,
}) async {
  if (athlete == null || type == null || nombre.trim().isEmpty) {
    showAppToast(context, 'Completa deportista, tipo y nombre.', type: 'error');
    return false;
  }
  if (ejercicios.isEmpty) {
    showAppToast(context, 'Agrega al menos un ejercicio.', type: 'error');
    return false;
  }
  final hh = int.tryParse(hourText.trim());
  final mm = int.tryParse(minText.trim());
  if (hh == null || mm == null || hh < 0 || hh > 23 || mm < 0 || mm > 59) {
    showAppToast(context, 'La hora de inicio no es válida.', type: 'error');
    return false;
  }

  final datos = <String, dynamic>{
    'nombre': nombre.trim(),
    'tipo': type,
    'nivel': nivel,
    'objetivo': objetivo.trim().isEmpty ? null : objetivo.trim(),
    'notas': notas.trim().isEmpty ? null : notas.trim(),
    'horaInicio':
        '${hh.toString().padLeft(2, '0')}:${mm.toString().padLeft(2, '0')}',
    'duracionMin': kRutinaDuraciones[selectedDur] ?? 60,
    'intensidad': intensidad,
    'fechaProgramada': fecha.isEmpty ? null : fecha,
    'ejercicios': [for (final e in ejercicios) e.toPayloadJson()],
  };

  try {
    if (editingId != null) {
      await ApiService().editarRutinaEntrenador(editingId, datos);
      if (context.mounted) {
        showAppToast(context, '"${datos['nombre']}" actualizada');
      }
    } else {
      final atletaIds = athlete == 'todos'
          ? [for (final d in deportistas) d.id]
          : [int.parse(athlete)];
      final ids = await ApiService().crearRutinasEntrenador({
        ...datos,
        'atletaIds': atletaIds,
      });
      if (athlete == 'todos') onClearVerAtletaIfAll();
      if (context.mounted) {
        final n = ids.length;
        showAppToast(
          context,
          n > 1
              ? '"${datos['nombre']}" asignada a $n deportistas'
              : '"${datos['nombre']}" asignada',
        );
      }
    }
    return true;
  } on ApiException catch (e) {
    if (context.mounted && !e.isUnauthorized) {
      showAppToast(context, e.message, type: 'error');
    }
    return false;
  } catch (_) {
    if (context.mounted) {
      showAppToast(context, 'No se pudo guardar la rutina.', type: 'error');
    }
    return false;
  }
}
