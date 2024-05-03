import 'dart:convert';
import 'package:flutter/material.dart';
import './config.dart';
import './constant/constant.dart';
import './forgotPasswordPsyco.dart';
import './googleSignInapi.dart';
import './loginscreen.dart';
import './pysco_dashbord.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'Modal/psycoAccount.dart';
import 'psycoRegister.dart';

class PsycoLogin extends StatefulWidget {
  @override
  State<PsycoLogin> createState() => _PsycoState();
}

class _PsycoState extends State<PsycoLogin> {
  bool load = false;
  TextEditingController countrycode = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  late SharedPreferences prefs;
  bool _validatePassword = false;
  bool _validateEmail = true;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    initSharedPref();
  }

  void initSharedPref() async {
    prefs = await SharedPreferences.getInstance();
  }

  Future psychologistSignIn() async {
    await googleSignInApi.logout();
    final user = await googleSignInApi.login();
    print(user?.email);
    if (user != null) {
      final googleauth = await user.authentication;

      final credential = googleauth.idToken;
      final accesToken = googleauth.accessToken;
      var myToken = credential ?? '';
      prefs.setString('token', myToken);
      prefs.setString('account', 'P');
      psycoData.loadUser();
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => PscDashBord()));
    } else {
      print('Something went wrong with token system');
      showErorMessage('Failed to connect with google');
    }
  }

  Future signInPyscowithGoogle() async {
    print("google sign in");
    if (GoogleSignIn().currentUser != null) {
      await GoogleSignIn().signOut();
    }

    try {
      await googleSignInApi.logout();
    } catch (e) {
      print('failed to disconnect on signout');
    }

    final user = await googleSignInApi.login();
    print(user?.email);
    if (user != null) {
      print(user.displayName);
      final googleauth = await user.authentication;
      final regBody = {
        "username": user.displayName,
        "email": user.email,
        "photoUrl": user.photoUrl
      };
      final uri = Uri.parse(googleLoginP);
      setState(() {
        load = true;
      });
      final response = await http.post(
        uri,
        body: regBody,
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
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
        prefs.setString('account', 'P');
        // prefs.setString('id', id);
        // print(id);
        psycoData.loadUser();
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => PscDashBord()));
      } else {
        print('Something went wrong with token system');
        showErorMessage("Network Error!");
      }
    } else {
      print('Something went wrong with token system');
      showErorMessage('Failed ');
    }
    setState(() {
      load = false;
    });
  }

  Future<void> loginuser() async {
    setState(() {
      load = true;
    });
    final email = emailController.text;
    final password = passwordController.text;

    final regBody = {"email": email, "password": password};

    print('Above DB Response Code');

    try {
      var response = await http.post(
        Uri.parse(psycoLogin),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(regBody),
      );

      print('Above jsonResponseCode' + response.body);

      if (response.statusCode == 200) {
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
        prefs.setString('account', 'P');
        // prefs.setString('id', id);
        // print(id);
        psycoData.loadUser().then((value) {
          notificationService.getDeviceToken();
        });
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => PscDashBord()));
      } else {
        print('Something went wrong with token system');
        showErorMessage(jsonDecode(response.body)["msg"]);
      }
    } catch (e) {
      print('Something went wrong with token system');
      showErorMessage('Failed! network error');
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
    return Scaffold(
        body: Container(
      color: Colors.cyan.shade800,
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
              const Text('Professional Psychologist Login'),
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
              SizedBox(
                  height: 40,
                  width: double.infinity,
                  child: TextButton(
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: ((context) =>
                                  ForgetPasswordScreenPsyco())));
                    },
                    child: const Text(
                      "Forgot Password ?",
                      style: TextStyle(),
                    ),
                  )),
              // SizedBox(
              //     height: 40,
              //     width: double.infinity,
              //     child: TextButton(
              //       onPressed: signInPyscowithGoogle,
              //       child: const Text("Sign in with Google"),
              //     )),
              // SizedBox(
              //     height: 40,
              //     width: double.infinity,
              //     child: TextButton(
              //       onPressed: signInPyscowithGoogle,
              //       child: Text("psychologist Login"),
              //     )),
              // SizedBox(
              //   height: 20,
              // ),
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
                              builder: ((context) => RagisterPsyco())));
                    },
                    child: const Text(
                      "Don't have psychologist account? Register",
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
                                builder: ((context) => loginScreen())));
                      },
                      child: const Text(
                        "User Login",
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
