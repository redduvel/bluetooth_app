import 'package:flutter/material.dart';

class TextInput extends StatefulWidget {
  final TextEditingController controller;
  final String hintText;
  final String labelText;
  final TextInputType? type;
  final IconData? icon;

  const TextInput({
    super.key,
    required this.controller,
    required this.hintText,
    required this.labelText,
    this.type,
    this.icon,
  });

  @override
  State<TextInput> createState() => _TextInputState();
}

class _TextInputState extends State<TextInput> {
  bool valid = true;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: widget.controller,
      onChanged: (value) => setState(() {
        valid = true;
      }),
      onSubmitted: (value) => setState(() {
        valid = value.isNotEmpty;
      }),
      keyboardType: widget.type,
      style: const TextStyle(
        fontSize: 14
      ),
      decoration: InputDecoration(
        icon: widget.icon != null ? Icon(widget.icon) : null,
        errorText: !valid ? 'Обязательное поле' : null,
        label: Text(widget.labelText),
        hintText: widget.hintText,
        
        labelStyle: const TextStyle(
          fontSize: 14
        ),
        hintStyle: const TextStyle(
          fontSize: 12
        ),
        errorStyle: const TextStyle(
          fontSize: 12
        )
      ),
    );
  }
}
