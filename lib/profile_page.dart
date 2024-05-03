import 'dart:convert';
import 'dart:math';
import 'package:firebase_storage/firebase_storage.dart';
import './config.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:fluttertoast/fluttertoast.dart';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import './Modal/psycoAccount.dart';
import './Modal/userAccount.dart';
import 'package:google_fonts/google_fonts.dart';
import 'psycoProfileEdit.dart';
import 'widget/appbar_widget.dart';
import 'widget/button_widget.dart';
import 'widget/numbers_widget.dart';
import 'widget/profile_widget.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool loadUserDate = true;
  final ImagePicker _pickImage = ImagePicker();
  bool imgUploadStart = false;
  bool uploded = false;
  bool pickIsClicked = false;
  var backImage;
  var finalpickedfilePath;
  XFile? _pickedFile;
  CroppedFile? _croppedFile;

  Future selectPhoto() async {
    await showModalBottomSheet(
      context: context,
      builder: (context) => BottomSheet(
        onClosing: () {},
        builder: (context) => Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.camera),
              title: Text('Camera'),
              onTap: (() {
                Navigator.pop(context);
                pickImage(ImageSource.camera);
              }),
            ),
            ListTile(
              leading: Icon(Icons.filter),
              title: Text('Pick from Gallery'),
              onTap: (() {
                Navigator.pop(context);
                pickImage(ImageSource.gallery);
              }),
            )
          ],
        ),
      ),
    );
  }

  Future<void> _cropImage() async {
    if (_pickedFile != null) {
      final croppedFile = await ImageCropper().cropImage(
        sourcePath: _pickedFile!.path,
        compressFormat: ImageCompressFormat.jpg,
        compressQuality: 100,
        // uiSettings: [
        //   AndroidUiSettings(
        //       toolbarTitle: 'Cropper',
        //       toolbarColor: Colors.deepOrange,
        //       toolbarWidgetColor: Colors.white,
        //       initAspectRatio: CropAspectRatioPreset.original,
        //       lockAspectRatio: false),
        //   IOSUiSettings(
        //     title: 'Cropper',
        //   ),
        //   WebUiSettings(
        //     context: context,
        //     presentStyle: CropperPresentStyle.dialog,
        //     boundary: const CroppieBoundary(
        //       width: 520,
        //       height: 520,
        //     ),
        //     viewPort:
        //         const CroppieViewPort(width: 480, height: 480, type: 'circle'),
        //     enableExif: true,
        //     enableZoom: true,
        //     showZoomer: true,
        //   ),
        // ],
      );
      if (croppedFile != null) {
        setState(() {
          _croppedFile = croppedFile;
          finalpickedfilePath = _croppedFile!.path;
        });
      } else {
        setState(() {
          pickIsClicked = true;
          uploded = true;
        });
      }
    }
  }

  void pickImage(ImageSource source) async {
    setState(() {
      imgUploadStart = true;
    });

    final clickedImage = await ImagePicker().pickImage(
        source: source,
        preferredCameraDevice: CameraDevice.front,
        imageQuality: 50,
        maxHeight: 500,
        maxWidth: 500);

    if (clickedImage == null) {
      setState(() {
        imgUploadStart = false;
        pickIsClicked = false;
        uploded = true;
      });
      return;
    }
    await updateImage2(clickedImage.path);
  }

  Future<void> updateImage() async {
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
    var url = '$updatePsycoProfile${psycoData.id}';
    final uri = Uri.parse(url);

    try {
      final regBody = {"imagepath": psycoData.imgPath};
      final response =
          await http.post(uri, headers: headers, body: jsonEncode(regBody));
      if (response.statusCode == 200) {
        // var json = jsonDecode(response.body);

        // await userData.loadUser();
        // Fluttertoast.showToast(msg: "File Uploaded");
      } else {
        debugPrint('Network Error' + response.body);
        // Fluttertoast.showToast(msg: "Network Error!");
      }
    } catch (e) {
      print(e);
      // Fluttertoast.showToast(msg: "Network Error!");
    }
    setState(() {
      imgUploadStart = false;
    });
  }

  Future<void> updateImage2(String path) async {
    try {
      final refrence = FirebaseStorage.instance.ref().child('userImage');
      final upldImg = refrence.child('${psycoData.id}.jpg');
      await upldImg.putFile(File(path));
      await psycoData.loadImageUrl();
      updateImage();
    } catch (e) {
      Fluttertoast.showToast(msg: "Network Error!");
    }
    setState(() {
      imgUploadStart = false;
    });
  }

  @override
  void initState() {
    super.initState();
    userData.loadUser().then((value) {
      setState(() {
        loadUserDate = false;
      });
    });
    // initSharedPref();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(),
        backgroundColor: Colors.cyan.shade800,
        title: const Text('Profile'),
        elevation: 5,
      ),
      body: loadUserDate
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : ListView(
              physics: const BouncingScrollPhysics(),
              children: [
                const SizedBox(
                  height: 10,
                ),
                imgUploadStart
                    ? SizedBox(
                        width: 100,
                        child: Container(
                          height: 140,
                          width: 100,
                          decoration: BoxDecoration(
                              // color: Colors.deepOrange,
                              borderRadius: BorderRadius.circular(100)),
                          child: const Center(
                            child: CircularProgressIndicator(
                              backgroundColor: Colors.deepOrange,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      )
                    : ProfileWidget(
                        imagePath: psycoData.imgPath, onClicked: selectPhoto),
                const SizedBox(height: 5),
                buildName(),
                const SizedBox(height: 15),
                Center(
                    child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber,
                    shape: const StadiumBorder(),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 32, vertical: 12),
                  ),
                  child: Text(
                    'Edit Profile',
                    style: GoogleFonts.lato().copyWith(color: Colors.black),
                  ),
                  onPressed: () {
                    print("userloaded-1");
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const PsycoProfileEditPage(),
                        )).then((value) {
                      print("userloaded6");
                      setState(() {});
                    });
                    print("userloaded7");
                  },
                )),
                const SizedBox(height: 5),
                // NumbersWidget(),
                // const SizedBox(height: 1),
                const Divider(endIndent: 30, indent: 30),
                itemProfile('About', psycoData.about, CupertinoIcons.person),
                const SizedBox(height: 7),

                itemProfile('Qualification', psycoData.qualification,
                    const IconData(0xe559, fontFamily: 'MaterialIcons')),

                const SizedBox(height: 7),
                disorderes(CupertinoIcons.person_3),
                const SizedBox(height: 7),
                itemProfile(
                    'Charges (RS./pm)', "379", CupertinoIcons.money_dollar),
                    
              ],
            ),
    );
  }

  itemProfile(String title, String subtitle, IconData iconData) {
    return Container(
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
                offset: Offset(0, 5),
                color: Colors.deepOrange.withOpacity(.2),
                spreadRadius: 2,
                blurRadius: 10)
          ]),
      child: ListTile(
        title: Text(title),
        subtitle: Text(subtitle),
        leading: Icon(iconData),
        // trailing: Icon(Icons.arrow_forward, color: Colors.grey.shade400),
        tileColor: Colors.white,
      ),
    );
  }

  disorderes(IconData iconData) {
    return Container(
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
                offset: Offset(0, 5),
                color: Colors.deepOrange.withOpacity(.2),
                spreadRadius: 2,
                blurRadius: 10)
          ]),
      child: ListTile(
        title: Text('Specialize '),
        subtitle: SizedBox(
          height: 20,
          width: 200,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemBuilder: (context, index) =>
                Text("${psycoData.disorders[index]['disorder_name']}, "),
            itemCount: min(psycoData.disorders.length, 5),
          ),
        ),
        leading: Icon(iconData),
        // trailing: Icon(Icons.arrow_forward, color: Colors.grey.shade400),
        tileColor: Colors.white,
      ),
    );
  }

  Widget buildName() => Column(
        children: [
          Text(
            psycoData.name,
            style: GoogleFonts.lato()
                .copyWith(fontWeight: FontWeight.bold, fontSize: 24),
          ),
          const SizedBox(height: 4),
          Text(
            psycoData.email,
            style: GoogleFonts.lato().copyWith(
                color: Color.fromARGB(255, 79, 79, 79), fontSize: 14.5),
          )
        ],
      );

  Widget buildUpgradeButton() => ButtonWidget(
        text: 'Edit Profile',
        onClicked: () {},
      );

  Widget buildAbout() => Container(
        padding: EdgeInsets.symmetric(horizontal: 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'About ',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            // const SizedBox(height: 5),
            Text(
              psycoData.about,
              style: TextStyle(fontSize: 16, height: 1.4),
            ),
          ],
        ),
      );
}

Widget buildListTile() => Container(
      padding: EdgeInsets.symmetric(horizontal: 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'About z',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          // const SizedBox(height: 5),
          Text(
            psycoData.about,
            style: TextStyle(fontSize: 16, height: 1.4),
          ),
        ],
      ),
    );
