import 'dart:convert';
import 'package:http/http.dart' as http;

class API {
  String authtoken;
  API({required this.authtoken});

  static String host = 'https://sigserver4.udg.edu';
  static String api_path = host + '/apps/carpool';

  static String register_device_url = api_path + '/api/devices/';

  Future<http.Response> registerDevice(String devicetoken) async {
    http.Response response = await http.post(
      Uri.parse(register_device_url),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Token ${authtoken}'
      },
      body: jsonEncode(
          <String, String>{'registration_id': devicetoken, 'type': 'web'}),
    );
    return response;
  }
}
