import 'dart:convert';
import 'package:flutter/material.dart';
import './config.dart';
import './loginscreen.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ResetPasswordScreen extends StatefulWidget {
  final otpNum;
  final email;
  const ResetPasswordScreen(
      {super.key, required this.otpNum, required this.email});
  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  TextEditingController countrycode = TextEditingController();
  TextEditingController firstPassword = TextEditingController();
  TextEditingController secondPassword = TextEditingController();
  late SharedPreferences prefs;
  bool load = false;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    initSharedPref();
  }

  void initSharedPref() async {
    prefs = await SharedPreferences.getInstance();
  }

  Future<void> resetPassword() async {
    setState(() {
      load = true;
    });
    if (firstPassword.value.text != secondPassword.value.text) {
      showErorMessage("Password Does't match");
      return;
    }

    final regBody = {
      "password": firstPassword.value.text,
      "token": widget.otpNum,
      "email": widget.email
    };

    var response = await http.post(
      Uri.parse(resetPasswordApi),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(regBody),
    );

    if (response.statusCode == 200 || response.statusCode == 202) {
      var jsonResponse = jsonDecode(response.body);
      if (jsonResponse["success"]) {
        showSuccessMessage("Password Reset Succesfully");
        Navigator.popUntil(context, (Route<dynamic> route) => route.isFirst);
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => loginScreen()));
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
        style: TextStyle(color: Colors.white),
      ),
      backgroundColor: Colors.red,
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;

    return Scaffold(
        body: Container(
      color: Colors.orange,
      height: height,
      width: width,
      child: Stack(
        children: [
          Container(
            margin: EdgeInsets.only(left: 25, right: 25),
            alignment: Alignment.center,
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    // color: Colors.green,
                    'assets/images/password.png',
                    width: 150,
                  ),
                  const Text(
                    'Reset Password.',
                    style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color.fromARGB(255, 36, 36, 36)),
                  ),
                  const SizedBox(height: 30),
                  const Row(
                    children: [
                      Text('Please enter a new password'),
                    ],
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Container(
                    height: 55,
                    padding: const EdgeInsets.only(left: 15),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5),
                        border: Border.all(width: 1, color: Colors.black)),
                    child: TextField(
                      obscureText: true,
                      controller: firstPassword,
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        hintText: 'Enter new password',
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Container(
                    height: 55,
                    padding: const EdgeInsets.only(left: 15),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5),
                        border: Border.all(width: 1, color: Colors.black)),
                    child: TextField(
                      obscureText: true,
                      controller: secondPassword,
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        hintText: 'Enter again',
                      ),
                    ),
                  ),

                  /*Container(
                      height: 55,
                      decoration: BoxDecoration(
                        border: Border.all(width: 1,color: Colors.grey),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 10,
                          ),
                          SizedBox(
                            width: 40,
                            child: TextField(
                              controller: countrycode,
                              decoration: InputDecoration(
                                border: InputBorder.none,
                              ),
                            ),
                          ),
          
                          Text('I',style: TextStyle(
                            fontSize: 43,
                            color: Colors.grey.shade600,
                          ),),
                          Expanded(
                            child: TextField(
                              decoration: InputDecoration(
                                border: InputBorder.none,
                              ),
                            ),
                          )
                        ],
                      ),
                    ),*/
                  const SizedBox(
                    height: 20,
                  ),
                  SizedBox(
                    height: 45,
                    width: double.infinity,
                    child: ElevatedButton(
                        onPressed: () {
                          if (firstPassword.value.text.isEmpty) {
                            showErorMessage("Please enter valid password");
                          } else {
                            resetPassword();
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.cyan.shade100,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ),
                        child: load
                            ? const Center(
                                child: CircularProgressIndicator(
                                  strokeWidth: 1,
                                ),
                              )
                            : const Text(
                                'Reset Password',
                                style: TextStyle(fontWeight: FontWeight.w700),
                              )),
                  ),
                  // SizedBox(
                  //   height: 10,
                  // ),
                  // Text("Or"),
                  // SizedBox(
                  //     height: 40,
                  //     width: double.infinity,
                  //     child: TextButton(
                  //       onPressed: signInwithGoogle,
                  //       child: Text("Sign in with Google"),
                  //     )),
                  // SizedBox(
                  //     height: 40,
                  //     width: double.infinity,
                  //     child: TextButton(
                  //       onPressed: () {
                  //         Navigator.pushReplacement(
                  //             context,
                  //             MaterialPageRoute(
                  //                 builder: ((context) => PsycoLogin())));
                  //       },
                  //       child: Text("psychologist Login"),
                  //     )),
                  // SizedBox(
                  //   height: 20,
                  // ),
                  // SizedBox(
                  //   height: 30,
                  // ),
                  // Divider(
                  //   color: Colors.grey,
                  // ),
                  // SizedBox(
                  //     height: 40,
                  //     width: double.infinity,
                  //     child: TextButton(
                  //         onPressed: () {
                  //           Navigator.pushReplacement(
                  //               context,
                  //               MaterialPageRoute(
                  //                   builder: ((context) => loginScreen())));
                  //         },
                  //         child: RichText(
                  //           text: TextSpan(
                  //             style: TextStyle(
                  //               fontSize: 14.0,
                  //               color: Colors.black,
                  //             ),
                  //             children: <TextSpan>[
                  //               new TextSpan(text: 'Don\'t need to do this. '),
                  //               new TextSpan(
                  //                   text: 'Login',
                  //                   style: new TextStyle(
                  //                       fontWeight: FontWeight.bold,
                  //                       color: Colors.green)),
                  //             ],
                  //           ),
                  //         ))),
                ],
              ),
            ),
          ),
          SizedBox(
            height: 100,
            width: width * 0.9,
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
        ],
      ),
    ));
  }
}
