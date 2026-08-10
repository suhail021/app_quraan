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
        secondary: DesignTokens.lightGoldAccent,
        surface: DesignTokens.lightCard,
      ),
      fontFamily: DesignTokens.fontCairo,
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
        iconTheme: IconThemeData(color: DesignTokens.lightTextPrimary),
        titleTextStyle: TextStyle(
          fontFamily: DesignTokens.fontCairo,
          color: DesignTokens.lightTextPrimary,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
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
        secondary: DesignTokens.darkGoldAccent,
        surface: DesignTokens.darkCard,
      ),
      fontFamily: DesignTokens.fontCairo,
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
    );
  }
}
