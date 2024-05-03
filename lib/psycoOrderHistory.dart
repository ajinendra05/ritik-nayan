import 'dart:convert';

import 'package:flutter/material.dart';
import './Modal/psycoAccount.dart';
import './Modal/userAccount.dart';
import './Modal/userData.dart';
import './bookingConfirmation_Psyco.dart';
import './chatScreen.dart';
import './constant/constant.dart';
import 'package:jiffy/jiffy.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:fluttertoast/fluttertoast.dart';

import 'Modal/psycoData.dart';
import 'config.dart';

class PsycoOrderHistory extends StatefulWidget {
  const PsycoOrderHistory({super.key});

  @override
  State<PsycoOrderHistory> createState() => _PsycoOrderHistoryState();
}

DateTime d = DateTime.now();

class _PsycoOrderHistoryState extends State<PsycoOrderHistory> {
  bool transectionLoad = true;
  List TransectionsData = [];
  bool sessionLoad = true;
  List sessionsList = [];
  List sessionsData = [];
  List userProfilesData = [];
  @override
  void initState() {
    super.initState();
    // fetchTrancection();
    getSessions();
  }

  Future<void> fetchTrancection() async {
    setState(() {
      transectionLoad = true;
    });

    var prefs = await SharedPreferences.getInstance();
    var myToken = prefs.getString('token') ?? "";
    var cookies = [
      'token=${myToken}',
    ];

    var headers = {
      'Cookie': cookies.join('; '),
      'Content-Type': 'application/json'
    };
    var url = '$transection?userId=${userData.id}';
    final uri = Uri.parse(url);
    try {
      final response = await http.get(uri, headers: headers);
      if (response.statusCode == 200) {
        var json = jsonDecode(response.body);
        setState(() {
          TransectionsData = json;
          TransectionsData = TransectionsData.reversed.toList();
          transectionLoad = false;
        });
      } else {
        debugPrint('Network Error');
        Fluttertoast.showToast(msg: "Network Error!");
      }
    } catch (e) {
      Fluttertoast.showToast(msg: "Network Error!");
    }
  }

  Widget transectionCard(int item) {
    return Container(
      margin: EdgeInsets.fromLTRB(1, 3, 1, 3),
      color: Colors.white,
      height: 80,
      width: double.infinity,
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(1)),
        color: Colors.white,
        child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(8, 1, 8, 1),
                    child: Text(
                      TransectionsData[item]['paymentId'] ==
                              "wallet transection"
                          ? "Booked a Psycologist"
                          : "Recharge Wallet",
                      style: TextStyle(
                          fontSize: 15.5, fontWeight: FontWeight.w500),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(8, 1, 8, 1),
                    child:
                        //  (TransectionsData[item]['status'] == 'failed')
                        //     ? Text(
                        //         (TransectionsData[item]['amount'] < 0)
                        //             ? '-₹. ${TransectionsData[item]['amount']}'
                        //             : '+₹. ${TransectionsData[item]['amount']}',
                        //         style: TextStyle(
                        //             fontSize: 16,
                        //             fontWeight: FontWeight.w900,
                        //             color: Colors.grey),
                        //       )
                        // :
                        Text(
                      (TransectionsData[item]['amount'] < 0)
                          ? '-₹. ${TransectionsData[item]['amount']}'
                          : '+₹. ${TransectionsData[item]['amount']}',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          color: TransectionsData[item]['amount'] < 0
                              ? Colors.red
                              : Colors.green),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 1, 8, 1),
                child: Text(
                  DateFormat('dd-MM-yyyy hh:mm a')
                      .format(DateTime.parse(TransectionsData[item]['date'])),
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.w500),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 0, 8, 1),
                child: Text(
                  (TransectionsData[item]['paymentId'] == "wallet transection")
                      ? TransectionsData[item]['_id']
                      : TransectionsData[item]['paymentId'],
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.w500),
                ),
              ),
              // (TransectionsData[item]['paymentId'] == "wallet transection")
              //     ? Padding(
              //         padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
              //         child: Text(
              //           '! Failed',
              //           style: TextStyle(
              //               color: Colors.red,
              //               fontSize: 10,
              //               fontWeight: FontWeight.w500),
              //         ),
              //       )
              //     : Container(),
            ]),
      ),
    );
  }

  Future<void> getSessions() async {
    setState(() {
      sessionLoad = true;
    });

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
    print("getseessions");
    var url = '$sessionsP?id=${psycoData.id}';
    final uri = Uri.parse(url);
    try {
      print(uri);
      final response = await http.get(uri, headers: headers);
      print('body: ');
      print(response.body);
      print(response.headers);
      print(response.statusCode);
      if (response.statusCode == 200) {
        print('hello');
        var json = jsonDecode(response.body);
        setState(() {
          sessionsData = json;
        });
        await midware();

        setState(() {
          sessionLoad = false;
        });
        print(json);
      } else {
        debugPrint('Network Error');
        Fluttertoast.showToast(msg: "Network Error!");
      }
    } catch (e) {
      print(e);
      Fluttertoast.showToast(msg: "Network Error!");
    }
  }

  Future<void> midware() async {
    for (int i = 0; i < sessionsData.length; i++) {
      await loadBookedUserProfile(sessionsData[i]['userId']);
    }
  }

  Future<void> loadBookedUserProfile(String id) async {
    userModel current = userModel();
    await current.loadUser(id);
    userProfilesData.add(current);
  }

  Widget schedulesCard(int item, double width) {
    return InkWell(
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => BookingConfirmationPsyco(
                  slot: sessionsData[item]["slot"],
                  sesionId: sessionsData[item]['_id'],
                  psycologistID: sessionsData[item]['psychologistId'],
                  userID: sessionsData[item]['userId'],
                  date: sessionsData[item]['date'],
                  sessionStatus: sessionsData[item]['sessionStatus'],
                  meetLink: sessionsData[item]['meetLink']),
            ));
      },
      child: Container(
        margin: EdgeInsets.fromLTRB(1, 3, 1, 3),
        color: Color.fromARGB(255, 241, 240, 240),
        height: 75,
        width: double.infinity,
        child: Card(
            elevation: 2,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(1)),
            color: Colors.white,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                SizedBox(
                  height: 70,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: CircleAvatar(
                          backgroundColor: Colors.green,
                          //backgroundImage: Image.network(''),
                          backgroundImage: userProfilesData[item].imgPath == ""
                              ? null
                              : NetworkImage(userProfilesData[item].imgPath),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(0, 8, 0, 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.fromLTRB(8, 1, 8, 1),
                              child: Text(
                                userProfilesData[item].name,
                                style: const TextStyle(
                                    fontSize: 14, fontWeight: FontWeight.w600),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.fromLTRB(8, 0, 8, 1),
                              child: Text(
                                sessionsData[item]['meetLink'],
                                style: const TextStyle(
                                    fontSize: 10, fontWeight: FontWeight.w500),
                              ),
                            ),
                            SizedBox(
                                height: 13,
                                width: width - 80,
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Padding(
                                      padding:
                                          const EdgeInsets.fromLTRB(8, 1, 0, 0),
                                      child: Text(
                                        'ID : ' +
                                            sessionsData[item]
                                                ['walletTransactionId'],
                                        style: TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.w500),
                                      ),
                                    ),
                                    Padding(
                                      padding:
                                          const EdgeInsets.fromLTRB(0, 1, 5, 1),
                                      child: Text(
                                        DateFormat('dd-MM-yyyy hh:mm a').format(
                                            DateTime.parse(
                                                sessionsData[item]['date'])),
                                        style: TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.w500),
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
            )),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Order History'),
          backgroundColor: Colors.cyan.shade800,
          bottom: const TabBar(
            tabs: [
              // Tab(
              //   text: 'Transections',
              // ),
              Tab(
                text: 'Completed Schedules',
              ),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // Container(
            //   height: height * 0.89,
            //   child: transectionLoad
            //       ? Center(
            //           child: CircularProgressIndicator(
            //           strokeWidth: 2,
            //         ))
            //       : RefreshIndicator(
            //           onRefresh: fetchTrancection,
            //           child: ListView.builder(
            //             itemBuilder: (context, index) {
            //               return transectionCard(index);
            //             },
            //             itemCount: TransectionsData.length,
            //           ),
            //         ),
            // ),
            Container(
              height: height * 0.89,
              child: RefreshIndicator(
                onRefresh: getSessions,
                child: sessionLoad
                    ? const Center(
                        child: CircularProgressIndicator(
                        strokeWidth: 2,
                      ))
                    : TransectionsData.isEmpty
                        ? backGroundLoadingScreen(
                            "You don't make any Transections.")
                        : ListView.builder(
                            itemBuilder: (context, index) {
                              return sessionsData[index]["sessionStatus"] ==
                                          'PENDING' ||
                                      sessionsData[index]["sessionStatus"] ==
                                          'Pending'
                                  ? const SizedBox(
                                      height: 0,
                                    )
                                  : schedulesCard(index, width);
                            },
                            itemCount: sessionsData.length,
                          ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
