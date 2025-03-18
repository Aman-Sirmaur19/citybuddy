import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  const CustomTextField({
    super.key,
    required this.controller,
    required this.keyboardType,
    this.obscureText = false,
    this.prefixIcon,
    required this.hintText,
    this.suffixIcon,
    this.onFieldSubmitted,
  });

  final TextEditingController? controller;
  final TextInputType keyboardType;
  final bool obscureText;
  final Widget? prefixIcon;
  final String hintText;
  final Widget? suffixIcon;
  final Function(String)? onFieldSubmitted;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: hintText == 'Message' || hintText == 'Complaint' ? null : 45,
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        obscureText: obscureText,
        maxLines: hintText == 'Message' ||
                hintText == 'Bio' ||
                hintText == 'Complaint'
            ? 5
            : hintText == 'Reply'
                ? null
                : 1,
        onFieldSubmitted: onFieldSubmitted,
        cursorColor: Colors.deepPurpleAccent,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 16,
          letterSpacing: 1,
        ),
        decoration: InputDecoration(
          contentPadding: prefixIcon == null
              ? const EdgeInsets.symmetric(vertical: 10, horizontal: 12)
              : EdgeInsets.zero,
          prefixIcon: prefixIcon,
          prefixIconConstraints:
              const BoxConstraints(minWidth: 40, maxHeight: 30),
          hintText: hintText,
          hintStyle: const TextStyle(
            fontSize: 14,
            color: Colors.grey,
            fontWeight: FontWeight.w500,
          ),
          suffixIcon: suffixIcon,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade400),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.deepPurpleAccent),
          ),
        ),
      ),
    );
  }
}
