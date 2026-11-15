import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../theme/dash_colors.dart';
import 'dash_card.dart';
import 'settings_general_card.dart';

// TODO(backend): En VolleyScan_Next (`ModalSoporte.jsx`), `SIMULAR = true` porque el
// endpoint `POST /api/usuario/soporte/` aún no existe en Backend_VolleyScan.
// Cuando se implemente en Django, cambiar `_simularSoporte` a `false` y llamar a `ApiService`.
const bool _simularSoporte = true;

const _faqItems = <(String, String)>[
  ('¿Cómo hago mi primer análisis con IA?', 'Entra a Análisis IA, permite el acceso a la cámara, ubícate de cuerpo completo frente a ella y pulsa Iniciar. Al terminar, el resultado queda guardado en tu historial de sesiones.'),
  ('La cámara no se activa, ¿qué hago?', 'Revisa que el navegador tenga permiso para usar la cámara (ícono del candado junto a la URL) y que ninguna otra aplicación la esté usando. También puedes revisar tus dispositivos en Configuración → Dispositivos.'),
  ('¿Dónde veo mi progreso?', 'En la sección Progreso encuentras tus estadísticas y la evolución de tus sesiones. Los datos se actualizan cada vez que finalizas un análisis.'),
  ('¿Quién puede ver mis datos?', 'Tú decides en Configuración → Privacidad. Puedes mostrarlos solo a ti, a tu entrenador, a tu equipo o a todos.'),
  ('Mi entrenador no ve mis sesiones', 'Verifica que tu visibilidad esté en “Mi entrenador” o “Mi equipo”. Si el problema continúa, repórtalo desde esta misma sección.'),
  ('Olvidé mi contraseña', 'En la pantalla de inicio de sesión pulsa “¿Olvidaste tu contraseña?”. Te enviaremos un enlace al correo para crear una nueva.'),
];

const _reportTypes = <String, String>{
  'error': 'Algo no funciona',
  'analisis': 'Problema con el análisis IA',
  'sugerencia': 'Sugerencia',
  'otro': 'Otro',
};

/// Sección "Ayuda y soporte" (`SeccionAyuda.jsx` en Next) con sus 3 modales.
class SettingsHelpCard extends StatelessWidget {
  const SettingsHelpCard({super.key});

  @override
  Widget build(BuildContext context) {
    final items = <(IconData, String, String, VoidCallback)>[
      (Icons.menu_book_rounded, 'Centro de ayuda', 'Guías y preguntas frecuentes', () => _showHelpCenterModal(context)),
      (Icons.mail_rounded, 'Contactar soporte', 'soporte@volleyscan.app', () => _showSupportModal(context, isReport: false)),
      (Icons.bug_report_rounded, 'Reportar un problema', 'Cuéntanos qué no funciona', () => _showSupportModal(context, isReport: true)),
      (Icons.info_rounded, 'Versión de la app', 'VolleyScan v2.4.1 · Build 241', () => _showVersionModal(context)),
    ];
    return DashCard(
      padding: const EdgeInsets.all(22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Ayuda y soporte', style: TextStyle(color: DashColors.textPrimary, fontSize: 17, fontWeight: FontWeight.w700)),
          const SizedBox(height: 16),
          for (final it in items)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Material(
                color: DashColors.surface,
                borderRadius: BorderRadius.circular(AppRadii.md),
                child: InkWell(
                  borderRadius: BorderRadius.circular(AppRadii.md),
                  onTap: it.$4,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(AppRadii.md), border: Border.all(color: DashColors.border)),
                    child: Row(
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(color: DashColors.blueGlow, borderRadius: BorderRadius.circular(AppRadii.sm)),
                          child: Icon(it.$1, size: 18, color: DashColors.blueLight),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(it.$2, style: const TextStyle(color: DashColors.textPrimary, fontSize: 14, fontWeight: FontWeight.w600)),
                              const SizedBox(height: 2),
                              Text(it.$3, style: const TextStyle(color: DashColors.textMuted, fontSize: 12)),
                            ],
                          ),
                        ),
                        const Icon(Icons.chevron_right_rounded, color: DashColors.textMuted),
                      ],
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

Widget _modalFrame(BuildContext ctx, {required String title, required double maxWidth, required Widget child, bool disableClose = false, double? maxHeight}) {
  return Dialog(
    backgroundColor: DashColors.card,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadii.md), side: const BorderSide(color: DashColors.border2)),
    child: ConstrainedBox(
      constraints: BoxConstraints(maxWidth: maxWidth, maxHeight: maxHeight ?? double.infinity),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(child: Text(title, style: const TextStyle(color: DashColors.textPrimary, fontSize: 17, fontWeight: FontWeight.w700))),
                IconButton(
                  onPressed: disableClose ? null : () => Navigator.of(ctx).pop(),
                  icon: const Icon(Icons.close_rounded, color: DashColors.textMuted, size: 20),
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),
            const SizedBox(height: 10),
            Flexible(child: child),
          ],
        ),
      ),
    ),
  );
}

Future<void> _showHelpCenterModal(BuildContext context) async {
  var query = '';
  var openIndex = -1;
  await showDialog<void>(
    context: context,
    barrierColor: DashColors.modalOverlay,
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setModalState) {
        final t = query.trim().toLowerCase();
        final filtered = t.isEmpty ? _faqItems : _faqItems.where((f) => f.$1.toLowerCase().contains(t) || f.$2.toLowerCase().contains(t)).toList();
        return _modalFrame(
          ctx,
          title: 'Centro de ayuda',
          maxWidth: 520,
          maxHeight: 560,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                onChanged: (v) => setModalState(() { query = v; openIndex = -1; }),
                style: const TextStyle(color: DashColors.textPrimary, fontSize: 13.5),
                decoration: const InputDecoration(hintText: 'Buscar en preguntas frecuentes…', prefixIcon: Icon(Icons.search_rounded, size: 18, color: DashColors.textMuted)),
              ),
              const SizedBox(height: 14),
              Flexible(
                child: filtered.isEmpty
                    ? const Padding(
                        padding: EdgeInsets.symmetric(vertical: 20),
                        child: Text('No encontramos resultados. Prueba con otra palabra o contacta a soporte.', textAlign: TextAlign.center, style: TextStyle(color: DashColors.textMuted, fontSize: 13)),
                      )
                    : ListView.separated(
                        shrinkWrap: true,
                        itemCount: filtered.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 8),
                        itemBuilder: (_, i) {
                          final item = filtered[i];
                          final isOpen = openIndex == i;
                          return GestureDetector(
                            onTap: () => setModalState(() => openIndex = isOpen ? -1 : i),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                              decoration: BoxDecoration(color: DashColors.surface, borderRadius: BorderRadius.circular(AppRadii.sm), border: Border.all(color: isOpen ? DashColors.border2 : DashColors.border)),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(children: [
                                    Expanded(child: Text(item.$1, style: const TextStyle(color: DashColors.textPrimary, fontSize: 13.5, fontWeight: FontWeight.w600))),
                                    Text(isOpen ? '–' : '+', style: const TextStyle(color: DashColors.blueLight, fontSize: 18)),
                                  ]),
                                  if (isOpen) ...[const SizedBox(height: 8), Text(item.$2, style: const TextStyle(color: DashColors.textSecondary, fontSize: 13, height: 1.5))],
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    ),
  );
}

Future<void> _showSupportModal(BuildContext context, {required bool isReport}) async {
  var tipo = 'error';
  var asunto = '';
  var mensaje = '';
  String? error;
  var sending = false;

  await showDialog<void>(
    context: context,
    barrierColor: DashColors.modalOverlay,
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setModalState) => _modalFrame(
        ctx,
        title: isReport ? 'Reportar un problema' : 'Contactar soporte',
        maxWidth: 500,
        disableClose: sending,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isReport ? 'Cuéntanos qué no funciona para poder corregirlo.' : 'Escríbenos y te responderemos al correo de tu cuenta.',
                style: const TextStyle(color: DashColors.textSecondary, fontSize: 13),
              ),
              const SizedBox(height: 14),
              if (isReport) ...[
                const Text('Tipo', style: TextStyle(color: DashColors.textPrimary, fontSize: 13, fontWeight: FontWeight.w500)),
                const SizedBox(height: 6),
                SettingsDropdown(expand: true, value: tipo, options: _reportTypes, onChanged: (v) => setModalState(() => tipo = v)),
                const SizedBox(height: 12),
              ],
              const Text('Asunto', style: TextStyle(color: DashColors.textPrimary, fontSize: 13, fontWeight: FontWeight.w500)),
              const SizedBox(height: 6),
              TextField(maxLength: 100, onChanged: (v) => setModalState(() => asunto = v), style: const TextStyle(color: DashColors.textPrimary, fontSize: 13.5), decoration: const InputDecoration(counterText: '')),
              const SizedBox(height: 12),
              Text(isReport ? '¿Qué pasó?' : 'Mensaje', style: const TextStyle(color: DashColors.textPrimary, fontSize: 13, fontWeight: FontWeight.w500)),
              const SizedBox(height: 6),
              TextField(maxLines: 4, maxLength: 500, onChanged: (v) => setModalState(() => mensaje = v), style: const TextStyle(color: DashColors.textPrimary, fontSize: 13.5), decoration: InputDecoration(counterText: '${mensaje.length}/500')),
              if (error != null) ...[
                const SizedBox(height: 6),
                Text(error!, style: const TextStyle(color: DashColors.red, fontSize: 12.5)),
              ],
              const SizedBox(height: 14),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton(
                    onPressed: sending ? null : () => Navigator.of(ctx).pop(),
                    style: OutlinedButton.styleFrom(foregroundColor: DashColors.textSecondary, backgroundColor: DashColors.surface, side: const BorderSide(color: DashColors.border2)),
                    child: const Text('Cancelar'),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton.icon(
                    onPressed: sending
                        ? null
                        : () async {
                            if (asunto.trim().length < 3) return setModalState(() => error = 'Escribe un asunto (mínimo 3 caracteres).');
                            if (mensaje.trim().length < 10) return setModalState(() => error = 'Cuéntanos un poco más (mínimo 10 caracteres).');
                            setModalState(() { error = null; sending = true; });
                            if (_simularSoporte) await Future<void>.delayed(const Duration(milliseconds: 900));
                            if (!ctx.mounted) return;
                            Navigator.of(ctx).pop();
                            if (context.mounted) {
                              showAppToast(context, isReport ? 'Reporte enviado. ¡Gracias por avisarnos!' : 'Mensaje enviado. Te responderemos pronto.');
                            }
                          },
                    icon: const Icon(Icons.send_rounded, size: 16),
                    label: Text(sending ? 'Enviando…' : (isReport ? 'Enviar reporte' : 'Enviar mensaje')),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

Future<void> _showVersionModal(BuildContext context) async {
  const rows = <(String, String)>[
    ('Aplicación', 'VolleyScan'),
    ('Versión', '2.4.1'),
    ('Build', '241'),
    ('Entorno', kReleaseMode ? 'Producción' : 'Desarrollo'),
  ];
  await showDialog<void>(
    context: context,
    barrierColor: DashColors.modalOverlay,
    builder: (ctx) => _modalFrame(
      ctx,
      title: 'Versión de la app',
      maxWidth: 380,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 0; i < rows.length; i++)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(border: i < rows.length - 1 ? const Border(bottom: BorderSide(color: DashColors.border)) : null),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(rows[i].$1, style: const TextStyle(color: DashColors.textMuted, fontSize: 13.5)),
                  Text(rows[i].$2, style: const TextStyle(color: DashColors.textPrimary, fontSize: 13.5, fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          const SizedBox(height: 18),
          Align(alignment: Alignment.centerRight, child: ElevatedButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cerrar'))),
        ],
      ),
    ),
  );
}
