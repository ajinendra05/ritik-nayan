import 'dart:convert';

import 'package:flutter/material.dart';
import './Modal/userAccount.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:fluttertoast/fluttertoast.dart';

import 'Modal/psycoData.dart';
import 'bookingConfiramtion.dart';
import 'config.dart';
import 'constant/constant.dart';

class Orderhistory extends StatefulWidget {
  const Orderhistory({super.key});

  @override
  State<Orderhistory> createState() => _OrderhistoryState();
}

DateTime d = DateTime.now();

class _OrderhistoryState extends State<Orderhistory> {
  bool sessionLoad = true;
  bool transectionLoad = true;

  List TransectionsData = [];

  List SchedulesData = [];
  List sessionsData = [];
  List<psycoProfileData> psycoList = [];
  @override
  void initState() {
    super.initState();
    fetchTrancection();
    getSessions();
  }

  Future<void> fetchTrancection() async {
    setState(() {
      transectionLoad = true;
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
    var url = '$transection?userId=${userData.id}';
    final uri = Uri.parse(url);
    try {
      final response = await http.get(uri, headers: headers);
      if (response.statusCode == 200) {
        var json = jsonDecode(response.body);
        setState(() {
          TransectionsData = json;
          // TransectionsData = TransectionsData.reversed.toList();
          TransectionsData.sort(
            (a, b) {
              return b["createdAt"].toString().compareTo(a['createdAt']);
            },
          );
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
      margin: EdgeInsets.fromLTRB(1, 1, 1, 3),
      decoration: BoxDecoration(
          border: Border(
              bottom: BorderSide(
            width: 0.7,
            color: Colors.grey.shade400,
          )),
          color: Colors.white),
      height: 80,
      width: double.infinity,
      child: Card(
        elevation: 0,
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
                      // TransectionsData[item]['paymentId'] ==
                      //         "wallet transection"
                      TransectionsData[item]['amount'] == 379
                          ? "Booked ${TransectionsData[item]["psychologistId"]["name"] ?? "a Psycologist"}"
                          : "Recharge Wallet",
                      style: const TextStyle(
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
                      (TransectionsData[item]['amount'] == 379)
                          ? '-₹ ${TransectionsData[item]['amount']}'
                          : '+₹ ${TransectionsData[item]['amount']}',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          color: TransectionsData[item]['amount'] == 379
                              ? Colors.red
                              : Colors.green),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 0, 8, 1),
                child: Text(
                  // (TransectionsData[item]['paymentId'] == "wallet transection")
                  TransectionsData[item]['amount'] == 379
                      ? TransectionsData[item]['_id']
                      : TransectionsData[item]['paymentId'],
                  style: const TextStyle(
                      fontSize: 10, fontWeight: FontWeight.w500),
                ),
              ),
              SizedBox(
                width: MediaQuery.of(context).size.width,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(8, 1, 8, 1),
                      child: Text(
                        TransectionsData[item]['createdAt'] == null
                            ? DateFormat('dd-MM-yyyy hh:mm a').format(
                                DateTime.parse(TransectionsData[item]['date']))
                            : DateFormat('yyyy-MMM-dd').format(DateTime.parse(
                                TransectionsData[item]['createdAt'])),
                        style: const TextStyle(
                            fontSize: 10, fontWeight: FontWeight.w500),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(8, 1, 8, 1),
                      child: Text(
                        TransectionsData[item]['createdAt'] == null
                            ? DateFormat('dd-MM-yyyy hh:mm a').format(
                                DateTime.parse(TransectionsData[item]['date']))
                            : DateFormat.jm().format(DateFormat("hh:mm:ss")
                                .parse(TransectionsData[item]['createdAt']
                                    .substring(11, 18))),
                        style: const TextStyle(
                            fontSize: 10, fontWeight: FontWeight.w500),
                      ),
                    ),
                  ],
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
              const SizedBox(
                height: 3,
              ),
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
    var cookies = [
      'token=$myToken',
    ];

    var headers = {
      'Cookie': cookies.join('; '),
      'Content-Type': 'application/json'
    };
    var url = sessions;
    final uri = Uri.parse(url);
    try {
      final response = await http.get(uri, headers: headers);
      if (response.statusCode == 200) {
        var json = jsonDecode(response.body);
        setState(() {
          sessionsData = json;
          sessionsData = sessionsData.reversed.toList();
        });

        await midware();

        setState(() {
          sessionLoad = false;
        });
      } else {
        debugPrint('Network Error12');
        debugPrint(response.body);
        Fluttertoast.showToast(msg: "Network Error!");
      }
    } catch (e) {
      Fluttertoast.showToast(msg: "Network Error!");
    }
  }

  Future<void> midware() async {
    for (int i = 0; i < sessionsData.length; i++) {
      await loadBookedPsycoProfile(sessionsData[i]['psychologistId']);
    }
  }

  Future<void> loadBookedPsycoProfile(String id) async {
    psycoProfileData current = psycoProfileData();
    await current.loadUser(id);
    psycoList.add(current);
  }

  Widget schedulesCard(int item, double width) {
    return InkWell(
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => BookingConfirmation(
                  slot: sessionsData[item]["slot"],
                  sessionId: sessionsData[item]["_id"],
                  psycologistID: sessionsData[item]['psychologistId'],
                  userID: sessionsData[item]['userId'],
                  date: sessionsData[item]['date'],
                  sessionStatus: sessionsData[item]['sessionStatus'],
                  meetLink: sessionsData[item]['meetLink']),
            ));
      },
      child: Container(
        margin: const EdgeInsets.fromLTRB(1, 1, 1, 1),
        height: 80,
        width: width * 0.88,
        decoration: BoxDecoration(
            border: Border(
                bottom: BorderSide(
              width: 0.7,
              color: Colors.grey.shade400,
            )),
            color: Colors.white),
        child: Card(
            elevation: 0,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(1)),
            color: Colors.white,
            child: SizedBox(
              height: 80,
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
                            backgroundImage: psycoList[item].imgPath == ""
                                ? null
                                : NetworkImage(psycoList[item].imgPath),
                          ),
                        ),
                        Container(
                          height: 70,
                          padding: const EdgeInsets.fromLTRB(0, 8, 0, 8),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.fromLTRB(8, 1, 8, 1),
                                child: Text(
                                  psycoList[item].name,
                                  style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.fromLTRB(8, 0, 8, 1),
                                child: Text(
                                  sessionsData[item]['sessionStatus'],
                                  style: const TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w500),
                                ),
                              ),
                              SizedBox(
                                  height: 13,
                                  width: width * 0.8,
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.fromLTRB(
                                            8, 1, 0, 0),
                                        child: Text(
                                          // ignore: prefer_interpolation_to_compose_strings
                                          'ID : ' +
                                              sessionsData[item]
                                                  ['walletTransactionId'],
                                          style: const TextStyle(
                                              fontSize: 10,
                                              fontWeight: FontWeight.w500),
                                        ),
                                      ),
                                      // Padding(
                                      //   padding: const EdgeInsets.fromLTRB(
                                      //       0, 1, 5, 1),
                                      //   child: Text(
                                      //     DateFormat('dd-MM-yyyy hh:mm a')
                                      //         .format(DateTime.parse(
                                      //             sessionsData[item]
                                      //                 ['createdAt'])),
                                      //     style: const TextStyle(
                                      //         fontSize: 10,
                                      //         fontWeight: FontWeight.w500),
                                      //   ),
                                      // ),
                                      SizedBox(
                                        width: 125,
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          children: [
                                            Padding(
                                              padding:
                                                  const EdgeInsets.fromLTRB(
                                                      8, 1, 2, 1),
                                              child: Text(
                                                sessionsData[item]
                                                            ['createdAt'] ==
                                                        null
                                                    ? DateFormat(
                                                            'dd-MM-yyyy hh:mm a')
                                                        .format(DateTime.parse(
                                                            sessionsData[item]
                                                                ['date']))
                                                    : DateFormat('yyyy-MMM-dd')
                                                        .format(DateTime.parse(
                                                            sessionsData[item]
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
                                                sessionsData[item]
                                                            ['createdAt'] ==
                                                        null
                                                    ? DateFormat('dd-MM-yyyy hh:mm a')
                                                        .format(DateTime.parse(
                                                            sessionsData[item]
                                                                ['date']))
                                                    : DateFormat.jm().format(
                                                        DateFormat("hh:mm:ss").parse(
                                                            sessionsData[item][
                                                                    'createdAt']
                                                                .substring(
                                                                    11, 18))),
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

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Order History'),
          backgroundColor: Colors.orange,
          bottom: const TabBar(
            tabs: [
              Tab(
                text: 'Transection',
              ),
              Tab(
                text: 'Schedules',
              ),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            SizedBox(
              height: height * 0.9,
              child: RefreshIndicator(
                onRefresh: fetchTrancection,
                child: transectionLoad
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
                                onPressed: fetchTrancection,
                                child: const Text('Refresh'))
                          ],
                        ),
                      ))
                    : TransectionsData.isEmpty
                        ? backGroundLoadingScreen(
                            "You don't make any Transections.")
                        : ListView.builder(
                            itemBuilder: (context, index) {
                              return transectionCard(index);
                            },
                            itemCount: TransectionsData.length,
                          ),
              ),
            ),
            SizedBox(
              height: height * 0.9,
              child: RefreshIndicator(
                onRefresh: getSessions,
                child: sessionLoad
                    ? Center(
                        child: SizedBox(
                        height: height * 0.7,
                        child: const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircularProgressIndicator(
                              strokeWidth: 2,
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            // TextButton(
                            //     style: ElevatedButton.styleFrom(
                            //         shape: const BeveledRectangleBorder()),
                            //     onPressed: getSessions,
                            //     child: const Text('Refresh'))
                          ],
                        ),
                      ))
                    : sessionsData.isEmpty
                        ? backGroundLoadingScreen(
                            "You don't have any sessions.")
                        : ListView.builder(
                            itemBuilder: (context, index) {
                              return schedulesCard(index, width);
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
