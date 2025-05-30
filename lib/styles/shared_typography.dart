import 'package:digi4_mobile/styles/color.dart';
import 'package:flutter/widgets.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTextStyles {
  static TextStyle h1 = GoogleFonts.plusJakartaSans(
    fontSize: 28.0,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );

  static TextStyle h2 = GoogleFonts.plusJakartaSans(
    fontSize: 24.0,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );

  static TextStyle h3 = GoogleFonts.plusJakartaSans(
    fontSize: 20.0,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static TextStyle h4 = GoogleFonts.plusJakartaSans(
    fontSize: 18.0,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  // Body Text Styles
  static TextStyle bodyLarge = GoogleFonts.plusJakartaSans(
    fontSize: 16.0,
    fontWeight: FontWeight.normal,
    color: AppColors.textPrimary,
  );

  static TextStyle bodyMedium = GoogleFonts.plusJakartaSans(
    fontSize: 14.0,
    fontWeight: FontWeight.normal,
    color: AppColors.textPrimary,
  );

  static TextStyle bodySmall = GoogleFonts.plusJakartaSans(
    fontSize: 12.0,
    fontWeight: FontWeight.normal,
    color: AppColors.textSecondary,
  );

  // Button Text Styles
  static TextStyle buttonLarge = GoogleFonts.plusJakartaSans(
    fontSize: 16.0,
    fontWeight: FontWeight.w500,
    color: AppColors.buttonText,
  );

  static TextStyle buttonMedium = GoogleFonts.plusJakartaSans(
    fontSize: 14.0,
    fontWeight: FontWeight.w500,
    color: AppColors.buttonText,
  );

  // Label & Input Styles
  static TextStyle labelMedium = GoogleFonts.plusJakartaSans(
    fontSize: 14.0,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
  );

  static TextStyle inputText = GoogleFonts.plusJakartaSans(
    fontSize: 14.0,
    fontWeight: FontWeight.normal,
    color: AppColors.textPrimary,
  );

  // Link Styles
  static TextStyle link = GoogleFonts.plusJakartaSans(
    fontSize: 14.0,
    fontWeight: FontWeight.w500,
    color: AppColors.primary,
  );

  // Helper styles
  static TextStyle caption = GoogleFonts.plusJakartaSans(
    fontSize: 12.0,
    fontWeight: FontWeight.normal,
    color: AppColors.textSecondary,
  );

  // Variasi dengan warna berbeda (contoh untuk pesan error/success)
  static TextStyle captionError = GoogleFonts.plusJakartaSans(
    fontSize: 12.0,
    fontWeight: FontWeight.normal,
    color: AppColors.error,
  );

  static TextStyle captionSuccess = GoogleFonts.plusJakartaSans(
    fontSize: 12.0,
    fontWeight: FontWeight.normal,
    color: AppColors.success,
  );
}
