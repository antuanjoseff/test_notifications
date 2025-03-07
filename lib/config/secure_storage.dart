import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

AndroidOptions _getAndroidOptions() => const AndroidOptions(
      encryptedSharedPreferences: true,
    );

final storage = FlutterSecureStorage(aOptions: _getAndroidOptions());

Future<String?> getUsernameFromStorage() async {
  debugPrint('Inside STORAGEX');
  return await storage.read(key: 'username') ?? null;
}

Future<void> saveUsername(username) async {
  debugPrint('SAVE USERNAME IN STORE');
  await storage.write(key: 'username', value: username);
}

Future<String?> getAuthtokenFromStorage() async {
  debugPrint('get token from storage');
  return await storage.read(key: 'authtoken');
}

Future<void> saveAuthToken(authtoken) async {
  debugPrint('SAVE AUTHTOKEN IN STORE $authtoken');
  await storage.write(key: 'authtoken', value: authtoken);
}

Future<String?> getDeviceTokenFromStorage() async {
  return await storage.read(key: 'devicetoken');
}

Future<void> saveDeviceToken(devicetoken) async {
  debugPrint('SAVE DEVICE TOKEN $devicetoken');
  await storage.write(key: 'devicetoken', value: devicetoken);
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
