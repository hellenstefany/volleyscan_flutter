import 'package:flutter/material.dart';

import '../../../theme/app_theme.dart';
import 'gestion_athlete.dart';
import 'gestion_colors.dart';
import 'gestion_common_widgets.dart';

/// Tarjeta individual de un deportista (`.card` en `page.jsx` / `deportistas.module.css`).
class DeportistaCard extends StatelessWidget {
  final EntrenadorDeportista atleta;
  final bool confirmandoRetiro;
  final bool busy;
  final VoidCallback onVerAnalisis;
  final VoidCallback onPedirRetirar;
  final VoidCallback onCancelarRetiro;
  final VoidCallback onConfirmarRetiro;

  const DeportistaCard({
    super.key,
    required this.atleta,
    required this.confirmandoRetiro,
    required this.busy,
    required this.onVerAnalisis,
    required this.onPedirRetirar,
    required this.onCancelarRetiro,
    required this.onConfirmarRetiro,
  });

  @override
  Widget build(BuildContext context) {
    final ia = atleta.ia;
    final sinRevisar = ia?.sinRevisar ?? 0;
    final verLabel = sinRevisar > 0
        ? 'Ver análisis · $sinRevisar sin revisar'
        : 'Ver análisis';

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: AppGradients.coachCardBg,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: GestionColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── .cardHead ──
          Row(
            children: [
              DeportistaAvatar(atleta: atleta, size: 60),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      atleta.nombreCompleto,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 17.2,
                        fontWeight: FontWeight.w700,
                        color: GestionColors.text,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      atleta.email,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 13.4,
                        color: GestionColors.muted,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // ── <Chips a={a} /> ──
          DeportistaChips(atleta: atleta),
          const SizedBox(height: 12),
          // ── <Perfil a={a} /> ──
          DeportistaPerfilGrid(atleta: atleta),
          const SizedBox(height: 12),
          // ── .ia ──
          Container(
            constraints: const BoxConstraints(minHeight: 66),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: GestionColors.card2,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: GestionColors.border),
            ),
            child: ia != null
                ? Row(
                    children: [
                      DeportistaScoreRing(
                        valor: ia.promedio,
                        size: 48,
                        sinDato: ia.promedio == null,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              'Práctica con IA',
                              style: TextStyle(
                                fontSize: 14.4,
                                fontWeight: FontWeight.w700,
                                color: GestionColors.text,
                              ),
                            ),
                            Text(
                              '${ia.sesiones} ${ia.sesiones == 1 ? 'sesión' : 'sesiones'}'
                              '${(ia.mejor != null && ia.promedio != null) ? ' · mejor ${ia.mejor}' : ''}',
                              style: const TextStyle(
                                fontSize: 13.2,
                                color: GestionColors.muted,
                              ),
                            ),
                            Text(
                              'Última: ${formatFechaCortaDeportista(ia.ultimaSesion)}',
                              style: const TextStyle(
                                fontSize: 13.2,
                                color: GestionColors.muted,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  )
                : const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Aún no ha practicado con la IA.',
                      style: TextStyle(
                        fontSize: 13.4,
                        color: GestionColors.muted,
                      ),
                    ),
                  ),
          ),
          const SizedBox(height: 12),
          // ── Botón "Ver análisis" ──
          InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: onVerAnalisis,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                gradient: AppGradients.coachPrimaryBtn,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                verLabel,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          // ── .cardPie ──
          Container(
            padding: const EdgeInsets.only(top: 10),
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: GestionColors.border)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    'Contigo desde ${formatFechaCortaDeportista(atleta.desde)}',
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13.2,
                      color: GestionColors.muted,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                if (confirmandoRetiro)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        '¿Retirar?',
                        style: TextStyle(
                          fontSize: 13.2,
                          color: GestionColors.text2,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Opacity(
                        opacity: busy ? 0.5 : 1,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(10),
                          onTap: busy ? null : onConfirmarRetiro,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: GestionColors.orange,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Text(
                              'Sí',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: GestionColors.bg,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      InkWell(
                        borderRadius: BorderRadius.circular(10),
                        onTap: busy ? null : onCancelarRetiro,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: GestionColors.card,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: GestionColors.border),
                          ),
                          child: const Text(
                            'No',
                            style: TextStyle(
                              fontSize: 13,
                              color: GestionColors.text2,
                            ),
                          ),
                        ),
                      ),
                    ],
                  )
                else
                  InkWell(
                    onTap: onPedirRetirar,
                    child: const Text(
                      'Retirar',
                      style: TextStyle(
                        fontSize: 13.2,
                        color: GestionColors.muted,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
