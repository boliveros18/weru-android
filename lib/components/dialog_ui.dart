import 'package:flutter/material.dart';
import 'package:weru/components/text_field_ui.dart';

class DialogUi extends StatelessWidget {
  final String title;
  final String hintText;
  final bool textField;
  final bool cancel;
  final Function(String) onConfirm;

  const DialogUi({
    super.key,
    required this.title,
    this.hintText = "",
    this.cancel = true,
    this.textField = true,
    required this.onConfirm,
  });

  static Future<void> show({
    required BuildContext context,
    required String title,
    String hintText = "",
    bool textField = true,
    bool cancel = true,
    required Function(String) onConfirm,
  }) async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black12,
      builder: (BuildContext context) {
        return DialogUi(
          title: title,
          hintText: hintText,
          textField: textField,
          cancel: cancel,
          onConfirm: (value) {
            onConfirm(value);
            Navigator.of(context).pop();
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final TextEditingController textController = TextEditingController();

    return AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
      ),
      title: Text(
        title,
        style: const TextStyle(fontSize: 16),
      ),
      content: textField
          ? SizedBox(
              width: 200,
              child: TextFieldUi(
                hint: hintText,
                controller: textController,
                regular: false,
              ),
            )
          : null,
      actions: [
        ElevatedButton(
          onPressed: () {
            if (textField) {
              if (textController.text.isNotEmpty) {
                onConfirm(textController.text);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Por favor, ingrese un valor!")),
                );
              }
            } else {
              onConfirm("id");
            }
            FocusScope.of(context).unfocus();
          },
          child: const Text("Aceptar"),
        ),
        textField && cancel
            ? ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  FocusScope.of(context).unfocus();
                },
                child: const Text("Cancelar"),
              )
            : Container(),
      ],
    );
  }
}
