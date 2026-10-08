import 'package:flutter/material.dart';

InputDecoration authInputDecoration(
  String hint,
  IconData icon, {
  Widget? suffix,
  bool invalid = false,
  double verticalPadding = 22,
  String? errorText,
}) => InputDecoration(
  hintText: hint,
  errorText: errorText,
  errorStyle: const TextStyle(fontSize: 13),
  errorMaxLines: 2,
  errorBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(22),
    borderSide: const BorderSide(color: Color(0xFFB53F48), width: 3.5),
  ),
  focusedErrorBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(22),
    borderSide: const BorderSide(color: Color(0xFFB53F48), width: 3.5),
  ),
  hintStyle: const TextStyle(
    fontSize: 16,
    height: 27 / 16,
    color: Color(0xFF747781),
  ),
  prefixIcon: Icon(
    icon,
    size: 22,
    color: invalid ? const Color(0xFFB53F48) : const Color(0xFF626773),
  ),
  suffixIcon: suffix,
  filled: true,
  fillColor: const Color(0xFFF5F5F7),
  contentPadding: EdgeInsets.symmetric(
    vertical: verticalPadding,
    horizontal: 16,
  ),
  border: OutlineInputBorder(
    borderRadius: BorderRadius.circular(22),
    borderSide: BorderSide(
      color: invalid ? const Color(0xFFB53F48) : const Color(0xFFE5E5EA),
      width: invalid ? 3.5 : 1,
    ),
  ),
  enabledBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(22),
    borderSide: BorderSide(
      color: invalid ? const Color(0xFFB53F48) : const Color(0xFFE5E5EA),
      width: invalid ? 3.5 : 1,
    ),
  ),
  focusedBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(22),
    borderSide: BorderSide(
      color: invalid ? const Color(0xFFB53F48) : const Color(0xFF818792),
      width: invalid ? 3.5 : 1.5,
    ),
  ),
);
