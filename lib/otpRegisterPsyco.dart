import 'dart:convert';

import 'package:flutter/material.dart';
import './config.dart';
import './psycoRegister.dart';
import './resetpassword.dart';
import 'package:pinput/pinput.dart';
import './psycoLogin.dart';
import 'package:http/http.dart' as http;

class otpScreenRagisterPsyco extends StatefulWidget {
  final otpNum;
  final email;
  const otpScreenRagisterPsyco(
      {Key? key, required this.otpNum, required this.email})
      : super(key: key);

  @override
  State<otpScreenRagisterPsyco> createState() => _otpScreenRagisterPsycoState();
}

class _otpScreenRagisterPsycoState extends State<otpScreenRagisterPsyco> {
  final pinputController = TextEditingController();
  bool load = false;
  Future<void> verifyEmail() async {
    setState(() {
      load = true;
    });

    final regBody = {
      "token": pinputController.value.text,
      "email": widget.email
    };

    var response = await http.post(
      Uri.parse(userverificationPsyco),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(regBody),
    );

    if (response.statusCode == 200 || response.statusCode == 202) {
      var jsonResponse = jsonDecode(response.body);
      if (jsonResponse["success"]) {
        showSuccessMessage(
            "Your Account has been verified Successfully! Please Login");
        Navigator.popUntil(context, (Route<dynamic> route) => route.isFirst);

        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => PsycoLogin()));
      } else {
        debugPrint(response.body.toString());
        showErorMessage('Something went wrong! ');
      }
    } else {
      debugPrint(
          'Something went wrong with token system${response.statusCode}${response.body}');
      showErorMessage('Something went wrong! ');
    }
    setState(() {
      load = false;
    });
    //showSuccessMessage('Successful LoggedIn ');
  }

  void showSuccessMessage(String message) {
    final snackBar = SnackBar(
      content: Text(
        message,
        style: TextStyle(color: Colors.yellow),
      ),
      backgroundColor: Colors.green,
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  void showErorMessage(String message) {
    final snackBar = SnackBar(
      content: Text(
        message,
        style: const TextStyle(color: Colors.white),
      ),
      backgroundColor: Colors.red,
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    final defaultPinTheme = PinTheme(
      width: 56,
      height: 56,
      textStyle: const TextStyle(
          fontSize: 20,
          color: Color.fromRGBO(30, 60, 87, 1),
          fontWeight: FontWeight.w600),
      decoration: BoxDecoration(
        color: Colors.cyan,
        border: Border.all(color: const Color.fromRGBO(129, 193, 246, 1)),
        borderRadius: BorderRadius.circular(10),
      ),
    );

    final focusedPinTheme = defaultPinTheme.copyDecorationWith(
      border: Border.all(color: Color.fromRGBO(114, 178, 238, 1)),
      borderRadius: BorderRadius.circular(8),
    );

    final submittedPinTheme = defaultPinTheme.copyWith(
      decoration: defaultPinTheme.decoration?.copyWith(
        color: Color.fromRGBO(234, 239, 243, 1),
      ),
    );
    return Scaffold(
        extendBodyBehindAppBar: true,
        // appBar: AppBar(
        //   backgroundColor: Colors.transparent,
        //   elevation: 0,
        //   leading: IconButton(
        //     onPressed: () {
        //       Navigator.push(
        //           context,
        //           MaterialPageRoute(
        //             builder: (context) => loginScreen(),
        //           ));
        //     },
        //     icon: const Icon(Icons.arrow_back_ios_rounded),
        //     color: Colors.black,
        //   ),
        // ),
        body: Container(
          color: Colors.cyan.shade800,
          height: height,
          width: width,
          child: Stack(children: [
            Container(
              padding: EdgeInsets.only(left: 25, right: 25),
              alignment: Alignment.center,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Text(
                    //   'Forgot Password?',
                    //   style: TextStyle(
                    //       fontSize: 24,
                    //       fontWeight: FontWeight.bold,
                    //       color: Color.fromARGB(255, 36, 36, 36)),
                    // ),
                    Image.asset(
                      'assets/images/otp.png',
                      width: 150,
                    ),
                    const Text(
                      'Enter your verification code',
                      style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color.fromARGB(255, 36, 36, 36)),
                    ),
                    const SizedBox(height: 10),
                    Text(
                        'We have sent a verification pin to your registred email ID ${widget.email}'),
                    const SizedBox(
                      height: 70,
                    ),

                    Pinput(
                      androidSmsAutofillMethod:
                          AndroidSmsAutofillMethod.smsUserConsentApi,
                      listenForMultipleSmsOnAndroid: true,
                      controller: pinputController,
                      defaultPinTheme: PinTheme(
                        width: 56,
                        height: 56,
                        textStyle: const TextStyle(
                            fontSize: 20,
                            color: Color.fromRGBO(30, 60, 87, 1),
                            fontWeight: FontWeight.w600),
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(207, 154, 207, 251),
                          border: Border.all(
                              color: const Color.fromRGBO(129, 193, 246, 1)),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      length: 6,
                      showCursor: true,
                      validator: (value) {
                        return value == widget.otpNum.toString()
                            ? null
                            : 'Pin is Incorrect';
                      },
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    SizedBox(
                      height: 45,
                      width: double.infinity,
                      child: ElevatedButton(
                          onPressed: () {
                            if (pinputController.value.text ==
                                widget.otpNum.toString()) {
                              // showSuccessMessage("")
                              verifyEmail();
                            } else {
                              showErorMessage("Pin is incorrect");
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.cyan.shade100,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                          ),
                          child: load
                              ? Center(
                                  child: CircularProgressIndicator(),
                                )
                              : const Text(
                                  'Verify OTP',
                                  style: TextStyle(fontWeight: FontWeight.w700),
                                )),
                    ),
                    TextButton(
                        onPressed: () {
                          Navigator.popUntil(
                              context, (Route<dynamic> route) => route.isFirst);

                          Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const RagisterPsyco()));
                        },
                        child: const Text(
                          'Edit email?',
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.red,
                          ),
                        ))
                  ],
                ),
              ),
            ),
            SizedBox(
              height: 100,
              width: width * 0.7,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Image.asset(
                    color: Colors.white,
                    'assets/images/BIBLogo.png',
                    width: 70,
                  ),
                  const Text(
                    'WELLNESS WARRIORS',
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black),
                  ),
                ],
              ),
            ),
          ]),
        ));
  }
}
