import 'package:flutter/material.dart';

Widget Button(double hgt, double wgt, String text, IconData icon) {
  return Container(
    height: hgt,
    width: wgt,
    child: Card(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Icon(
            icon,
            color: const Color.fromARGB(255, 11, 102, 14),
          ),
          Text(
            text,
            style: const TextStyle(
                color: Color.fromARGB(255, 11, 102, 14),
                fontSize: 15,
                fontWeight: FontWeight.w900),
          ),
        ],
      ),
    ),
  );
}
