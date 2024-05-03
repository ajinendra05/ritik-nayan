import 'dart:convert';

import 'package:flutter/material.dart';
import './config.dart';
import './constant/fixApi.dart';
import './dialog.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'Modal/userAccount.dart';
import 'constant/constant.dart';

class paymentGateway {
  final Razorpay razorpay = Razorpay();
  BuildContext context;
  paymentGateway({required this.context});
  var amountTransfered;
  Future<void> handlePaymentSuccess(PaymentSuccessResponse response) async {
    // Navigator.pop(context);
    // Do something when payment succeeds

    await rechargeWalletBalance(userData.id, amountTransfered.toDouble(),
        DateTime.now(), response.paymentId ?? "not mentioned");
  }

  void handlePaymentError(PaymentFailureResponse response) {
    Navigator.pop(context);
    // Do something when payment fails

    PaymentFailedDialog(context);
  }

  void handleExternalWallet(ExternalWalletResponse response) {
    Navigator.pop(context);
    // Do something when an external wallet is selected
  }

  void openCheckout(int amount) {
    amountTransfered = amount;
    var options = {
      "key": razorpayApiKey.toString(),
      "amount": amount * 100,
      "name": "Wellness-Warriors",
      "description": " this is the test payment ajji",
      "timeout": 120,
      "currency": "INR",
      "prefill": {
        "contact": "11111111111",
        "email": "test@abc.com",
        "options": {
          "checkout": {
            "method": {
              "netbanking": "1",
              "card": "1",
              "upi": "1",
              "wallet": "1"
            }
          }
        }
      }
    };
    razorpay.open(options);
  }

  Future<void> rechargeWalletBalance(
      String id, double amount, DateTime date, String paymentId) async {
    var prefs = await SharedPreferences.getInstance();
    var myToken = prefs.getString('token') ?? "";
    var cookies = [
      'token=$myToken',
    ];

    var headers = {
      'Cookie': cookies.join('; '),
      'Content-Type': 'application/json'
    };
    final url = getWalletBalnce;
    final uri = Uri.parse(url);
    final bodyDate = {
      "userId": id,
      "amount": amount,
      "date": date.toString(),
      "paymentId": paymentId
    };
    final jsonBody = jsonEncode(bodyDate);
    final response = await http.post(uri, body: jsonBody, headers: headers);
    try {
      if (response.statusCode == 200) {
        var json = jsonDecode(response.body);
        Navigator.pop(context);
        PaymentSuccessDialog(context, amountTransfered);
        sendNotification(
            "your wallet is recharge by amount $amount RS successfully.",
            "Wallet Recharge");
      } else {
        debugPrint('Network Error');
        Fluttertoast.showToast(msg: "Network Error! Try again");
        PaymentFailedDialog(context);
      }
    } catch (e) {
      debugPrint('Network Error $e');
      Fluttertoast.showToast(msg: "Network Error! Try again");
      PaymentFailedDialog(context);
    }

    await getWalletBalance();
    userData.loadUser();
  }

  Future<void> getWalletBalance() async {
    var prefs = await SharedPreferences.getInstance();
    var myToken = prefs.getString('token') ?? "";
    var cookies = [
      'token=$myToken',
    ];

    var headers = {
      'Cookie': cookies.join('; '),
      'Content-Type': 'application/json'
    };

    final url = "$getWalletBalnce?userId=${userData.id}";
    print(url);
    final uri = Uri.parse(url);

    final response = await http.get(
      uri,
      headers: headers,
    );

    if (response.statusCode == 200) {
      var json = jsonDecode(response.body);
      userData.walletbalance = json['walletBalance'].toDouble();
      // sendNotification('Your wallet is recharge succefully', 'Wallet Rechsrge');
    } else {
      debugPrint('Network Error');
      Fluttertoast.showToast(msg: "Network Error! Try again");
    }
    // userData.loadUser();
  }

  void sendNotification(String msg, String title) async {
    var userToken = await notificationService.getUserDeviceToken(userData.id);
    var data = {
      'type': 'Transection',
    };
    saveNotificationuser(
        userID: userData.id, message: msg, title: title, data: data);
    notificationService.pushNotifications(
        token: userToken, title: title, body: msg, data: data);
    // notificationService.pushNotifications(
    //     token: psycoToken, title: title, body: msg, data: data);
    print("sent");
  }
}
