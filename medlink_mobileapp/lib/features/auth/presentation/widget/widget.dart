import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

InputDecoration _buildInputDecoration(String labelText, String? errorText) {
    return InputDecoration(
      contentPadding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 12.0),
      hintText: labelText,
      labelStyle: GoogleFonts.poppins(color: const Color(0xFFAFBACA)),
      errorText: errorText,
      errorMaxLines: 2,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFF2b8761)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(
          color: errorText != null ? Colors.red : const Color(0xFF2b8761),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(
          color: errorText != null ? Colors.red : const Color(0xFF2b8761),
          width: 2,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Colors.red),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Colors.red, width: 2),
      ),
    );
  }