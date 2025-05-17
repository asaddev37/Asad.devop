import 'package:flutter/material.dart';

class InputField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final Function(String) onChanged;
  final String? Function(String?)? validator;
  final TextStyle? labelStyle; // Added for dynamic label color
  final Color? fillColor; // Added for dynamic fill color
  final Color? borderColor; // Added for dynamic border color
  final TextStyle? style; // Added for dynamic input text color
  final Color? cursorColor; // Added for dynamic cursor color

  const InputField({
    super.key,
    required this.label,
    required this.controller,
    required this.onChanged,
    this.validator,
    this.labelStyle,
    this.fillColor,
    this.borderColor,
    this.style,
    this.cursorColor,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: labelStyle ?? TextStyle(color: Colors.green),
        filled: true,
        fillColor: fillColor ?? Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: borderColor ?? Colors.green, width: 2),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      onChanged: onChanged,
      validator: validator,
      keyboardType: TextInputType.numberWithOptions(decimal: true),
      style: style ?? TextStyle(color: Colors.black), // Default to black if not provided
      cursorColor: cursorColor ?? Colors.green, // Default to green if not provided
    );
  }
}