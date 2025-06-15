import 'package:flutter/material.dart';
import 'package:weru/components/text_ui.dart';

class MenuItemUi extends StatelessWidget {
  final String title;
  final String IconPath;
  final Widget page;

  const MenuItemUi(
      {super.key,
      required this.IconPath,
      required this.title,
      required this.page});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => page,
          ),
        );
      },
      child: SizedBox(
        height: 90,
        width: 90,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: Colors.grey,
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Transform.scale(
                scale: 0.7,
                child: Image.asset(
                  IconPath,
                  fit: BoxFit.contain,
                ),
              ),
              TextUi(
                text: title,
                fontSize: 10,
                main: true,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
