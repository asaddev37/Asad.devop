import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../constants/colors.dart';
import '../constants/sizes.dart';

class AppTheme {
  static ThemeData lightTheme() {
    return ThemeData(
      primaryColor: AppColors.primary,
      scaffoldBackgroundColor: AppColors.background,
      cardColor: AppColors.card,
      textTheme: TextTheme(
        headlineMedium: TextStyle(
          fontSize: AppSizes.fontHeadline,
          color: AppColors.textPrimary,
          fontWeight: FontWeight.bold,
          fontFamily: 'Comic Sans MS',
        ),
        titleLarge: TextStyle(
          fontSize: AppSizes.fontSubtitle,
          color: AppColors.textPrimary,
          fontFamily: 'Comic Sans MS',
        ),
        bodyMedium: TextStyle(
          fontSize: AppSizes.fontBody,
          color: AppColors.textPrimary,
          fontFamily: 'Comic Sans MS',
        ),
        bodySmall: TextStyle(
          fontSize: AppSizes.fontCaption,
          color: AppColors.textSecondary,
          fontFamily: 'Comic Sans MS',
        ),
      ),
      buttonTheme: ButtonThemeData(
        buttonColor: AppColors.primary,
        textTheme: ButtonTextTheme.primary,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, AppSizes.buttonHeight),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.cardRadius),
          ),
          padding: const EdgeInsets.symmetric(horizontal: AppSizes.padding * 2, vertical: AppSizes.padding),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.card,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.cardRadius),
        ),
        labelStyle: TextStyle(
          color: AppColors.accentLight,
          fontFamily: 'Comic Sans MS',
        ),
        hintStyle: TextStyle(
          color: AppColors.textSecondary,
          fontFamily: 'Comic Sans MS',
        ),
      ),
    );
  }

  static ThemeData darkTheme() {
    return ThemeData(
      primaryColor: AppColors.primary,
      scaffoldBackgroundColor: AppColors.darkBackground,
      cardColor: AppColors.darkCard,
      textTheme: TextTheme(
        headlineMedium: TextStyle(
          fontSize: AppSizes.fontHeadline,
          color: AppColors.darkText,
          fontWeight: FontWeight.bold,
          fontFamily: 'Comic Sans MS',
        ),
        titleLarge: TextStyle(
          fontSize: AppSizes.fontSubtitle,
          color: AppColors.darkText,
          fontFamily: 'Comic Sans MS',
        ),
        bodyMedium: TextStyle(
          fontSize: AppSizes.fontBody,
          color: AppColors.darkText,
          fontFamily: 'Comic Sans MS',
        ),
        bodySmall: TextStyle(
          fontSize: AppSizes.fontCaption,
          color: AppColors.textSecondary,
          fontFamily: 'Comic Sans MS',
        ),
      ),
      buttonTheme: ButtonThemeData(
        buttonColor: AppColors.primary,
        textTheme: ButtonTextTheme.primary,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, AppSizes.buttonHeight),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.cardRadius),
          ),
          padding: const EdgeInsets.symmetric(horizontal: AppSizes.padding * 2, vertical: AppSizes.padding),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.darkCard,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.cardRadius),
        ),
        labelStyle: TextStyle(
          color: AppColors.accentDark,
          fontFamily: 'Comic Sans MS',
        ),
        hintStyle: TextStyle(
          color: AppColors.textSecondary,
          fontFamily: 'Comic Sans MS',
        ),
      ),
    );
  }
}