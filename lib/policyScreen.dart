import 'dart:convert';

import 'package:flutter/material.dart';

class Orderhistory extends StatefulWidget {
  const Orderhistory({super.key});

  @override
  State<Orderhistory> createState() => _OrderhistoryState();
}

DateTime d = DateTime.now();

class _OrderhistoryState extends State<Orderhistory> {
  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    return DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Order History'),
            backgroundColor: Colors.orange,
          ),
        ));
  }
}
