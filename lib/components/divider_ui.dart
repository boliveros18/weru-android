import 'package:flutter/material.dart';

class DividerUi extends StatelessWidget {
  final double paddingHorizontal;
  final Color? color;

  const DividerUi(
      {super.key,
      this.paddingHorizontal = 10,
      this.color = const Color.fromARGB(255, 224, 224, 224)});

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: paddingHorizontal),
            child: Divider(
              color: color,
              thickness: 1.0,
              height: 0,
            ),
          ),
        ],
      ),
    );
  }
}
