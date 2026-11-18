import 'package:flutter/material.dart';
import 'horario_colors.dart';
import 'horario_common_widgets.dart';
import 'horario_model.dart';

/// Selector de mes/año. Devuelve DateTime(año, mes, 1).
class MonthPickerDialog extends StatefulWidget {
  final int initialYear;
  final DateTime selected;
  const MonthPickerDialog({
    super.key,
    required this.initialYear,
    required this.selected,
  });

  @override
  State<MonthPickerDialog> createState() => _MonthPickerDialogState();
}

class _MonthPickerDialogState extends State<MonthPickerDialog> {
  late int _year = widget.initialYear;

  bool _isSel(int i) =>
      widget.selected.month == i + 1 && widget.selected.year == _year;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: HC.card2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: const BorderSide(color: HC.border2),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 320),
        child: Padding(
          padding: const EdgeInsets.all(26),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Seleccionar mes',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: HC.t1,
                      ),
                    ),
                  ),
                  CloseBtn(onTap: () => Navigator.pop(context)),
                ],
              ),
              const SizedBox(height: 20),
              GridView.count(
                crossAxisCount: 3,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
                childAspectRatio: 2.2,
                children: [
                  for (var i = 0; i < 12; i++)
                    InkWell(
                      onTap: () =>
                          Navigator.pop(context, DateTime(_year, i + 1, 1)),
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          gradient: _isSel(i)
                              ? const LinearGradient(
                                  colors: [HC.purpleG1, HC.purpleG2],
                                )
                              : null,
                          color: _isSel(i) ? null : HC.card3,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: HC.border),
                        ),
                        child: Text(
                          kMonthNames[i].substring(0, 3),
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                            color: _isSel(i) ? Colors.white : HC.t2,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CtrlBtn(
                    icon: Icons.chevron_left,
                    onTap: () => setState(() => _year--),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    '$_year',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: HC.t1,
                    ),
                  ),
                  const SizedBox(width: 12),
                  CtrlBtn(
                    icon: Icons.chevron_right,
                    onTap: () => setState(() => _year++),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
