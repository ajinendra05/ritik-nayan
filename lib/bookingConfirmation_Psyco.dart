import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:wellnesswarriors/Modal/psycoAccount.dart';
import 'package:wellnesswarriors/Modal/userAccount.dart';
import 'package:wellnesswarriors/Modal/userData.dart';
import 'package:wellnesswarriors/psyprofile.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'Modal/psycoData.dart';
import 'config.dart';
import 'constant/constant.dart';
import 'constant/counterModel.dart';
import 'constant/fixApi.dart';

class BookingConfirmationPsyco extends StatefulWidget {
  const BookingConfirmationPsyco(
      {super.key,
      required this.psycologistID,
      required this.userID,
      required this.date,
      required this.sessionStatus,
      required this.meetLink,
      required this.sesionId,
      required this.slot});
  final String sesionId;
  final String userID;
  final String psycologistID;
  final String date;
  final String sessionStatus;
  final String meetLink;
  final String slot;

  @override
  State<BookingConfirmationPsyco> createState() =>
      _BookingConfirmationPsycoState();
}

class _BookingConfirmationPsycoState extends State<BookingConfirmationPsyco> {
  final userD = userModel();
  final psycoD = psycoProfileData();
  bool loading = true;
  var book;
  var meetLink = 'Not Shared yet';
  String selectedStatus = 'Schedule soon';
  List<String> status = [
    "Missed by User",
    "Missed by Psycologist",
    "Pending",
    "Successfull",
  ];
  final TextEditingController _textFieldController = TextEditingController();
  @override
  void initState() {
    super.initState();
    String slot = widget.slot;
    if (slot.length == 7) slot = '0$slot';
    int hour = int.parse(slot.split(":")[0]);
    int minute = int.parse(slot.split(":")[1].split(" PM")[0].split(" AM")[0]);
    bool isPm = slot.contains("PM") ? true : false;
    book = DateTime.parse(widget.date);
    book = DateTime(
        book.year, book.month, book.day, isPm ? hour + 12 : hour, minute, 00);
    meetLink = widget.meetLink;
    selectedStatus = widget.sessionStatus;
    if (!status.contains(selectedStatus)) {
      status.add(selectedStatus);
    }
    loadData();
  }

  Future<void> loadData() async {
    await userD.loadUser(widget.userID);
    await psycoD.loadUser(widget.psycologistID);
    print('object154');
    // await userD.loadUser('65af8a53b07c78c251323ee8');
    // await psycoD.loadUser('65af78bfd849511617a333db');

    setState(() {
      loading = false;
    });
  }

  _launchURLBrowser() async {
    try {
      // var url = Uri.parse("https://meet.google.com/ipb-fpmx-zps");
      var url = Uri.parse(meetLink);
      if (await canLaunchUrl(url)) {
        await launchUrl(url);
      } else {
        Fluttertoast.showToast(msg: 'meet is not schedule by psycologist yet');
      }
    } catch (e) {
      Fluttertoast.showToast(msg: 'meet is not schedule by psycologist yet');
    }
  }

  Future<void> updateMeetLink(String meet) async {
    setState(() {
      meetLink = meet;
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
    var url = '$updateSession${psycoData.id}/${widget.sesionId}';
    final uri = Uri.parse(url);
    try {
      final regBody = {"meetlink": meet};
      final response =
          await http.post(uri, headers: headers, body: jsonEncode(regBody));
      if (response.statusCode == 200) {
        var json = jsonDecode(response.body);
        setState(() {
          meetLink = json["session"]["meetLink"];
        });
        sendNotification(
            '${psycoD.name} has updated google meet link for session scheduled on ${DateFormat.yMMMEd().format(book)} at ${widget.slot} ',
            'Session Update');
      } else {
        debugPrint('Network Error');
        Fluttertoast.showToast(msg: "Network Error!");
      }
    } catch (e) {
      Fluttertoast.showToast(msg: "Network Error!");
    }
    setState(() {});
  }

  Future<void> updateSessionStatus(String status) async {
    // setState(() {
    //   sessionLoad = true;
    // });

    var prefs = await SharedPreferences.getInstance();
    var myToken = prefs.getString('token') ?? "";
    var cookies = [
      'token=$myToken',
    ];

    var headers = {
      'Cookie': cookies.join('; '),
      'Content-Type': 'application/json'
    };
    var url = '$updateSession${psycoData.id}/${widget.sesionId}';
    final uri = Uri.parse(url);
    try {
      final regBody = {"sessionStatus": status};
      final response =
          await http.post(uri, headers: headers, body: jsonEncode(regBody));
      if (response.statusCode == 200) {
        var json = jsonDecode(response.body);
        setState(() {
          selectedStatus = json["session"]["sessionStatus"];
        });
        sendNotification(
            '${psycoD.name} has updated session status for session completed at ${DateFormat.yMMMEd().format(book)}, ${widget.slot}. Now you can submit review about your meet',
            'Session Update');
      } else {
        debugPrint('Network Error');
        Fluttertoast.showToast(msg: "Network Error!2");
      }
    } catch (e) {
      Fluttertoast.showToast(msg: "Network Error!");
    }
    setState(() {});
  }

  void sendNotification(String msg, String title) async {
    var userToken = await notificationService.getUserDeviceToken(widget.userID);
    // var psycoToken =
    //     await notificationService.getUserDeviceToken(widget.psycologistID);
    var data = {
      'type': 'Booking',
      'psycologistID': widget.psycologistID,
      'userID': widget.userID,
      'date': widget.date,
      'sessionStatus': selectedStatus,
      'meetLink': meetLink,
      "sesionId": widget.sesionId,
      "slot": widget.slot
    };
    saveNotificationuser(
        userID: widget.userID, message: msg, title: title, data: data);
    notificationService.pushNotifications(
        token: userToken, title: title, body: msg, data: data);
    // notificationService.pushNotifications(
    //     token: psycoToken, title: title, body: msg, data: data);
  }

  Future<void> _displayTextInputDialog(BuildContext context) async {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Insert Meet Link'),
          content: TextField(
            controller: _textFieldController,
            decoration: const InputDecoration(
                hintText: "https://meet.google.com/mpe-wfgs-saw"),
          ),
          actions: <Widget>[
            ElevatedButton(
              child: const Text('CANCEL'),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            ElevatedButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.pop(context);
                updateMeetLink(_textFieldController.text.trim());
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        elevation: 4,
        shadowColor: Colors.black,
        leading: const BackButton(),
        // backgroundColor: Color.fromRGBO(191, 69, 91, 1),
        backgroundColor: Colors.cyan.shade800,
        title: Text(
          'Appointment',
          style: kAppBarText,
        ),
      ),
      body: loading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : MultiProvider(
              providers: [
                ChangeNotifierProvider<counter>(create: (BuildContext context) {
                  return counter();
                }),
              ],
              child: Container(
                // color: Color.fromRGBO(213, 57, 85, 1),
                // color: Colors.orange,
                height: height * 0.9,
                width: width,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: height * 0.04,
                    ),
                    Text(
                      'Appointment Confirm!',
                      style: kh1Text.copyWith(
                          color: const Color.fromRGBO(219, 101, 123, 1)),
                    ),
                    SizedBox(
                      height: height * 0.01,
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                      child: Text(
                        textAlign: TextAlign.center,
                        // 'Your Appoinment with ${psycoD.name} on 30 Mar, 2024 at 2:30 is confirmed.',
                        'Your Appoinment with ${psycoD.name} on ${DateFormat.yMMMEd().format(book)} at ${widget.slot} is confirmed.',
                        style: knormalText.copyWith(
                          color: const Color.fromRGBO(152, 143, 144, 1),
                        ),
                      ),
                    ),
                    Divider(
                      indent: width * 0.3,
                      endIndent: width * 0.3,
                    ),
                    SizedBox(
                      height: height * 0.03,
                    ),
                    SizedBox(
                      height: height * 0.2,
                      width: width,
                      child: Row(
                        children: [
                          SizedBox(
                              height: height * 0.25,
                              width: width * 0.5,
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  Image.asset(
                                    'assets/images/bcBack5.png',
                                    height: 150,
                                    width: 150,
                                  ),
                                  Positioned(
                                    child: ClipOval(
                                      child: Material(
                                        color: Colors.orange,
                                        child: userD.imgPath == ''
                                            ? null
                                            : Ink.image(
                                                image:
                                                    NetworkImage(userD.imgPath),
                                                fit: BoxFit.cover,
                                                width: 110,
                                                height: 110,
                                                // child: InkWell(onTap: onClicked),
                                              ),
                                      ),
                                    ),
                                  ),
                                  // CircleAvatar(
                                  //   minRadius: 70,
                                  //   backgroundColor: Colors.amber,
                                  //   backgroundImage: userD.imgPath == ''
                                  //       ? null
                                  //       : NetworkImage(
                                  //           'https://wellnesswarriorsnp.onrender.com' +
                                  //               userD.imgPath),
                                  // )
                                ],
                              )),
                          SizedBox(
                              height: height * 0.25,
                              width: width * 0.5,
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  ClipOval(
                                      child: Image.asset(
                                    'assets/images/bcBack5.png',
                                    height: 150,
                                    width: 150,
                                  )),
                                  Positioned(
                                    child: ClipOval(
                                      child: Material(
                                        color: Colors.orange,
                                        child: psycoD.imgPath == ''
                                            ? null
                                            : Ink.image(
                                                image: NetworkImage(
                                                    psycoD.imgPath),
                                                fit: BoxFit.cover,
                                                width: 110,
                                                height: 110,
                                                // child: InkWell(onTap: onClicked),
                                              ),
                                      ),
                                    ),
                                  ),
                                  // CircleAvatar(
                                  //   minRadius: 70,
                                  //   backgroundColor: Colors.amber,
                                  //   backgroundImage: userD.imgPath == ''
                                  //       ? null
                                  //       : NetworkImage(
                                  //           'https://wellnesswarriorsnp.onrender.com' +
                                  //               userD.imgPath),
                                  // )
                                ],
                              ))
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 20,
                      width: width,
                      child: Row(
                        // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // SizedBox(
                          //   width: width * 0.1,
                          // ),
                          SizedBox(
                            width: width * 0.5,
                            child: Center(
                              child: Text(
                                userD.name,
                                style: kh2Text.copyWith(
                                    overflow: TextOverflow.ellipsis),
                              ),
                            ),
                          ),
                          // SizedBox(
                          //   width: width * 0.35,
                          // ),
                          Container(
                            padding: const EdgeInsets.only(left: 10),
                            width: width * 0.5,
                            child: Center(
                              child: Text(
                                psycoD.name,
                                style: kh2Text.copyWith(
                                    overflow: TextOverflow.ellipsis),
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 20,
                      width: width,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          SizedBox(
                            width: width * 0.5,
                            child: Center(
                              child: Text(
                                userD.email,
                                style: kh4Text.copyWith(
                                    overflow: TextOverflow.ellipsis),
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.only(left: 10),
                            width: width * 0.5,
                            child: Center(
                              child: Text(
                                psycoD.email,
                                style: kh4Text.copyWith(
                                    overflow: TextOverflow.ellipsis),
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 30, 20, 0),
                      child: Text(
                        textAlign: TextAlign.center,
                        // 'Your Appoinment with ${psycoD.name} on 30 Mar, 2024 at 2:30 is confirmed.',
                        'Session ID :  ${widget.sesionId}',
                        style: knormalText.copyWith(
                          fontSize: 12,
                          color: const Color.fromRGBO(152, 143, 144, 1),
                        ),
                      ),
                    ),
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 5, 20, 0),
                        child: Text(
                          'Time left For appoinment.',
                          style: knormalText.copyWith(
                              color: Color.fromRGBO(152, 143, 144, 1)),
                        ),
                      ),
                    ),
                    Consumer<counter>(builder: (context, value, child) {
                      Provider.of<counter>(context, listen: false).timer(book);
                      return Container(
                        height: 80,
                        width: width,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child:
                                  buildTimeCard(value.days.toString(), 'Days'),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: buildTimeCard(
                                  value.hours.toString(), 'Hours'),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: buildTimeCard(
                                  value.minutes.toString(), 'Minutes'),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: buildTimeCard(
                                  value.sec.toString(), 'Seconds'),
                            ),
                          ],
                        ),

                        //  Padding(
                        //   padding: const EdgeInsets.fromLTRB(20, 30, 20, 0),
                        //   child: Text(
                        //     '${value.days}-${value.hours}-${value.minutes}',
                        //     style: knormalText.copyWith(
                        //         color: Color.fromRGBO(152, 143, 144, 1)),
                        //   ),
                        // ),
                      );
                    }),
                    SizedBox(
                      width: width,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(10, 8, 0, 0),
                        child: Text(
                          'Meet link :',
                          style: knormalText.copyWith(
                              color: Color.fromRGBO(152, 143, 144, 1)),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 40,
                      width: width,
                      child: ListTile(
                        title: SizedBox(
                          width: width,
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                            child: InkWell(
                              onTap: _launchURLBrowser,
                              child: Text(
                                meetLink,
                                style: knormalText.copyWith(
                                    color: Color.fromRGBO(45, 102, 247, 1)),
                              ),
                            ),
                          ),
                        ),
                        trailing: IconButton(
                            onPressed: () {
                              _displayTextInputDialog(context);
                            },
                            icon: Icon(Icons.edit)),
                      ),
                    ),
                    SizedBox(
                      width: width,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(10, 15, 0, 0),
                        child: Row(
                          children: [
                            Text(
                              'Status :',
                              style: knormalText.copyWith(
                                  color: Color.fromRGBO(152, 143, 144, 1)),
                            ),
                            const SizedBox(
                              width: 20,
                            ),
                            Container(
                              width: 200,
                              height: 30,
                              child: InputDecorator(
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(
                                      borderSide: BorderSide(width: 2),
                                      borderRadius: BorderRadius.circular(1.0)),
                                  contentPadding: const EdgeInsets.all(2),
                                ),
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton<String>(
                                      isDense: true,
                                      style: TextStyle(fontSize: 13),
                                      // isExpanded: true,
                                      menuMaxHeight: 350,
                                      value: selectedStatus,
                                      onChanged: (String? newValue) {
                                        if (book
                                                .difference(DateTime.now())
                                                .inMinutes >
                                            0) {
                                          Fluttertoast.showToast(
                                              msg:
                                                  'You can\'t update session status before the time of meet');
                                          return;
                                        }

                                        if (newValue != null)
                                          updateSessionStatus(newValue);
                                        setState(() {
                                          selectedStatus =
                                              newValue ?? 'Schedule soon';
                                        });
                                      },
                                      items: [
                                        const DropdownMenuItem(
                                          value: "",
                                          child: Text(
                                            "Select Here",
                                          ),
                                        ),
                                        ...status.map((String value) {
                                          return DropdownMenuItem<String>(
                                            value: value,
                                            child: Text(
                                              value,
                                              style: TextStyle(
                                                  color: Colors.black),
                                            ),
                                          );
                                        }).toList(),
                                      ]),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(
                      height: height * 0.04,
                    ),
                    // ElevatedButton(
                    //     style: ElevatedButton.styleFrom(
                    //         foregroundColor: Color.fromARGB(255, 225, 224, 224),
                    //         disabledForegroundColor: Colors.black54,
                    //         // disabledBackgroundColor: Colors.green,
                    //         backgroundColor: Color.fromRGBO(222, 82, 108, 1)),
                    //     onPressed:
                    //         selectedStatus == 'Schedule soon' ? null : () {},
                    //     child: Text(
                    //       'Add Review',
                    //       style: GoogleFonts.lato().copyWith(
                    //         fontWeight: FontWeight.w900,
                    //         fontSize: 16,
                    //       ),
                    //     ))
                  ],
                ),
              ),
            ),
    );
  }
}

Widget buildTimeCard(String time, String header) => SizedBox(
      height: 60,
      width: 60,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            height: 35,
            width: 35,
            // padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
                color: Color.fromRGBO(191, 69, 91, 1),
                borderRadius: BorderRadius.circular(5)),
            child: Center(
              child: Text(
                time,
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontSize: 20),
              ),
            ),
          ),
          Text(header)
        ],
      ),
    );
