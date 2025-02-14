import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import './secure_storage.dart';
import './config.dart';
import '../screens/screens.dart';

final navigatiorKey = GlobalKey<NavigatorState>();

final router = GoRouter(
  navigatorKey: navigatiorKey,
  initialLocation: '/',
  routes: [
    GoRoute(
      name:
          'home', // Optional, add name to your routes. Allows you navigate by name instead of path
      path: '/',
      builder: (context, state) => HomeScreen(),
    ),
    GoRoute(
      name: 'message',
      path: '/message',
      builder: (context, state) => MessageScreen(),
    ),
    GoRoute(
      name: 'message-user',
      path: '/message/:userId',
      builder: (context, state) {
        final userId =
            state.pathParameters["userId"]!; // Get "id" param from URL

        setUsernameToStorage(userId);
        return HomeScreen();
      },
    ),
  ],
);
