import 'dart:convert';

import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:fluttertoast/fluttertoast.dart';

import 'Modal/userAccount.dart';
import 'config.dart';

class UserImagePicker extends StatefulWidget {
  final void Function(File x) imagePickerFn;
  const UserImagePicker({super.key, required this.imagePickerFn});

  @override
  State<UserImagePicker> createState() => _UserImagePickerState();
}

class _UserImagePickerState extends State<UserImagePicker> {
  
  bool pickIsClicked = false;
  var backImage;
  Widget circularAvatarWidget = const Icon(
    Icons.camera_alt_outlined,
    size: 40,
  );
  void pickImage() async {
    setState(() {
      pickIsClicked = false;
    });
    final clickedImage = await ImagePicker().pickImage(
        source: ImageSource.camera, preferredCameraDevice: CameraDevice.front);
    setState(() {
      pickIsClicked = true;
      backImage = FileImage(
        File(clickedImage!.path),
      );
    });

    return widget.imagePickerFn(File(clickedImage!.path));
  }

  Future<void> updateImage(String name) async {
    print("hellobhai");
    var prefs = await SharedPreferences.getInstance();
    var myToken = prefs.getString('token') ?? "";
    print(myToken);
    var cookies = [
      'token=${myToken}',
    ];

    var headers = {
      'Cookie': cookies.join('; '),
      'Content-Type': 'application/json'
    };
    var url = '$updateUserProfile{userData.id}';
    final uri = Uri.parse(url);
    try {
      final regBody = {"username": "Gulshan04"};
      final response = await http.post(uri, headers: headers);
      if (response.statusCode == 200) {
        var json = jsonDecode(response.body);

        await userData.loadUser();

        setState(() {
          pickIsClicked = true;
        });
      } else {
        debugPrint('Network Error');
        Fluttertoast.showToast(msg: "Network Error!");
      }
    } catch (e) {
      print(e);
      Fluttertoast.showToast(msg: "Network Error!");
    }
    setState(() {
      pickIsClicked = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 110,
      width: 110,
      child: Stack(
        // mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(
            child: CircleAvatar(
              backgroundColor: Theme.of(context).primaryColor.withOpacity(0.6),
              backgroundImage: backImage,
              radius: 45,
              child: pickIsClicked ? null : circularAvatarWidget,
            ),
          ),
          Container(
            alignment: Alignment.bottomRight,
            child: IconButton(
              onPressed: pickImage,
              icon: Icon(
                pickIsClicked ? Icons.replay : Icons.camera,
                size: 35,
              ),
              // label: pickIsClicked
              //     ? const Text("Click\nAgain")
              //     : const Text('Click')),
            ),
          ),
        ],
      ),
    );
    // return ElevatedButton(
    //   style: ElevatedButton.styleFrom(
    //       shape: const CircleBorder(),
    //       shadowColor: const Color.fromARGB(0, 255, 193, 7),
    //       backgroundColor: const Color.fromARGB(0, 255, 255, 255)),
    //   onPressed: pickIsClicked ? null : pickImage,
    //   child: CircleAvatar(
    //     backgroundColor: Theme.of(context).primaryColor.withOpacity(0.6),
    //     backgroundImage: backImage,
    //     radius: 45,
    //     child: pickIsClicked ? null : circularAvatarWidget,
    //   ),
    // );
  }
}
