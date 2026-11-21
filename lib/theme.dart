import 'package:material_ui/material_ui.dart';

const ink = Color(0xFF15251E);
const muted = Color(0xFF7A8981);
const green = Color(0xFF35B88A);
const canvas = Color(0xFFF5F7F4);
const card = Colors.white;

ThemeData appTheme() => ThemeData(
  useMaterial3: true,
  scaffoldBackgroundColor: canvas,
  colorScheme: ColorScheme.fromSeed(
    seedColor: green,
    brightness: Brightness.light,
  ),
  fontFamily: 'Roboto',
  appBarTheme: const AppBarTheme(backgroundColor: canvas, foregroundColor: ink),
  navigationBarTheme: const NavigationBarThemeData(
    backgroundColor: Colors.white,
    indicatorColor: Color(0xFFE4F5EC),
  ),
);

String money(num amount) =>
    '₹${amount.toStringAsFixed(amount % 1 == 0 ? 0 : 2)}';
