import 'package:flutter/material.dart';
import 'package:glucoograph/constants/constants.dart';

class PatientDetailsPage extends StatelessWidget {
  final String patientName;

  const PatientDetailsPage({Key? key, required this.patientName})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(patientName),
        backgroundColor: kPrimaryColor,
      ),
      body: Center(
        child: Text(
          "Patient: $patientName",
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
