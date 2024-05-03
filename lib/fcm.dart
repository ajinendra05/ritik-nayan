// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:http/http.dart' as http;

// const AndroidNotificationChannel channel = AndroidNotificationChannel(
//     'high_importance_channel', // id
//     'High Importance Notifications', // title
//     // 'This channel is used for sending notifications.', // description
//     importance: Importance.high,
//     playSound: true);

// final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
//     FlutterLocalNotificationsPlugin();
// Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
//   await Firebase.initializeApp();
// }

// void setNotificationSetting() async {
//   var androisinitialize =
//       const AndroidInitializationSettings('@mipmap/ic_launcher');
//   var initializeionSettings =
//       InitializationSettings(android: androisinitialize);
//   await flutterLocalNotificationsPlugin.initialize(initializeionSettings);

//   FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

//   await flutterLocalNotificationsPlugin
//       .resolvePlatformSpecificImplementation<
//           AndroidFlutterLocalNotificationsPlugin>()
//       ?.createNotificationChannel(channel);

//   await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
//     alert: true,
//     badge: true,
//     sound: true,
//   );

//   FirebaseMessaging.instance.requestPermission(
//     alert: true,
//     announcement: false,
//     badge: true,
//     carPlay: false,
//     criticalAlert: false,
//     provisional: false,
//     sound: true,
//   );
// }

// class FCM {
//   final messaging = FirebaseMessaging.instance;
//   String? tokenCollectionName;
//   String? tokenDocumentName;

//   FCM() {
//     setNotificationSetting();

//     FirebaseMessaging.onMessage.listen((RemoteMessage message) {
//       RemoteNotification notification = message.notification!;
//       AndroidNotification? android = message.notification!.android;
//       if (android != null) {
//         flutterLocalNotificationsPlugin.show(
//             notification.hashCode,
//             notification.title,
//             notification.body,
//             NotificationDetails(
//               android: AndroidNotificationDetails(channel.id, channel.name,
//                   color: Colors.blue,
//                   playSound: true,
//                   icon: '@mipmap/ic_launcher'),
//             ));
//       }
//     });

// //when token refreshed
//     FirebaseMessaging.instance.onTokenRefresh.listen((event) {
//       if (tokenCollectionName != null && tokenDocumentName != null) {
//         updateToken(
//             collection: tokenCollectionName ?? "",
//             document: tokenDocumentName ?? "");
//       }
//     });
//   }

//   ///Will be updated in the document with the field as token
//   updateToken({@required String collection, @required String document}) async {
//     tokenCollectionName = collection;
//     tokenDocumentName = document;
//     FirebaseFirestore.instance.collection(collection).doc(document).update({
//       "token": FieldValue.arrayUnion([await messaging.getToken()])
//     });
//   }

//   //Send Notification
//   Future<bool> pushNotifications({
//     @required String token,
//     @required String title,
//     @required String body,
//   }) async {
//     String dataNotifications = '{ "to" : "$token",'
//         ' "notification" : {'
//         ' "title":"$title",'
//         '"body":"$body"'
//         ' }'
//         ' }';

//     await http.post(
//       Uri.parse('https://fcm.googleapis.com/fcm/send'),
//       headers: <String, String>{
//         'Content-Type': 'application/json',
//         'Authorization':
//             'key= AAAABUM20EE:APA91bE8c5a4VvY04Irpt8QHDL3vwHWsR4rp0eLnbh51QoqVNUCNXZ1Qx9HI1qzKjNLbAGrEKO5SeM9stRt2tMt1WKMLPtETxWiGZSZRM2mr4J1F20s__rBkPzh7tv1oa3bGfee0oOL4',
//       },
//       body: dataNotifications,
//     );
//     return true;
//   }
// }
