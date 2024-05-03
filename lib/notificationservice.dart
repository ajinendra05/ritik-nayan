import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import './Modal/psycoAccount.dart';
import './Modal/userAccount.dart';
import './OrderHistory.dart';
import './bookingConfiramtion.dart';
import './bookingConfirmation_Psyco.dart';
import './constant/globalKey.dart';
import './psycoOrderHistory.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

// import 'package:timezone/data/latest.dart' as tz;

class NotificationServices {
  final FlutterLocalNotificationsPlugin _notification =
      FlutterLocalNotificationsPlugin();
  FirebaseMessaging messaging = FirebaseMessaging.instance;

  // Future<void> NotificationContain() async {
  //   AndroidInitializationSettings initializationSettings =
  //       const AndroidInitializationSettings('launch_background');

  //   var initialisationSettingIOS = DarwinInitializationSettings(
  //     requestAlertPermission: true,
  //     requestSoundPermission: true,
  //     requestBadgePermission: true,
  //     onDidReceiveLocalNotification: (id, title, body, payload) async {},
  //   );
  //   var initialisSetting = InitializationSettings(
  //       android: initializationSettings, iOS: initialisationSettingIOS);

  //   await _notification.initialize(
  //     initialisSetting,
  //     onDidReceiveNotificationResponse: (details) {},
  //   );
  // }

  // NotificationDetails notificationDetails() {
  //   return const NotificationDetails(
  //       android: AndroidNotificationDetails('channelId', 'channelName'),
  //       iOS: DarwinNotificationDetails());
  // }

  // Future showNotification(
  //     {int id = 0, String? title, String? body, String? payload}) async {
  //   return _notification.show(id, title, body, notificationDetails());
  // }

  // Future scheduleNotification(
  //     {int id = 0,
  //     String? title,
  //     String? body,
  //     String? payload,
  //     DateTime? dateTime}) async {
  //   // return _notification.zonedSchedule(id, title, body, tz.TZ , notificationDetails(), uiLocalNotificationDateInterpretation: uiLocalNotificationDateInterpretation)
  //   return _notification.show(id, title, body, notificationDetails());
  // }

  void requestNotificationPermission() async {
    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );
    NotificationSettings settings = await messaging.requestPermission(
        alert: true,
        announcement: true,
        badge: true,
        carPlay: true,
        criticalAlert: true,
        sound: true,
        provisional: true);
    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print("Notification Granted");
    } else if (settings.authorizationStatus ==
        AuthorizationStatus.provisional) {
      print("provisonal notification granted");
    } else {
      print("notifiaction not granted");
    }
  }

  // Future<void> _firebaseMessagingBackgroundHandler(
  //     RemoteMessage message) async {
  //   await Firebase.initializeApp();
  // }

  Future<void> initNotification(RemoteMessage message) async {
    var androidInitalisationSetting =
        const AndroidInitializationSettings('@mipmap/ic_launcher');
    var iosInitalisationSetting = const DarwinInitializationSettings();
    var initialisSetting = InitializationSettings(
        android: androidInitalisationSetting, iOS: iosInitalisationSetting);

    await _notification.initialize(
      initialisSetting,
      onDidReceiveNotificationResponse: (details) {
        handleMessage(message);
      },
    );
    // FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  }

  void firebaseInIt() {
    print("fireInIt");
    FirebaseMessaging.onMessage.listen((event) {
      print("listen new message");
      try {
        initNotification(event);
        showNotification2(event);
      } catch (e) {
        print(e);
      }
    });
  }

  Future<void> showNotification2(RemoteMessage message) async {
    print("show new message");

    //channel
    AndroidNotificationChannel androidNotificationChannel =
        const AndroidNotificationChannel(
            'high_importance_channel', // id
            'High Importance Notifications', // titl
            importance: Importance.max);
    //details
    AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
      androidNotificationChannel.toString(),
      androidNotificationChannel.name.toString(),
      importance: Importance.high,
      priority: Priority.high,
      ticker: 'ticker',
    );

    DarwinNotificationDetails darwinNotificationDetails =
        const DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    NotificationDetails notificationDetails = NotificationDetails(
        android: androidNotificationDetails, iOS: darwinNotificationDetails);
    _notification.show(0, message.notification!.title.toString(),
        message.notification!.body.toString(), notificationDetails);
    print("show end message");
  }

  void handleMessage(RemoteMessage message) async {
    print("handle new message");
    var prefs = await SharedPreferences.getInstance();
    var account = prefs.getString('account') ?? "";
    if (message.data['type'].toString() == 'Booking') {
      try {
        if (account == 'U') {
          Navigator.push(
              GlobalVariable.navigatorkey.currentContext!,
              MaterialPageRoute(
                builder: (context) => BookingConfirmation(
                    slot: message.data['slot'].toString(),
                    sessionId: message.data['sesionId'].toString(),
                    psycologistID: message.data['psycologistID'].toString(),
                    userID: message.data['userID'].toString(),
                    date: message.data['date'].toString(),
                    sessionStatus: message.data['sessionStatus'].toString(),
                    meetLink: message.data['meetLink'].toString()),
              ));
        } else {
          Navigator.push(
              GlobalVariable.navigatorkey.currentContext!,
              MaterialPageRoute(
                builder: (context) => BookingConfirmationPsyco(
                  slot: message.data['slot'].toString(),
                  psycologistID: message.data['psycologistID'].toString(),
                  userID: message.data['userID'].toString(),
                  date: message.data['date'].toString(),
                  sessionStatus: message.data['sessionStatus'].toString(),
                  meetLink: message.data['meetLink'].toString(),
                  sesionId: message.data['sesionId'].toString(),
                ),
              ));
        }
      } catch (e) {
        debugPrint(e.toString());
      }
    }
    if (message.data['type'].toString() == 'Transection') {
      try {
        if (account == 'U') {
          Navigator.push(GlobalVariable.navigatorkey.currentContext!,
              MaterialPageRoute(builder: (context) => const Orderhistory()));
        } else {
          Navigator.push(
              GlobalVariable.navigatorkey.currentContext!,
              MaterialPageRoute(
                  builder: (context) => const PsycoOrderHistory()));
        }
      } catch (e) {
        debugPrint(e.toString());
      }
    }
    print("handle end message");
  }

  Future<void> setUpInterFaceMessage() async {
    print("setup new message");

    //when app is terminated
    RemoteMessage? initialMessage =
        await FirebaseMessaging.instance.getInitialMessage();

    if (initialMessage != null) {
      // initNotification(initialMessage);
      showNotification2(initialMessage);
      handleMessage(initialMessage);
    }

    //when app is inbackground
    FirebaseMessaging.onMessageOpenedApp.listen((event) {
      // initNotification(event);
      showNotification2(event);
      handleMessage(event);
    });
    print("setup end message");
  }

  //Send Notification
  Future<bool> pushNotifications({
    required String token,
    required String title,
    required String body,
    required var data,
  }) async {
    print("push new message");

    var dataNotifications = {
      "to": token,
      "priority": 'high',
      "notification": {
        "title": title,
        "body": body,
      },
      "data": data
    };
    print(jsonEncode(dataNotifications));
    try {
      var response = await http.post(
        Uri.parse('https://fcm.googleapis.com/fcm/send'),
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Authorization':
              'key=AAAAKsXX9LM:APA91bHxPQkDaVD_aLB1vwmDflu2eFB84ls-N1_6G9Bh2rhQ7Rp26dl9Nmb5vwzan6V_yE78EMXXwY7LcGQeaS4WXE3dfZM5xzPJ-qOAIoHh3nhxTI30dghFHGgT_y7f_Af_K8UO4nyP',
        },
        body: jsonEncode(dataNotifications),
      );
      print(response.statusCode);
      print(response.body);
    } catch (e) {
      print(e);
    }

    return true;
  }

  Future<void> getDeviceToken() async {
    String? token = await messaging.getToken();
    debugPrint("tokens : ");
    debugPrint(token);
    saveTokenToDatabase(token ?? "");
    // return token!;
  }

  void isTokenRefresh() {
    messaging.onTokenRefresh.listen(saveTokenToDatabase);
  }

  Future<void> saveTokenToDatabase(String token) async {
    var prefs = await SharedPreferences.getInstance();
    var account = prefs.getString('account') ?? "";
    if (account == 'U') {
      try {
        await userData.loadUser();
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userData.id)
            .set({
          'tokens': FieldValue.arrayUnion([token]),
        });
      } catch (e) {
        print("error");
        print(e);
      }
    } else {
      await psycoData.loadUser();
      await FirebaseFirestore.instance
          .collection('users')
          .doc(psycoData.id)
          .set({
        'tokens': FieldValue.arrayUnion([token]),
      });
    }
  }

  Future<String> getUserDeviceToken(String id) async {
    var token;
    try {
      await FirebaseFirestore.instance
          .collection("users")
          .doc(id)
          .get()
          .then((value) {
        if (value.data() != null) {
          token = value.data()?['tokens'];
        }
      });
    } catch (e) {
      print("error ye hai : $e , $id");
    }
  
    return token[0];
  }
}
