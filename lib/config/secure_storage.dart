import 'package:flutter_secure_storage/flutter_secure_storage.dart';

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
