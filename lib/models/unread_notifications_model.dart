import 'package:flutter/material.dart';
import 'dart:convert';

import 'package:test_notifications/models/ChatList.dart';

class UnreadNotificationsModel {
  Map<int, Chat> unread;

  UnreadNotificationsModel({required this.unread});
}
