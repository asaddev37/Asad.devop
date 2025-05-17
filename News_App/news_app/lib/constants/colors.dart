import 'package:flutter/material.dart';

class AppColors {
  static const Color neonPink = Color(0xFFFF2E63);
  static const Color electricBlue = Color(0xFF00D4FF);
  static const Color limeGreen = Color(0xFF39FF14);
  static const Color darkPurple = Color(0xFF1A0B2E);
  static const Color midnightBlack = Color(0xFF0D0D0D);

  static const LinearGradient primaryGradient = LinearGradient(
    colors: [neonPink, electricBlue, limeGreen],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient secondaryGradient = LinearGradient(
    colors: [darkPurple, midnightBlack],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}