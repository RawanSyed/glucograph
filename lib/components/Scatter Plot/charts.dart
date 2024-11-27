import 'package:flutter/material.dart';
import 'package:glucoograph/components/Scatter%20Plot/pressure.dart';
import 'package:glucoograph/components/Scatter%20Plot/suagar.dart';
import 'package:glucoograph/components/Scatter%20Plot/temp.dart';
import 'package:glucoograph/constants/constants.dart';
import 'package:glucoograph/user.dart';

class all_plot extends StatefulWidget {
  final String patientName;
  const all_plot({super.key, required this.patientName});

  @override
  _AllGraphState createState() => _AllGraphState();
}

class _AllGraphState extends State<all_plot> {
  bool showBloodSugar = true;
  bool showBloodPressure = true;
  bool showTemp = true;

  @override
  void initState() {
    super.initState();
    // Ensure that all graphs are shown on initial load
    showBloodSugar = true;
    showBloodPressure = true;
    showTemp = true;
  }

  void resetGraphs() {
    setState(() {
      showBloodSugar = true;
      showBloodPressure = true;
      showTemp = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          widget.patientName,
          style: TextStyle(
              color: Colors.white, fontSize: 20, fontFamily: kPrimaryFont),
        ),
        backgroundColor: kPrimaryColor,
        actions: [
          IconButton(
            icon: Icon(
              Icons.refresh,
              color: Colors.white,
              size: 25,
            ),
            onPressed:
                resetGraphs, // Reload the graphs when the button is pressed
          ),
          IconButton(
              icon: Icon(
                Icons.home,
                color: Colors.white,
                size: 25,
              ),
              onPressed: () {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => User()),
                  (route) => false,
                );
              })
        ],
      ),
      body: SingleChildScrollView(
        // تفعيل التمرير في الصفحة
        child: Column(
          children: [
            // عرض الأزرار أفقيًا
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Container(
                height: 55, // تحديد ارتفاع الأزرار
                child: ListView.builder(
                  scrollDirection: Axis.horizontal, // الاتجاه أفقي
                  itemCount: 3, // عدد الأزرار
                  itemBuilder: (context, index) {
                    String buttonText;
                    // Define the button text based on the index
                    switch (index) {
                      case 0:
                        buttonText = "Blood Sugar";
                        break;
                      case 1:
                        buttonText = "Blood Pressure";
                        break;
                      case 2:
                        buttonText = "Temperature";
                        break;
                      default:
                        buttonText = "Button ${index + 1}";
                    }

                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: ElevatedButton(
                        onPressed: () {
                          setState(() {
                            // Hide other graphs and show the selected one
                            if (index == 0) {
                              showBloodSugar = true;
                              showBloodPressure = false;
                              showTemp = false;
                            } else if (index == 1) {
                              showBloodPressure = true;
                              showBloodSugar = false;
                              showTemp = false;
                            } else if (index == 2) {
                              showTemp = true;
                              showBloodSugar = false;
                              showBloodPressure = false;
                            }
                          });
                        },
                        child: Text(
                          buttonText, // Change the button text based on the index
                          style: TextStyle(
                            color: kPrimaryColor,
                            fontSize: 12,
                            fontFamily: kPrimaryFont,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color.fromRGBO(236, 236, 236, 1),
                          fixedSize: Size(125, 40),
                          elevation: 3, // ارتفاع الظل

                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            SizedBox(
              height: 20,
            ),
            // Display graphs conditionally
            if (showBloodSugar) ...[
              Container(
                height: 700, // يمكنك تغيير الارتفاع حسب الحاجة
                width: 400,
                child: ScatterPlot_sugar(
                  patientName: widget.patientName,
                ),
              ),
              SizedBox(
                height: 50,
              ),
            ],
            if (showBloodPressure) ...[
              Container(
                height: 700, // يمكنك تغيير الارتفاع حسب الحاجة
                width: 400,
                child: ScatterPlot_Pressure(
                  patientName: widget.patientName,
                ),
              ),
              SizedBox(
                height: 50,
              ),
            ],
            if (showTemp) ...[
              Container(
                height: 700, // يمكنك تغيير الارتفاع حسب الحاجة
                width: 400,

                child: ScatterPlot_Temperature(
                  patientName: widget.patientName,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
