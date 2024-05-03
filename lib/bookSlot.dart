

import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:wellnesswarriors/config.dart';
import 'package:jiffy/jiffy.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:fluttertoast/fluttertoast.dart';

class BookSlot extends StatefulWidget {
  BuildContext context;
  String id;
  BookSlot({super.key, required this.id, required this.context});

  @override
  State<BookSlot> createState() => _BookSlotState();
}

class _BookSlotState extends State<BookSlot> {
  int selected = -1;

  DateTime choosedDate = DateTime.now();
  List shedule = [];
  bool load = true;

  @override
  void initState() {
    super.initState();

    getShedule(choosedDate);
  }

  _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: choosedDate, // Refer step 1
      firstDate: DateTime(2000),
      lastDate: DateTime(2025),
    );
    if (picked != null && picked != choosedDate)
      setState(() {
        choosedDate = picked;
        // getShedule(id, choosedDate);
      });
  }

  Future<void> getShedule(DateTime date) async {
    final url =
        "${getPyscoShedule}?psychologistId=${widget.id}&date=${choosedDate.year}-${choosedDate.month}-${choosedDate.day}";
    final uri = Uri.parse(url);
// ?psychologistId=6598997ad730939f3d5095b8&date=2024-01-03
    try {
      final response = await http.get(
        uri,
      );
      if (response.statusCode == 200) {
        var json = jsonDecode(response.body);
        setState(() {
          shedule = json["slots"];
          print(shedule);
          load = false;
        });
      } else {
        debugPrint('Network Error');
        Fluttertoast.showToast(msg: "Network Error!2");
      }
    } catch (e) {
      print(e);
      Fluttertoast.showToast(msg: "Network Error!");
    }
  }

  Widget gridview() {
    return Container(
        margin: EdgeInsets.fromLTRB(10, 5, 10, 0),
        child: GridView.count(
          crossAxisCount: 4,
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          childAspectRatio: 2.5,
          children: List.generate(
            shedule.length,
            (index) {
              return shedule[index]["available"]
                  ? SizedBox(
                      height: 10,
                      width: 10,
                      child: InkWell(
                        onTap: () {
                          setState(() {
                            selected = index;
                          });
                          bool flag = shedule[index]['available'];
                        },
                        splashColor: Colors.amber,
                        child: Container(
                          // margin: EdgeInsets.all(10),

                          decoration: BoxDecoration(
                            color: selected == index ? Colors.amber : null,
                            borderRadius: BorderRadius.all(Radius.circular(5)),
                            border: Border.all(color: Colors.black, width: 0.7),
                          ),
                          child: Center(
                            child: Text(
                              '${shedule[index]['time']}',
                              style: const TextStyle(
                                color: Colors.black,
                                fontSize: 10,
                              ),
                            ),
                          ),
                        ),
                      ),
                    )
                  : Container();
            },
          ),
        ));
  }

  @override
  Widget build(BuildContext context) {
    var date = Jiffy.parse(
            "${choosedDate.year}/${choosedDate.month}/${choosedDate.day}")
        .yMMMMd;
    var day = DateFormat('EEEE').format(choosedDate);
    return Container(
      child: Column(children: [
        // const Text(
        //   "Choose Date",
        //   style: TextStyle(
        //       fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black54),
        // ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            IconButton(
                onPressed: () {}, icon: const Icon(Icons.arrow_circle_left)),
            GestureDetector(
              onTap: () {
                _selectDate(context);
              },
              child: Container(
                width: MediaQuery.of(widget.context).size.width * 0.6,
                height: 60,
                decoration: BoxDecoration(
                    border: Border.all(
                        color: const Color.fromARGB(165, 0, 0, 0), width: 0.6),
                    borderRadius: BorderRadius.circular(8)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      date,
                      style: const TextStyle(
                          fontWeight: FontWeight.w600, color: Colors.black87),
                    ),
                    Text(
                      day,
                      style: const TextStyle(
                          fontWeight: FontWeight.w400,
                          color: Color.fromARGB(251, 70, 70, 70),
                          fontSize: 11),
                    )
                  ],
                ),
              ),
            ),
            IconButton(
                onPressed: () {}, icon: const Icon(Icons.arrow_circle_right))
          ],
        ),
        const SizedBox(
          height: 10,
        ),
        Container(
          child: Column(
            children: [
              // const Text(
              //   "Morning",
              //   style: TextStyle(
              //       fontSize: 16,
              //       fontWeight: FontWeight.w500,
              //       color: Colors.black54),
              // ),
              const Divider(),
              load
                  ? Center(
                      child: CircularProgressIndicator(),
                    )
                  : SizedBox(
                      height: MediaQuery.of(widget.context).size.height * 0.35,
                      width: double.infinity,
                      child: gridview(),
                    ),
              const SizedBox(
                height: 5,
              ),
            ],
          ),
        ),
        
      ]),
    );
  }
}
