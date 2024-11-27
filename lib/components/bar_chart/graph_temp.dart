import 'package:flutter/material.dart';
import 'package:glucoograph/constants/constants.dart';
import 'package:glucoograph/connection/connection.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart'; // استيراد مكتبة Intl

class GraphTemp extends StatelessWidget {
  final String patientName;
  final DateTimeRange? selectedDateRange;

  const GraphTemp({
    Key? key,
    required this.patientName,
    this.selectedDateRange,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: FutureBuilder<List<Map<String, dynamic>>>(
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

            // إذا كانت الفترة الزمنية مختارة، فلتر البيانات بناءً عليها
            if (selectedDateRange != null) {
              data = data.where((biologicalData) {
                DateTime date = _parseDate(biologicalData['date']);
                return date.isAfter(selectedDateRange!.start) && date.isBefore(selectedDateRange!.end);
              }).toList();
            }

            // تحضير بيانات الرسم البياني
            List<BarChartGroupData> barChartGroups = data.map((biologicalData) {
              DateTime date;
              if (biologicalData['date'] is String) {
                date = DateTime.parse(biologicalData['date']);
              } else {
                date = biologicalData['date'];
              }

              double temperature = biologicalData['avg_temperature']; // البيانات الخاصة بدرجة الحرارة

              // تحديد اللون بناءً على درجة الحرارة
              Color barColor;
              if (temperature < 36.5) {
                barColor = Colors.blue; // درجة حرارة منخفضة
              } else if (temperature >= 36.5 && temperature <= 37.5) {
                barColor = Colors.green; // درجة حرارة طبيعية
              } else {
                barColor = Colors.red; // درجة حرارة مرتفعة
              }

              return BarChartGroupData(
                x: date.millisecondsSinceEpoch, // الوقت الذي سيتم ربطه مع البيانات
                barRods: [
                  BarChartRodData(
                    toY: temperature, // درجة الحرارة على المحور Y
                    color: barColor, // تخصيص اللون بناءً على درجة الحرارة
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
                    "Average Temperature", // العنوان الذي سيظهر فوق الجراف
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
                      gridData: FlGridData(show: true), // إخفاء الشبكة
                      titlesData: FlTitlesData(
                        show: true,
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, titleMeta) {
                              var date = DateTime.fromMillisecondsSinceEpoch(value.toInt());
                              return RotatedBox(
                                quarterTurns: 1, // تدوير النص 90 درجة ليصبح عمودي
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
                        topTitles: AxisTitles(
                          sideTitles: SideTitles(showTitles: false), // إخفاء البيانات في الجهة العليا
                        ),
                        rightTitles: AxisTitles(
                          sideTitles: SideTitles(showTitles: false), // إخفاء البيانات على اليمين
                        ),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true, // إبقاء العناوين على اليسار
                            getTitlesWidget: (value, titleMeta) {
                              return Center(
                                child: Text(
                                  value.toStringAsFixed(0), // تحويل القيم لعدد صحيح
                                  style: TextStyle(
                                    fontSize: 15, // تقليل حجم الخط
                                  ),
                                ),
                              );
                            },
                            reservedSize: 40, // تقليل المسافة بين القيم
                          ),
                        ),
                      ),
                      borderData: FlBorderData(show: true), // إضافة حدود للـ graph
                      barGroups: barChartGroups, // البيانات التي سيتم رسمها
                      alignment: BarChartAlignment.spaceAround, // محاذاة الأعمدة
                      maxY: 50, // أقصى قيمة للـ Y axis
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
