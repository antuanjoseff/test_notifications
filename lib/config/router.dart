import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:test_notifications/screens/chat_page.dart';
import 'package:test_notifications/screens/menu_screen.dart';
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
      name: 'menu',
      path: '/:userId/:token',
      builder: (context, state) {
        final username =
            state.pathParameters["userId"]!; // Get "id" param from URL
        final token = state.pathParameters["token"]!; // Get "id" param from URL
        return MenuPage(username: username, authtoken: token);
      },
    ),
    GoRoute(
      name: 'chats',
      path: '/chats',
      builder: (context, state) {
        return ChatPage();
      },
    ),
  ],
);
