import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:glucoograph/constants/constants.dart';
import 'login.dart';
import 'register.dart';

class Auth extends StatelessWidget {
  const Auth({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
        body: Container(
          padding: EdgeInsets.all(30.r),
          width: double.infinity,
          decoration: const BoxDecoration(
              gradient: LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [
              Colors.blueAccent,
              kPrimaryColor,
            ],
          )),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text('Wellcome To GlucoGraph',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 25,
                        fontWeight: FontWeight.w600)),
                SizedBox(
                  height: 50.h,
                ),
                InkWell(
                  onTap: () => Get.to(SignUpView()),
                  child: Container(
                    height: 60.h,
                    width: 200.w,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.transparent.withOpacity(0.12),
                    ),
                    child: const Text(
                      "Sign Up",
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18),
                    ),
                  ),
                ),
                SizedBox(
                  height: 50.h,
                ),
                InkWell(
                  onTap: () => Get.to(LogInView()),
                  child: Container(
                    height: 60.h,
                    width: 200.w,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.transparent.withOpacity(0.12),
                    ),
                    child: const Text(
                      "Log In",
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
}
