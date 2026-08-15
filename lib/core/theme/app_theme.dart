import 'package:flutter/material.dart';
import 'design_tokens.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: DesignTokens.lightBg,
      primaryColor: DesignTokens.lightPrimaryAccent,
      colorScheme: const ColorScheme.light(
        primary: DesignTokens.lightPrimaryAccent,
        secondary: DesignTokens.lightPrimaryAccent,
        surface: DesignTokens.lightCard,
        surfaceContainerHighest: DesignTokens.lightAyahHighlight,
        onSurface: DesignTokens.lightTextPrimary,
        onSurfaceVariant: DesignTokens.lightTextSecondary,
        outline: DesignTokens.lightBorder,
      ),
      fontFamily: DesignTokens.fontCairo,
      dividerColor: DesignTokens.lightBorder,
      cardTheme: const CardThemeData(
        color: DesignTokens.lightCard,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          side: BorderSide(color: DesignTokens.lightBorder),
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: DesignTokens.lightPrimaryAccent),
        titleTextStyle: TextStyle(
          fontFamily: DesignTokens.fontCairo,
          color: DesignTokens.lightPrimaryAccent,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: DesignTokens.lightCard,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
      ),
      iconTheme: const IconThemeData(color: DesignTokens.lightPrimaryAccent),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: DesignTokens.darkBg,
      primaryColor: DesignTokens.darkPrimaryAccent,
      colorScheme: const ColorScheme.dark(
        primary: DesignTokens.darkPrimaryAccent,
        secondary: DesignTokens.darkPrimaryAccent,
        surface: DesignTokens.darkCard,
        surfaceContainerHighest: DesignTokens.darkAyahHighlight,
        onSurface: DesignTokens.darkTextPrimary,
        onSurfaceVariant: DesignTokens.darkTextSecondary,
        outline: DesignTokens.darkBorder,
      ),
      fontFamily: DesignTokens.fontCairo,
      dividerColor: DesignTokens.darkBorder,
      cardTheme: const CardThemeData(
        color: DesignTokens.darkCard,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          side: BorderSide(color: DesignTokens.darkBorder),
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: DesignTokens.darkTextPrimary),
        titleTextStyle: TextStyle(
          fontFamily: DesignTokens.fontCairo,
          color: DesignTokens.darkTextPrimary,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: DesignTokens.darkCard,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
      ),
      iconTheme: const IconThemeData(color: DesignTokens.darkTextPrimary),
    );
  }
}
