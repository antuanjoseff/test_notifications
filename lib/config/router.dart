import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:test_notifications/main.dart';
import './secure_storage.dart';
import './config.dart';
import '../screens/screens.dart';

final navigatiorKey = GlobalKey<NavigatorState>();

final router = GoRouter(
  navigatorKey: navigatiorKey,
  // initialLocation: initRouterPath,
  routes: [
    GoRoute(
      name:
          'login', // Optional, add name to your routes. Allows you navigate by name instead of path
      path: '/',
      builder: (context, state) {
        return LoginScreen();
      },
    ),
    GoRoute(
      name: 'message',
      path: '/message',
      builder: (context, state) => MessageScreen(),
    ),
    GoRoute(
      name: 'chatList-v2',
      path: '/:userId/:token',
      builder: (context, state) {
        final userId =
            state.pathParameters["userId"]!; // Get "id" param from URL
        final token = state.pathParameters["token"]!; // Get "id" param from URL
        debugPrint('userID $userId');
        debugPrint('userToken $token');
        setUsernameToStorage(userId);
        return ChatListScreen(token: token);
      },
    ),
  ],
);
