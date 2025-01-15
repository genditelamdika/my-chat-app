import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:mychat/widgets/chat_message.dart';
import 'package:mychat/widgets/new_message.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChatScreen extends StatefulWidget {
  static const String routeName = 'chat_screen';
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  void setupPushNotifications() async {
    final fcm = FirebaseMessaging.instance;
    await fcm.requestPermission();

    final token = await fcm.getToken();
    print(token);
  }

  void initState() {
    // TODO: implement initState
    super.initState();
    setupPushNotifications();
  }

  Future<void> clearSharedPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text(
            'Chat',
            style: TextStyle(color: Colors.black),
          ),
          actions: [
            IconButton(
              onPressed: () {
                clearSharedPreferences();
                FirebaseAuth.instance.signOut();
              },
              icon: const Icon(Icons.exit_to_app),
              color: Colors.black,
            )
          ],
        ),
        body: const Center(
          child: Column(
            children: [
              Expanded(child: ChatMessage()),
              NewMessage(),
            ],
          ),
        ));
  }
}
