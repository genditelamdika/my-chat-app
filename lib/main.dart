import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:get/get.dart';
import 'package:mychat/Screens/auth.dart';
// import 'package:mychat/Screens/chat.dart';
import 'package:mychat/Screens/chat_baru.dart';
import 'package:mychat/Screens/splash.dart';
import 'package:mychat/analytycs_engine.dart';
import 'package:mychat/call/callPage.dart';
// import 'package:mychat/firebase_options.dart';
import 'package:mychat/menu/menu.dart';
import 'package:camera/camera.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Stripe.publishableKey = "pk_test_51PfzAg2MkuQG9xLywVd9ljpA0aghLbdKoTSXR5Gc6Yc9BpgCZhlQJGHw5tJvJaDC7Mq5l51H6Zt8371biGU0lIoE00KTWUU0sj"
;  await AnalyticsEngine.init();
  final cameras = await availableCameras();
  final firstCamera = cameras.first;
  
  // await Firebase.initializeApp(
  //   options: DefaultFirebaseOptions.currentPlatform,
  // );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData().copyWith(
            useMaterial3: true,
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color.fromARGB(255, 63, 17, 177),
            )),
        // home: AuthScreen(),
        home: StreamBuilder(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const SplashScreen();
            }
            if (snapshot.hasData) {
              return  ResponsiveNavBarPage();
            }
            return const AuthScreen();
          },
        ),
        routes:{
          ChatScreenn.routeName:(context) =>  ChatScreenn(),
          // CallPage.routeName:(context) =>  CallPage(callID: '',userID: '',userName: '',),
        });
  }
}
