import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:wellnesswarriors/Modal/userData.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'Modal/psycoData.dart';
import 'config.dart';
import 'constant/constant.dart';
import 'constant/counterModel.dart';
import 'package:http/http.dart' as http;

class BookingConfirmation extends StatefulWidget {
  const BookingConfirmation(
      {super.key,
      required this.psycologistID,
      required this.userID,
      required this.date,
      required this.sessionStatus,
      required this.meetLink,
      required this.sessionId,
      required this.slot});

  final String userID;
  final String psycologistID;
  final String date;
  final String slot;
  final String sessionStatus;
  final String meetLink;
  final String sessionId;
  @override
  State<BookingConfirmation> createState() => _BookingConfirmationState();
}

class _BookingConfirmationState extends State<BookingConfirmation> {
  final userD = userModel();
  final psycoD = psycoProfileData();
  bool loading = true;
  DateTime book = DateTime.now();
  var meetLink = 'Not Shared yet';
  String selectedStatus = 'Schedule soon';
  var reviewData;
  bool reviewPosted = false;
  bool reviewPostingStart = false;
  List<String> status = [
    "Missed by User",
    "Missed by Psycologist",
    "Pending",
    "Successfull",
  ];
  var _stars = 0;
  final TextEditingController _textFieldController = TextEditingController();
  DateTime tempDate = DateTime.now();
  @override
  void initState() {
    super.initState();
    String slot = widget.slot;
    if (slot.length == 7) slot = '0$slot';
    int hour = int.parse(slot.split(":")[0]);
    int minute = int.parse(slot.split(":")[1].split(" PM")[0].split(" AM")[0]);
    bool isPm = slot.contains("PM") ? true : false;
// final DateTime newDate = DateTime(year,month,day,hour,minute);
    book = DateTime.parse(widget.date);
    tempDate = DateTime(
        book.year, book.month, book.day, isPm ? hour + 12 : hour, minute, 00);
    meetLink = widget.meetLink;
    selectedStatus = widget.sessionStatus;
    if (!status.contains(selectedStatus)) {
      status.add(selectedStatus);
    }
    loadData();
  }

  Future<void> postReview(int star, String msg) async {
    setState(() {
      reviewPostingStart = true;
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
    var url = postReviewApi;
    final uri = Uri.parse(url);
    try {
      final regBody = {
        "userId": widget.userID,
        "psychologistId": widget.psycologistID,
        "stars": star,
        "review": msg
      };
      final response =
          await http.post(uri, headers: headers, body: jsonEncode(regBody));
      if (response.statusCode == 200) {
        var json = jsonDecode(response.body);
        reviewData = json["review"];
        setState(() {
          reviewPosted = true;
        });
        sendNotification(
            '${userD.name} submit review about your recent session completed on ${DateFormat.yMMMEd().format(book)}, ${widget.slot}.',
            'Session Review');
        // Fluttertoast.showToast(msg: "Review Posted");
      } else {
        debugPrint('Network Error5');
        Fluttertoast.showToast(msg: "Network Error!");
      }
    } catch (e) {
      Fluttertoast.showToast(msg: "Network Error!");
    }
    setState(() {
      reviewPostingStart = false;
      _stars = 0;
      _textFieldController.clear();
    });
  }

  Future<void> ReviewDialog(BuildContext context) async {
    return showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(builder:
            (BuildContext context, void Function(void Function()) setState) {
          Widget _buildStar(int starCount) {
            return InkWell(
              child: Icon(
                Icons.star,
                color: _stars >= starCount
                    ? Colors.redAccent
                    : const Color.fromARGB(255, 255, 255, 255),
              ),
              onTap: () {
                setState(() {
                  _stars = starCount;
                });
              },
            );
          }

          return AlertDialog(
            backgroundColor: Colors.amber,
            title: const Center(
              child: Text('Customer Reviews'),
            ),
            content: SizedBox(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      const SizedBox(
                        height: 10,
                      ),
                      _buildStar(1),
                      _buildStar(2),
                      _buildStar(3),
                      _buildStar(4),
                      _buildStar(5),
                    ],
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  TextField(
                    clipBehavior: Clip.none,
                    keyboardType: TextInputType.multiline,
                    maxLines: null,
                    controller: _textFieldController,
                    decoration: const InputDecoration(
                        hintText:
                            "Awesome! felt comfortable sharing troubles, clinical experience, easy …"),
                  ),
                ],
              ),
            ),
            actions: <Widget>[
              ElevatedButton(
                child: const Text('CANCEL'),
                onPressed: () {
                  _stars = 0;
                  _textFieldController.clear();
                  Navigator.of(context).pop;
                },
              ),
              ElevatedButton(
                child: reviewPostingStart
                    ? const Center(
                        child: CircularProgressIndicator(),
                      )
                    : const Text('OK'),
                onPressed: () async {
                  if (_stars < 1) {
                    Fluttertoast.showToast(
                        msg: 'Please rate the psycologist first');
                    return;
                  }
                  if (_textFieldController.value.text.isEmpty) {
                    Fluttertoast.showToast(
                        msg: 'Please review the psycologist first');
                    return;
                  }
                  postReview(_stars, _textFieldController.value.text);
                  _stars = 0;
                  _textFieldController.clear();
                  Navigator.of(context).pop(_stars);
                },
              )
            ],
          );
        });
      },
    );
  }

  void sendNotification(String msg, String title) async {
    // print("sending noti");
    // var userToken = await notificationService.getUserDeviceToken(widget.userID);
    var psycoToken =
        await notificationService.getUserDeviceToken(widget.psycologistID);
    var data = {
      'type': 'Booking',
      'psycologistID': widget.psycologistID,
      'userID': widget.userID,
      'date': widget.date,
      'sessionStatus': selectedStatus,
      'meetLink': meetLink,
      "sesionId": widget.sessionId,
      "slot": widget.slot
    };

    // notificationService.pushNotifications(
    //     token: userToken, title: title, body: msg, data: data);
    notificationService.pushNotifications(
        token: psycoToken, title: title, body: msg, data: data);
    print("sent");
  }

  Future<void> loadData() async {
    await userD.loadUser(widget.userID);
    await psycoD.loadUser(widget.psycologistID);
    setState(() {
      loading = false;
    });
  }

  _launchURLBrowser() async {
    try {
      // var url = Uri.parse("https://meet.google.com/ipb-fpmx-zps");

      if (meetLink != "Yet to be scheduled by the psychologist") {
        var url = meetLink.contains("https")
            ? Uri.parse(meetLink)
            : Uri.parse("https://$meetLink");
        await launchUrl(url);
      } else {
        Fluttertoast.showToast(msg: 'meet is not schedule by psycologist yet');
      }
    } catch (e) {
      Fluttertoast.showToast(msg: 'meet is not schedule by psycologist yet');
    }
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        elevation: 4,
        shadowColor: Colors.black,
        leading: const BackButton(),
        // backgroundColor: Color.fromRGBO(191, 69, 91, 1),
        backgroundColor: Colors.orange,
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
                child: SingleChildScrollView(
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
                            color: Color.fromRGBO(219, 101, 123, 1)),
                      ),
                      SizedBox(
                        height: height * 0.01,
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                        child: Text(
                          textAlign: TextAlign.center,
                          // 'Your Appoinment with ${psycoD.name} on 30 Mar, 2024 at 2:30 is confirmed.',
                          'Your Appoinment with ${psycoD.name} on ${DateFormat.yMMMEd().format(book)} at ${widget.slot}  is confirmed.',
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
                                          color: Colors.transparent,
                                          child: userD.imgPath == ''
                                              ? null
                                              : Ink.image(
                                                  image: NetworkImage(
                                                      userD.imgPath),
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
                                          color: Colors.transparent,
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
                          'Session ID :  ${widget.sessionId}',
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
                        Provider.of<counter>(context, listen: false)
                            .timer(tempDate);
                        return Container(
                          height: 80,
                          width: width,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: buildTimeCard(
                                    value.days.toString(), 'Days'),
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
                                color: const Color.fromRGBO(152, 143, 144, 1)),
                          ),
                        ),
                      ),
                      SizedBox(
                        width: width,
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(10, 8, 0, 0),
                          child: InkWell(
                            onTap: _launchURLBrowser,
                            child: Text(
                              meetLink,
                              style: knormalText.copyWith(
                                  color: const Color.fromRGBO(45, 102, 247, 1)),
                            ),
                          ),
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
                                    color:
                                        const Color.fromRGBO(152, 143, 144, 1)),
                              ),
                              const SizedBox(
                                width: 20,
                              ),
                              SizedBox(
                                width: 200,
                                child: Text(
                                  selectedStatus,
                                  style: const TextStyle(color: Colors.black),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(
                        height: height * 0.04,
                      ),
                      ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              foregroundColor:
                                  const Color.fromARGB(255, 225, 224, 224),
                              disabledForegroundColor: Colors.black54,
                              // disabledBackgroundColor: Colors.green,
                              backgroundColor: tempDate
                                          .difference(DateTime.now())
                                          .inSeconds >
                                      0
                                  ? Colors.black54
                                  : const Color.fromRGBO(222, 82, 108, 1)),
                          onPressed: () {
                            tempDate.difference(DateTime.now()).inSeconds > 0
                                ? Fluttertoast.showToast(
                                    msg:
                                        'You can give feedback after the meeting is completed')
                                : ReviewDialog(context);
                          },
                          child: Text(
                            'Add Review',
                            style: GoogleFonts.lato().copyWith(
                              fontWeight: FontWeight.w900,
                              fontSize: 16,
                            ),
                          ))
                    ],
                  ),
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
                color: const Color.fromRGBO(191, 69, 91, 1),
                borderRadius: BorderRadius.circular(5)),
            child: Center(
              child: Text(
                time,
                style: const TextStyle(
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
