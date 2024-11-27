import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart'; // استيراد مكتبة Intl
import 'package:glucoograph/connection/connection.dart'; // تأكد من المسار الصحيح لهذه المكتبة
import 'package:glucoograph/constants/constants.dart'; // تأكد من المسار الصحيح لمكتبة الثوابت

class press_area extends StatelessWidget {
  final String patientName;
  final DateTimeRange? selectedDateRange; // إضافة معامل التاريخ

  const press_area({
    Key? key,
    required this.patientName,
    this.selectedDateRange, // إضافة معامل التاريخ
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

            // تصفية البيانات بناءً على التاريخ المحدد
            if (selectedDateRange != null) {
              data = data.where((biologicalData) {
                DateTime date = biologicalData['date'] is String
                    ? DateTime.parse(biologicalData['date'])
                    : biologicalData['date'];

                // التحقق إذا كانت البيانات داخل النطاق المحدد
                return date.isAfter(selectedDateRange!.start) &&
                    date.isBefore(selectedDateRange!.end);
              }).toList();
            }

            // إعداد بيانات الرسم البياني الخطي
            List<FlSpot> lineChartSpots = data.map((biologicalData) {
              DateTime date = biologicalData['date'] is String
                  ? DateTime.parse(biologicalData['date'])
                  : biologicalData['date'];
              double bloodPressure = biologicalData['blood_pressure'] != null
                  ? double.tryParse(biologicalData['blood_pressure']) ?? 0.0
                  : 0.0;

              return FlSpot(
                date.millisecondsSinceEpoch.toDouble(),
                bloodPressure,
              );
            }).toList();

            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    "Blood Pressure", // العنوان
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: kPrimaryColor,
                      fontFamily: kPrimaryFont,
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 15),
                    child: LineChart(
                      LineChartData(
                        maxY: 180, // التعديل هنا بناءً على نطاق ضغط الدم
                        minY: 0,
                        titlesData: FlTitlesData(
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, meta) {
                                DateTime date =
                                    DateTime.fromMillisecondsSinceEpoch(
                                        value.toInt());
                                return RotatedBox(
                                  quarterTurns: 1, // تدوير النص ليصبح عمودياً
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 6.0),
                                    child: Text(
                                      DateFormat('dd/MM/yyyy')
                                          .format(date), // تنسيق التاريخ
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
                                    value.toStringAsFixed(
                                        0), // تحويل القيم لعدد صحيح
                                    style: TextStyle(fontSize: 15),
                                  ),
                                );
                              },
                              reservedSize: 40, // تقليل المسافة بين القيم
                            ),
                          ),
                          topTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: false,
                            ),
                          ),
                          rightTitles: AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                        ),
                        gridData: const FlGridData(show: true),
                        lineBarsData: [
                          LineChartBarData(
                            spots: lineChartSpots,
                            isCurved: true, // جعل الخط منحني
                            color: Colors.blue, // اللون الأزرق
                            barWidth: 4,
                            belowBarData: BarAreaData(
                              show: true, // تمكين المساحة أسفل الخط
                              color: Colors.blue
                                  .withOpacity(0.3), // اللون والمساحة أسفل الخط
                            ),
                            dotData:
                                FlDotData(show: true), // إظهار النقاط على الخط
                          ),
                        ],
                        minX: lineChartSpots.first.x, // بداية المحور X
                        maxX:
                            lineChartSpots.last.x + 590090001, // نهاية المحور X
                      ),
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
}
