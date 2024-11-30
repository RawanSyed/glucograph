import 'package:glucoograph/auth/extensions/validation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:glucoograph/HealthStatusChart.dart';
import 'package:glucoograph/constants/constants.dart';

class SignUpView extends StatefulWidget {
  const SignUpView({super.key});

  @override
  State<SignUpView> createState() => _SignUpViewState();
}

class _SignUpViewState extends State<SignUpView> {
  final _formKey = GlobalKey<FormState>();
  var username = '';
  var password = '';
  var email = '';
  bool _showPassword = true;

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          toolbarHeight: 120.h,
          centerTitle: true,
          title: const Text(
            'Sgin Up',
            style: TextStyle(fontSize: 30),
          ),
          flexibleSpace: Container(
            decoration: const BoxDecoration(
                gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                Colors.blueAccent,
                kPrimaryColor,
                // Colors.blue,
              ],
            )),
          ),
        ),
        backgroundColor: Colors.white,
        body: SizedBox(
            width: double.infinity,
            child: Padding(
              padding: EdgeInsets.all(20.r),
              child: Form(
                autovalidateMode: AutovalidateMode.onUserInteraction,
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    SizedBox(
                      height: 30.h,
                    ),
                    TextFormField(
                      validator: (value) => value!.length < 5
                          ? 'Please Enter more than 5 characters'
                          : null,
                      onSaved: (value) => username = value!,
                      textInputAction: TextInputAction.done,
                      keyboardType: TextInputType.name,
                      decoration: InputDecoration(
                          icon: const Icon(Icons.person),
                          border: const UnderlineInputBorder(),
                          floatingLabelBehavior: FloatingLabelBehavior.always,
                          // focusedBorder: OutlineInputBorder(),
                          focusColor: Theme.of(context).primaryColor,
                          labelText: "Username",
                          hintText: "username",
                          errorBorder: const UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.red)),
                          focusedErrorBorder: const UnderlineInputBorder(
                              borderSide:
                                  BorderSide(color: Colors.red, width: 2.5))),
                    ),
                    SizedBox(
                      height: 30.h,
                    ),
                    TextFormField(
                      validator: ((value) => value!.isValidEmail()),
                      onSaved: (value) => email = value!,
                      textInputAction: TextInputAction.done,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                          icon: const Icon(Icons.email_rounded),
                          border: const UnderlineInputBorder(),
                          floatingLabelBehavior: FloatingLabelBehavior.always,
                          focusColor: Theme.of(context).primaryColor,
                          labelText: "Email",
                          hintText: 'username@example.com',
                          errorBorder: const UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.red)),
                          focusedErrorBorder: const UnderlineInputBorder(
                              borderSide:
                                  BorderSide(color: Colors.red, width: 2.5))),
                    ),
                    SizedBox(
                      height: 30.h,
                    ),
                    TextFormField(
                      validator: (value) => value!.isValidPassword(),
                      onSaved: (value) => password = value!,
                      obscureText: _showPassword,
                      obscuringCharacter: '*',
                      textInputAction: TextInputAction.done,
                      keyboardType: TextInputType.visiblePassword,
                      decoration: InputDecoration(
                          suffixIcon: IconButton(
                              onPressed: () {
                                setState(() {
                                  _showPassword = !_showPassword;
                                });
                              },
                              icon: _showPassword
                                  ? const Icon(Icons.visibility_off)
                                  : const Icon(Icons.visibility)),
                          icon: const Icon(Icons.key_rounded),
                          border: const UnderlineInputBorder(),
                          floatingLabelBehavior: FloatingLabelBehavior.always,
                          focusColor: Theme.of(context).primaryColor,
                          labelText: "Password",
                          hintText: '**********',
                          errorBorder: const UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.red)),
                          focusedErrorBorder: const UnderlineInputBorder(
                              borderSide:
                                  BorderSide(color: Colors.red, width: 2.5))),
                    ),
                    SizedBox(height: 60.h),
                    InkWell(
                      // splashColor: Colors.green,
                      onTap: () {
                        final isValid = _formKey.currentState?.validate();
                        // auth check
                        if (isValid == true) {
                          // Check if the form is valid
                          _formKey.currentState!
                              .save(); // Save the form data if valid
                          Get.to(() =>
                              HealthStatusChart()); // Navigate to HealthScreen
                        } else {
                          Get.snackbar(
                            "Validation Error",
                            "Please fix the errors in the form",
                            snackPosition: SnackPosition.BOTTOM,
                            backgroundColor: Colors.red,
                            colorText: Colors.white,
                          ); // Show a snackbar if validation fails
                        }
                      },
                      child: Container(
                        height: 60.r,
                        width: 300.r,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            gradient: const LinearGradient(
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                              colors: [
                                Colors.blueAccent,
                                kPrimaryColor,
                                // Colors.blue,
                              ],
                            )),
                        child: const Text(
                          "Submit",
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
            )),
      );
}
