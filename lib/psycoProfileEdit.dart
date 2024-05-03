import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import './Modal/psycoAccount.dart';
import './Modal/userAccount.dart';
import './config.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:fluttertoast/fluttertoast.dart';
import 'dart:io';

class PsycoProfileEditPage extends StatefulWidget {
  const PsycoProfileEditPage({super.key});

  @override
  State<PsycoProfileEditPage> createState() => _PsycoProfileEditPageState();
}

class _PsycoProfileEditPageState extends State<PsycoProfileEditPage> {
  final _formKey = GlobalKey<FormState>();
  bool updatestart = false;
  final TextEditingController _nameController =
      TextEditingController(text: psycoData.name);
  final TextEditingController qualificationController =
      TextEditingController(text: psycoData.qualification);
  final TextEditingController aboutController =
      TextEditingController(text: psycoData.about);
  final TextEditingController chargesomeController =
      TextEditingController(text: psycoData.chargespm.toString());
  final TextEditingController disorderController = TextEditingController();
  Map<String, bool> allDisorders = {
    "Anxiety": false,
    "Bi-polar": false,
    "Depression": false,
    "Relationship issues": false,
    "Stress": false,
    "Other": false,
  };
  final List<String> disorderList = [
    "Anxiety",
    "Bi-polar",
    "Depression",
    "Relationship issues",
    "Stress",
    "Other",
  ];
  @override
  void initState() {
    super.initState();
    psycoData.disorders.forEach((element) {
      setState(() {
        allDisorders[element["disorder_name"].toString()] = true;
      });
    });
    // initSharedPref();
  }

  Future<void> UpdateData() async {
    setState(() {
      updatestart = true;
    });
    var prefs = await SharedPreferences.getInstance();
    var myToken = prefs.getString('token') ?? "";
    print(myToken);
    var cookies = [
      'token=${myToken}',
    ];

    var headers = {
      'Cookie': cookies.join('; '),
      'Content-Type': 'application/json'
    };
    var url = '$updatePsycoProfile${psycoData.id}';
    final uri = Uri.parse(url);
    try {
      List<dynamic> tempList = [];
      allDisorders.forEach((key, value) {
        if (value) {
          tempList.add({"disorder_name": key});
        }
      });
      final regBody = {
        "username": _nameController.value.text.trim(),
        "about": aboutController.value.text.trim(),
        "qualification": qualificationController.value.text.trim(),
        "chargespm": chargesomeController.value.text.trim(),
        "disorders": tempList
      };
      final response =
          await http.post(uri, headers: headers, body: jsonEncode(regBody));
      if (response.statusCode == 200 || response.statusCode == 202) {
        var json = jsonDecode(response.body);

        await psycoData.loadUser();
        print("userloaded");
        Fluttertoast.showToast(msg: "Updated");
      } else {
        debugPrint('Network Error ${response.body}');
        Fluttertoast.showToast(msg: "Network Error!");
      }
    } catch (e) {
      print(e);
      Fluttertoast.showToast(msg: "Network Error!");
    }
    Navigator.pop(context);
    setState(() {
      updatestart = false;
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    aboutController.dispose();
    qualificationController.dispose();
    chargesomeController.dispose();
    disorderController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor:const Color.fromARGB(255, 159, 194, 225).withOpacity(0.4),
          title: const Text('Edit Profile'),
        ),
        body: SingleChildScrollView(
          padding:const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
             const   SizedBox(
                  height: 20,
                ),
                TextFormField(
                  controller: _nameController,
                  keyboardType: TextInputType.name,
                  decoration: inputDecoration(
                      prefixIcon:const Icon(Icons.account_box_outlined),
                      hintText: 'John Doe',
                      labelText: 'Name'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please fill this field';
                    }
                    return null;
                  },
                ),
             const   SizedBox(
                  height: 20,
                ),
                TextFormField(
                  controller: aboutController,
                  // keyboardType: TextInputType.emailAddress,
                  decoration: inputDecoration(
                      prefixIcon:const Icon(Icons.menu),
                      hintText: 'write about yourself',
                      labelText: 'About Yourself'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please fill this field';
                    }
                    return null;
                  },
                ),
            const    SizedBox(
                  height: 20,
                ),
                TextFormField(
                  controller: qualificationController,
                  // inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  // keyboardType: TextInputType.number,
                  decoration: inputDecoration(
                      prefixIcon: const Icon(
                          IconData(0xe559, fontFamily: 'MaterialIcons')),
                      hintText: 'Btech',
                      labelText: 'Qualifications'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please fill this field';
                    }
                    return null;
                  },
                ),
             const   SizedBox(
                  height: 20,
                ),
                // TextFormField(
                //   controller: chargesomeController,
                //   keyboardType: TextInputType.number,
                //   decoration: inputDecoration(
                //       prefixIcon: Icon(Icons.wallet),
                //       hintText: '123 ',
                //       labelText: 'Charge (RS. / pm)'),
                //   validator: (value) {
                //     if (value == null || value.isEmpty) {
                //       return 'Please fill this field';
                //     }
                //     return null;
                //   },
                // ),
            const    SizedBox(
                  height: 20,
                ),
                // TextFormField(
                //   controller: disorderController,
                //   keyboardType: TextInputType.text,
                //   decoration: inputDecoration(
                //       prefixIcon: Icon(Icons.person_3),
                //       hintText: 'London',
                //       labelText: 'Disorders'),
                // ),
            const    SizedBox(
                  height: 10,
                ),
                Container(
                  padding:const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                      border: Border.all(
                          color:const Color.fromARGB(255, 67, 127, 167), width: 2)),
                  child: SingleChildScrollView(
                    child: SizedBox(
                      height: 150,
                      child: GridView.count(
                          crossAxisCount: 2,
                          // mainAxisSpacing: 10,
                          crossAxisSpacing: 50,
                          childAspectRatio: 2.5,
                          children: List.generate(disorderList.length, (index) {
                            return checkBoxItem(disorderList[index]);
                          })),
                    ),
                  ),
                ),
              const  SizedBox(
                  height: 50,
                ),
                SizedBox(
                  width: 250,
                  child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor:const Color.fromARGB(255, 67, 127, 167)
                              .withOpacity(0.7),
                          foregroundColor: Colors.white,
                          minimumSize: Size.fromHeight(50)),
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          showDialog(
                            context: context,
                            builder: (context) =>const Center(
                                child: SizedBox(
                                    height: 50,
                                    width: 50,
                                    child: CircularProgressIndicator())),
                          );
                          await UpdateData();
                          print("userloaded3");
                          Navigator.pop(context);
                          print("userloaded4");
                          // ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          //     content: Text(
                          //         'Hello ${_nameController.text}\nYour details have been submitted and an email sent to ${aboutController.text}.')));
                        } else {
                          // The form has some validation errors.
                          // Do Something...
                        }
                      },
                      child:const Text(
                        'Submit',
                        style: TextStyle(
                            fontSize: 17, fontWeight: FontWeight.w800),
                      )),
                )
              ],
            ),
          ),
        ));
  }

  Widget checkBoxItem(String disorder) {
    return CheckboxListTile(
      activeColor: Colors.green,
      checkColor: Colors.white,
      contentPadding: EdgeInsets.fromLTRB(0, 5, 0, 0),
      title: Text(disorder),
      value: allDisorders[disorder],
      onChanged: (bool? value) {
        if (value != null) {
          setState(() {
            allDisorders[disorder] = value;
          });
        }
      },
    );
  }

  InputDecoration inputDecoration({
    InputBorder? enabledBorder,
    InputBorder? border,
    Color? fillColor,
    bool? filled,
    Widget? prefixIcon,
    String? hintText,
    String? labelText,
  }) =>
      InputDecoration(
          enabledBorder: enabledBorder ??
              const OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.blueGrey, width: 2.0)),
          border: border ?? OutlineInputBorder(borderSide: BorderSide()),
          fillColor: fillColor ?? Colors.white,
          filled: filled ?? true,
          prefixIcon: prefixIcon,
          hintText: hintText,
          labelText: labelText);
}
/*

  final ImagePicker _pickImage = ImagePicker();
  bool uploded = false;
  bool loadUserDate = true;
  bool editName = false;
  bool editQualification = false;
  bool editAbout = false;
  bool editChargeSome = false;
  bool pickIsClicked = false;
  bool editDisorder = false;
  var backImage;
  var finalpickedfilePath;
  XFile? _pickedFile;
  CroppedFile? _croppedFile;
  TextEditingController nameController =
      TextEditingController(text: psycoData.name);
  TextEditingController qualificationController =
      TextEditingController(text: psycoData.qualification);
  TextEditingController aboutController =
      TextEditingController(text: psycoData.about);
  TextEditingController chargesomeController =
      TextEditingController(text: psycoData.chargespm.toString());
  TextEditingController disorderController = TextEditingController();

  Future<void> updateName(String name) async {
    print("hellobhai");
    var prefs = await SharedPreferences.getInstance();
    var myToken = prefs.getString('token') ?? "";
    print(myToken);
    var cookies = [
      'token=${myToken}',
    ];

    var headers = {
      'Cookie': cookies.join('; '),
      'Content-Type': 'application/json'
    };
    var url = '$updatePsycoProfile${psycoData.id}';
    final uri = Uri.parse(url);
    try {
      final regBody = {"username": name};
      final response =
          await http.post(uri, headers: headers, body: jsonEncode(regBody));
      if (response.statusCode == 200) {
        var json = jsonDecode(response.body);

        await psycoData.loadUser();

        setState(() {
          editName = false;
        });
        Fluttertoast.showToast(msg: "Updated");
      } else {
        debugPrint('Network Error');
        Fluttertoast.showToast(msg: "Network Error!");
      }
    } catch (e) {
      print(e);
      Fluttertoast.showToast(msg: e.toString());
    }
    setState(() {
      editName = false;
    });
  }

  @override
  void initState() {
    super.initState();
    // initSharedPref();
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 159, 194, 225).withOpacity(0.3),
        title: const Text('Edit Profile'),
        // actions: [
        //   // IconButton(
        //   //     onPressed: () {
        //   //       Navigator.push(
        //   //           context,
        //   //           MaterialPageRoute(
        //   //             builder: (context) => RechargeScreen(),
        //   //           ));
        //   //     },
        //   //     icon: Icon(Icons.wallet)),
        //   // IconButton(onPressed: () {}, icon: const Icon(Icons.notifications))
        // ],
      ),
      body: Container(
          height: height * 0.89,
          padding: EdgeInsets.fromLTRB(15, 10, 15, 0),
          child: ListView(
            physics: BouncingScrollPhysics(),
            children: [
              Text('Personal Information'),
              Text('Account Name'),
              TextField(
                controller: nameController,
                decoration: InputDecoration(
col
                    // hintText: 'enter your name',
                    border: OutlineInputBorder(
                        borderSide: BorderSide(
                            color: Colors.greenAccent,
                            width: 2,
                            style: BorderStyle.solid),
                        borderRadius: BorderRadius.circular(10))),
                onSubmitted: ((value) {
                  print("in");
                  updateName(value);
                }),
              )
            ],
          )),
    );
  }
}


// class _MyHomePageState extends State<MyHomePage> {
 */