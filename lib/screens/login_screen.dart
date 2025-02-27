import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:go_router/go_router.dart';
import '../config/secure_storage.dart';
import 'package:web/web.dart' as web;

final Uri _url =
    Uri.parse('https://sigserver4.udg.edu/apps/carpool/saml2/login');

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  String username = '';
  @override
  void initState() {
    // TODO: implement initState
    getUsernameFromStorage().then((value) {
      setState(() {
        username = value;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text('LOGIN PAGE')),
        body: Center(
          child: Column(
            children: [
              Text('From secure storage $username'),
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
