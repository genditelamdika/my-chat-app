import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mychat/widgets/user_image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

final _firebase = FirebaseAuth.instance;

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final formKey = GlobalKey<FormState>();
  bool isLogin = true;
  var enteredEmail = '';
  var enterPassword = '';
  File? _selectedImage;
  var _isAuthentication = false;
  var enteredUsername = '';
  void submit() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final isValid = formKey.currentState!.validate();
    if (!isValid || !isLogin && _selectedImage == null) {
      //show errro message
      return;
    }

    formKey.currentState!.save();
    try {
      setState(() {
        _isAuthentication = true;
      });
      if (isLogin) {
        final userCredentials = await _firebase.signInWithEmailAndPassword(
            email: enteredEmail, password: enterPassword);
        saveUsername(enteredEmail);

        // print(userCredentials);
        // log users
      } else {
        final userCredentials = await _firebase.createUserWithEmailAndPassword(
            email: enteredEmail, password: enterPassword);
        final storageRef = FirebaseStorage.instance
            .ref()
            .child('user_images')
            .child('${userCredentials.user!.uid}.jpg');
        await storageRef.putFile(_selectedImage!);
        print("firebasestore2");
        final imageUrl = await storageRef.getDownloadURL();
        print("firebasestore1");
        print(imageUrl);
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userCredentials.user!.uid)
            .set({
          'id': userCredentials.user!.uid,
          'username': enteredUsername,
          'email': enteredEmail,
          'image_url': imageUrl,
        });
        saveUsername(enteredEmail);

        //  await FirebaseFirestore.instance
        //     .collection('users')
        //     .doc(userCredentials.user!.uid)
        //     .set({'username': 'to bee done. . .',
        //   'email': enteredEmail,
        //   'image_url': imageUrl,});
        print("firebasestore");
      }
    } on FirebaseAuthException catch (error) {
      if (error.code == 'email-already-in-use') {}
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.message ?? 'Authentication failed.'),
        ),
      );
      setState(() {
        _isAuthentication = false;
      });
    }
  }

  Future<void> saveUsername(String username) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('username_login', username);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).splashColor,
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                margin: EdgeInsets.all(20),
                width: 200,
                child: Image.asset('assets/images/chat.png'),
              ),
              Card(
                margin: EdgeInsets.all(20),
                child: SingleChildScrollView(
                  child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Form(
                          key: formKey,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (!isLogin)
                                UserImagePicker(
                                  onPickedImage: (pickedImage) {
                                    _selectedImage = pickedImage;
                                  },
                                ),
                              TextFormField(
                                decoration:
                                    const InputDecoration(labelText: 'Email'),
                                keyboardType: TextInputType.emailAddress,
                                autocorrect: false,
                                textCapitalization: TextCapitalization.none,
                                validator: (value) {
                                  if (value == null ||
                                      value.trim().isEmpty ||
                                      !value.contains('@')) {
                                    return 'Please enter a valid email address.';
                                  }
                                  return null;
                                },
                                onSaved: (value) {
                                  enteredEmail = value!;
                                },
                              ),
                              if(!isLogin)
                              TextFormField(
                                  decoration:
                                      InputDecoration(labelText: 'Username'),
                                  enableSuggestions: false,
                                  validator: (value) {
                                    if (value == null ||
                                        value.isEmpty ||
                                        value.trim().length < 4) {
                                      return 'Please enter at least 4 characters';
                                    }
                                    return null;
                                  },
                                  onSaved: (value) {
                                    enteredUsername = value!;
                                  }),
                              TextFormField(
                                decoration: const InputDecoration(
                                  labelText: 'Password',
                                ),
                                obscureText: true,
                                validator: (value) {
                                  if (value == null ||
                                      value.trim().length < 6 ||
                                      !value.contains('@')) {
                                    return 'Please enter a valid password.';
                                  }
                                  return null;
                                },
                                onSaved: (value) {
                                  enterPassword = value!;
                                },
                              ),
                              const SizedBox(height: 12),
                              if (_isAuthentication)
                                const CircularProgressIndicator(),
                              if (!_isAuthentication)
                                ElevatedButton(
                                    onPressed: () {
                                      submit();
                                    },
                                    child: Text(isLogin ? 'Login' : 'Signup')),
                              if (!_isAuthentication)
                                TextButton(
                                  onPressed: () {
                                    setState(() {
                                      // submit();
                                      isLogin = !isLogin;
                                    });
                                  },
                                  child: Text(isLogin
                                      ? 'Create Acount'
                                      : 'ready have acount'),
                                )
                            ],
                          ))),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
