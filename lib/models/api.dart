import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:test_notifications/models/api_data.dart';

extension IsOk on http.Response {
  bool get ok {
    return (statusCode ~/ 100) == 2;
  }
}

class API {
  String authtoken;
  API({required this.authtoken});

  static String host = 'https://sigserver4.udg.edu';
  static String api_path = host + '/apps/carpool';

  static String register_device_url = api_path + '/api/devices/';
  static String get_users_url = api_path + '/api/user/';
  static String get_user_charts_url = api_path + '/api/chats/mine/';
  static String chat_detail_url = api_path + '/api/chats/detail';
  static String send_notification_url = api_path + '/api/chats/chatnotify';

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

  Future<http.Response> getUsers() async {
    return http.get(Uri.parse(get_users_url), headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': 'Token $authtoken'
    });
  }

  Future<http.Response> getUserChatsList() async {
    return http.get(Uri.parse(get_user_charts_url), headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': 'Token ${authtoken}'
    });
  }

  Future<http.Response> getChatDetail(int userid) async {
    return http
        .get(Uri.parse('$chat_detail_url/$userid'), headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': 'Token ${authtoken}'
    });
  }

  Future<ApiData> sendNotification(String message, int userid) async {
    late http.Response response;
    try {
      response = await http.post(
        Uri.parse('$send_notification_url/$userid/'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Token ${authtoken}'
        },
        body: jsonEncode(
            <String, String>{'title': 'UdG carpool', 'message': message}),
      );
      return ApiData(
          statusCode: response.statusCode, message: response.reasonPhrase);
    } catch (e) {
      return ApiData(statusCode: -1, message: 'Unknown error');
    }
  }
}
