import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'signup.dart';
import 'navbar.dart';

final GoRouter appRouter = GoRouter(
  routes: <RouteBase>[
    // Signup route outside the ShellRoute so it is NOT wrapped by NavBar
    GoRoute(
      path: '/',
      name: 'signup',
      builder: (BuildContext context, GoRouterState state) =>
          const SignUpPage(),
    ),
  ],
);
// ...existing code...
