import 'package:flutter/material.dart';

class ButtonUi extends StatelessWidget {
  final String value;
  final Color color;
  final Color textColor;
  final double borderRadius;
  final double fontSize;
  final Function() onClicked;
  final bool disabled;
  final double? height;

  const ButtonUi(
      {super.key,
      required this.value,
      this.color = const Color(0xFF03a9f4),
      this.textColor = const Color.fromARGB(255, 255, 255, 255),
      this.borderRadius = 10,
      this.fontSize = 15,
      required this.onClicked,
      this.height,
      this.disabled = false});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: height ?? 45,
      child: ElevatedButton(
        onPressed: disabled ? null : onClicked,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.all(0),
          backgroundColor: color,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
        ),
        child: Text(
          value,
          style: TextStyle(
            fontSize: fontSize,
            color: textColor,
            fontWeight: FontWeight.w400,
          ),
        ),
      ),
    );
  }
}
