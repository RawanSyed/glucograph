import 'package:flutter/material.dart';
import 'package:glucoograph/components/bar_chart/graph_blood%20sugar.dart';
import 'package:glucoograph/components/bar_chart/graph_bloodpressure.dart';
import 'package:glucoograph/components/bar_chart/graph_temp.dart';
import 'package:glucoograph/constants/constants.dart';
import 'package:glucoograph/user.dart';

class AllGraph extends StatefulWidget {
  final String patientName;
  const AllGraph(
      {super.key, required this.patientName, DateTimeRange? selectedDateRange});

  @override
  _AllGraphState createState() => _AllGraphState();
}

class _AllGraphState extends State<AllGraph> {
  bool showBloodSugar = true;
  bool showBloodPressure = true;
  bool showTemp = true;

  DateTimeRange? selectedDateRange; // متغير لحفظ الفترة الزمنية المختارة

  @override
  void initState() {
    super.initState();
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
            icon: Icon(Icons.calendar_today, color: Colors.white, size: 25),
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
                Icon(Icons.bar_chart, color: Colors.black, size: 25),
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
                Icon(Icons.bar_chart, color: Colors.black, size: 25),
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
                Icon(Icons.bar_chart, color: Colors.black, size: 25),
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
                Icon(Icons.bar_chart, color: Colors.black, size: 25),
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
        child: Column(
          children: [
            // عرض الرسومات البيانية
            SizedBox(height: 20),
            if (showBloodSugar) ...[
              Container(
                height: 700,
                width: 400,
                child: GraphBloodSugar(
                  patientName: widget.patientName,
                  selectedDateRange:
                      selectedDateRange, // تمرير التواريخ المحددة
                ),
              ),
              SizedBox(height: 50),
            ],
            if (showBloodPressure) ...[
              Container(
                height: 700,
                width: 400,
                child: Pressure(
                  patientName: widget.patientName,
                  selectedDateRange:
                      selectedDateRange, // تمرير التواريخ المحددة
                ),
              ),
              SizedBox(height: 50),
            ],
            if (showTemp) ...[
              Container(
                height: 700,
                width: 400,
                child: GraphTemp(
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
