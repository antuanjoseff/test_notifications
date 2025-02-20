import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:test_notifications/config/router.dart';
import 'package:test_notifications/models/UserCubit.dart';

AndroidOptions _getAndroidOptions() => const AndroidOptions(
      encryptedSharedPreferences: true,
    );

final storage = FlutterSecureStorage(aOptions: _getAndroidOptions());

Future<String> getUsernameFromStorage() async {
  return await storage.read(key: 'username') ?? 'no-usename';
}

Future<void> setUsernameToStorage(username) async {
  await storage.write(key: 'username', value: username);
}

Future<String?> getTokenFromStorage() async {
  debugPrint('get token from storage');
  return await storage.read(key: 'token');
}

Future<void> setTokenToStorage(token) async {
  debugPrint('SET token from storage');
  await storage.write(key: 'token', value: token);
}

Future<List<String>> getMessageFromStorage(user) async {
  String? storaged = await storage.read(key: 'messages-$user');
  debugPrint('storaged messages $storaged');
  List<String> messages = jsonDecode(storaged ?? '');

  return messages;
}

Future<void> setMessagesToStorage(String user, List<String> messages) async {
  debugPrint('Stroging messages... ${jsonEncode(messages)}');
  await storage.write(key: 'messages-$user', value: jsonEncode(messages));
}
