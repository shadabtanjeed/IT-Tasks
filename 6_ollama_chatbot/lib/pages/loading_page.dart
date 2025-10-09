import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'chat_page.dart';

class LoadingPage extends StatefulWidget {
  const LoadingPage({super.key});

  @override
  State<LoadingPage> createState() => _LoadingPageState();
}

class _LoadingPageState extends State<LoadingPage> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 2500), () {
      if (mounted) {
        Navigator.of(
          context,
        ).pushReplacement(MaterialPageRoute(builder: (_) => const ChatPage()));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
                  'assets/images/ollama_logo.png',
                  width: 120,
                  height: 120,
                )
                .animate()
                .scale(
                  duration: 800.ms,
                  curve: Curves.easeOutBack,
                  begin: const Offset(0.0, 0.0),
                  end: const Offset(1.0, 1.0),
                )
                .fadeIn(duration: 600.ms),

            const SizedBox(height: 32),

            const Text(
                  'OLLAMA Chatbot',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(255, 0, 0, 0),
                  ),
                )
                .animate()
                .scale(
                  begin: const Offset(0.0, 0.0),
                  end: const Offset(1.0, 1.0),
                )
                .fadeIn(delay: 600.ms, duration: 600.ms, curve: Curves.easeOut),
            // .slideY(
            //   delay: 600.ms,
            //   duration: 600.ms,
            //   begin: 0.3,
            //   end: 0.0,
            //   curve: Curves.easeOut,
            // ),
          ],
        ),
      ),
    );
  }
}
