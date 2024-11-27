import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:glucoograph/connection/connection.dart';
import 'package:glucoograph/constants/constants.dart';

class ScatterPlot_Pressure extends StatelessWidget {
  final String patientName;

  const ScatterPlot_Pressure({Key? key, required this.patientName})
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

            // إعداد بيانات النقاط لرسمها في Scatter Plot
            List<FlSpot> bloodPressureSpots = data.map((biologicalData) {
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

            // تحديد minX و maxX بناءً على البيانات المتاحة
            double minX = bloodPressureSpots.first.x;
            double maxX = bloodPressureSpots.last.x;

            // إضافة مسافة بين آخر نقطة والمحور الأفقي (مثلًا: إضافة 5% من المسافة)
            double additionalSpace = (maxX - minX) * 0.05;
            maxX = maxX + additionalSpace;

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
                        gridData: FlGridData(show: true),
                        titlesData: FlTitlesData(
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, titleMeta) {
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
                              reservedSize: 100, // زيادة المسافة بين التواريخ
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
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          rightTitles: AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                        ),
                        borderData: FlBorderData(show: true),
                        lineBarsData: [
                          // الخط الذي يظهر النقاط فقط (بدون خط منحني أو مستقيم)
                          LineChartBarData(
                            spots: bloodPressureSpots,
                            isCurved: false, // إلغاء المنحنيات بين النقاط
                            color: Colors.transparent, // إلغاء الخطوط
                            barWidth: 0, // إخفاء الخط بين النقاط
                            dotData: FlDotData(
                              show: true, // إظهار النقاط فقط
                              getDotPainter: (spot, percent, barData, index) {
                                double bloodPressureLevel = spot.y;
                                Color pointColor;

                                // تخصيص الألوان بناءً على مستوى الضغط
                                if (bloodPressureLevel < 90) {
                                  pointColor = Colors.orange; // ضغط منخفض
                                } else if (bloodPressureLevel >= 90 &&
                                    bloodPressureLevel <= 120) {
                                  pointColor = Colors.green; // ضغط طبيعي
                                } else {
                                  pointColor = Colors.red; // ضغط مرتفع
                                }

                                // تخصيص اللون للنقطة بناءً على القيمة
                                return FlDotCirclePainter(
                                  color: pointColor,
                                  radius: 6, // حجم النقاط
                                );
                              },
                            ),
                            belowBarData: BarAreaData(
                                show: false), // إخفاء المساحة أسفل الخط
                          ),
                        ],
                        minX: minX, // الحد الأدنى للـ X (أول تاريخ)
                        maxX: maxX, // الحد الأقصى للـ X (آخر تاريخ + المسافة)
                        minY: 0,
                        maxY: 200,
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
