import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:glucoograph/connection/connection.dart';
import 'package:glucoograph/constants/constants.dart';
import 'package:intl/intl.dart'; // استيراد مكتبة Intl

class Temp extends StatelessWidget {
  final String patientName;
  final DateTimeRange? selectedDateRange; // إضافة معامل التاريخ

  const Temp({
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

            // تصفية البيانات بناءً على التاريخ المحدد (إن وجد)
            if (selectedDateRange != null) {
              data = data.where((biologicalData) {
                DateTime date = biologicalData['date'] is String
                    ? DateTime.parse(biologicalData['date'])
                    : biologicalData['date'];

                // التحقق إذا كانت البيانات ضمن النطاق المحدد
                return date.isAfter(selectedDateRange!.start) &&
                    date.isBefore(selectedDateRange!.end);
              }).toList();
            }

            // تحضير بيانات الرسم البياني
            List<FlSpot> lineChartSpots = data.map((biologicalData) {
              DateTime date = biologicalData['date'] is String
                  ? DateTime.parse(biologicalData['date'])
                  : biologicalData['date'];

              double temperature = biologicalData['avg_temperature'] != null
                  ? biologicalData['avg_temperature']
                  : 0.0; // التعامل مع درجات الحرارة

              return FlSpot(
                date.millisecondsSinceEpoch.toDouble(), // X-axis: التاريخ
                temperature, // Y-axis: avg_temperature
              );
            }).toList();

            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    "Temperature", // العنوان الذي سيظهر فوق الجراف
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: kPrimaryColor, // اللون الأساسي
                      fontFamily: kPrimaryFont,
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 15),
                    child: LineChart(
                      LineChartData(
                        gridData: FlGridData(show: true), // عرض الشبكة
                        titlesData: FlTitlesData(
                          show: true,
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, titleMeta) {
                                var date = DateTime.fromMillisecondsSinceEpoch(
                                    value.toInt());

                                return RotatedBox(
                                  quarterTurns:
                                      1, // تدوير النص 90 درجة ليصبح عمودي
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
                              reservedSize: 100, // زيادة المسافة بين التواريخ
                            ),
                          ),
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, titleMeta) {
                                return Center(
                                  child: Text(
                                    value.toStringAsFixed(
                                        1), // عرض درجات الحرارة إلى منزلتين عشريتين
                                    style: TextStyle(fontSize: 15),
                                  ),
                                );
                              },
                              reservedSize: 40, // تقليل المسافة بين القيم
                            ),
                          ),
                          topTitles: AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          rightTitles: AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                        ),
                        borderData: FlBorderData(show: true),
                        lineBarsData: [
                          LineChartBarData(
                            spots: lineChartSpots,
                            isCurved: true, // جعل الخط منحني
                            color: Colors.blue, // اللون الأزرق
                            barWidth: 4,
                            belowBarData: BarAreaData(
                                show: false), // إخفاء المساحة أسفل الخط
                            dotData: FlDotData(show: true), // إظهار النقاط
                          ),
                        ],
                        minX: lineChartSpots.first.x,
                        maxX:
                            lineChartSpots.last.x + 962000000, // نهاية المحور X
                        minY: 0, // الحد الأدنى للمحور Y
                        maxY: 50, // الحد الأقصى للمحور Y
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
