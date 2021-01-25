import 'package:flutter/material.dart';

class CustomInputField extends StatelessWidget {

  CustomInputField({this.textController, this.textInputType, this.hintText, this.obscureText });

  final TextEditingController textController;
  final TextInputType textInputType;
  final String hintText;
  final obscureText;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: textController,
      obscureText: obscureText,
      keyboardType: textInputType,
      decoration: InputDecoration(
          border: InputBorder.none,
          hintText: hintText,
          fillColor: Colors.grey[200],
          filled: true
      ),
    );
  }
}

