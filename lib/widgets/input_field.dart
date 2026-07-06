import 'package:flutter/material.dart';

class InputField extends StatelessWidget {
  const InputField(
      {super.key,
      required this.hintText,
      required this.labelText,
      required this.controller,
      required this.keyboardType,
      required this.prefixIcon,
      this.obsecureText = false,
      this.maxLines = 1,
      this.validator,
      this.textCapitalization = TextCapitalization.words});

  final String hintText;
  final String labelText;
  final TextEditingController controller;
  final TextInputType keyboardType;
  final IconData prefixIcon;
  final bool obsecureText;
  final int maxLines;
  final FormFieldValidator<String>? validator;
  final TextCapitalization textCapitalization;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      maxLines: maxLines,
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obsecureText,
      textCapitalization: textCapitalization,
      decoration: InputDecoration(
          hintText: hintText,
          labelText: labelText,
          prefixIcon: Icon(prefixIcon),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                color: Colors.black,
                width: 2,
              ))),
      validator: validator,
    );
  }
}
