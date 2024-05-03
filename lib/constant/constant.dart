import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../notificationservice.dart';

NotificationServices notificationService = NotificationServices();

final kAppBarText =
    GoogleFonts.raleway().copyWith(fontWeight: FontWeight.w700, fontSize: 20);
final kh1Text =
    GoogleFonts.lato().copyWith(fontWeight: FontWeight.w700, fontSize: 20);
final kh2Text =
    GoogleFonts.roboto().copyWith(fontWeight: FontWeight.w500, fontSize: 18);
final kh4Text = GoogleFonts.pacifico()
    .copyWith(fontWeight: FontWeight.w500, fontSize: 12, color: Colors.black45);
final knormalText = GoogleFonts.lato().copyWith(fontSize: 16);
final kbuttonText =
    GoogleFonts.roboto().copyWith(fontWeight: FontWeight.w700, fontSize: 18);

Widget backGroundLoadingScreen(String msg) {
  return Center(
      child: SizedBox(
    height: 300,
    width: 280,
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Image.asset(
          'assets/images/allPageBack.png',
          width: 180,
        ),
        Text(
          msg,
          textAlign: TextAlign.center,
          style: const TextStyle(
              color: Color.fromARGB(255, 29, 182, 164),
              fontSize: 18,
              fontWeight: FontWeight.bold),
        )
      ],
    ),
  ));
}




