import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:test_notifications/models/ChatList.dart';
import 'package:test_notifications/models/UserCubit.dart';
import 'package:test_notifications/models/Usuari.dart';
import 'package:test_notifications/services/PushNotifications.dart';
import 'package:web/web.dart' as web;
import '../config/config.dart';
import 'package:http/http.dart' as http;

final Uri _url =
    Uri.parse('https://sigserver4.udg.edu/apps/carpool/saml2/login');

class ChatListScreen extends StatefulWidget {
  String token;
  ChatListScreen({super.key, required this.token});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen>
    with WidgetsBindingObserver {
  String username = '';
  String? token;
  late UserCubit userCubit;
  Map<String, Usuari> usersMap = {};
  List<String> allMessages = [];
  AppLifecycleState? _notification;
  List<Usuari> users = [];
  List<ChatList> chatList = [];

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    debugPrint('--------->>>  $state');
    if (state == AppLifecycleState.resumed) {
      setState(() {
        _notification = state;
      });
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void initState() {
    // debugPrint('widget token: ${widget.token}');
    getUsers().then((response) async {
      String utf8Response = Utf8Decoder().convert(response.bodyBytes);

      users = usuariFromJson(utf8Response);

      users.forEach((u) {
        usersMap[u.pk.toString()] = u;
      });

      getChatList().then((response) {
        String utf8Response = Utf8Decoder().convert(response.bodyBytes);
        debugPrint('chat list utf8 response $utf8Response');
        chatList = chatListFromJson(utf8Response);
        setState(() {});
      });
    });

    if (kIsWeb) {
      debugPrint('WEB: ChatList before set user cubit');
      PushNotifications.getFCMToken().then((value) {
        token = value;
        debugPrint('token received: $token');
        // userCubit.setUser(User(username: 'u8839485', token: token));
      });
    } else {
      getTokenFromStorage().then((value) {
        debugPrint('DEVICE: ChatList before set user cubit');
        setState(() {
          token = value;
          // userCubit.setUser(User(username: 'u8839485', token: token));
        });
      });
    }

    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  Future<http.Response> getUsers() {
    return http.get(
        Uri.parse('https://sigserver4.udg.edu/apps/carpool/api/user/'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Token ${widget.token}'
        });
  }

  Future<http.Response> getChatList() {
    return http.get(
        Uri.parse('https://sigserver4.udg.edu/apps/carpool/api/chats/mine/'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Token ${widget.token}'
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text('ChatList')),
        body: Center(
          child: Column(
            children: [
              // Text('From secure storage $username'),
              Text('Home Screen'),
              ElevatedButton(
                onPressed: () {
                  _launchUrl();
                },
                child: Text('Login'),
              ),
              ElevatedButton(
                onPressed: () {
                  context.push('/message');
                },
                child: Text('Go to message'),
              ),
              ElevatedButton(
                onPressed: () {
                  context.push('/getToken');
                },
                child: Text('Get Token'),
              )
            ],
          ),
        ));
  }
}

Future<void> _launchUrl() async {
  if (kIsWeb) {
    debugPrint('open in web same tab');
    web.window.open(_url.toString(), '_self');
  } else {
    if (!await launchUrl(_url, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $_url');
    }
  }
}
