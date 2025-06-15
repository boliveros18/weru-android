import 'package:flutter/material.dart';

class ProgressIndicatorUi extends StatefulWidget {
  const ProgressIndicatorUi({super.key});

  @override
  State<ProgressIndicatorUi> createState() => _ProgressIndicatorState();
}

class _ProgressIndicatorState extends State<ProgressIndicatorUi>
    with TickerProviderStateMixin {
  late AnimationController controller;

  @override
  void initState() {
    controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..addListener(() {
        setState(() {});
      });
    controller.repeat(reverse: false);
    super.initState();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Center(
        child: CircularProgressIndicator(
          value: controller.value,
          strokeWidth: 3.0,
        ),
      ),
    );
  }
}

void showLoadingDialog(BuildContext context) {
  showDialog(
    context: context,
    barrierDismissible: true,
    builder: (BuildContext context) {
      return const ProgressIndicatorUi();
    },
  );
}

void hideLoadingDialog(BuildContext context) {
  Navigator.of(context).pop();
}
