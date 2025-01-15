import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mychat/Screens/chat_baru.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserListScreen extends StatefulWidget {
  @override
  _UserListScreenState createState() => _UserListScreenState();
}

class _UserListScreenState extends State<UserListScreen> {
  String? currentUserUsername = '';

  late Future<List<Map<String, dynamic>>> _allUsersFuture;
  late Future<void> init;

  @override
  void initState() {
    super.initState();

    init = _initializeUser();
    _allUsersFuture = getAllUsers();
  }

  Future<void> getUsername() async {
    final prefs = await SharedPreferences.getInstance();
    currentUserUsername =
        prefs.getString('username_login') ?? 'default_username';
    print(currentUserUsername);
  }

  Future<void> _initializeUser() async {
    await getUsername();
    setState(() {});
  }

  Future<List<Map<String, dynamic>>> getAllUsers() async {
    CollectionReference users = FirebaseFirestore.instance.collection('users');
    QuerySnapshot querySnapshot = await users.get();
    final allUsers = querySnapshot.docs
        .map((doc) => doc.data() as Map<String, dynamic>)
        .toList();
    return allUsers;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('All Users'),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _allUsersFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No users found'));
          } else {
            final users = snapshot.data!;
            return ListView.builder(
              itemCount: users.length,
              itemBuilder: (context, index) {
                final user = users[index];
                final userImage = user['image_url'];
                final userId =
                    user['id']; // Ensure your user document has an 'id' field
                final username = user['username'];
                final email = user['email'];

                var usersama = email == currentUserUsername;
                return ListTile(
                  leading: usersama
                      ? null
                      : userImage != null
                          ? CircleAvatar(
                              backgroundImage: NetworkImage(userImage),
                              backgroundColor:
                                  theme.colorScheme.primary.withAlpha(180),
                              radius: 23,
                            )
                          : CircleAvatar(
                              backgroundColor:
                                  theme.colorScheme.primary.withAlpha(180),
                              radius: 23,
                            ),
                  title: usersama ? null : Text(username),
                  onTap: () {
                    if (usersama) {
                      return;
                    } else {
                      usersama ? null : print("routesekrng");
                      print(userId);
                      Navigator.pushNamed(
                        context,
                        ChatScreenn.routeName,
                        arguments: {'email': email, 'id': userId,'username': username},
                      );
                    }
                  },
                );
              },
            );
          }
        },
      ),
    );
  }
}
