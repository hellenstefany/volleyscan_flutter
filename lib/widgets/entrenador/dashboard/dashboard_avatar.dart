import 'package:flutter/material.dart';

class DashboardAvatar extends StatelessWidget {
  final String text;
  final Color bg;
  final double size;
  final double fontSize;

  const DashboardAvatar({
    super.key,
    required this.text,
    required this.bg,
    required this.size,
    required this.fontSize,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
      child: Text(
        text,
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
      ),
    );
  }
}
