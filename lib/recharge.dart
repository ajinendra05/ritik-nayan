import 'dart:convert';

import 'package:flutter/material.dart';
import './config.dart';
import 'package:http/http.dart' as http;
import 'package:fluttertoast/fluttertoast.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'Modal/userAccount.dart';
import 'paymentGateway.dart';

class RechargeScreen extends StatefulWidget {
  const RechargeScreen({super.key});

  @override
  State<RechargeScreen> createState() => _RechargeScreenState();
}

class _RechargeScreenState extends State<RechargeScreen> {
  late final paymentGateway pginstance;
  double walletBalance = 0;
  bool flag = true;
  List amount = [
    50,
    100,
    200,
    300,
    500,
    1000,
    1500,
    2000,
    2500,
    3000,
    3500,
    4000,
    5000,
    8000,
    10000
  ];
  int amounttoPay = 0;

  @override
  void initState() {
    super.initState();
    getWalletBalance();

    pginstance = paymentGateway(context: context);

    pginstance.razorpay
        .on(Razorpay.EVENT_PAYMENT_SUCCESS, pginstance.handlePaymentSuccess);
    pginstance.razorpay
        .on(Razorpay.EVENT_PAYMENT_ERROR, pginstance.handlePaymentError);
    pginstance.razorpay
        .on(Razorpay.EVENT_EXTERNAL_WALLET, pginstance.handleExternalWallet);
  }

  Future<void> getWalletBalance() async {
    var prefs = await SharedPreferences.getInstance();
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
      userData.walletbalance = json['walletBalance'].toDouble();
      setState(() {
        flag = false;
      });
    } else {
      debugPrint('Network Error');
      Fluttertoast.showToast(msg: "Network Error!");
    }
    // userData.loadUser();
  }

  @override
  Widget build(BuildContext context) {
    double hgt = MediaQuery.of(context).size.height;
    double wth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Add money to wallet'),
        backgroundColor: Colors.orange,
      ),
      body: flag
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Padding(
                padding: EdgeInsets.all(
                  8,
                ),
                child: Text(
                  'Available Balance',
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: Colors.grey),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
                child: Text(
                  '₹ ${userData.walletbalance}',
                  style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: Color.fromARGB(255, 45, 44, 44)),
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(15, 0, 15, 0),
                child: SizedBox(
                  height: hgt * 0.6,
                  child: GridView.count(
                    crossAxisCount: 2,
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 30,
                    childAspectRatio: 3.5,
                    children: List.generate(
                      15,
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
                                    const BorderRadius.all(Radius.circular(5)),
                                border:
                                    Border.all(color: Colors.black, width: 1),
                              ),
                              child: Center(
                                child: Text(
                                  '₹ ${amount[index]}',
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontSize: 15,
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
              ),
              const SizedBox(height: 16),
              Padding(
                padding: EdgeInsets.fromLTRB(wth * 0.4, 10, wth * 0.2, 10),
                child: Text("$amounttoPay Rs"),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(wth * 0.28, 0, wth * 0.2, 10),
                child: ElevatedButton(
                    onPressed: () {
                      pginstance.openCheckout(amounttoPay);
                    },
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.amber,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5))),
                    child: const Text(
                      'Proceed To Pay',
                      style: TextStyle(
                          fontWeight: FontWeight.w600, color: Colors.black),
                    )),
              ),
            ]),
    );
  }
}
