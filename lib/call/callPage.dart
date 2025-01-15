// import 'dart:math';

// import 'package:flutter/material.dart';
// import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';

// final userId = Random().nextInt(9999);

// class CallPage extends StatelessWidget {
//   static const routeName = '/callPage';
//   final String userID;
//   final String userName;
//   final String callID;

//   CallPage({
//     required this.userID,
//     required this.userName,
//     required this.callID,
//   });

//   // const CallPage({Key? key, required this.callID}) : super(key: key);
//   // final String callID;

//   @override
//   Widget build(BuildContext context) {
//     return ZegoUIKitPrebuiltCall(
//       appID:
//           1163753858, // Fill in the appID that you get from ZEGOCLOUD Admin Console.
//       appSign:
//           "52f227b0934857b849297e5270bf1dd1486db82ccc90e72812fec214fd0279cb", // Fill in the appSign that you get from ZEGOCLOUD Admin Console.
//       userID: userID,
//       userName: userName,
//       callID: callID,
//       // You can also use groupVideo/groupVoice/oneOnOneVoice to make more types of calls.
//       config: ZegoUIKitPrebuiltCallConfig.oneOnOneVideoCall(),
//     );
//   }
// }
