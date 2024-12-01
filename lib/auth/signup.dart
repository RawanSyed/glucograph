import 'package:flutter/material.dart';
import 'package:glucoograph/auth/login.dart';
import 'package:glucoograph/connection/connection.dart';
import 'package:glucoograph/constants/constants.dart';
import 'package:glucoograph/welcome.dart';

class SignUpView extends StatefulWidget {
  const SignUpView({super.key});

  @override
  State<SignUpView> createState() => _SignUpViewState();
}

class _SignUpViewState extends State<SignUpView> {
  final _formKey = GlobalKey<FormState>();
  bool _showPassword = true;
  var username = '';
  var password = '';
  var type = 'Admin'; // Default value for dropdown
  var additionalInfo = '';
  final _types = ['Admin', 'Doctor', 'Nurse']; // Dropdown options

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          toolbarHeight: 120,
          centerTitle: true,
          title: const Text(
            'Sign Up',
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
                    validator: (value) => value!.length < 5
                        ? 'Please enter more than 5 characters'
                        : null,
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
                  SizedBox(height: 30),
                  // Type Dropdown
                  Row(
                    children: [
                      const Icon(Icons.person_pin_rounded, color: Colors.grey),
                      SizedBox(width: 10),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: type,
                          items: _types
                              .map((item) => DropdownMenuItem(
                                    value: item,
                                    child: Text(item),
                                  ))
                              .toList(),
                          onChanged: (value) {
                            setState(() {
                              type = value!;
                            });
                          },
                          decoration: const InputDecoration(
                            labelText: "Type",
                            hintText: "Select your role",
                            border: UnderlineInputBorder(),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 30),
                  // Additional Info
                  TextFormField(
                    onSaved: (value) => additionalInfo = value!,
                    maxLines: 5,
                    decoration: InputDecoration(
                      labelText: "Additional Info",
                      hintText: "Provide additional information about yourself",
                      alignLabelWithHint: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
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

                          // Query to insert the new user into the database
                          var result = await conn.query(
                            'INSERT INTO users (username, password, type, additional_info) VALUES (?, ?, ?, ?)',
                            [username, password, type, additionalInfo],
                          );

                          await conn.close();

                          if (result.affectedRows != null &&
                              result.affectedRows! > 0) {
                            // If user is successfully added, navigate to Welcome screen
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const Welcome(),
                              ),
                            );
                          } else {
                            // If the registration fails, show an error
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Failed to register. Try again."),
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
                      const Text("Already have an account? "),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const LogInView(),
                            ),
                          );
                        },
                        child: const Text(
                          "Sign In",
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
