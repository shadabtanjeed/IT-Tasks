import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_strategy/url_strategy.dart';
import 'providers/scale_provider.dart';
import 'providers/theme_provider.dart';

void main() {
  setPathUrlStrategy();
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scale = ref.watch(scaleProvider);

    // Build a base theme and multiply font sizes via textScaleFactor
    final baseTextTheme = GoogleFonts.interTextTheme();

    final isDark = ref.watch(themeProvider);

    // Define professional blues - darker for light mode, lighter for dark mode text
    const professionalBlue = Color(0xFF134686);
    const lightBlueForDark = Color(
      0xFF6BA3E6,
    ); // Lighter blue for dark mode visibility

    final lightTheme = ThemeData(
      brightness: Brightness.light,
      colorScheme: const ColorScheme.light(
        primary: professionalBlue,
        onPrimary: Colors.white,
        secondary: professionalBlue,
        surface: Colors.white,
        onSurface: Colors.black87,
      ),
      textTheme: baseTextTheme,
      primaryTextTheme: baseTextTheme,
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          minimumSize: Size(88 * scale, 48 * scale),
          padding: EdgeInsets.symmetric(
            horizontal: 20 * scale,
            vertical: 14 * scale,
          ),
          backgroundColor: professionalBlue,
          foregroundColor: Colors.white,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        labelStyle: const TextStyle(color: professionalBlue),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: professionalBlue),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: professionalBlue, width: 2),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: professionalBlue),
        ),
      ),
    );

    final darkTheme = ThemeData(
      brightness: Brightness.dark,
      colorScheme: const ColorScheme.dark(
        primary:
            lightBlueForDark, // Use lighter blue for text/icons in dark mode
        onPrimary: Colors.white,
        secondary: lightBlueForDark,
        surface: Color(0xFF1E1E1E),
        onSurface: Colors.white,
      ),
      textTheme: baseTextTheme.apply(
        bodyColor: Colors.white,
        displayColor: Colors.white,
      ),
      primaryTextTheme: baseTextTheme,
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          minimumSize: Size(88 * scale, 48 * scale),
          padding: EdgeInsets.symmetric(
            horizontal: 20 * scale,
            vertical: 14 * scale,
          ),
          backgroundColor: lightBlueForDark,
          foregroundColor: Colors.white,
        ),
      ),
      cardColor: const Color(0xFF2D2D2D),
      inputDecorationTheme: InputDecorationTheme(
        labelStyle: const TextStyle(color: lightBlueForDark),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: lightBlueForDark),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: lightBlueForDark, width: 2),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: lightBlueForDark),
        ),
      ),
    );

    return MaterialApp.router(
      title: 'Notes',
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(textScaleFactor: scale),
          child: child ?? const SizedBox.shrink(),
        );
      },
      routerConfig: appRouter,
    );
  }
}
