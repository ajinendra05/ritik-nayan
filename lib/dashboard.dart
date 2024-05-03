//import 'dart:html';

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:wellnesswarriors/config.dart';
import 'package:wellnesswarriors/navbar.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class dashBoard extends StatefulWidget {
  //final token;
  const dashBoard({Key? key}) : super(key: key);

  @override
  State<dashBoard> createState() => _dashBoardState();
}



class _dashBoardState extends State<dashBoard> {
  late String email;
  late SharedPreferences prefs;
  List abcd = [];

  //List items =[];
  //List<PostModal> postList =[];

  Future<void> fetchPsychologist() async {
    final url = psychologist;
    final uri = Uri.parse(url);
    final response = await http.post(uri);





    
    print(response.statusCode);
    //print(response.body);

    if(response.statusCode == 200) {



      return jsonDecode(response.body);
      //var result = json[""] as List;

      //print(result);

      // setState(() {

      //   abcd = result;

      //   print('PRINT Length');
      //   print(abcd.length);
      //   print(result[0]);



      // });

    }else{
      //show error
      print('executing else error part');
    }




  }


  @override
  void initState() {
    super.initState();
    initSharedPref();
    fetchPsychologist();
  }

  void initSharedPref() async {
    prefs = await SharedPreferences.getInstance();
    var myToken = prefs.getString('token') ?? "";

    Map<String, dynamic> jwtDecoderToken = JwtDecoder.decode(myToken);
    email = jwtDecoderToken['email'];
    print(email);
    print('email belongs to shared pref - dashboard');

  }

  List names = [
    'Kratika ',
    'Rohit Ahirwar',
    'Gulshan Patel',
    'Ashok Kumar'
  ];
  List designations = [
    'Family Physician',
    'Entrepreneur',
    'Director',
    'General Manager'
  ];
  List charges = ['10/min', '12/min', '7/min', '8/min'];
  List ppic = [
    'https://png.pngitem.com/pimgs/s/128-1284293_marina-circle-girl-picture-in-circle-png-transparent.png',
    'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSqps7s9zYLNam3VPD8qpSLIXCojQqgx_7H2g&usqp=CAU',
    'https://images.squarespace-cdn.com/content/v1/58e167a8414fb5c0b2b8c13e/1503561540900-K0FXVM3QNP4843AJGQCD/Circle+Profile.jpg',
    'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRQVlQ_ho1JIyjjRePM3nMpzpK4uYnof4ZSaQ&usqp=CAU'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: NavBar(),
      appBar: AppBar(
        backgroundColor: Colors.greenAccent,
        title: Text('Talk to Therapist'),
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.notifications))
        ],

      ),
      body: ListView.builder(
        //itemCount: abcd.length,
        itemCount: 4,
        shrinkWrap: true,
        itemBuilder: (BuildContext context, int index) => Container(
          width: MediaQuery.of(context).size.width,
          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          child: Card(
            elevation: 5,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(0),
            ),
            child: Container(
              color: Colors.pink,
              width: MediaQuery.of(context).size.width,
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: 65,
                        width: 65,
                        //color: Colors.greenAccent,
                        child: CircleAvatar(
                          backgroundColor: Colors.green,
                          //backgroundImage: NetworkImage(ppic[index]),
                          backgroundImage: NetworkImage(
                              'https://png.pngitem.com/pimgs/s/128-1284293_marina-circle-girl-picture-in-circle-png-transparent.png'),
                        ),
                      ),
                      SizedBox(
                        width: 15,
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            names[index],
                            //abcd[0],
                            style: TextStyle(
                                fontSize: 19, fontWeight: FontWeight.bold),
                          ),
                          Text(designations[index]),
                          Text(charges[index])
                        ],
                      )
                    ],
                  ),
                  Container(
                    alignment: Alignment.center,
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                    child: ElevatedButton(
                      onPressed: () {},
                      child: Text('Call'),
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
