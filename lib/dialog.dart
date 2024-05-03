import 'package:flutter/material.dart';

void PaymentSuccessDialog(BuildContext context, var amount) {
  var height = MediaQuery.of(context).size.height;
  var width = MediaQuery.of(context).size.width;
  showDialog(
    context: context,
    builder: (context) => Container(
      height: height * 0.06,
      width: width * 0.09,
      child: SimpleDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        alignment: Alignment.center,
        title: Stack(alignment: Alignment.center, children: [
          Icon(
            Icons.check,
            size: height * 0.05,
            color: const Color.fromARGB(255, 34, 80, 35),
          ),
          Icon(
            Icons.circle_outlined,
            size: height * 0.07,
            color: Color.fromARGB(255, 34, 80, 35),
          ),
        ]),
        contentPadding: EdgeInsets.symmetric(horizontal: width * 0.04),
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                height: height * 0.02,
              ),
              const Text(
                'Payment Success!',
                style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w400,
                    color: Colors.black),
              ),
              const SizedBox(
                height: 10,
              ),
              Text(
                  'Congratulation! Your Payment is done Successfully. \n your wallet is recharge by ${amount} Rs.',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w400)),
              SizedBox(
                height: height * 0.05,
              ),
              SizedBox(
                height: height * 0.02,
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8))),
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Padding(
                  padding: EdgeInsets.fromLTRB(12, 2, 12, 2),
                  child: Text('Continue',
                      style: TextStyle(
                        color: Colors.green,
                        fontFamily: 'Manrope',
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                      )),
                ),
              ),
              SizedBox(
                height: height * 0.04,
              )
            ],
          )
        ],
      ),
    ),
  );
}

void PaymentFailedDialog(BuildContext context) {
  var height = MediaQuery.of(context).size.height;
  var width = MediaQuery.of(context).size.width;
  showDialog(
    context: context,
    builder: (context) => Container(
      height: height * 0.06,
      width: width * 0.9,
      child: SimpleDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        alignment: Alignment.center,
        title: Stack(alignment: Alignment.center, children: [
          Icon(
            Icons.close,
            size: height * 0.05,
            color: Colors.red,
          ),
          Icon(
            Icons.circle_outlined,
            size: height * 0.07,
            color: Colors.red,
          ),
        ]),
        contentPadding: EdgeInsets.symmetric(horizontal: width * 0.04),
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                height: height * 0.02,
              ),
              const Text(
                'Payment Failed!',
                style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w400,
                    color: Colors.black),
              ),
              const SizedBox(
                height: 10,
              ),
              const Text(
                  'It seems you have network issue.\n Don\'t worry if money is deducted from your account it will be refund in few working hours',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w400)),
              SizedBox(
                height: height * 0.05,
              ),
              SizedBox(
                height: height * 0.02,
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8))),
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Padding(
                  padding: EdgeInsets.fromLTRB(12, 2, 12, 2),
                  child: Text('Retry',
                      style: TextStyle(
                        color: Colors.red,
                        fontFamily: 'Manrope',
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                      )),
                ),
              ),
              SizedBox(
                height: height * 0.04,
              )
            ],
          )
        ],
      ),
    ),
  );
}

void slotBooked(BuildContext context) {
  var height = MediaQuery.of(context).size.height;
  var width = MediaQuery.of(context).size.width;
  showDialog(
    context: context,
    builder: (context) => Container(
      height: height * 0.06,
      width: width * 0.09,
      child: SimpleDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        alignment: Alignment.center,
        title: Stack(alignment: Alignment.center, children: [
          Icon(
            Icons.check,
            size: height * 0.05,
            color: const Color.fromARGB(255, 34, 80, 35),
          ),
          Icon(
            Icons.circle_outlined,
            size: height * 0.07,
            color: Color.fromARGB(255, 34, 80, 35),
          ),
        ]),
        contentPadding: EdgeInsets.symmetric(horizontal: width * 0.04),
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                height: height * 0.02,
              ),
              const Text(
                'Slot Booked!',
                style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w400,
                    color: Colors.black),
              ),
              const SizedBox(
                height: 10,
              ),
              Text(
                  'Congratulation! Your Payment is done Successfully. \n your session is booked, go and check in order History',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w400)),
              SizedBox(
                height: height * 0.05,
              ),
              SizedBox(
                height: height * 0.02,
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8))),
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Padding(
                  padding: EdgeInsets.fromLTRB(12, 2, 12, 2),
                  child: Text('Continue',
                      style: TextStyle(
                        color: Colors.green,
                        fontFamily: 'Manrope',
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                      )),
                ),
              ),
              SizedBox(
                height: height * 0.04,
              )
            ],
          )
        ],
      ),
    ),
  );
}

void slotbookingerror(BuildContext context) {
  var height = MediaQuery.of(context).size.height;
  var width = MediaQuery.of(context).size.width;
  showDialog(
    context: context,
    builder: (context) => Container(
      height: height * 0.06,
      width: width * 0.9,
      child: SimpleDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        alignment: Alignment.center,
        title: Stack(alignment: Alignment.center, children: [
          Icon(
            Icons.close,
            size: height * 0.05,
            color: Colors.red,
          ),
          Icon(
            Icons.circle_outlined,
            size: height * 0.07,
            color: Colors.red,
          ),
        ]),
        contentPadding: EdgeInsets.symmetric(horizontal: width * 0.04),
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                height: height * 0.02,
              ),
              const Text(
                'Network error',
                style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w400,
                    color: Colors.black),
              ),
              const SizedBox(
                height: 10,
              ),
              const Text(
                  'It seems your nework is week try again with strong network.',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w400)),
              SizedBox(
                height: height * 0.05,
              ),
              SizedBox(
                height: height * 0.02,
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8))),
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Padding(
                  padding: EdgeInsets.fromLTRB(12, 2, 12, 2),
                  child: Text('Retry',
                      style: TextStyle(
                        color: Colors.red,
                        fontFamily: 'Manrope',
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                      )),
                ),
              ),
              SizedBox(
                height: height * 0.04,
              )
            ],
          )
        ],
      ),
    ),
  );
}

void noEnoughBalance(BuildContext context) {
  var height = MediaQuery.of(context).size.height;
  var width = MediaQuery.of(context).size.width;
  showDialog(
    context: context,
    builder: (context) => Container(
      height: height * 0.06,
      width: width * 0.9,
      child: SimpleDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        alignment: Alignment.center,
        title: Stack(alignment: Alignment.center, children: [
          Icon(
            Icons.close,
            size: height * 0.05,
            color: Colors.red,
          ),
          Icon(
            Icons.circle_outlined,
            size: height * 0.07,
            color: Colors.red,
          ),
        ]),
        contentPadding: EdgeInsets.symmetric(horizontal: width * 0.04),
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                height: height * 0.02,
              ),
              const Text(
                'Recharge Your Wallet',
                style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w400,
                    color: Colors.black),
              ),
              const SizedBox(
                height: 10,
              ),
              const Text('It seems you have no enough balance to book a slot',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w400)),
              SizedBox(
                height: height * 0.05,
              ),
              SizedBox(
                height: height * 0.02,
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8))),
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Padding(
                  padding: EdgeInsets.fromLTRB(12, 2, 12, 2),
                  child: Text('Retry',
                      style: TextStyle(
                        color: Colors.red,
                        fontFamily: 'Manrope',
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                      )),
                ),
              ),
              SizedBox(
                height: height * 0.04,
              )
            ],
          )
        ],
      ),
    ),
  );
}
