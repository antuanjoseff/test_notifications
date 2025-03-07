import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

AndroidOptions _getAndroidOptions() => const AndroidOptions(
      encryptedSharedPreferences: true,
    );

final storage = FlutterSecureStorage(aOptions: _getAndroidOptions());

Future<String?> getUsernameFromStorage() async {
  return await storage.read(key: 'username') ?? null;
}

Future<void> saveUsername(username) async {
  await storage.write(key: 'username', value: username);
}

Future<String?> getAuthtokenFromStorage() async {
  return await storage.read(key: 'authtoken');
}

Future<void> saveAuthToken(authtoken) async {
  await storage.write(key: 'authtoken', value: authtoken);
}

Future<String?> getDeviceTokenFromStorage() async {
  return await storage.read(key: 'devicetoken');
}

Future<void> saveDeviceToken(devicetoken) async {
  await storage.write(key: 'devicetoken', value: devicetoken);
}

Future<List<String>> getMessageFromStorage(user) async {
  String? storaged = await storage.read(key: 'messages-$user');

  List<String> messages = jsonDecode(storaged ?? '');

  return messages;
}

Future<void> setMessagesToStorage(String user, List<String> messages) async {
  await storage.write(key: 'messages-$user', value: jsonEncode(messages));
}
