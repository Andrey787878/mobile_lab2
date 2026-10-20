import 'package:flutter/material.dart';

import 'converter_screen.dart';

void main() => runApp(const ConverterApp());

class ConverterApp extends StatelessWidget {
  const ConverterApp({super.key});

  @override
  Widget build(BuildContext context) {
    final accent = Colors.amber.shade700;
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Конвертер валют',
      theme: ThemeData(
        fontFamily: 'Roboto',
        brightness: Brightness.dark,
        scaffoldBackgroundColor: Colors.black,
        colorScheme: ColorScheme.dark(
          primary: accent,
          secondary: accent,
          surface: Colors.grey.shade900,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
          surfaceTintColor: Colors.transparent,
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            backgroundColor: accent,
            foregroundColor: Colors.white,
            minimumSize: const Size(0, 56),
            textStyle: const TextStyle(fontSize: 18),
            shape: const StadiumBorder(),
          ),
        ),
      ),
      home: const ConverterScreen(),
    );
  }
}
