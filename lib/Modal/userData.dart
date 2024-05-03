import 'dart:convert';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:wellnesswarriors/config.dart';
import 'package:wellnesswarriors/main.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:shared_preferences/shared_preferences.dart';

class userModel {
  String name = '';
  String email = '';
  String imgPath = '';
  double walletbalance = -1;
  Future<void> loadImageUrl(String id) async {
    try {
      print("1");
      final refrence = FirebaseStorage.instance.ref().child('userImage');
      final upldImg = refrence.child('${id}.jpg');
      imgPath = await upldImg.getDownloadURL();
      print("2");
    } catch (e) {
      // Fluttertoast.showToast(msg: "Network Error!2");
    }
  }

  Future<void> loadUser(String id) async {
    //token

    print(id);
    final url = '$userProfile?userId=$id';
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
    await loadImageUrl(id);
  }
}
