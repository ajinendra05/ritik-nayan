import 'dart:convert';
import 'package:flutter/material.dart';
import './Modal/userAccount.dart';
import './config.dart';
import './constant/constant.dart';
import './dashtry.dart';
import './forget_password_user.dart';
import './googleSignInapi.dart';
import './registeruser.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'psycoLogin.dart';

class loginScreen extends StatefulWidget {
  @override
  State<loginScreen> createState() => _loginScreenState();
}

class _loginScreenState extends State<loginScreen> {
  TextEditingController countrycode = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  bool _validatePassword = false;
  bool _validateEmail = true;
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

  Future signInwithGoogle() async {
    if (GoogleSignIn().currentUser != null) {
      await GoogleSignIn().signOut();
    }
    try {
      await googleSignInApi.logout();
    } catch (e) {
      print('failed to disconnect on signout');
    }
    final user = await googleSignInApi.login();
    if (user != null) {
      final googleauth = await user.authentication;
      final regBody = {
        "username": user.displayName,
        "email": user.email,
        "photoUrl": user.photoUrl
      };
      setState(() {
        load = true;
      });
      final uri = Uri.parse(googleLogin);
      final response = await http.post(
        uri,
        body: jsonEncode(regBody),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200 || response.statusCode == 202) {
        var jsonResponse = jsonDecode(response.body);
        String rawCookie = response.headers['set-cookie']!;
        int index = rawCookie.indexOf(';');
        String refreshToken =
            (index == -1) ? rawCookie : rawCookie.substring(0, index);
        int idx = refreshToken.indexOf("=");
        print("token : " + refreshToken.substring(idx + 1).trim());

        final myToken = refreshToken.substring(idx + 1).trim();
        // final id = jsonResponse['_id'];
        prefs.setString('token', myToken);
        prefs.setString('account', 'U');
        // prefs.setString('id', id);
        // print(id);
        userData.loadUser();
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => dashtry()));
      } else {
        print('Something went wrong with token system' +
            response.statusCode.toString() +
            response.body.toString());
        showErorMessage('Something went wrong! ');
      }
    } else {
      print('Something went wrong with token system');
      showErorMessage('Something went wrong! ');
    }
    setState(() {
      load = false;
    });
  }

  Future<void> loginuser() async {
    debugPrint("enter in login");
    setState(() {
      load = true;
    });
    try {
      final email = emailController.text;
      final password = passwordController.text;

      final regBody = {"email": email, "password": password};

      var response = await http.post(
        Uri.parse(login),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(regBody),
      );

      if (response.statusCode == 200) {
        var jsonResponse = jsonDecode(response.body);
        String rawCookie = response.headers['set-cookie']!;
        int index = rawCookie.indexOf(';');
        String refreshToken =
            (index == -1) ? rawCookie : rawCookie.substring(0, index);
        int idx = refreshToken.indexOf("=");
        final myToken = refreshToken.substring(idx + 1).trim();
        // final id = jsonResponse['_id'];
        prefs.setString('token', myToken);
        prefs.setString('account', 'U');
        userData.loadUser().then((value) {
          notificationService.getDeviceToken();
        });
        // prefs.setString('id', id);
        // print(id);
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => dashtry()));
      } else {
        debugPrint(
            'Something went wrong with token system${response.statusCode}${response.body}');
        showErorMessage(jsonDecode(response.body)["msg"]);
      }
    } catch (e) {
      debugPrint('Network Error fetchPsyclo $e');
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
    return Scaffold(
        body: Container(
      color: Color.fromARGB(255, 255, 115, 0),
      child: Container(
        margin: const EdgeInsets.only(left: 25, right: 25),
        alignment: Alignment.center,
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/images/BIBLogo.png',
                width: 150,
              ),
              const Text(
                'WELLNESS WARRIORS',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              const Text('Talk to Professional Psychologist'),
              const SizedBox(
                height: 10,
              ),
              Container(
                height: 55,
                padding: const EdgeInsets.only(left: 15),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    border: Border.all(
                      width: 1,
                      color: Colors.black,
                    )),
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
              Container(
                height: 55,
                padding: const EdgeInsets.only(left: 15),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    border: Border.all(width: 1, color: Colors.black)),
                child: TextField(
                  obscureText: true,
                  controller: passwordController,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    hintText: 'Password',
                  ),
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              SizedBox(
                height: 45,
                width: double.infinity,
                child: ElevatedButton(
                    onPressed: () async {
                      FocusScope.of(context).unfocus();

                      if (emailController.value.text.isEmpty ||
                          !emailController.value.text.contains('@') ||
                          emailController.value.text.length < 4) {
                        setState(() {
                          emailController.clear();
                          _validateEmail = true;
                        });
                        showErorMessage("Enter valid email");
                        return;
                      } else {
                        setState(() {
                          _validateEmail = false;
                        });
                      }
                      if (passwordController.value.text.isEmpty) {
                        setState(() {
                          _validatePassword = true;
                          passwordController.clear();
                        });
                        showErorMessage("Enter valid password");
                        return;
                      } else {
                        setState(() {
                          _validatePassword = false;
                        });
                      }

                      if (!(_validateEmail || _validatePassword)) {
                        await loginuser();
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
                        : const Text('Login')),
              ),
              const SizedBox(
                height: 10,
              ),
              const Text("Or"),
              // SizedBox(
              //     height: 40,
              //     width: double.infinity,
              //     child: TextButton(
              //       onPressed: signInwithGoogle,
              //       child: const Text("Sign in with Google"),
              //     )),
              SizedBox(
                  height: 40,
                  width: double.infinity,
                  child: TextButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: ((context) => ForgetPasswordScreen())));
                    },
                    child: const Text("Forgot Password ?"),
                  )),
              const SizedBox(
                height: 20,
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
                              builder: ((context) => const registeruser())));
                    },
                    child: const Text(
                      "Don't have user account? Register",
                      style: TextStyle(color: Colors.white),
                    ),
                  )),
              Align(
                child: SizedBox(
                    height: 40,
                    width: double.infinity,
                    child: TextButton(
                      onPressed: () {
                        Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: ((context) => PsycoLogin())));
                      },
                      child: const Text(
                        "Psychologist Login",
                        style: TextStyle(color: Colors.white),
                      ),
                    )),
              ),
            ],
          ),
        ),
      ),
    ));
  }
}
