import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:glucoograph/connection/connection.dart';
import 'package:glucoograph/constants/constants.dart';
import 'package:intl/intl.dart';

class GraphBloodSugar extends StatelessWidget {
  final String patientName;
  final DateTimeRange? selectedDateRange;  // إضافة الفترة الزمنية المحددة

  const GraphBloodSugar({Key? key, required this.patientName, this.selectedDateRange})
      : super(key: key);

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
            
            // إذا كانت الفترة الزمنية مختارة، فلتر البيانات
            if (selectedDateRange != null) {
              data = data.where((biologicalData) {
                // التأكد من أن التاريخ يتم تحليله بشكل صحيح
                DateTime date = _parseDate(biologicalData['date']);
                return date.isAfter(selectedDateRange!.start) && date.isBefore(selectedDateRange!.end);
              }).toList();
            }

            // إعداد بيانات الشريط
            List<BarChartGroupData> barChartGroups = data.map((biologicalData) {
              DateTime date = _parseDate(biologicalData['date']);
              double bloodSugarLevel = biologicalData['blood_sugar_level'] as double;

              return BarChartGroupData(
                x: date.millisecondsSinceEpoch,
                barRods: [
                  BarChartRodData(
                    toY: bloodSugarLevel,
                    color: bloodSugarLevel > 120
                        ? Colors.red
                        : (bloodSugarLevel < 80 ? Colors.orange : Colors.green),
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
                    "Blood Sugar", // العنوان الذي سيظهر فوق الجراف
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
                      maxY: 200,
                      titlesData: FlTitlesData(
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              DateTime date = DateTime.fromMillisecondsSinceEpoch(value.toInt());
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
                            reservedSize: 100,
                          ),
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
                        topTitles: AxisTitles(
                          sideTitles: SideTitles(
                              showTitles: false,
                              reservedSize: 50,
                              getTitlesWidget: (value, meta) {
                                return Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 5),
                                    child: Text("Blood sugar",
                                        style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                            color: kPrimaryColor,
                                            fontFamily: kPrimaryFont)));
                              }),
                        ),
                        rightTitles: AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                      ),
                      gridData: const FlGridData(show: true),
                      barGroups: barChartGroups,
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
