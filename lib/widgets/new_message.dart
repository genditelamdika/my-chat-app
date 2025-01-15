import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class NewMessage extends StatefulWidget {
  const NewMessage({super.key});

  @override
  State<NewMessage> createState() => _NewMessageState();
}

class _NewMessageState extends State<NewMessage> {
  final TextEditingController messageController = TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  // @override
  // void dispose() {
  //   messageController.dispose();
  //   super.dispose;
  // }

  void _submitMessage() async {
    print("bisa");
    final enteredMessage = messageController.text;

    if (enteredMessage.trim().isEmpty) {
      print('berhenti');
      return;
    }
    print('bisa2');
    final user = FirebaseAuth.instance.currentUser!;
    final userData = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();
    print('bisa3');
    FirebaseFirestore.instance.collection('users').doc(user.uid).get();
    FirebaseFirestore.instance.collection('chat').add({
      'text': enteredMessage,
      'createdAt': Timestamp.now(),
      'userId': user.uid,
      'username': userData.data()!['username'],
      'userImage': userData.data()!['image_url'],
    });
    messageController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: 15, right: 1, bottom: 14),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: messageController,
              textCapitalization: TextCapitalization.sentences,
              autocorrect: true,
              enableSuggestions: true,
              decoration: InputDecoration(labelText: 'send a message'),
            ),
          ),
          IconButton(
              color: Theme.of(context).colorScheme.primary,
              icon: Icon(Icons.send),
              onPressed: () {
                _submitMessage();
              }),
        ],
      ),
    );
  }
}
