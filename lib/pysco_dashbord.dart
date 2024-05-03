import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import './Modal/psycoAccount.dart';
import './bookingConfirmation_Psyco.dart';
import './config.dart';
import './navbar.dart';
import './notificationScreenPsyco.dart';
import 'package:jiffy/jiffy.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'Modal/userData.dart';
import 'chatScreen.dart';
import 'constant/constant.dart';
import 'notificationScreen.dart';
import 'psycoNavBar.dart';

class PscDashBord extends StatefulWidget {
  const PscDashBord({super.key});

  @override
  State<PscDashBord> createState() => _PscDashBordState();
}

// final List morning = [10, 10.5, 11, 11.5];
// final List noon = [12, 12.5, 1, 1.5, 2, 2.5, 3, 3.5, 4, 4.5];
// final List evening = [5, 5.5, 6, 6.5, 7, 7.5];
// final List night = [8, 8.5, 9, 9.5];

// final List morningB = [false, false, false, false];
// final List noonB = [
//   false,
//   false,
//   false,
//   false,
//   false,
//   false,
//   false,
//   false,
//   false,
//   false
// ];
// final List eveningB = [false, false, false, false, false, false];
// final List nightB = [false, false, false, false];

class _PscDashBordState extends State<PscDashBord> {
  DateTime choosedDate = DateTime.now();
  bool sessionLoad = true;
  List sessionsList = [];
  List sessionsData = [];
  List userProfilesData = [];
  List shedule = [];
  bool load = true;
  List buttonLoad = [
    false,
    false,
    false,
    false,
    false,
    false,
    false,
    false,
    false,
    false,
    false,
    false,
    false,
    false,
    false,
    false,
    false,
    false,
    false,
    false,
    false,
    false,
    false,
    false,
    false,
    false
  ];
  String id = "";
  @override
  void initState() {
    // TODO: implement initState
    psycoData.loadUser();
    getShedule(choosedDate);
    getSessions();
    super.initState();
  }

  Future<void> getShedule(DateTime date) async {
    print("inside get");
    var url =
        '$getPyscoShedule?psychologistId=${psycoData.id}&date=${date.year}-${date.month}-${date.day}';
    final uri = Uri.parse(url);
    var prefs = await SharedPreferences.getInstance();
    var myToken = prefs.getString('token') ?? "";
    var cookies = [
      'token=${myToken}',
    ];

    var headers = {
      'Cookie': cookies.join('; '),
      'Content-Type': 'application/json'
    };
    print(uri);
    try {
      final response = await http.get(uri, headers: headers);
      print("inside get2");
      if (response.statusCode == 200) {
        var json = jsonDecode(response.body);
        setState(() {
          shedule = json["slots"];
          load = false;
        });
      } else {
        debugPrint('Network Error getschedule');
        Fluttertoast.showToast(msg: "Network Error!");
      }
    } catch (e) {
      Fluttertoast.showToast(msg: "Network Error!");
    }
  }

  Future<void> setShedule(
      int index, String id, DateTime date, String slot, bool avlb) async {
    setState(() {
      buttonLoad[index] = true;
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

    const url = getPyscoShedule;
    final uri = Uri.parse(url);
    final regBody = {
      "psychologistId": psycoData.id,
      "date": "${date.year}-${date.month}-${date.day}",
      "slots": slot,
      "available": avlb
    };
    try {
      final response =
          await http.post(uri, body: jsonEncode(regBody), headers: headers);
      if (response.statusCode == 200) {
        var json = jsonDecode(response.body);
        setState(() {
          shedule = json["slots"];
          buttonLoad[index] = false;
          load = false;
        });
      } else {
        debugPrint('Network Error');
        Fluttertoast.showToast(msg: "Network Error!");
        setState(() {
          buttonLoad[index] = false;
        });
      }
    } catch (e) {
      print(e);
      Fluttertoast.showToast(msg: "Network Error!");
      setState(() {
        buttonLoad[index] = false;
      });
    }
  }

  _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: choosedDate, // Refer step 1
      firstDate: DateTime(2000),
      lastDate: DateTime(2025),
    );
    if (picked != null && picked != choosedDate)
      setState(() {
        choosedDate = picked;
        getShedule(choosedDate);
      });
  }

  Widget gridview() {
    DateTime present = DateTime.now();
    bool presentDay = present.year == choosedDate.year &&
        present.month == choosedDate.month &&
        present.day == choosedDate.day;

    return Container(
        margin:const EdgeInsets.fromLTRB(10, 5, 10, 0),
        child: GridView.count(
          crossAxisCount: 4,
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          childAspectRatio: 2.5,
          children: List.generate(
            shedule.length,
            (index) {
              return SizedBox(
                height: 10,
                width: 10,
                child: InkWell(
                  onTap: presentDay && present.hour >= 3 + index
                      ? null
                      : () {
                          bool flag = shedule[index]['available'];
                          setShedule(index, psycoData.id, choosedDate,
                              shedule[index]['time'], !flag);
                        },
                  splashColor: const Color.fromARGB(255, 21, 69, 23),
                  child: buttonLoad[index]
                      ? const Center(
                          child: Padding(
                            padding: const EdgeInsets.all(5.0),
                            child: CircularProgressIndicator(
                              strokeWidth: 1,
                              color: Colors.red,
                            ),
                          ),
                        )
                      : Container(
                          // margin: EdgeInsets.all(10),

                          decoration: BoxDecoration(
                            color: presentDay && present.hour >= 3 + index
                                ? Colors.grey.shade400
                                : shedule[index]["available"]
                                    ? null
                                    : Colors.green,
                            borderRadius: BorderRadius.all(Radius.circular(5)),
                            border: Border.all(color: Colors.black, width: 1),
                          ),
                          child: Center(
                            child: Text(
                              presentDay && present.hour >= 3 + index
                                  ? "Not available"
                                  : '${shedule[index]['time']}',
                              style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600),
                            ),
                          ),
                        ),
                ),
              );
            },
          ),
        ));
  }

  Future<void> getSessions() async {
    setState(() {
      sessionLoad = true;
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
    var url = '$sessionsP?id=${psycoData.id}';
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
            )).then((value) {
          getSessions();
        });
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

  // Widget schedulesCard(int item) {
  //   return InkWell(
  //     onTap: () {
  //       // Navigator.push(
  //       //     context,
  //       //     MaterialPageRoute(
  //       //       builder: (context) => ChatScreen(),
  //       //     ));
  //     },
  //     child: Container(
  //       margin: EdgeInsets.fromLTRB(1, 3, 1, 3),
  //       color: Color.fromARGB(255, 241, 240, 240),
  //       height: 70,
  //       width: double.infinity,
  //       child: Card(
  //           elevation: 2,
  //           shape:
  //               RoundedRectangleBorder(borderRadius: BorderRadius.circular(1)),
  //           color: Colors.white,
  //           child: Row(
  //             mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //             crossAxisAlignment: CrossAxisAlignment.end,
  //             children: [
  //               SizedBox(
  //                 height: 65,
  //                 child: Row(
  //                   mainAxisAlignment: MainAxisAlignment.start,
  //                   crossAxisAlignment: CrossAxisAlignment.start,
  //                   children: [
  //                     Padding(
  //                       padding: const EdgeInsets.all(8.0),
  //                       child: CircleAvatar(
  //                         backgroundColor: Colors.green,
  //                         //backgroundImage: Image.network(''),
  //                         backgroundImage: SchedulesData[item]['imagepath'] ==
  //                                 null
  //                             ? null
  //                             : NetworkImage(SchedulesData[item]['imagepath']),
  //                       ),
  //                     ),
  //                     Padding(
  //                       padding: const EdgeInsets.fromLTRB(0, 8, 0, 8),
  //                       child: Column(
  //                         crossAxisAlignment: CrossAxisAlignment.start,
  //                         children: [
  //                           Padding(
  //                             padding: const EdgeInsets.fromLTRB(8, 1, 8, 1),
  //                             child: Text(
  //                               SchedulesData[item]['name'],
  //                               style: TextStyle(
  //                                   fontSize: 14, fontWeight: FontWeight.w600),
  //                             ),
  //                           ),
  //                           Padding(
  //                             padding: const EdgeInsets.fromLTRB(8, 0, 8, 1),
  //                             child: Text(
  //                               SchedulesData[item]['status'],
  //                               style: TextStyle(
  //                                   fontSize: 10, fontWeight: FontWeight.w500),
  //                             ),
  //                           ),
  //                         ],
  //                       ),
  //                     )
  //                   ],
  //                 ),
  //               ),
  //               Padding(
  //                 padding: const EdgeInsets.fromLTRB(8, 1, 8, 1),
  //                 child: Text(
  //                   DateFormat('dd-MM-yyyy hh:mm a').format(d),
  //                   style: TextStyle(fontSize: 10, fontWeight: FontWeight.w500),
  //                 ),
  //               ),
  //             ],
  //           )),
  //     ),
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;

    var date = Jiffy.parse(
            "${choosedDate.year}/${choosedDate.month}/${choosedDate.day}")
        .yMMMMd;
    var day = DateFormat('EEEE').format(choosedDate);
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        drawer: PsycoNavBar(),
        appBar: AppBar(
          backgroundColor: Colors.cyan.shade800,
          title: Text(psycoData.name),
          actions: [
            IconButton(
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const NotificationScreenPsyco(),
                      ));
                },
                icon: const Icon(Icons.notifications))
          ],
          bottom: const TabBar(
            tabs: [
              Tab(
                text: 'Available',
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
                height: height * 0.7,
                width: width,
                child: SizedBox(
                  height: height * 0.7,
                  child: Column(children: [
                    const Text(
                      "Choose Date",
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black54),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        IconButton(
                            onPressed: () {
                              if (choosedDate.compareTo(DateTime.now()) > 0) {
                                setState(() {
                                  choosedDate =
                                      choosedDate.add(Duration(days: -1));
                                  load = true;
                                });
                              } else {
                                Fluttertoast.showToast(
                                    msg: "Cant go to befores date");
                              }
                              getShedule(choosedDate);
                            },
                            icon:const Icon(
                              Icons.arrow_circle_left,
                              color: Colors.amber,
                            )),
                        GestureDetector(
                          onTap: () {
                            _selectDate(context);
                          },
                          child: Container(
                            width: width * 0.6,
                            height: 60,
                            decoration: BoxDecoration(
                                border: Border.all(
                                    color: const Color.fromARGB(165, 0, 0, 0),
                                    width: 0.6),
                                borderRadius: BorderRadius.circular(8)),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  date,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black87),
                                ),
                                Text(
                                  day,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w400,
                                      color: Color.fromARGB(251, 70, 70, 70),
                                      fontSize: 11),
                                )
                              ],
                            ),
                          ),
                        ),
                        IconButton(
                            onPressed: () {
                              setState(() {
                                choosedDate =
                                    choosedDate.add(const Duration(days: 1));
                                load = true;
                              });
                              getShedule(choosedDate);
                            },
                            icon:const Icon(Icons.arrow_circle_right,
                                color: Colors.amber))
                      ],
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Container(
                      child: Column(
                        children: [
                          // const Text(
                          //   "Morning",
                          //   style: TextStyle(
                          //       fontSize: 16,
                          //       fontWeight: FontWeight.w500,
                          //       color: Colors.black54),
                          // ),
                          const Divider(),
                          load
                              ?const Center(
                                  child: CircularProgressIndicator(),
                                )
                              : SizedBox(
                                  height: height * 0.6,
                                  width: double.infinity,
                                  child: gridview(),
                                ),
                          const SizedBox(
                            height: 5,
                          ),
                          // Text(
                          //   "Noon",
                          //   style: TextStyle(
                          //       fontSize: 16,
                          //       fontWeight: FontWeight.w500,
                          //       color: Colors.black54),
                          // ),
                          // Divider(),
                          // SizedBox(
                          //   height: height * 0.05 * 3.8,
                          //   width: double.infinity,
                          //   child: gridview(noon, noonB),
                          // ),
                          // SizedBox(
                          //   height: 5,
                          // ),
                          // Text(
                          //   "Evening",
                          //   style: TextStyle(
                          //       fontSize: 16,
                          //       fontWeight: FontWeight.w500,
                          //       color: Colors.black54),
                          // ),
                          // Divider(),
                          // SizedBox(
                          //   height: height * 0.05 * 2.5,
                          //   width: double.infinity,
                          //   child: gridview(evening, eveningB),
                          // ),
                          // SizedBox(
                          //   height: 5,
                          // ),
                          // Text(
                          //   "Night",
                          //   style: TextStyle(
                          //       fontSize: 16,
                          //       fontWeight: FontWeight.w500,
                          //       color: Colors.black54),
                          // ),
                          // Divider(),
                          // SizedBox(
                          //   height: height * 0.05,
                          //   width: double.infinity,
                          //   child: gridview(night, nightB),
                          // ),
                        ],
                      ),
                    )
                  ]),
                )),
            SizedBox(
              height: height * 0.89,
              child: RefreshIndicator(
                onRefresh: getSessions,
                child: sessionLoad
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
                                    shape: BeveledRectangleBorder()),
                                onPressed: getSessions,
                                child: const Text('Refresh'))
                          ],
                        ),
                      ))
                    : sessionsData.isEmpty
                        ? Column(
                            children: [
                              backGroundLoadingScreen(
                                  "You don't have any sessions."),
                              TextButton(
                                  style: ElevatedButton.styleFrom(
                                      shape: BeveledRectangleBorder()),
                                  onPressed: getSessions,
                                  child: const Text('Refresh'))
                            ],
                          )
                        : ListView.builder(
                            itemBuilder: (context, index) {
                              return sessionsData[index]["sessionStatus"] ==
                                          'PENDING' ||
                                      sessionsData[index]["sessionStatus"] ==
                                          'Pending'
                                  ? schedulesCard(index, width)
                                  : const SizedBox(
                                      height: 0,
                                    );
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
