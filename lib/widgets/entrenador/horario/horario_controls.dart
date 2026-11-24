import 'package:flutter/material.dart';

import '../../../theme/dash_colors.dart';
import 'horario_colors.dart';
import 'horario_model.dart';

BoxDecoration hBox(Color c, double r) => BoxDecoration(
      color: c,
      borderRadius: BorderRadius.circular(r),
      border: Border.all(color: HC.border),
    );

class CtrlBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const CtrlBtn({super.key, required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) => InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(color: HC.card2, borderRadius: BorderRadius.circular(8), border: Border.all(color: HC.border2)),
          child: Icon(icon, size: 16, color: HC.t2),
        ),
      );
}

class ViewBtn extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;
  const ViewBtn({super.key, required this.label, required this.active, required this.onTap});

  @override
  Widget build(BuildContext context) => InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
          decoration: BoxDecoration(
            gradient: active ? HC.activeGrad : null,
            color: active ? null : HC.card2,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: active ? Colors.transparent : HC.border2),
            boxShadow: active ? [BoxShadow(color: HC.purple.withValues(alpha: 0.35), blurRadius: 12)] : null,
          ),
          child: Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: active ? DashColors.textPrimary : HC.t2)),
        ),
      );
}

class EvBox extends StatelessWidget {
  final Color bg, border;
  final double radius, width;
  final EdgeInsets padding;
  final Widget child;
  const EvBox({
    super.key,
    required this.bg,
    required this.border,
    required this.radius,
    required this.padding,
    required this.child,
    this.width = 3,
  });

  @override
  Widget build(BuildContext context) => ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: DecoratedBox(
          decoration: BoxDecoration(color: bg, border: Border(left: BorderSide(color: border, width: width))),
          child: Padding(padding: padding, child: child),
        ),
      );
}

class CloseBtn extends StatelessWidget {
  final VoidCallback onTap;
  const CloseBtn({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) => InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(color: HC.card3, borderRadius: BorderRadius.circular(8)),
          child: const Icon(Icons.close, size: 14, color: HC.t2),
        ),
      );
}

class HorarioStatusBanner extends StatelessWidget {
  final bool loading;
  final String error;
  final VoidCallback onRetry;
  const HorarioStatusBanner({super.key, required this.loading, required this.error, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    if (error.isNotEmpty) {
      return Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: HC.orange.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(9),
          border: Border.all(color: HC.orange.withValues(alpha: 0.35)),
        ),
        child: Row(
          children: [
            Expanded(child: Text(error, style: const TextStyle(fontSize: 12.5, color: DashColors.warningText))),
            TextButton(
              onPressed: onRetry,
              child: const Text('Reintentar', style: TextStyle(fontSize: 12.5, color: HC.blue2, decoration: TextDecoration.underline)),
            ),
          ],
        ),
      );
    }
    if (loading) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Row(
          children: [
            Container(width: 8, height: 8, decoration: const BoxDecoration(shape: BoxShape.circle, color: HC.blue)),
            const SizedBox(width: 10),
            const Text('Cargando horario…', style: TextStyle(fontSize: 12.5, color: HC.t2)),
          ],
        ),
      );
    }
    return const SizedBox.shrink();
  }
}

/// Barra superior del calendario: ‹ › Hoy · Mes Año · Semana/Mes.
class CalendarControls extends StatelessWidget {
  final bool narrow;
  final DateTime current;
  final String view;
  final VoidCallback onPrev, onNext, onToday, onPickMonth;
  final ValueChanged<String> onView;

  const CalendarControls({
    super.key,
    required this.narrow,
    required this.current,
    required this.view,
    required this.onPrev,
    required this.onNext,
    required this.onToday,
    required this.onPickMonth,
    required this.onView,
  });

  @override
  Widget build(BuildContext context) {
    final left = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        CtrlBtn(icon: Icons.chevron_left, onTap: onPrev),
        const SizedBox(width: 6),
        CtrlBtn(icon: Icons.chevron_right, onTap: onNext),
        const SizedBox(width: 6),
        InkWell(
          onTap: onToday,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
            decoration: BoxDecoration(color: HC.card2, borderRadius: BorderRadius.circular(8), border: Border.all(color: HC.border2)),
            child: const Text('Hoy', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: HC.t1)),
          ),
        ),
      ],
    );

    final center = InkWell(
      onTap: onPickMonth,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('${kMonthNames[current.month - 1]} ${current.year}', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: HC.t1)),
            const SizedBox(width: 7),
            const Icon(Icons.keyboard_arrow_down, size: 16, color: HC.t1),
          ],
        ),
      ),
    );

    final right = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ViewBtn(label: 'Semana', active: view == 'semana', onTap: () => onView('semana')),
        const SizedBox(width: 6),
        ViewBtn(label: 'Mes', active: view == 'mes', onTap: () => onView('mes')),
      ],
    );

    return Container(
      padding: EdgeInsets.symmetric(horizontal: narrow ? 12 : 16, vertical: 10),
      decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: HC.border))),
      child: narrow
          ? Column(children: [Row(children: [left, const Spacer(), right]), const SizedBox(height: 6), center])
          : Row(children: [left, Expanded(child: Center(child: center)), right]),
    );
  }
}
