import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'home_page.dart';
import 'add_task.dart';
import 'edit_task.dart';
import 'settingsPage.dart';

final GoRouter appRouter = GoRouter(
  routes: <GoRoute>[
    GoRoute(
      path: '/',
      builder: (BuildContext context, GoRouterState state) =>
          const MyHomePage(title: 'My Notes'),
    ),
    GoRoute(
      path: '/add-task',
      builder: (BuildContext context, GoRouterState state) =>
          const AddTaskPage(),
    ),

    GoRoute(
      path: '/edit-task',
      builder: (BuildContext context, GoRouterState state) =>
          const EditTaskPage(),
    ),

    GoRoute(
      path: '/settings',
      builder: (BuildContext context, GoRouterState state) =>
          const SettingsPage(),
    ),
  ],
);
