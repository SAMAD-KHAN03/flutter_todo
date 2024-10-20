import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:todo/widgets/home_screen.dart';

final theme = ThemeData(
  cardColor: const ColorScheme.dark(brightness: Brightness.light).onPrimary,
  colorScheme: ColorScheme.fromSeed(
    brightness: Brightness.light,
    seedColor: const Color.fromARGB(255, 208, 208, 208),
  ),
  appBarTheme: const AppBarTheme(
    backgroundColor: Color.fromARGB(255, 235, 235, 13),
  ),
  textTheme: GoogleFonts.kaiseiOptiTextTheme(Typography.blackRedwoodCity),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: const ButtonStyle().copyWith(
      backgroundColor: const WidgetStatePropertyAll(Colors.yellow),
    ),
  ),
);
void main() {
  runApp(const ProviderScope(
    child: MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: theme,
      home: const HomeScreen(),
    );
  }
}
