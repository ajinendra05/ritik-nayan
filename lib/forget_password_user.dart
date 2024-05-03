import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:wellnesswarriors/config.dart';
import 'package:wellnesswarriors/loginscreen.dart';
import 'package:wellnesswarriors/otp.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ForgetPasswordScreen extends StatefulWidget {
  @override
  State<ForgetPasswordScreen> createState() => _ForgetPasswordScreenState();
}

class _ForgetPasswordScreenState extends State<ForgetPasswordScreen> {
  TextEditingController countrycode = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  late SharedPreferences prefs;
  bool load = false;
  @override
  void initState() {
    // TODO: implement initState
    //countrycode.text="+91";
    super.initState();
    initSharedPref();
  }

  void initSharedPref() async {
    prefs = await SharedPreferences.getInstance();
  }

  Future<void> sendEmail() async {
    setState(() {
      load = true;
    });
    final email = emailController.value.text.trim();
    final regBody = {"email": email};
    final uri = Uri.parse(forgotPassword);

    var response = await http.post(
      Uri.parse(forgotPassword),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(regBody),
    );
    if (response.statusCode == 200) {
      var jsonResponse = jsonDecode(response.body);

      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => otpScreen(
                    otpNum: jsonResponse["t"],
                    email: email,
                  )));
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
        style: const TextStyle(color: Colors.yellow),
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

    return Scaffold(
        body: Container(
      color: Colors.orange,
      height: height,
      width: width,
      child: Stack(
        children: [
          Container(
            margin: const EdgeInsets.only(left: 25, right: 25),
            alignment: Alignment.center,
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    // color: Colors.black,
                    'assets/images/forgot.png',
                    width: 150,
                  ),
                  const Text(
                    'Forgot Password?',
                    style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color.fromARGB(255, 36, 36, 36)),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                      'Enter the email you registered with and we will send you a pin to reset your password.'),
                  const SizedBox(
                    height: 70,
                  ),
                  Container(
                    height: 55,
                    padding: const EdgeInsets.only(left: 15),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5),
                        border: Border.all(width: 1, color: Colors.black)),
                    child: TextField(
                      controller: emailController,
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        hintText: 'Email ID',
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  // Container(
                  //   height: 55,
                  //   decoration: BoxDecoration(
                  //       border: Border.all(width: 1, color: Colors.green)),
                  //   child: TextField(
                  //     obscureText: true,
                  //     controller: passwordController,
                  //     decoration: InputDecoration(
                  //       border: InputBorder.none,
                  //       hintText: 'Password',
                  //     ),
                  //   ),
                  // ),

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
                    height: 5,
                  ),
                  SizedBox(
                    height: 45,
                    width: double.infinity,
                    child: ElevatedButton(
                        onPressed: () {
                          FocusScope.of(context).unfocus();
                          if (emailController.value.text.isEmpty ||
                              !emailController.value.text.contains('@')) {
                            setState(() {
                              emailController.clear();
                            });
                            showErorMessage("Enter valid email");
                          } else {
                            sendEmail();
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
                                'Send Email',
                                style: TextStyle(fontWeight: FontWeight.w700),
                              )),
                  ),

                  const SizedBox(
                    height: 30,
                  ),
                  const Divider(
                    color: Colors.grey,
                  ),
                  SizedBox(
                      height: 40,
                      width: double.infinity,
                      child: TextButton(
                          onPressed: () {
                            Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: ((context) => loginScreen())));
                          },
                          child: RichText(
                            text: const TextSpan(
                              style: TextStyle(
                                fontSize: 14.0,
                                color: Colors.black,
                              ),
                              children: <TextSpan>[
                                TextSpan(text: 'Don\'t need to do this. '),
                                TextSpan(
                                    text: 'Login',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white)),
                              ],
                            ),
                          ))),
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
