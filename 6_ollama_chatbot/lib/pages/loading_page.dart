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
    // Give animations time to complete before navigating
    Future.delayed(const Duration(milliseconds: 3500), () {
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
            // Logo: zoom in, then swap to the cloud image
            Image.asset(
                  'assets/images/ollama_logo.png',
                  width: 120,
                  height: 120,
                )
                .animate()
                // initial zoom/fade
                .scale(
                  duration: 800.ms,
                  curve: Curves.easeOutBack,
                  begin: const Offset(0.0, 0.0),
                  end: const Offset(1.0, 1.0),
                )
                .fadeIn(duration: 500.ms)
                // wait a bit, then shrink the first image to a very small scale
                .then(delay: 700.ms)
                .scale(
                  duration: 300.ms,
                  begin: const Offset(1.0, 1.0),
                  end: const Offset(0.05, 0.05),
                  curve: Curves.easeIn,
                )
                // immediately swap to the cloud image (now tiny) and scale it up
                .swap(
                  builder: (_, __) {
                    return Image.asset(
                          'assets/images/ollama_cloud.png',
                          width: 120,
                          height: 120,
                        )
                        .animate()
                        .scale(
                          duration: 400.ms,
                          begin: const Offset(0.05, 0.05),
                          end: const Offset(1.0, 1.0),
                          curve: Curves.easeOut,
                        )
                        .fadeIn(duration: 300.ms);
                  },
                ),

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
                .fadeIn(delay: 1500.ms, duration: 600.ms, curve: Curves.easeOut)
                .slideY(delay: 1500.ms, duration: 600.ms, begin: 0.2, end: 0.0),
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
