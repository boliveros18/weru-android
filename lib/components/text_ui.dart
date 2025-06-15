import 'package:flutter/material.dart';

class TextUi extends StatelessWidget {
  final String text;
  final Color? color;
  final double? fontSize;
  final bool main;
  final num? long;

  const TextUi(
      {super.key,
      required this.text,
      this.color,
      this.main = false,
      this.fontSize = 13,
      this.long = 32});

  @override
  Widget build(BuildContext context) {
    final truncatedText = (text.length > long!)
        ? '${text.substring(0, int.parse(long.toString()))}'
        : text;

    final parts = truncatedText.split(': ');
    final boldText =
        parts.isNotEmpty ? '${parts.first} ${main ? "" : ":"} ' : '';
    final normalText = parts.length > 1 ? parts.sublist(1).join(': ') : '';

    return Text.rich(
      TextSpan(
        children: [
          TextSpan(
            text: boldText,
            style: TextStyle(
              fontWeight: FontWeight.w400,
              color: color ?? const Color.fromARGB(255, 0, 45, 168),
              fontSize: fontSize,
            ),
          ),
          TextSpan(
            text: normalText,
            style: TextStyle(
              fontWeight: FontWeight.w300,
              color: color ?? const Color.fromARGB(255, 95, 87, 89),
              fontSize: fontSize,
            ),
          ),
        ],
      ),
      maxLines: 1,
      textAlign: TextAlign.center,
    );
  }
}
