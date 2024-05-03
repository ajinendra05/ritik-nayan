import 'dart:convert';
import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:wellnesswarriors/config.dart';
import 'package:wellnesswarriors/main.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:shared_preferences/shared_preferences.dart';

class userData {
  static String id = '';
  static String name = '';
  static String email = '';
  static String imgPath = '';
  static double walletbalance = -1;
  static Future<void> loadImageUrl() async {
    try {
      final refrence = FirebaseStorage.instance.ref().child('userImage');
      final upldImg = refrence.child('${userData.id}.jpg');
      imgPath = await upldImg.getDownloadURL();
    } catch (e) {
      // Fluttertoast.showToast(msg: "Network Error!2");
    }
  }

  static Future<void> getWalletBalance() async {
    var prefs = await SharedPreferences.getInstance();

    var myToken = prefs.getString('token') ?? "";
    var cookies = [
      'token=${myToken}',
    ];

    var headers = {
      'Cookie': cookies.join('; '),
      'Content-Type': 'application/json'
    };

    final url = "$getWalletBalnce?userId=${userData.id}";
    final uri = Uri.parse(url);

    final response = await http.get(
      uri,
      headers: headers,
    );

    if (response.statusCode == 200) {
      var json = jsonDecode(response.body);
      userData.walletbalance = json['walletBalance'].toDouble();
    } else {
      debugPrint('Network Error');
      // Fluttertoast.showToast(msg: "Network Error!");
    }
  }

  static Future<void> loadUser() async {
    //token
    prefs = await SharedPreferences.getInstance();
    var myToken = prefs.getString('token') ?? "";
    Map<String, dynamic> jwtDecoderToken = JwtDecoder.decode(myToken);
    id = jwtDecoderToken['userId'];
    final url = '${userProfile}?userId=${id}';
    final uri = Uri.parse(url);
    try {
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        var json = jsonDecode(response.body);
        name = json['name'];
        email = json['email'];

        // imgPath = json['imagePath'];
        walletbalance = json['walletBalance'];
      } else {
        //show error
        // Fluttertoast.showToast(msg: "Network Error!");
      }
    } catch (e) {
      // Fluttertoast.showToast(msg: "Network Error!");
    }
    await loadImageUrl();
    getWalletBalance();
  }
}
