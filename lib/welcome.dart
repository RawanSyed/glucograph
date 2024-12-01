import 'package:flutter/material.dart';
import 'package:glucoograph/HealthStatusChart.dart';
import 'package:glucoograph/auth/login.dart';
import 'package:glucoograph/constants/constants.dart';
import 'package:glucoograph/user.dart';
//import 'package:easy_localization/easy_localization.dart';
import 'package:lottie/lottie.dart';

class Welcome extends StatelessWidget {
  const Welcome({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        actions: [
          IconButton(
              onPressed: () {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => LogInView()),
                  (route) => false,
                );
              },
              icon: Icon(Icons.logout_outlined)),
          // زر النقاط الثلاثة (خيارات اللغة)
          PopupMenuButton<String>(
            /* onSelected: (){}   (value) {
              if (value == 'en') {
                context.setLocale(Locale('en'));
              } else if (value == 'ar') {
                context.setLocale(Locale('ar'));
              }
            },*/
            itemBuilder: (BuildContext context) {
              return [
                PopupMenuItem<String>(
                  value: 'en',
                  child: Text('English'),
                ),
                PopupMenuItem<String>(
                  value: 'ar',
                  child: Text('العربية'),
                ),
              ];
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Icon(
                Icons.more_vert, // أيقونة النقاط الثلاثة
                color: kPrimaryColor,
              ),
            ),
          ),
        ],
      ),
      body: Center(
        child: Column(
          children: [
            Text(
              "GlucoGraph" //.tr()
              ,
              style: TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.bold,
                fontFamily: kPrimaryFont,
                color: kPrimaryColor,
              ),
            ),
            Lottie.asset('animation/animation1.json', height: 375, width: 300),
            Text(
              "Welcome to GlucoGraph" //.tr()
              ,
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
                fontFamily: kPrimaryFont,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: 350,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 10),
                child: Text(
                  "GlucoGraph helps you track blood sugar levels over time, making it easy to spot trends and manage your health effectively." //.tr()
                  ,
                  style: TextStyle(
                    fontSize: 15,
                    fontFamily: kPrimaryFont,
                    color: Colors.grey,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 70),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context)
                    .push(MaterialPageRoute(builder: (context) => User()));
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: kPrimaryColor,
                fixedSize: const Size(300, 60),
              ),
              child: Text(
                "Get started" //.tr()
                ,
                style: TextStyle(
                  fontSize: 25,
                  fontFamily: kPrimaryFont,
                  color: Colors.white,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
