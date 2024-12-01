import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:glucoograph/auth/signup.dart';
import 'package:glucoograph/connection/connection.dart';
import 'package:glucoograph/constants/constants.dart';
import 'package:glucoograph/welcome.dart';

class LogInView extends StatefulWidget {
  const LogInView({super.key});

  @override
  State<LogInView> createState() => _LogInViewState();
}

class _LogInViewState extends State<LogInView> {
  final _formKey = GlobalKey<FormState>();
  bool _showPassword = true;
  var password = '';
  var username = '';

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: Center(
            child: const Text(
              'Log In',
              style: TextStyle(fontSize: 30),
            ),
          ),
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [
                  Colors.blueAccent,
                  kPrimaryColor,
                ],
              ),
            ),
          ),
        ),
        backgroundColor: Colors.white,
        body: SizedBox(
          width: double.infinity,
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  SizedBox(height: 30),
                  // Username Input Field
                  TextFormField(
                    validator: (value) =>
                        value!.isNotEmpty ? null : 'Enter a valid username',
                    onSaved: (value) => username = value!,
                    textInputAction: TextInputAction.done,
                    keyboardType: TextInputType.text,
                    decoration: InputDecoration(
                      icon: const Icon(Icons.person_rounded),
                      border: const UnderlineInputBorder(),
                      floatingLabelBehavior: FloatingLabelBehavior.always,
                      focusColor: Theme.of(context).primaryColor,
                      labelText: "Username",
                      hintText: 'Enter your username',
                      errorBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.red),
                      ),
                      focusedErrorBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.red, width: 2.5),
                      ),
                    ),
                  ),
                  SizedBox(height: 30),
                  // Password Input Field
                  TextFormField(
                    validator: (value) => value!.length >= 6
                        ? null
                        : 'Password must be at least 6 characters',
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
                            : const Icon(Icons.visibility),
                      ),
                      icon: const Icon(Icons.key_rounded),
                      border: const UnderlineInputBorder(),
                      floatingLabelBehavior: FloatingLabelBehavior.always,
                      focusColor: Theme.of(context).primaryColor,
                      labelText: "Password",
                      hintText: '',
                      errorBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.red),
                      ),
                      focusedErrorBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.red, width: 2.5),
                      ),
                    ),
                  ),
                  SizedBox(height: 60),
                  // Submit Button
                  InkWell(
                    onTap: () async {
                      final isValid = _formKey.currentState?.validate();

                      if (isValid == true) {
                        _formKey.currentState!.save();

                        try {
                          final conn = await DatabaseHelper.connect();

                          // Query to validate login credentials
                          var result = await conn.query(
                            'SELECT id FROM users WHERE username = ? AND password = ?',
                            [username, password],
                          );

                          await conn.close();

                          if (result.isNotEmpty) {
                            // If credentials are valid, navigate to Welcome
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const Welcome(),
                              ),
                            );
                          } else {
                            // If credentials are invalid, show an error
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Invalid username or password"),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        } catch (e) {
                          // Handle database connection or query errors
                          print('Error: $e');
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content:
                                  Text("Failed to connect to the database"),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      } else {
                        // Show a snackbar if validation fails
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Please fix the errors in the form"),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    },
                    child: Container(
                      height: 60,
                      width: 300,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        gradient: const LinearGradient(
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                          colors: [
                            Colors.blueAccent,
                            kPrimaryColor,
                          ],
                        ),
                      ),
                      child: const Text(
                        "Submit",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  // Sign Up Option
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Don't have an account? "),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const SignUpView(),
                            ),
                          );
                        },
                        child: const Text(
                          "Sign Up",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: kPrimaryColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      );
}
