// ...existing code...
import 'package:go_router/go_router.dart';
import 'login.dart';
import 'signup.dart';
import 'home_page.dart';
import 'forgot_password.dart';
import 'reset_password.dart';
import 'navbar.dart';
import 'product_details_page.dart';
import 'cart_page.dart';
import 'categories_page.dart';
import 'profile_page.dart';
import 'checkout_page.dart';
import 'order_history_page.dart';

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
    ShellRoute(
      builder: (context, state, child) => AppNavShell(child: child),
      routes: [
        GoRoute(
          path: '/home',
          name: 'home',
          pageBuilder: (context, state) =>
              const NoTransitionPage(child: HomePage()),
        ),
        GoRoute(
          path: '/cart',
          name: 'cart',
          pageBuilder: (context, state) =>
              const NoTransitionPage(child: CartPage()),
        ),
        GoRoute(
          path: '/categories',
          name: 'categories',
          pageBuilder: (context, state) =>
              const NoTransitionPage(child: CategoriesPage()),
        ),
        GoRoute(
          path: '/profile',
          name: 'profile',
          pageBuilder: (context, state) =>
              const NoTransitionPage(child: ProfilePage()),
        ),
        GoRoute(
          path: '/product/:id',
          name: 'product-details',
          pageBuilder: (context, state) {
            final id = state.pathParameters['id']!;
            return NoTransitionPage(child: ProductDetailsPage(productId: id));
          },
        ),
        GoRoute(
          path: '/checkout',
          name: 'checkout',
          pageBuilder: (context, state) =>
              const NoTransitionPage(child: CheckoutPage()),
        ),
        GoRoute(
          path: '/order-history',
          name: 'order-history',
          pageBuilder: (context, state) =>
              const NoTransitionPage(child: OrderHistoryPage()),
        ),
      ],
    ),
  ],
);
