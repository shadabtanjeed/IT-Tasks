// ...existing code...
import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'login.dart';
import 'signup.dart';
import 'home_page.dart';
import 'forgot_password.dart';
import 'reset_password.dart';
import 'navbar.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/login',
  routes: <RouteBase>[
    GoRoute(
      path: '/login',
      name: 'login',
      builder: (context, state) => const LoginPage(),
    ),
    GoRoute(
      path: '/signup',
      name: 'signup',
      builder: (context, state) => const SignUpPage(),
    ),
    GoRoute(
      path: '/forgot-password',
      name: 'forgot-password',
      builder: (context, state) => const ForgotPasswordPage(),
    ),
    GoRoute(
      path: '/reset-password',
      name: 'reset-password',
      builder: (context, state) => const ResetPasswordPage(),
    ),
    GoRoute(
      path: '/home',
      name: 'home',
      builder: (context, state) => const AppNavShell(), // use shell with navbar
    ),
  ],
);
