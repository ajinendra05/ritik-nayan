import 'package:flutter/material.dart';

Future<void> ConfirmToBook(BuildContext context, int amount) async {
  return showDialog(
    context: context,
    builder: (con) {
      final w = MediaQuery.of(con).size.width;
      final h = MediaQuery.of(con).size.height;

      return AlertDialog(
        backgroundColor: Colors.white,
        title: const Center(
          child: SizedBox(
              child: Column(
            children: [
              Text(
                'Confirm Payment',
                style: TextStyle(fontSize: 18),
              ),
              SizedBox(
                height: 5,
              ),
              Text(
                'Review details of this transaction and hit Confirm to proceed',
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ],
          )),
        ),
        content: SizedBox(
          height: h * 0.5,
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.fromLTRB(50, 30, 50, 30),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    color: Colors.amber.shade300),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: w * 0.8,
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Amount'),
                            Text(amount.toString())
                          ]),
                    ),
                    SizedBox(
                      width: w * 0.8,
                      child: const Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [Text('Charges'), Text('0')]),
                    ),
                  ],
                ),
              ),
           
            ],
          ),
        ),
        // actions: <Widget>[
        //   ElevatedButton(
        //     child: const Text('CANCEL'),
        //     onPressed: () {
        //       Navigator.of(context).pop;
        //     },
        //   ),
        //   ElevatedButton(
        //     child: const Text('OK'),
        //     onPressed: () async {
        //       Navigator.of(context).pop();
        //     },
        //   )
        // ],
      );
    },
  );
}
