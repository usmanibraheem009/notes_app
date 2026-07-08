import 'package:flutter/material.dart';

class InputField extends StatelessWidget {
  const InputField(
      {super.key,
      required this.hintText,
      this.labelText,
      required this.controller,
      required this.keyboardType,
      required this.prefixIcon,
      this.obsecureText = false,
      this.maxLines = 1,
      this.validator,
      this.textCapitalization = TextCapitalization.words});

  final String hintText;
  final String? labelText;
  final TextEditingController controller;
  final TextInputType keyboardType;
  final IconData prefixIcon;
  final bool obsecureText;
  final int maxLines;
  final FormFieldValidator<String>? validator;
  final TextCapitalization textCapitalization;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return TextFormField(
      maxLines: maxLines,
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obsecureText,
      cursorColor: scheme.onPrimary,
      style: TextStyle(color: scheme.onPrimary),
      textCapitalization: textCapitalization,
      decoration: InputDecoration(
          hintText: hintText,
          labelText: labelText,
          labelStyle: TextStyle(color: scheme.onPrimary),
          hintStyle: TextStyle(color: scheme.onPrimary),
          filled: true,
          fillColor: scheme.surface,
          prefixIcon: Icon(prefixIcon),
          prefixIconColor: scheme.onPrimary,
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                color: scheme.onSurface,
                width: 1,
              )),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(
                  color: scheme.onSurface,

                )
              )),
      validator: validator,
    );
  }
}
