import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:weru/pages/briefcase.dart';
import 'package:weru/provider/session.dart';
import 'package:provider/provider.dart';

class MenuOption {
  final int value;
  final String label;
  final IconData? icon;
  final bool iconToEnd;

  MenuOption({
    required this.value,
    required this.label,
    this.icon,
    this.iconToEnd = false,
  });
}

class AppBarUi extends StatefulWidget implements PreferredSizeWidget {
  final String header;
  final bool prefixIcon;
  final double prefixIconHeight;
  final double prefixIconWidth;
  final String prefixIconPath;
  final bool menuIcon;
  final bool centerTitle;

  const AppBarUi({
    super.key,
    this.header = "",
    this.prefixIcon = false,
    this.prefixIconHeight = 15,
    this.prefixIconWidth = 15,
    this.prefixIconPath = "",
    this.menuIcon = false,
    this.centerTitle = true,
  });

  @override
  _AppBarUiState createState() => _AppBarUiState();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _AppBarUiState extends State<AppBarUi> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Row(
        children: [
          if (widget.prefixIcon)
            SvgPicture.asset(
              widget.prefixIconPath,
              width: widget.prefixIconWidth,
              height: widget.prefixIconHeight,
            ),
          if (widget.prefixIcon) const SizedBox(width: 10),
          Text(
            widget.header,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 18,
              fontWeight: FontWeight.normal,
            ),
          ),
        ],
      ),
      backgroundColor: Colors.white,
      elevation: 0.0,
      centerTitle: widget.centerTitle,
      actions: widget.menuIcon
          ? [
              GestureDetector(
                onTap: () {
                  _showMenu(context);
                },
                child: Container(
                  margin: const EdgeInsets.all(10),
                  alignment: Alignment.center,
                  width: 37,
                  decoration: BoxDecoration(
                    color: const Color(0xffF7F8F8),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: SvgPicture.asset(
                    'assets/icons/ellipsis-vertical-solid.svg',
                    height: 20,
                    width: 20,
                  ),
                ),
              ),
            ]
          : null,
    );
  }

  void _showMenu(BuildContext context) async {
    Session session = Provider.of<Session>(context, listen: false);
    List<MenuOption> menuOptions = [
      MenuOption(value: 1, label: 'Maletín'),
      MenuOption(value: 2, label: 'Buscar'),
      MenuOption(value: 3, label: 'Versión: 1.0'),
      MenuOption(
          value: 4,
          label: 'Cerrar sesión',
          icon: Icons.login_outlined,
          iconToEnd: true),
    ];

    final selectedValue = await showMenu<int>(
      context: context,
      position: RelativeRect.fromDirectional(
        textDirection: TextDirection.rtl,
        start: 50,
        end: 100,
        top: 50,
        bottom: 0,
      ),
      items: menuOptions
          .map(
            (option) => PopupMenuItem<int>(
              value: option.value,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (!option.iconToEnd) ...[
                    if (option.icon != null) Icon(option.icon),
                  ],
                  Text(
                    option.label,
                    style: const TextStyle(color: Colors.black),
                  ),
                  if (option.iconToEnd) ...[
                    if (option.icon != null) Icon(option.icon),
                  ],
                ],
              ),
            ),
          )
          .toList(),
      elevation: 8,
      color: Colors.white,
      constraints: const BoxConstraints(
        minWidth: 160,
        maxWidth: 160,
      ),
    );

    if (selectedValue != null) {
      switch (selectedValue) {
        case 1:
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const BriefcasePage(),
            ),
          );
          break;
        case 2:
          break;
        case 3:
          break;
        case 4:
          await session.logout();
          break;
      }
    }
  }
}
