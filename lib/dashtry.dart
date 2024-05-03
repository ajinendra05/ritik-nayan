import 'dart:convert';
import 'dart:math';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:wellnesswarriors/config.dart';
import 'package:wellnesswarriors/navbar.dart';
import 'package:wellnesswarriors/notificationScreen.dart';
import 'package:wellnesswarriors/psyprofile.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:fluttertoast/fluttertoast.dart';

import 'constant/constant.dart';
import 'recharge.dart';

class dashtry extends StatefulWidget {
  const dashtry({Key? key}) : super(key: key);

  @override
  State<dashtry> createState() => _dashtryState();
}

class _dashtryState extends State<dashtry> {
  bool loading = true;
  late String email;
  late SharedPreferences prefs;
  List psycoList = [];
  List psycoImg = [];
  //late String psyemail;

  Future<void> fetchPsychologist() async {
    setState(() {
      loading = true;
    });

    try {
      const url = psychologist;
      final uri = Uri.parse(url);

      final response = await http.get(uri);

      if (response.statusCode == 200) {
        var json = jsonDecode(response.body);

        setState(() {
          psycoList = json;
        });
        psycoImg.clear();
        await loadImages();
      } else {
        debugPrint('Network Error fetchPsyclo');
        Fluttertoast.showToast(msg: "Network Error!");
      }
    } catch (e) {
      debugPrint('Network Error fetchPsyclo');
      Fluttertoast.showToast(msg: "Network Error!");
    }

    setState(() {
      loading = false;
    });
  }

  Future<void> loadImages() async {
    final refrence = FirebaseStorage.instance.ref().child('userImage');
    for (int ind = 0; ind < psycoList.length; ind++) {
      try {
        final upldImg = refrence.child('${psycoList[ind]["_id"]}.jpg');
        var imgPath = await upldImg.getDownloadURL();
        psycoImg.add(imgPath);
      } catch (e) {
        psycoImg.add("");
      }
    }
    // psycoList.forEach((element) async {
    //   try {
    //     final upldImg = refrence.child('${element["_id"]}.jpg');
    //     var imgPath = await upldImg.getDownloadURL();
    //     psycoImg.add(imgPath);
    //     print("correct firebase path");
    //   } catch (e) {
    //     print("wrong firebase path");
    //     psycoImg.add("");
    //   }
    // });
  }

  @override
  void initState() {
    super.initState();
    fetchPsychologist();
  }

  @override
  Widget build(BuildContext context) {
    final wth = MediaQuery.of(context).size.width;
    final hgt = MediaQuery.of(context).size.height;
    return Scaffold(
      drawer: NavBar(),
      appBar: AppBar(
        backgroundColor: Colors.orange,
        title: const Text('Talk to Therapist'),
        actions: [
          IconButton(
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const RechargeScreen(),
                    ));
              },
              icon: const Icon(Icons.wallet)),
          IconButton(
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const NotificationScreen(),
                    ));
              },
              icon: const Icon(Icons.notifications)),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: fetchPsychologist,
        child: loading
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : psycoList.isEmpty
                ? backGroundLoadingScreen("There is no psycologist yet")
                : Container(
                    color: Colors.amber,
                    height: hgt * 0.9,
                    width: wth,
                    child: ListView.builder(
                      itemCount: psycoList.length,
                      itemBuilder: (BuildContext context, int index) {
                        final psycologist = psycoList[index];
                        //List dat = psycoList[index];

                        return psycologist["active_status"] == false
                            ? const SizedBox(
                                height: 0,
                              )
                            : Container(
                                width: MediaQuery.of(context).size.width,
                                color: Colors.amber,
                                height: 120,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 5),
                                child: InkWell(
                                  splashColor: Colors.red,
                                  onTap: (() {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => psyprofile(
                                            psychologistId: psycologist['_id'],
                                          ),
                                        ));
                                  }),
                                  child: Card(
                                      elevation: 5,
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(10)),
                                      child: Container(
                                        // width: MediaQuery.of(context).size.width,
                                        //color: Colors.cyan,
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 5, vertical: 10),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                SizedBox(
                                                  //color: Colors.cyan,
                                                  height: 65,
                                                  width: wth * 0.15,
                                                  child: CircleAvatar(
                                                    backgroundColor:
                                                        Colors.green,
                                                    //backgroundImage: Image.network(''),
                                                    backgroundImage: psycoImg[
                                                                index] ==
                                                            ""
                                                        ? null
                                                        : NetworkImage(
                                                            psycoImg[index]),
                                                  ),
                                                ),
                                                const SizedBox(
                                                  width: 5,
                                                ),
                                                SizedBox(
                                                  width: wth * 0.52,
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                          psycologist['name'] ??
                                                              "Not Mentioned",
                                                          style: const TextStyle(
                                                              fontSize: 15,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold)),
                                                      Text(
                                                          psycologist[
                                                                  'qualification'] ??
                                                              "Not Mentioned",
                                                          style:
                                                              const TextStyle(
                                                                  fontSize:
                                                                      12)),
                                                      psycologist['chargespm'] ==
                                                              null
                                                          ? const Text(
                                                              "Not Mentioned")
                                                          : Text(
                                                              '${psycologist['chargespm']} INR / Minutes'),
                                                      // const Text(
                                                      //     '379 INR /min'),
                                                      psycologist['disorders'] ==
                                                              null
                                                          ? const Text(
                                                              "Not Mentioned")
                                                          : SizedBox(
                                                              height: 20,
                                                              width: 200,
                                                              child: ListView
                                                                  .builder(
                                                                scrollDirection:
                                                                    Axis.horizontal,
                                                                itemBuilder: (context,
                                                                        index) =>
                                                                    Text(
                                                                        "${psycologist['disorders'][index]['disorder_name']}, "),
                                                                itemCount: min(
                                                                    psycologist[
                                                                            'disorders']
                                                                        .length,
                                                                    3),
                                                              ),
                                                            )
                                                    ],
                                                  ),
                                                ),
                                                SizedBox(
                                                  // width: wth * 0.2,
                                                  child: Container(
                                                    alignment: Alignment.center,
                                                    child: ElevatedButton(
                                                      onPressed: () {
                                                        Navigator.push(
                                                            context,
                                                            MaterialPageRoute(
                                                              builder:
                                                                  (context) =>
                                                                      psyprofile(
                                                                psychologistId:
                                                                    psycologist[
                                                                        '_id'],
                                                              ),
                                                            ));
                                                      },
                                                      child: const Text('Book'),
                                                    ),
                                                  ),
                                                )
                                              ],
                                            )
                                          ],
                                        ),
                                      )),
                                ),
                              );
                      },
                      //itemCount: psycoList.length,
                    ),
                  ),
      ),
    );
  }
}
