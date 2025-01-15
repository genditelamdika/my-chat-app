
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mychat/analytycs_engine.dart';
import 'package:mychat/call/callPage.dart';
import 'package:mychat/model/model_message.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChatScreenn extends StatefulWidget {
  static const routeName = '/chat_screenn';

  const ChatScreenn({super.key});

  @override
_ChatScreennState createState() => _ChatScreennState();
}

class _ChatScreennState extends State<ChatScreenn> {
  final TextEditingController _messageController = TextEditingController();
  String currentUserUsername = ''; // Inisialisasi dengan nilai default
  late String otherUsername;
  String usernameFirebaseLogin = "";
  late String newUsername;
  
  String chatId = '';
  String currentUserId = '';
  late CollectionReference chatCollection;
  late Future<void> _init;
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  @override
  void initState() {
    super.initState();

    _init = _initializeUser();
    // Dapatkan token perangkat
    _firebaseMessaging.getToken().then((String? token) {
      assert(token != null);
      print("Device Token: $token");
    });

    // Konfigurasi foreground notification
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (message.data['type'] == 'call') {
        _handleIncomingCall(message.data);
      } else {
        _showNotificationDialog(message);
        print("Notification: ${message.notification?.title}");
      }
    });

    // Konfigurasi background/terminated notification
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      if (message.data['type'] == 'call') {
        _navigateToCallPage(message.data);
      } else {
        // Handle other types of messages
      }
    });
  }

  Future<void> _initializeUser() async {
    await getUsername();
    await getusernameFirebase();
    await getCurrentUserId();
    setState(() {});
  }

  Future<void> getUsername() async {
    final prefs = await SharedPreferences.getInstance();
    currentUserUsername =
        prefs.getString('username_login') ?? 'default_username';
    print(currentUserUsername);
  }

  Future<String?> getCurrentUserId() async {
    User? user = FirebaseAuth.instance.currentUser;
    currentUserId = user?.uid ?? '';
    print(user?.uid);

    return user
        ?.uid; // Mengembalikan UID pengguna atau null jika tidak terautentikasi
  }
  Future<void> getusernameFirebase() async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null ) {
      DocumentSnapshot userDOc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();

      if (userDOc.exists) {
        setState(() {
          usernameFirebaseLogin = userDOc.get('username');
        });

    }
  }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    getCurrentUserId();
    final args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    otherUsername = args['email'];
    chatId = args['id'];
    newUsername = args['username'];
    print("romantis");
    print(chatId);

    chatCollection = FirebaseFirestore.instance
        .collection('chats')
        .doc(_getChatId())
        .collection('messages');
    print({
      'currentUserUsername': currentUserId,
      'otherid': chatId,
      'chatId': _getChatId()
    });
  }

  String _getChatId() {
    // Buat ID unik untuk percakapan antara dua pengguna berdasarkan username mereka
    return currentUserId.compareTo(chatId) <= 0
        ? '$currentUserId-$chatId'
        : '$chatId-$currentUserId';
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;

    final message = Message(
      senderUsername:
          usernameFirebaseLogin, // Menggunakan username pengguna sended,
      receiverUsername: newUsername,
      text: _messageController.text.trim(),
      timestamp: Timestamp.now(),
    );

    await chatCollection.add(message.toMap());
    AnalyticsEngine.counterPressed(newUsername);
    _messageController.clear();
  }

  void _handleIncomingCall(Map<String, dynamic> data) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Incoming Call'),
        content: Text('You have an incoming call from ${data['callerName']}'),
        actions: <Widget>[
          TextButton(
            child: Text('Reject'),
            onPressed: () => Navigator.of(context).pop(),
          ),
          TextButton(
            child: Text('Accept'),
            onPressed: () {
              Navigator.of(context).pop();
              _navigateToCallPage(data);
            },
          ),
        ],
      ),
    );
  }

  void _navigateToCallPage(Map<String, dynamic> data) {
    // Navigator.push(
    //   context,
    //   MaterialPageRoute(
    //     builder: (context) => CallPage(
    //       userID: currentUserId,
    //       userName: currentUserUsername,
    //       callID: data['callID'],
    //     ),
    //   ),
    // );
  }

  void _showNotificationDialog(RemoteMessage message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        content: ListTile(
          title: Text(message.notification?.title ?? ''),
          subtitle: Text(message.notification?.body ?? ''),
        ),
        actions: <Widget>[
          TextButton(
            child: Text('OK'),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _init,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            appBar: AppBar(
              title: Text('Loading...'),
            ),
            body: Center(child: CircularProgressIndicator()),
          );
        } else {
          return Scaffold(
            appBar: AppBar(
              title: Row(children: [
                Text('Chat with $newUsername'),
                Spacer(),
                TextButton(
                  onPressed: () {
                    // Navigator.push(
                    //   context,
                    //   MaterialPageRoute(
                    //     builder: (context) => CallPage(
                    //       userID: currentUserId,
                    //       userName: currentUserUsername,
                    //       callID: _getChatId(),
                    //     ),
                    //   ),
                    // );
                  },
                  child: Icon(Icons.video_call),
                ),
                
              ]),
            ),
            body: Column(
              children: [
                Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                    stream: chatCollection
                        .orderBy('timestamp', descending: true)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator());
                      }
                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                        return Center(child: Text('No messages'));
                      }

                      final messages = snapshot.data!.docs
                          .map((doc) => Message.fromMap(
                              doc.data() as Map<String, dynamic>))
                          .toList();

                      return ListView.builder(
                        reverse: true,
                        itemCount: messages.length,
                        itemBuilder: (context, index) {
                          final message = messages[index];
                          final isMe =
                              message.senderUsername == usernameFirebaseLogin;
                          return Container(
                            margin: EdgeInsets.only(left: 15,right: 15),
                            child: Column(children: [
                              Align(
                                alignment: isMe
                                    ? Alignment.centerRight
                                    : Alignment.centerLeft,
                                child: Text(message.senderUsername),
                              ),
                              Align(
                                alignment: isMe
                                    ? Alignment.centerRight
                                    : Alignment.centerLeft,
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                      vertical: 10, horizontal: 15),
                                  decoration: BoxDecoration(
                                    color: isMe ? Colors.blue : Colors.grey,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    message.text,
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                              ),
                            ]),
                          );
                        },
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _messageController,
                          decoration: InputDecoration(
                            hintText: 'Type a message',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.send),
                        onPressed: _sendMessage,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }
      },
    );
  }
}
