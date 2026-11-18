import 'package:flutter/material.dart';

import '../../../theme/dash_colors.dart';

int _toInt(dynamic value, [int fallback = 0]) {
  if (value == null) return fallback;
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value.toString()) ?? fallback;
}

String _toStr(dynamic value, [String fallback = '']) {
  if (value == null) return fallback;
  return value.toString();
}

/// Evento próximo dentro de los 7 días siguientes (`eventos_proximos` en `GET /api/panel/dashboard`).
class EntrenadorEventoProximo {
  final int id;
  final String titulo;
  final String tipoEvento;
  final String fecha;
  final String horaInicio;
  final String horaFin;
  final String? ubicacion;

  const EntrenadorEventoProximo({
    required this.id,
    required this.titulo,
    required this.tipoEvento,
    required this.fecha,
    required this.horaInicio,
    required this.horaFin,
    this.ubicacion,
  });

  factory EntrenadorEventoProximo.fromJson(Map<String, dynamic> json) {
    final rawUbicacion = json['ubicacion']?.toString().trim();
    return EntrenadorEventoProximo(
      id: _toInt(json['id']),
      titulo: _toStr(json['titulo']),
      tipoEvento: _toStr(json['tipo_evento']),
      fecha: _toStr(json['fecha']),
      horaInicio: _toStr(json['hora_inicio']),
      horaFin: _toStr(json['hora_fin']),
      ubicacion:
          (rawUbicacion != null && rawUbicacion.isNotEmpty) ? rawUbicacion : null,
    );
  }

  /// Devuelve `HH:MM` igual que `String(ev.hora_inicio).slice(0, 5)` en `page.jsx`.
  String get horaInicioCorta =>
      horaInicio.length >= 5 ? horaInicio.substring(0, 5) : horaInicio;
}

/// Partido reciente del entrenador (`ultimos_partidos` en `GET /api/panel/dashboard`).
class EntrenadorUltimoPartido {
  final int id;
  final String rival;
  final String fecha;
  final int setsGanados;
  final int setsPerdidos;

  const EntrenadorUltimoPartido({
    required this.id,
    required this.rival,
    required this.fecha,
    required this.setsGanados,
    required this.setsPerdidos,
  });

  factory EntrenadorUltimoPartido.fromJson(Map<String, dynamic> json) {
    return EntrenadorUltimoPartido(
      id: _toInt(json['id']),
      rival: _toStr(json['rival']),
      fecha: _toStr(json['fecha']),
      setsGanados: _toInt(json['sets_ganados']),
      setsPerdidos: _toInt(json['sets_perdidos']),
    );
  }

  /// Porcentaje de sets ganados: `totalSets > 0 ? Math.round((sets_ganados / totalSets) * 100) : 0`.
  int get porcentajeSets {
    final total = setsGanados + setsPerdidos;
    if (total <= 0) return 0;
    return ((setsGanados / total) * 100).round();
  }

  /// Iniciales del rival (`p.rival.slice(0, 2).toUpperCase() || 'VS'`).
  String get iniciales {
    final limpio = rival.trim();
    if (limpio.isEmpty) return 'VS';
    return (limpio.length >= 2 ? limpio.substring(0, 2) : limpio).toUpperCase();
  }
}

/// Respuesta completa de `GET /api/panel/dashboard` (`DashboardView` en Django).
class EntrenadorDashboardData {
  final int equiposActivos;
  final int deportistasActivos;
  final int analisisPendientes;
  final List<EntrenadorEventoProximo> eventosProximos;
  final List<EntrenadorUltimoPartido> ultimosPartidos;

  const EntrenadorDashboardData({
    required this.equiposActivos,
    required this.deportistasActivos,
    required this.analisisPendientes,
    required this.eventosProximos,
    required this.ultimosPartidos,
  });

  factory EntrenadorDashboardData.fromJson(Map<String, dynamic> json) {
    final rawEventos = json['eventos_proximos'];
    final rawPartidos = json['ultimos_partidos'];
    return EntrenadorDashboardData(
      equiposActivos: _toInt(json['equipos_activos']),
      deportistasActivos: _toInt(json['deportistas_activos']),
      analisisPendientes: _toInt(json['analisis_pendientes']),
      eventosProximos: rawEventos is List
          ? rawEventos
              .whereType<Map>()
              .map(
                (m) => EntrenadorEventoProximo.fromJson(
                  Map<String, dynamic>.from(m),
                ),
              )
              .toList()
          : const <EntrenadorEventoProximo>[],
      ultimosPartidos: rawPartidos is List
          ? rawPartidos
              .whereType<Map>()
              .map(
                (m) => EntrenadorUltimoPartido.fromJson(
                  Map<String, dynamic>.from(m),
                ),
              )
              .toList()
          : const <EntrenadorUltimoPartido>[],
    );
  }
}

/// Modelo para una tarjeta KPI en la cuadrícula superior.
class DashboardKpi {
  final Color color;
  final String icon;
  final String label;
  final int value;
  final String suffix;
  final String? sub;

  const DashboardKpi(
    this.color,
    this.icon,
    this.label,
    this.value,
    this.suffix, {
    this.sub,
  });
}

/// Paleta cíclica de colores por fila en "Últimos partidos" (`COLORES_FILA` en `page.jsx`),
/// expresada con tokens existentes de `DashColors`.
const List<(Color color, Color bg)> dashboardRowPalette = [
  (DashColors.sidebarLogoBlue, DashColors.blueGlow),
  (DashColors.green, DashColors.greenGlow),
  (DashColors.accentYellow, DashColors.cardHover),
  (DashColors.purple, DashColors.sidebarActiveStart),
  (DashColors.red, DashColors.dangerOutlineBorder),
];

/// Choices de `tipo_evento` del modal "Nueva Sesión" (`POST /api/panel/horarios`).
const List<(String value, String label)> dashboardTipoEventoOptions = [
  ('entrenamiento', 'Entrenamiento'),
  ('partido', 'Partido'),
  ('evaluacion', 'Evaluación'),
  ('reunion', 'Reunión'),
  ('otro', 'Otro'),
];
