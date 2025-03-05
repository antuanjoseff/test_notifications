import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:test_notifications/models/api_data.dart';
import 'dart:io' show Platform;

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

  Map<String, String> getAuthHeaders() {
    Map<String, String> headers = {
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': 'Token ${authtoken}'
    };
    return headers;
  }

  Future<ApiData> doPost(
      Uri uri, Map<String, String> headers, String body) async {
    try {
      http.Response response =
          await http.post(uri, headers: headers, body: body);
      if (response.ok) {
        return Success(data: response);
      } else {
        return Error(message: response.statusCode.toString());
      }
    } on Exception catch (e) {
      return ExceptionError(exception: e);
    } catch (e) {
      return Error(message: e.toString());
    }
  }

  Future<ApiData> doGet(Uri uri, Map<String, String> headers) async {
    try {
      http.Response response = await http.get(uri, headers: headers);
      if (response.ok) {
        return Success(data: response);
      } else {
        return Error(message: response.statusCode.toString());
      }
    } on Exception catch (e) {
      return ExceptionError(exception: e);
    } catch (e) {
      return Error(message: e.toString());
    }
  }

  Future<ApiData> registerDevice(String devicetoken) async {
    Uri uri = Uri.parse(register_device_url);
    Map<String, String> headers = getAuthHeaders();
    String type = kIsWeb
        ? 'web'
        : Platform.isAndroid
            ? 'android'
            : Platform.isIOS
                ? 'ios'
                : '';
    String body = jsonEncode(
        <String, String>{'registration_id': devicetoken, 'type': type});

    return doPost(uri, headers, body);
  }

  Future<ApiData> getUsers() async {
    Uri uri = Uri.parse(get_users_url);
    Map<String, String> headers = getAuthHeaders();

    return doGet(uri, headers);
  }

  Future<ApiData> getUserChatsList() async {
    try {
      http.Response response = await http
          .get(Uri.parse(get_user_charts_url), headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Token ${authtoken}'
      });

      if (response.ok) {
        return Success(data: response);
      } else {
        return Error(message: response.statusCode.toString());
      }
    } on Exception catch (e) {
      return ExceptionError(exception: e);
    } catch (e) {
      return Error(message: e.toString());
    }
  }

  Future<ApiData> getChatDetail(int userid) async {
    try {
      http.Response response = await http
          .get(Uri.parse('$chat_detail_url/$userid'), headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Token ${authtoken}'
      });
      if (response.ok) {
        return Success(data: response);
      } else {
        return Error(message: response.statusCode.toString());
      }
    } on Exception catch (e) {
      return ExceptionError(exception: e);
    } catch (e) {
      return Error(message: e.toString());
    }
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
      if (response.ok) {
        return Success(data: []);
      } else {
        return Error(message: response.statusCode.toString());
      }
    } on Exception catch (e) {
      return ExceptionError(exception: e);
    } catch (e) {
      return Error(message: e.toString());
    }
  }
}
