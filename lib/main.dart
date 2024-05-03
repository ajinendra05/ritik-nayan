import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:wellnesswarriors/constant/fixApi.dart';
import './Modal/psycoAccount.dart';
import './bookingConfiramtion.dart';
import './config.dart';
import './constant/globalKey.dart';
import './dashboard.dart';
import './dashtry.dart';
import './forget_password_user.dart';
import './imagesolution.dart';
import './loginscreen.dart';
import './navbar.dart';
import './notificationservice.dart';
import './otp.dart';
import './psycoLogin.dart';
import './psyprofile.dart';
import './pysco_dashbord.dart';
import './registeruser.dart';
import './resetpassword.dart';
import './splashscreen.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

import 'package:firebase_core/firebase_core.dart';
//import 'package:flutter_application_1/splashScreen.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:shared_preferences/shared_preferences.dart';
import 'constant/constant.dart';

import 'Modal/userAccount.dart';
import 'OrderHistory.dart';
import 'notificationScreen.dart';

late SharedPreferences prefs;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (kIsWeb) {
  } else {
    await Firebase.initializeApp();
    NotificationServices _notificationService = NotificationServices();
    _notificationService.firebaseInIt();
    _notificationService.requestNotificationPermission();
    _notificationService.setUpInterFaceMessage();
    // NotificationServices().NotificationContain();
    // await FirebaseAppCheck.instance
    //     // Your personal reCaptcha public key goes here:
    //     .activate(
    //   androidProvider: AndroidProvider.debug,
    //   appleProvider: AppleProvider.debug,
    //   webProvider:
    //       ReCaptchaV3Provider('6Lemcn0dAAAAABLkf6aiiHvpGD6x-zF3nOSDU2M8'),
    // );
    // NotificationServices _notificationService = NotificationServices();
    // _notificationService.requestNotificationPermission();
    // _notificationService.getDeviceToken();
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  }

  tz.initializeTimeZones();
  prefs = await SharedPreferences.getInstance();
  fetchRazorPayApi();
  var token = prefs.getString('token') ?? "";
  runApp(flutterApp());
}

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
}

class flutterApp extends StatelessWidget {
  flutterApp({
    Key? key,
  }) : super(key: key);

  void initState() {}

  @override
  Widget build(BuildContext context) {
    var token = prefs.getString('token') ?? "";
    var account = prefs.getString('account') ?? "";
    if (token != "") {
      if (account == 'U') {
        userData.loadUser().then((value) {
          notificationService.getDeviceToken();
        });
      } else {
        psycoData.loadUser().then((value) {
          notificationService.getDeviceToken();
        });
      }
    }

    return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: "Wellness Warriors",
        theme:
            ThemeData(primarySwatch: Colors.amber, primaryColor: Colors.amber),
        // home: Orderhistory(),
        // home: dashtry(),
        // home: ResetPasswordScreen(),
        // home: otpScreen(otpNum: 154269),
        // home: NotificationScreen(),
        home: (token != "")
            ? (account == 'U')
                ? const dashtry()
                : const PscDashBord()
            : loginScreen(),
        navigatorKey: GlobalVariable.navigatorkey);
  }
}
