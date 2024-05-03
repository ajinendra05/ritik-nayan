import 'dart:convert';
import 'dart:math';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import './Modal/userAccount.dart';
import './bookSlot.dart';
import './bookingConfiramtion.dart';
import './chatScreen.dart';
import './config.dart';
import './constant/constant.dart';
import './dialog.dart';
import './navbar.dart';
import './notificationservice.dart';
import './paymentGateway.dart';
import './recharge.dart';
import './widget/Button.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:jiffy/jiffy.dart';
import 'package:intl/intl.dart';

import 'Modal/psycoAccount.dart';
import 'constant/fixApi.dart';
import 'notificationScreen.dart';

class psyprofile extends StatefulWidget {
  final String psychologistId;
  const psyprofile({super.key, required this.psychologistId});
  @override
  State<psyprofile> createState() => _psyprofileState();
}

class _psyprofileState extends State<psyprofile> {
  int amounttoPay = 0;
  bool load = true;
  late Map<String, dynamic> psyprofiles;
  List reviews = [];
  List reviewUsers = [];
  double walletBalance = -1;
  var bookingDetails;
  late String email = "";
  late SharedPreferences prefs;
  List amount = [100, 200, 300, 500, 1000, 2000, 3000, 4000, 8000];
  late var hgt;
  late var wth;
  late final paymentGateway pginstance;
  bool isBalanceLoaded = false;
  int selected = -1;
  DateTime choosedDate = DateTime.now();
  List shedule = [];
  bool load2 = true;
  bool load3 = false;
  Future<void> fetchPsychologistData() async {
/*
  final queryParameters = {
  'name': 'Bob',
  'age': '87',
};
final uri = Uri.http('www.example.com', '/path', queryParameters);
final headers = {HttpHeaders.contentTypeHeader: 'application/json'};
final response = await http.get(uri, headers: headers);

    try {
      final regBody = {"psychologistId": "6598997ad730939f3d5095b8"};
      final uri = Uri.https('', url, regBody);
      final headers = {HttpHeaders.contentTypeHeader: 'application/json'};
      print(uri);
      final response = await http.get(uri, headers: headers);
      print(response);
      print(response.statusCode);
      if (response.statusCode == 200) {
        print(response.statusCode);
        var json = jsonDecode(response.body);
        setState(() {
          psyprofiles = json;
        });
      } else {
        debugPrint('Show error');
      }
    } catch (e) {
      print(e);
    }
*/
    final url = "${psyprofiledata}?psychologistId=${widget.psychologistId}";
    final uri = Uri.parse(url);
    final response = await http.get(
      uri,
    );
    if (response.statusCode == 200) {
      var json = jsonDecode(response.body);
      setState(() {
        psyprofiles = json;
      });
    } else {
      debugPrint('Network Error');
      Fluttertoast.showToast(msg: "Network Error!");
    }
    final url2 = "$userReviewData?psychologistId=${widget.psychologistId}";
    final uri2 = Uri.parse(url2);
    final respons2 = await http.get(uri2);
    if (respons2.statusCode == 200) {
      var json2 = jsonDecode(respons2.body);
      setState(() {
        reviews = json2;
        // load = false;
      });
      // try {
      //   final refrence = FirebaseStorage.instance.ref().child('userImage');
      //   final upldImg = refrence.child('${widget.psychologistId}.jpg');
      //   var imgPath = await upldImg.getDownloadURL();
      //   psyprofiles['imagepath'] = imgPath;
      // } catch (e) {
      //   psyprofiles['imagepath'] = null;
      // }
      UserDatafetch();
    } else {
      debugPrint('Network Error');
      Fluttertoast.showToast(msg: "Network Error!");
    }
  }

  Future<void> UserDatafetch() async {
    for (int i = 0; i < reviews.length; i++) {
      String id = reviews[i]['userId'];
      final url = '$userProfile?userId=$id';
      final uri = Uri.parse(url);
      try {
        final response = await http.get(uri);

        if (response.statusCode == 200) {
          var json = jsonDecode(response.body);
          var name = json['name'] ?? "";
          var imgPath = json['imagePath'] ?? "";
          // try {
          //   final refrence = FirebaseStorage.instance.ref().child('userImage');
          //   final upldImg = refrence.child('${id}.jpg');
          //   imgPath = await upldImg.getDownloadURL();
          // } catch (e) {
          //   imgPath = null;
          // }
          reviewUsers.add({'name': name, 'imgPath': imgPath});
        } else {
          //show error
          Fluttertoast.showToast(msg: "Network Error!");
        }
      } catch (e) {
        Fluttertoast.showToast(msg: "Network Error!");
      }
    }
    setState(() {
      print("final");
      load = false;
    });
  }

  void initSharedPref() async {
    prefs = await SharedPreferences.getInstance();
    var myToken = prefs.getString('token') ?? "";

    Map<String, dynamic> jwtDecoderToken = JwtDecoder.decode(myToken);
    email = jwtDecoderToken['email'];
  }

  @override
  void initState() {
    super.initState();
    pginstance = paymentGateway(context: context);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      asyncMethod();
    });
    pginstance.razorpay
        .on(Razorpay.EVENT_PAYMENT_SUCCESS, pginstance.handlePaymentSuccess);
    pginstance.razorpay
        .on(Razorpay.EVENT_PAYMENT_ERROR, pginstance.handlePaymentError);
    pginstance.razorpay
        .on(Razorpay.EVENT_EXTERNAL_WALLET, pginstance.handleExternalWallet);
  }

  @override
  void dispose() {
    pginstance.razorpay.clear(); // Removes all listeners
    // TODO: implement dispose
    super.dispose();
  }

  void asyncMethod() async {
    initSharedPref();
    userData.getWalletBalance();
    fetchPsychologistData();
    getShedule(choosedDate);
  }

  Future<bool> bookSlot(String id, DateTime date, String slot) async {
    //book session
    const url2 = bookSession;
    final uri2 = Uri.parse(url2);
    //  "date": dat"Network Error!",
    print(slot);
    final regBody2 = {
      "userId": userData.id,
      "amount": 379,
      "date": "${date.year}-${date.month}-${date.day}",
      "closingBalance": (userData.walletbalance - 379),
      "psychologistId": id,
      "paymentId": "Wallet Transection",
      "slot": slot,
      "username": userData.name,
      "psycname": psyprofiles['name'],
      "userEmail": userData.email
    };
    print(regBody2);
    var prefs = await SharedPreferences.getInstance();
    var myToken = prefs.getString('token') ?? "";
    var cookies = [
      'token=$myToken',
    ];

    var headers = {
      'Cookie': cookies.join('; '),
      'Content-Type': 'application/json'
    };

    try {
      final response =
          await http.post(uri2, body: jsonEncode(regBody2), headers: headers);
      if (response.statusCode == 200) {
        var json = jsonDecode(response.body);
        print(json);
        setState(() {
          bookingDetails = json["newBooking"];
        });
        return true;
      } else {
        Fluttertoast.showToast(msg: "Network Error!book");
      }
    } catch (e) {
      Fluttertoast.showToast(msg: "Network Error!");
    }
    return false;
  }

  Future<bool> setShedule(
      int index, String id, DateTime date, String slot, bool avlb) async {
    await userData.getWalletBalance();
    if (userData.walletbalance < 379) {
      noEnoughBalance(context);
      Navigator.pop(context);
      return false;
    }

    // var prefs = await SharedPreferences.getInstance();
    // var myToken = prefs.getString('token') ?? "";
    // var cookies = [
    //   'token=${myToken}',
    // ];

    // var headers = {
    //   'Cookie': cookies.join('; '),
    //   'Content-Type': 'application/json'
    // };

    // const url = getPyscoShedule;
    // final uri = Uri.parse(url);
    // final regBody = {
    //   "psychologistId": id,
    //   "date": "${date.year}-${date.month}-${date.day}",
    //   "slot": slot,
    //   "available": true
    // };
    bool booked = await bookSlot(id, date, slot);
    if (!booked) {
      return false;
    }
    await getShedule(choosedDate);
    setState(() {
      load = false;
      load3 = false;
    });
    return true;

    // try {
    //   final response =
    //       await http.post(uri, body: jsonEncode(regBody), headers: headers);
    //   if (response.statusCode == 200) {
    //     var json = jsonDecode(response.body);
    //     print(regBody);
    //     print(json);
    //     setState(() {
    //       shedule = json["slots"];
    //       load = false;
    //       load3 = false;
    //     });

    //     return true;
    //   } else {
    //     debugPrint('Network Error slot booking');
    //     Fluttertoast.showToast(msg: "Network Error!");
    //   }
    // } catch (e) {
    //   print(e);
    //   Fluttertoast.showToast(msg: "Network Error!");
    // }
  }

  void showSlotDialog() {
    hgt = MediaQuery.of(context).size.height;
    wth = MediaQuery.of(context).size.width;
    showGeneralDialog(
      barrierLabel: "showGeneralDialog",
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(0.6),
      transitionDuration: const Duration(milliseconds: 400),
      context: context,
      pageBuilder: (context, _, __) {
        return Align(
          alignment: Alignment.center,
          child: _buildSlotDialogContent(),
        );
      },
      transitionBuilder: (_, animation1, __, child) {
        return SlideTransition(
          position: Tween(
            begin: const Offset(0, 1),
            end: const Offset(0, 0),
          ).animate(animation1),
          child: child,
        );
      },
    );
  }

  Widget _buildSlotDialogContent() {
    return StatefulBuilder(builder:
        (BuildContext context, void Function(void Function()) setState) {
      DateTime present = DateTime.now();
      bool presentDay = present.year == choosedDate.year &&
          present.month == choosedDate.month &&
          present.day == choosedDate.day;
      var date = Jiffy.parse(
              "${choosedDate.year}/${choosedDate.month}/${choosedDate.day}")
          .yMMMMd;
      var day = DateFormat('EEEE').format(choosedDate);
      return IntrinsicHeight(
        child: Container(
          width: double.maxFinite,
          clipBehavior: Clip.antiAlias,
          padding: const EdgeInsets.all(16),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.all(Radius.circular(5)),
          ),
          child: Material(
            child: Column(
              children: [
                const Text(
                  'Select Slot',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
                Column(children: [
                  // const Text(
                  //   "Choose Date",
                  //   style: TextStyle(
                  //       fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black54),
                  // ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      IconButton(
                          onPressed: () {
                            setState(() {
                              if (choosedDate.compareTo(DateTime.now()) > 0) {
                                choosedDate =
                                    choosedDate.add(Duration(days: -1));
                                load2 = true;
                              } else {
                                Fluttertoast.showToast(
                                    msg: "Cant go to befores date");
                              }

                              selected = -1;
                            });
                            getShedule(choosedDate).then((value) => {
                                  setState(
                                    () {
                                      load2 = false;
                                    },
                                  )
                                });
                          },
                          icon: const Icon(
                            Icons.arrow_circle_left,
                            color: Colors.orange,
                          )),
                      GestureDetector(
                        onTap: () {
                          _selectDate(context).then((value) {
                            setState(() {});
                          });
                          setState(
                            () {
                              load2 = true;
                              selected = -1;
                            },
                          );
                        },
                        child: Container(
                          width: MediaQuery.of(context).size.width * 0.6,
                          height: 60,
                          decoration: BoxDecoration(
                              border: Border.all(
                                  color: const Color.fromARGB(165, 0, 0, 0),
                                  width: 1),
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
                              choosedDate = choosedDate.add(Duration(days: 1));
                              load2 = true;
                              selected = -1;
                            });
                            getShedule(choosedDate).then((value) => {
                                  setState(
                                    () {
                                      load2 = false;
                                    },
                                  )
                                });
                          },
                          icon: const Icon(Icons.arrow_circle_right,
                              color: Colors.orange))
                    ],
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Column(
                    children: [
                      const Divider(),
                      load2
                          ? const Center(
                              child: CircularProgressIndicator(
                                color: Colors.amber,
                              ),
                            )
                          : SizedBox(
                              height: MediaQuery.of(context).size.height * 0.35,
                              width: double.infinity,
                              child: Container(
                                  margin:
                                      const EdgeInsets.fromLTRB(10, 5, 10, 0),
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
                                          child: shedule[index]["available"] ||
                                                  (presentDay &&
                                                      present.hour >= 3 + index)
                                              ? Container(
                                                  // margin: EdgeInsets.all(10),

                                                  decoration: BoxDecoration(
                                                    color: Colors.grey,
                                                    borderRadius:
                                                        const BorderRadius.all(
                                                            Radius.circular(5)),
                                                    border: Border.all(
                                                        color: Colors.black,
                                                        width: 1),
                                                  ),
                                                  child: const Center(
                                                    child: Text(
                                                      // '${shedule[index]['time']}',
                                                      'Not Available',
                                                      style: TextStyle(
                                                        color: Colors.black,
                                                        fontSize: 10,
                                                      ),
                                                    ),
                                                  ),
                                                )
                                              : InkWell(
                                                  onTap: () {
                                                    setState(() {
                                                      selected = index;
                                                    });
                                                    bool flag = shedule[index]
                                                        ['available'];
                                                  },
                                                  splashColor: Colors.amber,
                                                  child: Container(
                                                    // margin: EdgeInsets.all(10),

                                                    decoration: BoxDecoration(
                                                      color: selected == index
                                                          ? Colors.amber
                                                          : null,
                                                      borderRadius:
                                                          const BorderRadius
                                                              .all(
                                                              Radius.circular(
                                                                  5)),
                                                      border: Border.all(
                                                          color: Colors.black,
                                                          width: 1),
                                                    ),
                                                    child: Center(
                                                      child: Text(
                                                        '${shedule[index]['time']}',
                                                        style: const TextStyle(
                                                          color: Colors.black,
                                                          fontSize: 10,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                        );
                                        // : Container(
                                        //     height: 0,
                                        //     width: 0,
                                        //   );
                                      },
                                    ),
                                  )),
                            ),
                      const SizedBox(
                        height: 5,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                          onPressed: () {
                            if (selected == -1) {
                              Fluttertoast.showToast(
                                  msg: "First Select a slot");
                            } else if (selected >= 0 &&
                                selected < shedule.length) {
                              ConfirmToBook(context, 379);
                            }
                          },
                          // onPressed: () {
                          //   // pginstance.openCheckout(379);
                          //   if (selected == -1) {
                          //     Fluttertoast.showToast(
                          //         msg: "First Select a slot");
                          //   } else if (selected >= 0 &&
                          //       selected < shedule.length) {
                          //     setState(
                          //       () {
                          //         load3 = true;
                          //       },
                          //     );

                          //     setShedule(0, widget.psychologistId, choosedDate,
                          //             shedule[selected]['time'], true)
                          //         .then((value) {
                          //       setState(
                          //         () {
                          //           load3 = false;
                          //           selected = -1;
                          //         },
                          //       );
                          //       if (value) {
                          //         // slotBooked(context);
                          //         // print(bookingDetails["psychologistId"]);
                          //         // print(bookingDetails["userId"]);
                          //         // print(bookingDetails["date"]);
                          //         // print(bookingDetails["sessionStatus"]);
                          //         print(bookingDetails);
                          //         Navigator.pop(context);
                          //         Navigator.push(context, MaterialPageRoute(
                          //           builder: (context) {
                          //             return BookingConfirmation(
                          //               psycologistID:
                          //                   bookingDetails["psychologistId"],
                          //               userID: bookingDetails["userId"],
                          //               date: bookingDetails["date"],
                          //               sessionStatus: "pending",
                          //               meetLink: "Schedule Soon",
                          //             );
                          //           },
                          //         ));
                          //       } else {
                          //         slotbookingerror(context);
                          //       }
                          //     });
                          //   }
                          // },
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange),
                          child: load3
                              ? Center(
                                  child: CircularProgressIndicator(),
                                )
                              : const Text(
                                  'Book Slot',
                                  style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black),
                                )),
                    ],
                  ),
                ]),
              ],
            ),
          ),
        ),
      );
    });
  }

  Future<void> ConfirmToBook(BuildContext context, int amount) async {
    return showDialog(
      context: context,
      builder: (con) {
        final w = MediaQuery.of(con).size.width;
        final h = MediaQuery.of(con).size.height;
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: Colors.white,
              title: const Center(
                child: SizedBox(
                    child: Column(
                  children: [
                    Text(
                      'Confirm Payment',
                      style:
                          TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    Text(
                      'Review details of this transaction and hit Confirm to proceed',
                      style: TextStyle(color: Colors.black87, fontSize: 14),
                    ),
                  ],
                )),
              ),
              content: SizedBox(
                height: h * 0.3,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Container(
                      width: w,
                      height: 90,
                      margin: const EdgeInsets.fromLTRB(0, 30, 0, 30),
                      padding: const EdgeInsets.fromLTRB(20, 5, 20, 5),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5),
                          color: const Color.fromARGB(97, 255, 214, 79)),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            width: w,
                            child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text('Amount'),
                                  Text('$amount Rs')
                                ]),
                          ),
                          const SizedBox(
                            height: 3,
                          ),
                          SizedBox(
                            width: w * 0.8,
                            child: const Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [Text('Charges'), Text('+ 0.0 Rs')]),
                          ),
                          const SizedBox(
                            height: 5,
                          ),
                          SizedBox(
                            width: w * 0.8,
                            child: const Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Total Amount',
                                    style: TextStyle(
                                        color:
                                            Color.fromARGB(255, 127, 39, 186),
                                        fontWeight: FontWeight.w800,
                                        fontSize: 16),
                                  ),
                                  Text(
                                    '379 Rs',
                                    style: TextStyle(
                                        color:
                                            Color.fromARGB(255, 127, 39, 186),
                                        fontWeight: FontWeight.w800,
                                        fontSize: 16),
                                  )
                                ]),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      width: w,
                      child: ElevatedButton(
                          onPressed: () {
                            // pginstance.openCheckout(379);
                            if (selected == -1) {
                              Fluttertoast.showToast(
                                  msg: "First Select a slot");
                            } else if (selected >= 0 &&
                                selected < shedule.length) {
                              setState(
                                () {
                                  load3 = true;
                                },
                              );

                              setShedule(0, widget.psychologistId, choosedDate,
                                      shedule[selected]['time'], true)
                                  .then((value) {
                                setState(
                                  () {
                                    load3 = false;
                                    selected = -1;
                                  },
                                );
                                if (value) {
                                  // slotBooked(context);
                                  // print(bookingDetails["psychologistId"]);
                                  // print(bookingDetails["userId"]);
                                  // print(bookingDetails["date"]);
                                  // print(bookingDetails["sessionStatus"]);
                                  print(bookingDetails);
                                  Navigator.pop(context);
                                  Navigator.pop(context);
                                  sendNotifications(bookingDetails);
                                  Navigator.push(context, MaterialPageRoute(
                                    builder: (context) {
                                      return BookingConfirmation(
                                        slot: bookingDetails["slot"],
                                        sessionId: bookingDetails["_id"],
                                        psycologistID:
                                            bookingDetails["psychologistId"],
                                        userID: bookingDetails["userId"],
                                        date: bookingDetails["date"],
                                        sessionStatus: "Pending",
                                        meetLink: "Schedule Soon",
                                      );
                                    },
                                  ));
                                } else {
                                  slotbookingerror(context);
                                }
                              });
                            }
                          },
                          style: ElevatedButton.styleFrom(
                              shape: const BeveledRectangleBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(5))),
                              backgroundColor: Colors.orange),
                          child: load3
                              ? Center(
                                  child: CircularProgressIndicator(),
                                )
                              : const Text(
                                  'Confirm',
                                  style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black),
                                )),
                    ),
                  ],
                ),
              ),
              // actions: <Widget>[
              //   ElevatedButton(
              //     child: const Text('CANCEL'),
              //     onPressed: () {
              //       Navigator.of(context).pop;
              //     },
              //   ),
              //   ElevatedButton(
              //     child: const Text('OK'),
              //     onPressed: () async {
              //       Navigator.of(context).pop();
              //     },
              //   )
              // ],
            );
          },
        );
      },
    );
  }

  void sendNotifications(dynamic bookindDetails) async {
    print(bookindDetails["userId"]);
    print(bookindDetails["psychologistId"]);
    var userToken;
    var psycoToken;
    try {
      userToken = await notificationService
          .getUserDeviceToken(bookindDetails["userId"]);
      psycoToken = await notificationService
          .getUserDeviceToken(bookindDetails["psychologistId"]);
    } catch (e) {
      print("ye bhi error hai $e");
    }

    var data = {
      'type': 'Booking',
      'psycologistID': bookindDetails["psychologistId"],
      'userID': bookindDetails["userId"],
      'date': bookindDetails["date"],
      'sessionStatus': 'Pending',
      'meetLink': "Schedule Soon",
      "sesionId": bookindDetails["_id"],
      "slot": bookindDetails["slot"]
    };
    try {
      saveNotificationuser(
          userID: bookindDetails["userId"],
          message:
              'Your booking with ${psyprofiles['name']} has been confirmed on ${DateFormat.yMMMEd().format(DateTime.parse(bookindDetails["date"]))}, ${bookindDetails["slot"]}',
          title: 'Booking Confirmation',
          data: data);
      saveNotificationPsyco(
          psycoID: bookindDetails["psychologistId"],
          message:
              'You have new session request from ${userData.name} on ${DateFormat.yMMMEd().format(DateTime.parse(bookindDetails["date"]))}, ${bookindDetails["slot"]}',
          title: 'Booking Confirmation',
          data: data);
      notificationService.pushNotifications(
          token: userToken,
          title: 'Booking Confirmation',
          body:
              'Your booking with ${psyprofiles['name']} has been confirmed on ${DateFormat.yMMMEd().format(DateTime.parse(bookindDetails["date"]))}, ${bookindDetails["slot"]}',
          data: data);
      notificationService.pushNotifications(
          token: psycoToken,
          title: 'Booking Confirmation',
          body:
              'You have new session request from ${userData.name} on ${DateFormat.yMMMEd().format(DateTime.parse(bookindDetails["date"]))}, ${bookindDetails["slot"]}',
          data: data);
    } catch (e) {
      print("error ye hai : $e");
    }
  }

  void showBottomDialog() {
    hgt = MediaQuery.of(context).size.height;
    wth = MediaQuery.of(context).size.width;
    showGeneralDialog(
      barrierLabel: "showGeneralDialog",
      barrierDismissible: true,
      barrierColor: Colors.black.withOpacity(0.6),
      transitionDuration: const Duration(milliseconds: 400),
      context: context,
      pageBuilder: (context, _, __) {
        return Align(
          alignment: Alignment.bottomCenter,
          child: _buildDialogContent(),
        );
      },
      transitionBuilder: (_, animation1, __, child) {
        return SlideTransition(
          position: Tween(
            begin: const Offset(0, 1),
            end: const Offset(0, 0),
          ).animate(animation1),
          child: child,
        );
      },
    );
  }

  Widget _buildDialogContent() {
    return StatefulBuilder(builder:
        (BuildContext context, void Function(void Function()) setState) {
      return IntrinsicHeight(
        child: Container(
          width: double.maxFinite,
          clipBehavior: Clip.antiAlias,
          padding: const EdgeInsets.all(16),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
            ),
          ),
          child: Material(
            child: Column(
              children: [
                Text(
                  "Minimum Balance of 379 Rs is required to book slot with ${psyprofiles['name']}.",
                  style: const TextStyle(
                      color: Colors.red,
                      fontSize: 14,
                      fontWeight: FontWeight.w400),
                ),
                const SizedBox(height: 16),
                const Text(
                  "Recharge Now",
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: 19,
                      fontWeight: FontWeight.w700),
                ),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.lightbulb,
                      color: Colors.amber,
                    ),
                    Text(
                      "   Tips:  90% user recharge for 10 min or more.",
                      style: TextStyle(
                          fontSize: 12,
                          color: Colors.black,
                          fontWeight: FontWeight.w400),
                    )
                  ],
                ),
                const SizedBox(height: 5),
                SizedBox(
                  height: hgt * 0.15,
                  child: GridView.count(
                    crossAxisCount: 4,
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 7,
                    childAspectRatio: 2.2,
                    children: List.generate(
                      8,
                      (index) {
                        return SizedBox(
                          height: 10,
                          width: 10,
                          child: InkWell(
                            onTap: () {
                              setState(() {
                                amounttoPay = amount[index];
                              });
                            },
                            splashColor: Colors.amber,
                            child: Container(
                              // margin: EdgeInsets.all(10),

                              decoration: BoxDecoration(
                                color: amounttoPay == amount[index]
                                    ? Colors.amber
                                    : null,
                                borderRadius:
                                    BorderRadius.all(Radius.circular(5)),
                                border:
                                    Border.all(color: Colors.black, width: 1),
                              ),
                              child: Center(
                                child: Text(
                                  'Rs. ${amount[index]}',
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontSize: 11,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text("$amounttoPay Rs."),
                ElevatedButton(
                    onPressed: () {
                      pginstance.openCheckout(amounttoPay);
                    },
                    style:
                        ElevatedButton.styleFrom(backgroundColor: Colors.amber),
                    child: const Text(
                      'Proceed To Pay',
                      style: TextStyle(
                          fontWeight: FontWeight.w600, color: Colors.black),
                    )),
              ],
            ),
          ),
        ),
      );
    });
  }

//

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: choosedDate, // Refer step 1
      firstDate: DateTime.now(),
      lastDate: DateTime(2025),
    );
    if (picked != null && picked != choosedDate)
      setState(() {
        load2 = false;
        choosedDate = picked;
      });
    await getShedule(choosedDate);

    return;
  }

  Future<void> getShedule(DateTime date) async {
    final url =
        "${getPyscoShedule}?psychologistId=${widget.psychologistId}&date=${choosedDate.year}-${choosedDate.month}-${choosedDate.day}";
    final uri = Uri.parse(url);
// ?psychologistId=6598997ad730939f3d5095b8&date=2024-01-03
    try {
      final response = await http.get(
        uri,
      );
      if (response.statusCode == 200) {
        var json = jsonDecode(response.body);
        setState(() {
          shedule = json["slots"];
          print(shedule);
          load2 = false;
        });
      } else {
        debugPrint('Network Error');
        Fluttertoast.showToast(msg: "Network Error!2");
      }
    } catch (e) {
      print(e);
      Fluttertoast.showToast(msg: "Network Error!");
    }
  }

  Future<void> getWalletBalance() async {
    prefs = await SharedPreferences.getInstance();
    var myToken = prefs.getString('token') ?? "";
    var cookies = [
      'token=${myToken}',
    ];

    var headers = {
      'Cookie': cookies.join('; '),
      'Content-Type': 'application/json'
    };

    final url = "$getWalletBalnce?userId=${userData.id}";
    print(url);
    final uri = Uri.parse(url);

    final response = await http.get(
      uri,
      headers: headers,
    );
    print(response.statusCode);
    print(response);
    print(response.body);
    if (response.statusCode == 200) {
      var json = jsonDecode(response.body);
      setState(() {
        walletBalance = json['walletBalance'].toDouble();
        isBalanceLoaded = true;
      });
    } else {
      debugPrint('Network Error');
      Fluttertoast.showToast(msg: "Network Error! Try again");
    }
  }

  Future<void> fetchBalanceAndBook() async {
    await userData.getWalletBalance();
    if (userData.walletbalance >= 379) {
      showSlotDialog();
    } else {
      showBottomDialog();
    }
  }

  Future<void> bookShedule(DateTime date, int index) async {
    showBottomDialog();

    // await getWalletBalance();
    // final chargepm = psyprofiles['chargespm'];
    // final charge = chargepm * 60;

    // if (charge < walletBalance) {
    // } else {
    //   showBottomDialog();
    // }
  }

  Widget gridview() {
    DateTime present = DateTime.now();
    bool presentDay = present.year == choosedDate.year &&
        present.month == choosedDate.month &&
        present.day == choosedDate.day;
    return Container(
        margin: EdgeInsets.fromLTRB(10, 5, 10, 0),
        child: GridView.count(
          crossAxisCount: 4,
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          childAspectRatio: 2.5,
          children: List.generate(
            shedule.length,
            (index) {
              return shedule[index]["available"]
                  ? SizedBox(
                      height: 10,
                      width: 10,
                      child: InkWell(
                        onTap: presentDay && present.hour >= 3 + index
                            ? null
                            : () {
                                setState(() {
                                  selected = index;
                                });
                                bool flag = shedule[index]['available'];
                              },
                        splashColor: Colors.amber,
                        child: Container(
                          // margin: EdgeInsets.all(10),

                          decoration: BoxDecoration(
                            color: presentDay && present.hour >= 3 + index
                                ? Colors.grey.shade400
                                : selected == index
                                    ? Colors.amber
                                    : null,
                            borderRadius: BorderRadius.all(Radius.circular(5)),
                            border: Border.all(color: Colors.black, width: 0.7),
                          ),
                          child: Center(
                            child: Text(
                              presentDay && present.hour >= 3 + index
                                  ? "Not available"
                                  : '${shedule[index]['time']}',
                              style: const TextStyle(
                                color: Colors.black,
                                fontSize: 10,
                              ),
                            ),
                          ),
                        ),
                      ),
                    )
                  : Container();
            },
          ),
        ));
  }

  @override
  Widget build(BuildContext context) {
    wth = MediaQuery.of(context).size.width;
    hgt = MediaQuery.of(context).size.height;

    return Scaffold(
      drawer: NavBar(),
      appBar: AppBar(
        backgroundColor: Colors.orange,
        title: const Text('Talk to Psychologist'),
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
              icon: const Icon(Icons.notifications))
        ],
      ),
      body: load
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : SizedBox(
              height: hgt * 0.9,
              child: Column(
                children: [
                  Container(
                    color: const Color.fromARGB(138, 246, 160, 30),
                    // color: Color.fromRGBO(191, 69, 91, 0.6),
                    width: MediaQuery.of(context).size.width,
                    height: hgt * 0.15,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 10),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          //color: Colors.blueGrey,
                          width: MediaQuery.of(context).size.width * 0.25,
                          height: 100,
                          child: CircleAvatar(
                            backgroundColor: Colors.orange,
                            backgroundImage: psyprofiles['imagepath'] == null
                                ? null
                                : NetworkImage(psyprofiles['imagepath']),
                          ),
                        ),
                        const SizedBox(width: 10),
                        SizedBox(
                          //color: Colors.red,
                          width: MediaQuery.of(context).size.width * 0.66,
                          child: Column(
                            //mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                width: wth * 0.7,
                                child: Text(psyprofiles['name'] ?? 'xyz',
                                    style: const TextStyle(fontSize: 20)),
                              ),
                              SizedBox(
                                width: MediaQuery.of(context).size.width * 0.66,
                                child: Text(
                                    psyprofiles['qualification'] == null
                                        ? ''
                                        : ' ${psyprofiles['qualification']}',
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontStyle: FontStyle.italic,
                                    )),
                              ),
                              psyprofiles['disorders'] == null
                                  ? const Text("Not Mentioned")
                                  : SizedBox(
                                      height: 20,
                                      width: MediaQuery.of(context).size.width *
                                          0.66,
                                      child: ListView.builder(
                                        scrollDirection: Axis.horizontal,
                                        itemBuilder: (context, index) => Text(
                                            "${psyprofiles['disorders'][index]['disorder_name']}, "),
                                        itemCount: min(
                                            psyprofiles['disorders'].length, 3),
                                      ),
                                    ),
                              const Text('379 INR /min'),
                              // psyprofiles['chargespm'] == null
                              //     ? const Text("Not Mentioned")
                              //     : Text(
                              //         '${psyprofiles['chargespm']} INR /min'),
                            ],
                          ),
                        ),
                      ],
                    ),
                    //height: 120,
                  ),
                  SizedBox(
                      height: hgt * 0.62,
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            Container(
                              margin:
                                  const EdgeInsets.only(left: 10, right: 10),
                              width: wth * 0.9,
                              // constraints: BoxConstraints(maxHeight: hgt * 0.1),
                              // height: hgt * 0.1,
                              //color: Colors.green,
                              child: SingleChildScrollView(
                                child: Text(
                                  psyprofiles['about'] ?? "",
                                  style: const TextStyle(
                                      fontSize: 17,
                                      fontStyle: FontStyle.italic),
                                ),
                              ),
                              // Profile Description in detail More, less
                            ),
                            const SizedBox(height: 10),
                            SizedBox(
                              width: wth * 0.9,
                              child: const Text(
                                'User Reviews ',
                                style: TextStyle(
                                    fontSize: 20, fontWeight: FontWeight.w900),
                              ),
                            ),
                            // Row(
                            //   children: [
                            //     Container(
                            //       width: MediaQuery.of(context).size.width * 0.35,
                            //       margin: const EdgeInsets.only(left: 10),
                            //       child: const Text(
                            //         'User Reviews ',
                            //         style: TextStyle(
                            //             fontSize: 20, fontWeight: FontWeight.w900),
                            //       ),
                            //     )
                            //   ],
                            // ),
                            Container(
                              color: Colors.white,
                              // height: (hgt * 0.6) - 120,
                              width: wth * 0.98,
                              child: reviews.isEmpty
                                  ? backGroundLoadingScreen(
                                      "${psyprofiles['name']} don't have any reviews yet.")
                                  : ListView.builder(
                                      itemCount: reviews.length,
                                      shrinkWrap: true,
                                      itemBuilder:
                                          (BuildContext con, int index) {
                                        final w = MediaQuery.of(con).size.width;
                                        return Container(
                                          width: w,
                                          margin: const EdgeInsets.symmetric(
                                              horizontal: 5, vertical: 5),
                                          child: Card(
                                            //color: Colors.pinkAccent.shade100,
                                            color: Colors.white,
                                            // elevation: 1,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(5),
                                            ),
                                            child: Container(
                                              decoration: BoxDecoration(
                                                  border: Border.all(
                                                      width: 0.5,
                                                      color: Colors.black26),
                                                  borderRadius:
                                                      BorderRadius.circular(5)),
                                              //color: Colors.green,
                                              width: MediaQuery.of(context)
                                                  .size
                                                  .width,
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 5,
                                                      vertical: 5),
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Row(
                                                    //mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      SizedBox(
                                                        // 1 in row
                                                        // color: Colors.green,
                                                        height: 45,
                                                        width: 45,
                                                        child: CircleAvatar(
                                                          backgroundColor:
                                                              Colors
                                                                  .greenAccent,
                                                          backgroundImage:
                                                              NetworkImage(reviewUsers[
                                                                          index]
                                                                      [
                                                                      'imgPath'] ??
                                                                  ""),
                                                        ),
                                                      ),
                                                      const SizedBox(
                                                        width: 10,
                                                      ),
                                                      SizedBox(
                                                        width: w * 0.7,
                                                        child: Column(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .start,
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            children: [
                                                              SizedBox(
                                                                width: w * 0.6,
                                                                child: Text(
                                                                  reviewUsers[index]
                                                                          [
                                                                          'name'] ??
                                                                      'xyz',
                                                                  style:
                                                                      const TextStyle(
                                                                    fontSize:
                                                                        15,
                                                                  ),
                                                                  textAlign:
                                                                      TextAlign
                                                                          .left,
                                                                ),
                                                              ),
                                                              SizedBox(
                                                                width: w * 0.6,
                                                                height: 15,
                                                                child: ListView
                                                                    .builder(
                                                                  scrollDirection:
                                                                      Axis.horizontal,
                                                                  itemCount:
                                                                      reviews[index]['stars']
                                                                              .ceil() ??
                                                                          0,
                                                                  itemBuilder:
                                                                      (context,
                                                                          index) {
                                                                    return const Padding(
                                                                      padding: EdgeInsets
                                                                          .fromLTRB(
                                                                              2,
                                                                              1,
                                                                              2,
                                                                              1),
                                                                      child:
                                                                          Icon(
                                                                        Icons
                                                                            .star,
                                                                        size:
                                                                            10,
                                                                        color: Colors
                                                                            .amber,
                                                                      ),
                                                                    );
                                                                  },
                                                                ),
                                                              ),
                                                            ]),
                                                      ),
                                                    ],
                                                  ),
                                                  SizedBox(
                                                    width: w * 0.9,
                                                    child: Text(reviews[index]
                                                            ['review'] ??
                                                        ""),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        );
                                      }),
                            ),
                          ],
                        ),
                      )),
                  Divider(),
                  SizedBox(
                    //color: Colors.green,
                    height: 50,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // SizedBox(
                        //   width: wth * 0.4,
                        //   height: 45,
                        //   child: Container(
                        //     child: ElevatedButton(
                        //       onPressed: () {
                        //         if (selected == -1) {
                        //           Fluttertoast.showToast(
                        //               msg: "Please select a slot to book");
                        //         } else {
                        //           bookShedule(choosedDate, selected);
                        //         }
                        //       },
                        //       child: Text(
                        //         'Book A Slot',
                        //         style: TextStyle(fontSize: 25),
                        //       ),
                        //     ),
                        //   ),
                        // ),
                        // SizedBox(width: 10),
                        // SizedBox(
                        //   height: hgt * 0.8,
                        //   width: wth * 0.45,
                        //   child: InkWell(
                        //     onTap: () {
                        //       Navigator.push(
                        //           context,
                        //           MaterialPageRoute(
                        //             builder: (context) => ChatScreen(),
                        //           ));
                        //     },
                        //     child: Button(
                        //         hgt * 0.02, wth * 0.1, "Chat", Icons.chat),
                        //   ),
                        // ),
                        SizedBox(
                          height: hgt * 0.8,
                          width: 150,
                          child: InkWell(
                            onTap: () {
                              setState(() {
                                selected = -1;
                              });
                              if (userData.walletbalance == -1) {
                                fetchBalanceAndBook();
                              } else {
                                if (userData.walletbalance >= 379) {
                                  showSlotDialog();
                                } else {
                                  showBottomDialog();
                                }
                              }

                              // bookShedule(choosedDate, selected);
                            },
                            child: Button(
                                hgt * 0.02, wth * 0.05, "Slots", Icons.book),
                          ),
                        )
                        /*SizedBox(
                        width: 180,
                        height: 45,
                        child: Container(
                          child: ElevatedButton(onPressed: (){},child: Text('Chat',style: TextStyle(fontSize: 25),),),
                        ),
                      )*/
                      ],
                    ),
                  )
                ],
              ),
            ),
    );
  }
}
