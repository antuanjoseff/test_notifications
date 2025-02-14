import 'package:flutter/material.dart';
import 'dart:convert';

class User {
  String? username;
  String? token;

  User({this.username, this.token});

  void printAttributes() {
    print("id: ${username}\n");
    print("token: ${token}\n");
  }
}
