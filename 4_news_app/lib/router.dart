// ...existing code...
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'new_stories.dart';
import 'top_stories.dart';
import 'best_stories.dart';
import 'navbar.dart';

final GoRouter appRouter = GoRouter(
  routes: <RouteBase>[
    ShellRoute(
      builder: (BuildContext context, GoRouterState state, Widget child) =>
          Navbar(child: child, location: state.uri.toString()),
      routes: <GoRoute>[
        GoRoute(
          path: '/',
          name: 'new',
          builder: (BuildContext context, GoRouterState state) =>
              const NewStoriesPage(),
        ),
        GoRoute(
          path: '/top-stories',
          name: 'top',
          builder: (BuildContext context, GoRouterState state) =>
              const TopStoriesPage(),
        ),
        GoRoute(
          path: '/best-stories',
          name: 'best',
          builder: (BuildContext context, GoRouterState state) =>
              const BestStories(),
        ),
      ],
    ),
  ],
);
