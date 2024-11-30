import 'package:flutter/material.dart';
import 'package:glucoograph/components/area_chart/press.dart';
import 'package:glucoograph/components/area_chart/sugar.dart';
import 'package:glucoograph/components/area_chart/temp.dart';
import 'package:glucoograph/components/linw_chart/pressure.dart';
import 'package:glucoograph/components/linw_chart/sugar.dart';
import 'package:glucoograph/components/linw_chart/temp.dart';
import 'package:glucoograph/constants/constants.dart';
import 'package:glucoograph/user.dart';
import 'package:intl/intl.dart'; // استيراد مكتبة Intl

class all_area extends StatefulWidget {
  final String patientName;
  const all_area({super.key, required this.patientName});

  @override
  _AllGraphState createState() => _AllGraphState();
}

class _AllGraphState extends State<all_area> {
  bool showBloodSugar = true;
  bool showBloodPressure = true;
  bool showTemp = true;

  DateTimeRange? selectedDateRange;

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

  // دالة لاختيار التاريخ
  Future<void> _selectDateRange(BuildContext context) async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      initialDateRange: selectedDateRange ??
          DateTimeRange(
            start: DateTime.now().isBefore(DateTime(2024, 11, 1))
                ? DateTime(2024, 11,
                    1) // إذا كان التاريخ الحالي قبل 1 نوفمبر 2024، اجعل البداية 1 نوفمبر 2024
                : DateTime
                    .now(), // إذا كان التاريخ الحالي بعد 1 نوفمبر 2024، استخدم التاريخ الحالي
            end: DateTime.now(),
          ),
      firstDate: DateTime(2024, 11, 1),
      lastDate: DateTime(2101),
    );

    if (picked != null && picked != selectedDateRange) {
      setState(() {
        selectedDateRange = picked;
      });
    }
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
          // زر لتحديد التواريخ
          IconButton(
            icon: Icon(
              Icons.calendar_today,
              color: Colors.white,
              size: 25,
            ),
            onPressed: () =>
                _selectDateRange(context), // استدعاء نافذة تحديد التاريخ
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            Container(
              height: 150,
              child: DrawerHeader(
                decoration: BoxDecoration(
                  color: kPrimaryColor,
                ),
                child: Text(
                  'Graphs',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontFamily: kPrimaryFont,
                  ),
                ),
              ),
            ),
            ListTile(
              title: Row(
                children: [
                  Icon(Icons.home, color: Colors.black, size: 25),
                  SizedBox(
                    width: 5,
                  ),
                  Text('Home'),
                ],
              ),
              onTap: () {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => User()),
                  (route) => false,
                );
              },
            ),
            ListTile(
              title: Row(children: [
                Icon(Icons.area_chart, color: Colors.black, size: 25),
                SizedBox(
                  width: 5,
                ),
                Text('All Graphs'),
              ]),
              onTap: () {
                setState(() {
                  showBloodSugar = true;
                  showBloodPressure = true;
                  showTemp = true;
                });
                Navigator.pop(context); // إغلاق الـ Drawer عند الانتقال
              },
            ),
            ListTile(
              title: Row(children: [
                Icon(Icons.area_chart, color: Colors.black, size: 25),
                SizedBox(
                  width: 5,
                ),
                Text('Blood Sugar'),
              ]),
              onTap: () {
                setState(() {
                  showBloodSugar = true;
                  showBloodPressure = false;
                  showTemp = false;
                });
                Navigator.pop(context); // إغلاق الـ Drawer عند الانتقال
              },
            ),
            ListTile(
              title: Row(children: [
                Icon(Icons.area_chart, color: Colors.black, size: 25),
                SizedBox(
                  width: 5,
                ),
                Text('Blood Pressure'),
              ]),
              onTap: () {
                setState(() {
                  showBloodSugar = false;
                  showBloodPressure = true;
                  showTemp = false;
                });
                Navigator.pop(context); // إغلاق الـ Drawer عند الانتقال
              },
            ),
            ListTile(
              title: Row(children: [
                Icon(Icons.area_chart, color: Colors.black, size: 25),
                SizedBox(
                  width: 5,
                ),
                Text('Temperature'),
              ]),
              onTap: () {
                setState(() {
                  showBloodSugar = false;
                  showBloodPressure = false;
                  showTemp = true;
                });
                Navigator.pop(context); // إغلاق الـ Drawer عند الانتقال
              },
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        // تفعيل التمرير في الصفحة
        child: Column(
          children: [
            SizedBox(
              height: 20,
            ),
            // Display graphs conditionally
            if (showBloodSugar) ...[
              Container(
                height: 700, // يمكنك تغيير الارتفاع حسب الحاجة
                width: 400,
                child: sugae_area(
                  patientName: widget.patientName,
                  selectedDateRange:
                      selectedDateRange, // تمرير التواريخ المحددة
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
                child: press_area(
                  patientName: widget.patientName,
                  selectedDateRange:
                      selectedDateRange, // تمرير التواريخ المحددة
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
                child: Temp_area(
                  patientName: widget.patientName,
                  selectedDateRange:
                      selectedDateRange, // تمرير التواريخ المحددة
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
