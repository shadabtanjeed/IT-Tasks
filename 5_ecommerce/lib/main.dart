import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'cart_provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');

  await Supabase.initialize(
    url: dotenv.env['supabase_url'] ?? '',
    anonKey: dotenv.env['supabase_anon_key'] ?? '',
  );
  runApp(
    ChangeNotifierProvider(create: (_) => CartProvider(), child: const MyApp()),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Notes',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF134686)),
        textTheme: GoogleFonts.interTextTheme(),
        primaryTextTheme: GoogleFonts.interTextTheme(),
      ),
      routerConfig: appRouter,
    );
  }
}
