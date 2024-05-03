import 'dart:convert';
//import 'dart:js_interop';

import 'package:flutter/material.dart';
import './dashtry.dart';
// import './loginscreen.dart';
import './main.dart';
import './otp.dart';
import './otpRagister.dart';
import './otpRegisterPsyco.dart';
// import './registeruser.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'config.dart';
import 'googleSignInapi.dart';
import 'psycoLogin.dart';

class RagisterPsyco extends StatefulWidget {
  const RagisterPsyco({Key? key}) : super(key: key);

  @override
  State<RagisterPsyco> createState() => _RagisterPsycoState();
}

class _RagisterPsycoState extends State<RagisterPsyco> {
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  bool startRagister = false;
  bool _isNotValidate = false;
  bool _validateName = false;
  bool _validateEmail = false;
  bool _validatePassword = false;

  Future<void> RagisterPsycos() async {
    final name = nameController.text;
    final email = emailController.text.trim();
    final password = passwordController.text;
    final regBody = {
      "username": name,
      "email": email,
      "password": password,
    };
    final uri = Uri.parse(psycoRegistration);
    var response = await http.post(uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(regBody));

    if (response.statusCode == 200 || response.statusCode == 201) {
      showSuccessMessage(
          'Account Registered Succefully! \n Please check your email to verify account.');

      var jsonResponse = jsonDecode(response.body);
      String otp = jsonResponse["rest"]["token"];
      String email = jsonResponse["rest"]["email"];
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => otpScreenRagisterPsyco(
                    otpNum: otp.toString(),
                    email: email,
                  )));
    } else {
      showErorMessage(jsonDecode(response.body)["msg"]);
      print('Failed to register');
      print(response.body);
    }
  }

  Future ragisterWithGoogle() async {
    await googleSignInApi.logout();
    final user = await googleSignInApi.login();
    print(user?.email);
    if (user != null) {
      final googleauth = await user.authentication;

      final credential = googleauth.idToken;
      final accesToken = googleauth.accessToken;
      var myToken = credential ?? '';
      prefs.setString('token', myToken);
      prefs.setString('account', 'U');

      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => dashtry()));
    } else {
      print('Something went wrong with token system');
      showErorMessage('Failed to connect with google');
    }
  }

  void initSharedPref() async {
    prefs = await SharedPreferences.getInstance();
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

  String errorTextVal = '';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Scaffold(
      body: Container(
        // color: Colors.black38,
        color: Colors.cyan.shade800,
        child: Container(
            margin: EdgeInsets.only(left: 25, right: 25),
            alignment: Alignment.center,
            child: SingleChildScrollView(
              child: (Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // const SizedBox(
                  //   height: 10,
                  // ),
                  Image.asset(
                    'assets/images/BIBLogo.png',
                    height: 150,
                  ),
                  const Text(
                    'Presents',
                    style: TextStyle(
                        fontStyle: FontStyle.italic,
                        fontSize: 25,
                        fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(
                    height: 10,
                  ),

                  const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'WELNESS',
                        style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w900,
                            color: Color.fromARGB(188, 0, 0, 0)),
                      ),
                      Text(
                        ' WARRIORS',
                        style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w900,
                            color: Color.fromARGB(188, 0, 0, 0)),
                      )
                    ],
                  ),
                  const SizedBox(
                    height: 50,
                  ),

                  Container(
                    height: 55,
                    padding: const EdgeInsets.only(left: 15),
                    decoration: BoxDecoration(
                      border: Border.all(width: 1, color: Colors.black),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: TextField(
                      onChanged: (value) {
                        setState(() {
                          if (value.isEmpty) {
                            errorTextVal = 'Empty';
                          } else {
                            errorTextVal = '';
                          }
                        });
                      },
                      controller: nameController,
                      keyboardType: TextInputType.text,
                      decoration: InputDecoration(
                          border: InputBorder.none,
                          errorStyle: const TextStyle(color: Colors.red),
                          // errorText: _validateName ? "Enter Full Name" : null,
                          hintText:
                              _validateName ? 'Enter valid name' : 'Full Name',
                          hintStyle: _validateName
                              ? const TextStyle(
                                  color: Color.fromARGB(255, 163, 58, 32))
                              : null,
                          errorBorder: const OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.red, width: 2),
                          )),
                    ),
                  ),
                  const SizedBox(
                    height: 19,
                  ),
                  Container(
                    height: 55,
                    padding: const EdgeInsets.only(left: 15),
                    decoration: BoxDecoration(
                      border: Border.all(width: 1, color: Colors.black),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: TextField(
                      controller: emailController,
                      keyboardType: TextInputType.text,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        errorStyle: const TextStyle(color: Colors.white),
                        errorText: _isNotValidate ? "Enter Email ID" : null,
                        hintText: _validateName ? 'Enter valid email' : 'Email',
                        hintStyle: _validateName
                            ? TextStyle(color: Color.fromARGB(255, 163, 58, 32))
                            : null,
                      ),
                    ),
                  ), // Email ID
                  const SizedBox(
                    height: 19,
                  ),
                  Container(
                    height: 55,
                    padding: const EdgeInsets.only(left: 15),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5),
                        border: Border.all(width: 1, color: Colors.black)),
                    child: TextField(
                      obscureText: true,
                      controller: passwordController,
                      keyboardType: TextInputType.text,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        errorStyle: const TextStyle(color: Colors.white),
                        errorText: _isNotValidate ? "Enter Password" : null,
                        hintText:
                            _validateName ? 'Enter valid password' : 'Password',
                        hintStyle: _validateName
                            ? const TextStyle(
                                color: Color.fromARGB(255, 163, 58, 32))
                            : null,
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 19,
                  ),
                  SizedBox(
                    height: 45,
                    width: double.infinity,
                    child: ElevatedButton(
                        onPressed: () async {
                          setState(() {
                            startRagister = true;
                          });
                          FocusScope.of(context).unfocus();
                          if (nameController.value.text.isEmpty) {
                            setState(() {
                              _validateName = true;
                            });
                          } else {
                            setState(() {
                              _validateName = false;
                            });
                          }
                          if (emailController.value.text.isEmpty ||
                              !emailController.value.text.contains('@') ||
                              emailController.value.text.length < 4) {
                            setState(() {
                              _validateEmail = true;
                            });
                          } else {
                            setState(() {
                              _validateEmail = false;
                            });
                          }
                          if (passwordController.value.text.isEmpty) {
                            setState(() {
                              _validatePassword = true;
                            });
                          } else {
                            setState(() {
                              _validatePassword = false;
                            });
                          }

                          if (!(_validateEmail ||
                              _validateName ||
                              _validatePassword)) {
                            await RagisterPsycos();
                          }
                          setState(() {
                            startRagister = false;
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.cyan.shade100,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ),
                        child: startRagister
                            ? const Center(
                                child: CircularProgressIndicator(),
                              )
                            : const Text('Register')),
                  ), // Password
                  const SizedBox(
                    height: 10,
                  ),
                  const Text("Or"),
                  SizedBox(
                      height: 40,
                      width: double.infinity,
                      child: TextButton(
                        onPressed: () {
                          Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: ((context) => PsycoLogin())));
                        },
                        child: Text("Login"),
                      )),
                  // SizedBox(
                  //     height: 40,
                  //     width: double.infinity,
                  //     child: TextButton(
                  //       onPressed: ragisterWithGoogle,
                  //       child: Text("Sign in with Google"),
                  //     )), // Button
                ],
              )),
            )),
      ),
    ));
  }
}
