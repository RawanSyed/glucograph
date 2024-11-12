import 'package:flutter/material.dart';
import 'package:glucoograph/constants/constants.dart';
import 'package:glucoograph/user.dart';

import 'package:lottie/lottie.dart';

class Welcome extends StatelessWidget {
  const Welcome({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          children: [
            const SizedBox(
              height: 50,
            ),
            const Text(
              "GlucoGraph",
              style: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  fontFamily: kPrimaryFont,
                  color: kPrimaryColor),
            ),
            Lottie.asset('animation/animation1.json', height: 375, width: 300),
            const Text("Welcome to GlucoGraph",
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  fontFamily: kPrimaryFont,
                  color: Colors.black,
                )),
            const SizedBox(
              height: 20,
            ),
            const SizedBox(
              width: 350,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                    "GlucoGraph helps you track blood sugar levels over time, making it easy to spot trends and manage your health effectively.",
                    style: TextStyle(
                      fontSize: 15,
                      fontFamily: kPrimaryFont,
                      color: Colors.grey,
                    )),
              ),
            ),
            const SizedBox(
              height: 100,
            ),
            ElevatedButton(
                onPressed: () {
                  Navigator.of(context)
                      .push(MaterialPageRoute(builder: (context) => User()));
                },
                style: ElevatedButton.styleFrom(
                    backgroundColor: kPrimaryColor,
                    fixedSize: const Size(300, 60)),
                child: const Text(
                  "Get started",
                  style: TextStyle(
                    fontSize: 25,
                    fontFamily: kPrimaryFont,
                    color: Colors.white,
                  ),
                ))
          ],
        ),
      ),
    );
  }
}
