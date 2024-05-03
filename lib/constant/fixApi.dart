import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:fluttertoast/fluttertoast.dart';

import '../config.dart';

Future<void> saveNotificationuser(
    {required String userID,
    required String message,
    required String title,
    required dynamic data}) async {
  var prefs = await SharedPreferences.getInstance();
  var myToken = prefs.getString('token') ?? "";
  var cookies = [
    'token=$myToken',
  ];

  var headers = {
    'Cookie': cookies.join('; '),
    'Content-Type': 'application/json'
  };
  // =${userData.id}
  var url = notificationSave;
  final uri = Uri.parse(url);
  var rawBody = {"userId": userID, "message": message, "title": title};
  print("Notification saving");
  try {
    final response =
        await http.post(uri, headers: headers, body: jsonEncode(rawBody));
    if (response.statusCode == 200) {
      var json = jsonDecode(response.body);
    } else {
      debugPrint('Network Error12');
      debugPrint(response.body);
      Fluttertoast.showToast(msg: "Network Error!");
    }
  } catch (e) {
    Fluttertoast.showToast(msg: "Network Error!");
    print("error $e");
  }
}

Future<void> saveNotificationPsyco(
    {required String psycoID,
    required String message,
    required String title,
    required dynamic data}) async {
  var prefs = await SharedPreferences.getInstance();
  var myToken = prefs.getString('token') ?? "";
  var cookies = [
    'token=$myToken',
  ];

  var headers = {
    'Cookie': cookies.join('; '),
    'Content-Type': 'application/json'
  };
  // =${userData.id}
  var url = notificationSave;
  final uri = Uri.parse(url);
  var rawBody = {
    "psychologistId": psycoID,
    "message": message,
    "title": title
    // "data": data
  };
  try {
    final response =
        await http.post(uri, headers: headers, body: jsonEncode(rawBody));
    if (response.statusCode == 200) {
      var json = jsonDecode(response.body);
    } else {
      debugPrint('Network Error12');
      debugPrint(response.body);
      Fluttertoast.showToast(msg: "Network Error!");
    }
  } catch (e) {
    Fluttertoast.showToast(msg: "Network Error!");
    print("error $e");
  }
}

String? razorpayApiKey;

Future<void> fetchRazorPayApi() async {
  try {
    const url = razorpayApi;
    final uri = Uri.parse(url);

    final response = await http.get(uri);

    if (response.statusCode == 200) {
      var json = jsonDecode(response.body);
      razorpayApiKey = json["key1"][0]["Key"];
      print("raorrrrrrpaaaaaaaayyy $razorpayApiKey");
    } else {
      debugPrint('Network Error fetchPsyclo');
      Fluttertoast.showToast(msg: "Network Error!");
    }
  } catch (e) {
    debugPrint('Network Error fetchPsyclo');
    Fluttertoast.showToast(msg: "Network Error!");
  }
}
