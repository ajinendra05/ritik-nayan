import 'package:flutter/material.dart';
import './config.dart';
import './loginscreen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:http/http.dart' as http;
import 'package:fluttertoast/fluttertoast.dart';
import 'package:url_launcher/url_launcher.dart';

import 'Modal/psycoAccount.dart';
import 'profile_page.dart';
import 'psycoOrderHistory.dart';

class PsycoNavBar extends StatefulWidget {
  @override
  State<PsycoNavBar> createState() => _PsycoNavBarState();
}

class _PsycoNavBarState extends State<PsycoNavBar> {
  late SharedPreferences prefs;
  late String email = "";
  String? id;
  // bool load = true;
  @override
  void initState() {
    super.initState();
    initSharedPref();
  }

  void initSharedPref() async {
    prefs = await SharedPreferences.getInstance();
    var myToken = prefs.getString('token') ?? "";
    // var id = prefs.getString('id') ?? "";
    Map<String, dynamic> jwtDecoderToken = JwtDecoder.decode(myToken);
    // email = jwtDecoderToken['email'];
    var id2 = jwtDecoderToken['userId'];
    id = id2;
    // loadUser();
  }

  // Future<void> loadUser() async {
  //   final url = '${userProfile}?userId=${id}';
  //   final uri = Uri.parse(url);
  //   try {
  //     final response = await http.get(uri);

  //     if (response.statusCode == 200) {
  //       var json = jsonDecode(response.body);

  //       setState(() {
  //         userData = json;
  //         load = false;
  //       });
  //     } else {
  //       //show error
  //       print(response.statusCode);
  //       print('executing else error part');
  //       debugPrint('Network Error');
  //       Fluttertoast.showToast(msg: "Network Error!");
  //     }
  //   } catch (e) {
  //     Fluttertoast.showToast(msg: "Network Error!" + e.toString());
  //   }
  // }

  Future<void> LogOut() async {
    final url = logout;
    final uri = Uri.parse(url);
  }

  _launchURLBrowser(String link) async {
    try {
      // var url = Uri.parse("https://meet.google.com/ipb-fpmx-zps");

      var url =
          link.contains("https") ? Uri.parse(link) : Uri.parse("https://$link");
      await launchUrl(url);
    } catch (e) {
      Fluttertoast.showToast(msg: 'Something went wrong');
    }
  }

  @override
  Widget build(BuildContext context) {
    final wth = MediaQuery.of(context).size.width;
    final hgt = MediaQuery.of(context).size.height;
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          // load
          //     ? Center(
          //         child: CircularProgressIndicator(),
          //       )
          //     :
          UserAccountsDrawerHeader(
            accountName: Text(psycoData.name),
            accountEmail: Text(psycoData.email),
            currentAccountPicture: CircleAvatar(
              child: ClipOval(
                  child: psycoData.imgPath == ""
                      ? null
                      : Image.network(
                          psycoData.imgPath,
                          width: 90,
                          height: 90,
                          fit: BoxFit.cover,
                        )),
            ),
            decoration: const BoxDecoration(
              color: Colors.cyan,
              image: DecorationImage(
                image: NetworkImage(
                    'https://thumbs.dreamstime.com/b/doctor-medical-background-24834402.jpg?w=1600'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          // ListTile(
          //   leading: Icon(Icons.favorite),
          //   title: Text('Favorites'),
          //   onTap: () => null,
          // ),
          ListTile(
            leading: const Icon(Icons.cabin),
            title: const Text('Profile'),
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProfilePage(),
                  )).then((value) {
                setState(() {});
              });
            },
          ),
          ListTile(
            leading: const Icon(Icons.history),
            title: const Text('Order History'),
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const PsycoOrderHistory(),
                  ));
            },
          ),
          ListTile(
            leading: const Icon(Icons.share),
            title: const Text('Share'),
            onTap: () {
              _launchURLBrowser(playstoreshare);
            },
          ),
          // ListTile(
          //   leading: Icon(Icons.settings),
          //   title: Text('Setting'),
          //   onTap: () => null,
          // ),
          ListTile(
            leading: const Icon(Icons.policy),
            title: const Text('Policies'),
            onTap: () {
              _launchURLBrowser("https://www.wellnesswarriors.co.in/policy");
            },
          ),

          ListTile(
            leading: const Icon(Icons.exit_to_app),
            title: const Text('LogOut'),
            onTap: () {
              psycoData.about = '';
              psycoData.qualification = '';
              psycoData.id = '';
              psycoData.imgPath = '';
              psycoData.name = '';
              psycoData.email = '';
              psycoData.walletbalance = -1;
              prefs.setString('token', '');
              prefs.setString('account', '');
              LogOut();
              Navigator.popUntil(
                  context, (Route<dynamic> route) => route.isFirst);
              Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (context) => loginScreen()));
            },
          ),
          SizedBox(
            height: hgt * 0.22,
          ),
          Container(
            height: MediaQuery.of(context).size.height * 0.12,
            alignment: Alignment.bottomCenter,
            child: Column(children: [
              Text("AVAILABLE ON"),
              Divider(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  GestureDetector(
                    onTap: () {
                      _launchURLBrowser(
                          "https://www.instagram.com/wellnesswarriors97/");
                    },
                    child: SizedBox(
                      height: MediaQuery.of(context).size.width * 0.08,
                      width: MediaQuery.of(context).size.width * 0.08,
                      child: Image.asset('assets/images/insta.png',
                          fit: BoxFit.fill),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      _launchURLBrowser(
                          "http://linkedin.com/showcase/wellnesswarriors");
                    },
                    child: SizedBox(
                      height: MediaQuery.of(context).size.width * 0.08,
                      width: MediaQuery.of(context).size.width * 0.08,
                      child: Image.asset('assets/images/linkedin.png',
                          fit: BoxFit.fill),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      _launchURLBrowser(
                          "https://www.facebook.com/profile.php?id=61556911073483");
                    },
                    child: SizedBox(
                      height: MediaQuery.of(context).size.width * 0.08,
                      width: MediaQuery.of(context).size.width * 0.08,
                      child: Image.asset('assets/images/facebook.png',
                          fit: BoxFit.fill),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      _launchURLBrowser(whatsappUrl);
                    },
                    child: SizedBox(
                      height: MediaQuery.of(context).size.width * 0.08,
                      width: MediaQuery.of(context).size.width * 0.08,
                      child: Image.asset('assets/images/whatsapp2.png',
                          fit: BoxFit.fill),
                    ),
                  )
                ],
              )
            ]),
          )
        ],
      ),
    );
  }
}
