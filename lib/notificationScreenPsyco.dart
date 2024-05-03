import 'dart:convert';

import 'package:flutter/material.dart';
import './Modal/psycoAccount.dart';
import './Modal/userAccount.dart';
import './psycoOrderHistory.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:fluttertoast/fluttertoast.dart';

import 'Modal/psycoData.dart';
import 'bookingConfiramtion.dart';
import 'config.dart';
import 'constant/constant.dart';

class NotificationScreenPsyco extends StatefulWidget {
  const NotificationScreenPsyco({super.key});

  @override
  State<NotificationScreenPsyco> createState() => _NotificationScreenState();
}

DateTime d = DateTime.now();

class _NotificationScreenState extends State<NotificationScreenPsyco> {
  bool notificationLoad = true;
  bool transectionLoad = true;

  List notificationData = [];
  List<psycoProfileData> psycoList = [];
  @override
  void initState() {
    super.initState();
    fetchNotification();
  }

  Future<void> fetchNotification() async {
    setState(() {
      notificationLoad = true;
    });

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
    var url = '${notificationFetch}psychologistId=${psycoData.id}';
    final uri = Uri.parse(url);
    try {
      final response = await http.get(uri, headers: headers);
      if (response.statusCode == 200) {
        var json = jsonDecode(response.body);
        setState(() {
          notificationData = json["psycNotifications"];
          notificationData = notificationData.reversed.toList();
        });

        setState(() {
          notificationLoad = false;
        });
      } else {
        debugPrint('Network Error12');
        debugPrint(response.body);
        Fluttertoast.showToast(msg: "Network Error!");
      }
    } catch (e) {
      Fluttertoast.showToast(msg: "Network Error!");
      print(e);
    }
  }

  Widget schedulesCard(int item, double width) {
    return InkWell(
      onTap: () {
        // Navigator.push(
        //     context,
        //     MaterialPageRoute(
        //       builder: (context) => BookingConfirmation(
        //           psycologistID: notificationData[item]['psychologistId'],
        //           userID: notificationData[item]['userId'],
        //           date: notificationData[item]['date'],
        //           sessionStatus: notificationData[item]['sessionStatus'],
        //           meetLink: notificationData[item]['meetLink']),
        //     ));
        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const PsycoOrderHistory(),
            ));
      },
      child: Container(
        margin: const EdgeInsets.fromLTRB(1, 1, 1, 1),
        height: 90,
        width: width * 0.92,
        decoration: const BoxDecoration(
            // border: Border(
            //     bottom: BorderSide(
            //   width: 0.7,
            //   color: Colors.grey.shade400,
            // )),
            color: Colors.white),
        child: Card(
            elevation: 0,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(1)),
            color: notificationData[item]["isRead"] ?? true
                // color: item > 2
                ? Colors.white
                : const Color.fromARGB(110, 208, 227, 243),
            child: SizedBox(
              height: 80,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  SizedBox(
                    height: 80,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: notificationData[item]["title"] ==
                                    "Wallet Recharge"
                                ? walletIcon()
                                : bookingIcon()),
                        Container(
                          height: 80,
                          padding: const EdgeInsets.fromLTRB(0, 8, 0, 8),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.fromLTRB(8, 1, 8, 1),
                                child: Text(
                                  notificationData[item]["title"] ?? "",
                                  style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600),
                                ),
                              ),
                              SizedBox(
                                width: (width * 0.9) - 60,
                                height: 29,
                                child: Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(8, 0, 8, 1),
                                  child: Text(
                                    notificationData[item]['message'] ?? "",
                                    style: const TextStyle(
                                        overflow: TextOverflow.fade,
                                        fontSize: 10,
                                        fontWeight: FontWeight.w500),
                                  ),
                                ),
                              ),
                              SizedBox(
                                  height: 13,
                                  width: width * 0.75,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      // Padding(
                                      //   padding: const EdgeInsets.fromLTRB(
                                      //       8, 1, 0, 0),
                                      //   child: Text(
                                      //     // ignore: prefer_interpolation_to_compose_strings
                                      //     'ID : ' +
                                      //         notificationData[item]
                                      //             ['walletTransactionId'],
                                      //     style: const TextStyle(
                                      //         fontSize: 10,
                                      //         fontWeight: FontWeight.w500),
                                      //   ),
                                      // ),
                                      // Padding(
                                      //   padding: const EdgeInsets.fromLTRB(
                                      //       0, 1, 5, 1),
                                      //   child: Text(
                                      //     DateFormat('dd-MM-yyyy hh:mm a')
                                      //         .format(DateTime.parse(
                                      //             notificationData[item]
                                      //                 ['createdAt'])),
                                      //     style: const TextStyle(
                                      //         fontSize: 10,
                                      //         fontWeight: FontWeight.w500),
                                      //   ),
                                      // ),
                                      SizedBox(
                                        width: 120,
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          children: [
                                            Padding(
                                              padding:
                                                  const EdgeInsets.fromLTRB(
                                                      8, 1, 2, 1),
                                              child: Text(
                                                notificationData[item]
                                                            ['createdAt'] ==
                                                        null
                                                    ? ""
                                                    : DateFormat('yyyy-MMM-dd')
                                                        .format(DateTime.parse(
                                                            notificationData[
                                                                    item]
                                                                ['createdAt'])),
                                                style: const TextStyle(
                                                    fontSize: 10,
                                                    fontWeight:
                                                        FontWeight.w500),
                                              ),
                                            ),
                                            Padding(
                                              padding:
                                                  const EdgeInsets.fromLTRB(
                                                      2, 1, 5, 1),
                                              child: Text(
                                                notificationData[item]
                                                            ['createdAt'] ==
                                                        null
                                                    ? DateFormat(
                                                            'dd-MM-yyyy hh:mm a')
                                                        .format(DateTime.parse(
                                                            notificationData[item]
                                                                ['date']))
                                                    : DateFormat.jm().format(
                                                        DateFormat("hh:mm:ss").parse(
                                                            notificationData[item]
                                                                    ['createdAt']
                                                                .substring(11, 18))),
                                                style: const TextStyle(
                                                    fontSize: 10,
                                                    fontWeight:
                                                        FontWeight.w500),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  )),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            )),
      ),
    );
  }

  Widget bookingIcon() {
    return Container(
      width: 45,
      height: 45,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5),
          // border: Border.all(width: 1, color: Colors.green.shade400),
          // color: Color.fromARGB(150, 201, 231, 202),
          color: const Color.fromARGB(156, 187, 222, 251)),
      child: Icon(
        Icons.send,
        color: Colors.blue.shade400,
      ),
    );
  }

  Widget walletIcon() {
    return Container(
      width: 45,
      height: 45,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5),
        // border: Border.all(width: 1, color: Colors.green.shade400),
        color: const Color.fromARGB(156, 187, 222, 251),
      ),
      child: Icon(
        Icons.wallet,
        color: Colors.blue.shade400,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notification'),
        backgroundColor: Colors.cyan.shade800,
      ),
      body: Container(
        height: height * 0.89,
        // width: width * 0.9,
        padding: EdgeInsets.fromLTRB(width * 0.03, 0, width * 0.03, 0),
        child: notificationLoad
            ? Center(
                child: SizedBox(
                height: height * 0.7,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CircularProgressIndicator(
                      strokeWidth: 2,
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    TextButton(
                        style: ElevatedButton.styleFrom(
                            shape: const BeveledRectangleBorder()),
                        onPressed: fetchNotification,
                        child: const Text('Refresh'))
                  ],
                ),
              ))
            : notificationData.length == 0
                ? backGroundLoadingScreen("You don't have any notification.")
                : RefreshIndicator(
                    onRefresh: fetchNotification,
                    child: ListView.builder(
                      itemBuilder: (context, index) {
                        return schedulesCard(index, width);
                      },
                      itemCount: notificationData.length,
                    ),
                  ),
      ),
    );
  }
}
