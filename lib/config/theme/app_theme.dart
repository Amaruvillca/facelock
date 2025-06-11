// app_theme.dart
import 'package:flutter/material.dart';

class AppTheme {
  ThemeData getTheme() => ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFBFE2FF), // Azul celeste claro
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: const Color(0xFFF8F5FA), // fondo suave
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFF8F5FA),
          foregroundColor: Color(0xFF0D3B3B),
          elevation: 0,
        ),
        iconTheme: const IconThemeData(color: Color(0xFF0D3B3B)),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          selectedItemColor: Color(0xFF0D3B3B),
          unselectedItemColor: Colors.grey,
          backgroundColor: Colors.white,
          showUnselectedLabels: true,
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: Color(0xFFFF6D60),
        ),
        textTheme: const TextTheme(
          titleMedium: TextStyle(fontWeight: FontWeight.w600),
          bodyMedium: TextStyle(color: Color(0xFF0D3B3B)),
        ),
      );
}
