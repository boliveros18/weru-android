import 'package:flutter/material.dart';

class TextFieldUi extends StatefulWidget {
  final String hint;
  final bool prefixIcon;
  final String? prefixIconPath;
  final int minLines;
  final TextEditingController? controller;
  final Function(String)? onChanged;
  final bool regular;
  final bool pass;
  final bool isNumeric;

  const TextFieldUi({
    super.key,
    required this.hint,
    this.prefixIcon = false,
    this.prefixIconPath,
    this.minLines = 1,
    this.controller,
    this.onChanged,
    this.regular = true,
    this.pass = false,
    this.isNumeric = false,
  });

  @override
  _TextFieldUiState createState() => _TextFieldUiState();
}

class _TextFieldUiState extends State<TextFieldUi> {
  bool _obscureText = true;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.pass;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(boxShadow: [
        BoxShadow(
          color: widget.regular
              ? const Color(0xff1D1617)
              : const Color(0xff1D1617).withValues(alpha: 0.11),
          blurRadius: widget.regular ? 0 : 20,
          spreadRadius: 0.0,
        ),
      ]),
      child: TextField(
        controller: widget.controller,
        onChanged: widget.onChanged,
        maxLines: widget.pass ? 1 : null,
        minLines: widget.pass ? 1 : widget.minLines,
        obscureText: widget.pass ? _obscureText : false,
        keyboardType:
            widget.isNumeric ? TextInputType.number : TextInputType.text,
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.only(left: 12, right: 20),
          hintText: widget.hint,
          hintStyle: const TextStyle(
              color: Color.fromARGB(255, 180, 180, 180),
              fontSize: 15,
              fontWeight: FontWeight.w300),
          prefixIcon: widget.prefixIcon && widget.prefixIconPath != null
              ? Padding(
                  padding: const EdgeInsets.all(12),
                  child: Transform.scale(
                    scale: 0.8,
                    child: Image.asset(
                      widget.prefixIconPath!,
                      fit: BoxFit.contain,
                    ),
                  ),
                )
              : null,
          suffixIcon: widget.pass
              ? IconButton(
                  icon: Icon(
                    _obscureText ? Icons.visibility_off : Icons.visibility,
                    color: Colors.grey,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscureText = !_obscureText;
                    });
                  },
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(widget.regular ? 0 : 10),
            borderSide: widget.regular ? const BorderSide() : BorderSide.none,
          ),
        ),
      ),
    );
  }
}
