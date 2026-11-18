import 'package:flutter/material.dart';

import '../../../theme/app_theme.dart';
import 'gestion_athlete.dart';
import 'gestion_colors.dart';
import 'gestion_common_widgets.dart';

/// Cabecera de Deportistas (`.head` y `.contadores` en `deportistas.module.css`)
/// + sección de Solicitudes pendientes (`.solicitudes` / `.solicitud`)
/// + barra de búsqueda y pills de posición (`.filtros` y `.pills`).
class DeportistasHeaderAndFilters extends StatelessWidget {
  final int totalDeportistas;
  final int totalSolicitudes;
  final bool mostrarContadores;
  final TextEditingController searchCtrl;
  final String posicionSeleccionada;
  final ValueChanged<String> onPosicionChanged;

  const DeportistasHeaderAndFilters({
    super.key,
    required this.totalDeportistas,
    required this.totalSolicitudes,
    required this.mostrarContadores,
    required this.searchCtrl,
    required this.posicionSeleccionada,
    required this.onPosicionChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Wrap(
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.end,
          spacing: 16,
          runSpacing: 16,
          children: [
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 680),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'PANEL DEL ENTRENADOR',
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.6,
                      color: GestionColors.blueLight,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Deportistas',
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.5,
                      color: GestionColors.text,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Los atletas que te eligieron como entrenador, con su perfil y su práctica con la IA.',
                    style: TextStyle(
                      fontSize: 14,
                      color: GestionColors.muted,
                    ),
                  ),
                ],
              ),
            ),
            if (mostrarContadores)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _ContadorCard(
                    valor: totalDeportistas,
                    label: 'DEPORTISTAS',
                    aviso: false,
                  ),
                  const SizedBox(width: 10),
                  _ContadorCard(
                    valor: totalSolicitudes,
                    label: 'SOLICITUDES',
                    aviso: totalSolicitudes > 0,
                  ),
                ],
              ),
          ],
        ),
      ],
    );
  }
}

class _ContadorCard extends StatelessWidget {
  final int valor;
  final String label;
  final bool aviso;

  const _ContadorCard({
    required this.valor,
    required this.label,
    required this.aviso,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minWidth: 110),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
      decoration: BoxDecoration(
        gradient: AppGradients.coachCardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: aviso
              ? GestionColors.orange.withValues(alpha: 0.55)
              : GestionColors.border,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$valor',
            style: TextStyle(
              fontSize: 27,
              fontWeight: FontWeight.w700,
              height: 1.1,
              color: aviso ? GestionColors.orange : GestionColors.text,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11.5,
              letterSpacing: 0.9,
              color: GestionColors.muted,
            ),
          ),
        ],
      ),
    );
  }
}

/// Bloque de "Solicitudes pendientes" (`.solicitudes` en `page.jsx`).
class DeportistasSolicitudesSection extends StatelessWidget {
  final List<EntrenadorDeportista> solicitudes;
  final int? ocupadoVinculoId;
  final void Function(EntrenadorDeportista atleta, String accion) onResponder;

  const DeportistasSolicitudesSection({
    super.key,
    required this.solicitudes,
    required this.ocupadoVinculoId,
    required this.onResponder,
  });

  @override
  Widget build(BuildContext context) {
    if (solicitudes.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(bottom: 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'Solicitudes pendientes',
                style: TextStyle(
                  fontSize: 18.4,
                  fontWeight: FontWeight.w700,
                  color: GestionColors.text,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: GestionColors.orange.withValues(alpha: 0.20),
                  borderRadius: BorderRadius.circular(99),
                ),
                child: Text(
                  '${solicitudes.length}',
                  style: const TextStyle(
                    fontSize: 12.8,
                    fontWeight: FontWeight.w700,
                    color: GestionColors.orange,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          const Text(
            'Estos atletas te eligieron. Acepta para que aparezcan en tu lista.',
            style: TextStyle(fontSize: 14, color: GestionColors.muted),
          ),
          const SizedBox(height: 14),
          for (var i = 0; i < solicitudes.length; i++)
            Padding(
              padding: EdgeInsets.only(
                bottom: i == solicitudes.length - 1 ? 0 : 12,
              ),
              child: _SolicitudTile(
                atleta: solicitudes[i],
                busy: ocupadoVinculoId == solicitudes[i].vinculoId,
                onAceptar: () => onResponder(solicitudes[i], 'aceptar'),
                onRechazar: () => onResponder(solicitudes[i], 'rechazar'),
              ),
            ),
        ],
      ),
    );
  }
}

class _SolicitudTile extends StatelessWidget {
  final EntrenadorDeportista atleta;
  final bool busy;
  final VoidCallback onAceptar;
  final VoidCallback onRechazar;

  const _SolicitudTile({
    required this.atleta,
    required this.busy,
    required this.onAceptar,
    required this.onRechazar,
  });

  @override
  Widget build(BuildContext context) {
    final narrow = MediaQuery.of(context).size.width < 600;

    final actions = Row(
      mainAxisSize: narrow ? MainAxisSize.max : MainAxisSize.min,
      children: [
        Expanded(
          flex: narrow ? 1 : 0,
          child: Opacity(
            opacity: busy ? 0.5 : 1,
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: busy ? null : onAceptar,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 9,
                ),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  gradient: AppGradients.coachPrimaryBtn,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'Aceptar',
                  style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          flex: narrow ? 1 : 0,
          child: Opacity(
            opacity: busy ? 0.5 : 1,
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: busy ? null : onRechazar,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 9,
                ),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: GestionColors.card,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: GestionColors.border),
                ),
                child: const Text(
                  'Rechazar',
                  style: TextStyle(
                    fontSize: 13.5,
                    color: GestionColors.text2,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            GestionColors.orange.withValues(alpha: 0.08),
            GestionColors.card,
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: GestionColors.orange.withValues(alpha: 0.35),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DeportistaAvatar(atleta: atleta, size: 56),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      atleta.nombreCompleto,
                      style: const TextStyle(
                        fontSize: 16.8,
                        fontWeight: FontWeight.w700,
                        color: GestionColors.text,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${atleta.email} · pidió el ${formatFechaCortaDeportista(atleta.solicitadoEn)}',
                      style: const TextStyle(
                        fontSize: 13.4,
                        color: GestionColors.muted,
                      ),
                    ),
                    const SizedBox(height: 6),
                    DeportistaChips(atleta: atleta),
                    const SizedBox(height: 8),
                    DeportistaPerfilGrid(atleta: atleta),
                  ],
                ),
              ),
              if (!narrow) ...[
                const SizedBox(width: 16),
                actions,
              ],
            ],
          ),
          if (narrow) ...[
            const SizedBox(height: 12),
            actions,
          ],
        ],
      ),
    );
  }
}

/// Barra de búsqueda y pills de posición (`.filtros` y `.pills` en `page.jsx`).
class DeportistasFilterBar extends StatelessWidget {
  final TextEditingController searchCtrl;
  final String posicionSeleccionada;
  final ValueChanged<String> onPosicionChanged;

  const DeportistasFilterBar({
    super.key,
    required this.searchCtrl,
    required this.posicionSeleccionada,
    required this.onPosicionChanged,
  });

  @override
  Widget build(BuildContext context) {
    final narrow = MediaQuery.of(context).size.width < 560;

    final searchBox = SizedBox(
      width: narrow ? double.infinity : 260,
      child: TextField(
        controller: searchCtrl,
        style: const TextStyle(fontSize: 14, color: GestionColors.text),
        decoration: InputDecoration(
          isDense: true,
          filled: true,
          fillColor: GestionColors.card,
          hintText: 'Buscar por nombre…',
          hintStyle: const TextStyle(
            fontSize: 14,
            color: GestionColors.muted,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 11,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: GestionColors.border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(
              color: GestionColors.blue,
              width: 1.5,
            ),
          ),
        ),
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (narrow) ...[
          const Text(
            'Mis deportistas',
            style: TextStyle(
              fontSize: 18.4,
              fontWeight: FontWeight.w700,
              color: GestionColors.text,
            ),
          ),
          const SizedBox(height: 10),
          searchBox,
        ] else
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Mis deportistas',
                style: TextStyle(
                  fontSize: 18.4,
                  fontWeight: FontWeight.w700,
                  color: GestionColors.text,
                ),
              ),
              searchBox,
            ],
          ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final pos in kDeportistaPosiciones)
              _PositionPill(
                label: pos.$2,
                active: posicionSeleccionada == pos.$1,
                onTap: () => onPosicionChanged(pos.$1),
              ),
          ],
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}

class _PositionPill extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;

  const _PositionPill({
    required this.label,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(99),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: active
              ? GestionColors.blue.withValues(alpha: 0.18)
              : GestionColors.card,
          borderRadius: BorderRadius.circular(99),
          border: Border.all(
            color: active ? GestionColors.blue : GestionColors.border,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13.7,
            color: active ? Colors.white : GestionColors.text2,
          ),
        ),
      ),
    );
  }
}
