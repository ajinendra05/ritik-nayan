import 'package:flutter/material.dart';
import './OrderHistory.dart';
import './config.dart';
import './dashtry.dart';
import './loginscreen.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:shared_preferences/shared_preferences.dart';
import './googleSignInapi.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'Modal/userAccount.dart';
import 'user_prifile_page.dart';

class NavBar extends StatefulWidget {
  @override
  State<NavBar> createState() => _NavBarState();
}

class _NavBarState extends State<NavBar> {
  late SharedPreferences prefs;

  // bool load = true;
  @override
  void initState() {
    super.initState();
    initSharedPref();
  }

  void initSharedPref() async {
    prefs = await SharedPreferences.getInstance();
    var myToken = prefs.getString('token') ?? "";
    Map<String, dynamic> jwtDecoderToken = JwtDecoder.decode(myToken);
  }
  // Future<void> LogOut() async {
  //   final url = logout;
  //   final uri = Uri.parse(url);
  // }

  _launchURLBrowser(String link) async {
    try {
      // var url = Uri.parse("https://meet.google.com/ipb-fpmx-zps");

      // var url =
      //     link.contains("https") ? Uri.parse(link) : Uri.parse("https://$link");
      var url = Uri.parse(link);
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
            accountName: Text(userData.name),
            accountEmail: Text(userData.email),
            currentAccountPicture: CircleAvatar(
              child: ClipOval(
                  child: userData.imgPath == ""
                      ? null
                      : Image.network(
                          userData.imgPath,
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
          ListTile(
            leading: const Icon(Icons.cabin),
            title: const Text('Home'),
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const dashtry(),
                  ));
            },
          ),
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('Profile'),
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => User_ProfilePage(),
                  ));
            },
          ),

          // ListTile(
          //   leading: Icon(Icons.favorite),
          //   title: Text('Favorites'),
          //   onTap: () => null,
          // ),
          ListTile(
            leading: const Icon(Icons.history),
            title: const Text('My Bookings'),
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const Orderhistory(),
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
            onTap: () async {
              userData.imgPath = '';
              userData.name = '';
              userData.email = '';
              userData.walletbalance = -1;
              prefs.setString('token', '');
              prefs.setString('account', '');
              // LogOut();
              if (GoogleSignIn().currentUser != null) {
                await GoogleSignIn().signOut();
                try {
                  await googleSignInApi.logout();
                } catch (e) {
                  print('failed to disconnect on signout');
                }
              }
              Navigator.popUntil(
                  context, (Route<dynamic> route) => route.isFirst);
              Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (context) => loginScreen()));
            },
          ),
          SizedBox(
            height: hgt * 0.16,
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
                      // launchUrl(whatsappUrl);
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
