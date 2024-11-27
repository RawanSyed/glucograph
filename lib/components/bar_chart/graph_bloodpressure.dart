import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart'; // استيراد مكتبة Intl لتنسيق التاريخ
import 'package:glucoograph/connection/connection.dart'; // تأكد من مسار مكتبة الاتصال
import 'package:glucoograph/constants/constants.dart'; // التأكد من مسار مكتبة الثوابت

class Pressure extends StatelessWidget {
  final String patientName;
  final DateTimeRange? selectedDateRange; // إضافة متغير الفترة الزمنية المحددة

  const Pressure({Key? key, required this.patientName, this.selectedDateRange})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: FutureBuilder<List<Map<String, dynamic>>>(
        // جلب البيانات من قاعدة البيانات
        future: DatabaseHelper.getBiologicalIndicators(patientName),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No data available'));
          } else {
            var data = snapshot.data!;

            // إذا كانت الفترة الزمنية مختارة، فلتر البيانات بناءً على النطاق الزمني
            if (selectedDateRange != null) {
              data = data.where((biologicalData) {
                DateTime date = _parseDate(biologicalData['date']);
                return date.isAfter(selectedDateRange!.start) &&
                    date.isBefore(selectedDateRange!.end);
              }).toList();
            }

            // إعداد البيانات للرسم البياني
            List<BarChartGroupData> barChartGroups = data.map((biologicalData) {
              DateTime date = _parseDate(biologicalData['date']);
              double bloodPressure = biologicalData['blood_pressure'] != null
                  ? double.tryParse(biologicalData['blood_pressure']) ?? 0.0
                  : 0.0;

              // تحديد اللون بناءً على قيمة الضغط
              Color barColor;
              if (bloodPressure < 90) {
                barColor = Colors.orange; // ضغط الدم منخفض
              } else if (bloodPressure >= 90 && bloodPressure <= 120) {
                barColor = Colors.green; // ضغط الدم طبيعي
              } else {
                barColor = Colors.red; // ضغط الدم مرتفع
              }

              return BarChartGroupData(
                x: date.millisecondsSinceEpoch, // تحويل التاريخ إلى قيمة x
                barRods: [
                  BarChartRodData(
                    toY: bloodPressure, // قيمة الضغط على المحور Y
                    color: barColor, // تخصيص اللون للضغط
                    width: 10,
                    borderRadius: BorderRadius.all(Radius.zero),
                  ),
                ],
              );
            }).toList();

            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    "Blood Pressure", // العنوان الذي سيظهر فوق الجراف
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: kPrimaryColor, // اللون الأساسي
                      fontFamily: kPrimaryFont, // الخط المستخدم
                    ),
                  ),
                ),
                Expanded(
                  child: BarChart(
                    BarChartData(
                      alignment: BarChartAlignment.spaceAround,
                      maxY: 150, // تعديل أعلى قيمة للضغط إذا لزم الأمر
                      titlesData: FlTitlesData(
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              DateTime date =
                                  DateTime.fromMillisecondsSinceEpoch(value.toInt());
                              return RotatedBox(
                                quarterTurns: 1, // تدوير النص ليصبح عمودياً
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 6.0),
                                  child: Text(
                                    DateFormat('dd/MM/yyyy').format(date), // تنسيق التاريخ
                                    style: TextStyle(fontSize: 12),
                                  ),
                                ),
                              );
                            },
                            reservedSize: 100, // زيادة المسافة بين التواريخ
                          ),
                        ),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true, // إبقاء العناوين على اليسار
                            getTitlesWidget: (value, titleMeta) {
                              return Center(
                                child: Text(
                                  value.toStringAsFixed(0), // تحويل القيم لعدد صحيح
                                  style: TextStyle(fontSize: 15), // تقليل حجم الخط
                                ),
                              );
                            },
                            reservedSize: 40, // تقليل المسافة بين القيم
                          ),
                        ),
                        topTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: false,
                            reservedSize: 50,
                          ),
                        ),
                        rightTitles: AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                      ),
                      gridData: FlGridData(show: true), // إظهار الشبكة
                      barGroups: barChartGroups, // رسم البيانات على الجراف
                    ),
                  ),
                ),
              ],
            );
          }
        },
      ),
    );
  }

  // دالة لتحليل التاريخ بشكل صحيح سواء كان String أو DateTime
  DateTime _parseDate(dynamic date) {
    if (date is String) {
      // إذا كان التاريخ من نوع String، نقوم بتحليله
      return DateTime.parse(date);
    } else if (date is DateTime) {
      // إذا كان التاريخ من نوع DateTime
      return date;
    } else {
      // إذا كان التاريخ من نوع غير معروف (افتراضي نعيد التاريخ الحالي)
      return DateTime.now();
    }
  }
}
