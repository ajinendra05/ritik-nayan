import 'dart:convert';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:wellnesswarriors/config.dart';
import 'package:wellnesswarriors/main.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:shared_preferences/shared_preferences.dart';

class psycoData {
  static String id = '';
  static String name = '';
  static String email = '';
  static String imgPath = '';
  static String qualification = '';
  static String about = '';
  static int chargespm = 0;
  static List disorders = [];
  static double walletbalance = -1;
  static Future<void> loadImageUrl() async {
    try {
      final refrence = FirebaseStorage.instance.ref().child('userImage');
      final upldImg = refrence.child('${psycoData.id}.jpg');
      imgPath = await upldImg.getDownloadURL();
    } catch (e) {
      // Fluttertoast.showToast(msg: "Network Error!2");
    }
  }

  static Future<void> loadUser() async {
    //token
    prefs = await SharedPreferences.getInstance();
    var myToken = prefs.getString('token') ?? "";
    Map<String, dynamic> jwtDecoderToken = JwtDecoder.decode(myToken);
    id = jwtDecoderToken['userId'];
    print(id);
    final url = "${psyprofiledata}?psychologistId=${id}";
    final uri = Uri.parse(url);

    try {
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        var json = jsonDecode(response.body);
        name = json['name'];
        email = json['email'];

        // imgPath = json['imagepath'];
        qualification = json['qualification'];
        about = json['about'];
        chargespm = json['chargespm'];
        disorders = json['disorders'];
      } else {
        //show error
        // Fluttertoast.showToast(msg: "Network Error!");
      }
    } catch (e) {
      // Fluttertoast.showToast(msg: "Network Error!" + e.toString());
    }
    await loadImageUrl();
  }
}
