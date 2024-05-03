import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

class counter extends ChangeNotifier {
  int timeRemaning = 600000;
  int timeCount = 600;
  int day = 0;
  int hour = 0;
  int minute = 0;
  int sec = 0;

  int get days => day;
  int get hours => hour;
  int get minutes => minute;
  void timer(bookingTime) {
    Duration timeDif = bookingTime.difference(DateTime.now());
    day = timeDif.inDays;
    hour = timeDif.inHours;
    hour -= day * 24;
    minute = timeDif.inMinutes;
    minute -= day * 24 * 60;
    minute -= hour * 60;
    sec = timeDif.inSeconds;
    sec -= day * 24 * 60 * 60;
    sec -= hour * 60 * 60;
    sec -= minute * 60;
    sec = max(sec, 0);
    day = max(day, 0);
    hour = max(hour, 0);
    minute = max(minute, 0);

    Timer timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (timeRemaning > 1) {
        Duration timeDif = bookingTime.difference(DateTime.now());
        timeRemaning = timeDif.inMinutes;
        day = timeDif.inDays;
        hour = timeDif.inHours;
        hour -= day * 24;
        minute = timeDif.inMinutes;
        minute -= day * 24 * 60;
        minute -= hour * 60;
        day = max(day, 0);
        hour = max(hour, 0);
        minute = max(minute, 0);

        notifyListeners();
      } else {
        timeCount = 0;
        timer.cancel();
        notifyListeners();
      }
    });
  }
}
