import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:glucoograph/connection/connection.dart';
import 'package:glucoograph/constants/constants.dart';

class ScatterPlot_Temperature extends StatelessWidget {
  final String patientName;

  const ScatterPlot_Temperature({Key? key, required this.patientName})
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

            // إعداد بيانات النقاط لرسمها في الرسم البياني
            List<FlSpot> temperatureSpots = data.map((biologicalData) {
              DateTime date = biologicalData['date'] is String
                  ? DateTime.parse(biologicalData['date'])
                  : biologicalData['date'];
              double temperature = biologicalData['avg_temperature'] as double;

              return FlSpot(
                date.millisecondsSinceEpoch.toDouble(),
                temperature,
              );
            }).toList();

            // تحديد minX و maxX بناءً على البيانات المتاحة
            double minX = temperatureSpots.first.x;
            double maxX = temperatureSpots.last.x;

            // إضافة مسافة بين آخر نقطة والمحور الأفقي
            double additionalSpace = (maxX - minX) * 0.05;
            maxX = maxX + additionalSpace;

            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    "Temperature", // العنوان
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
                                        1), // تحويل القيم لعدد عشري
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
                            spots: temperatureSpots,
                            isCurved: false, // إلغاء المنحنيات بين النقاط
                            color: Colors.transparent, // إلغاء الخطوط
                            barWidth: 0, // إخفاء الخط بين النقاط
                            dotData: FlDotData(
                              show: true, // إظهار النقاط فقط
                              getDotPainter: (spot, percent, barData, index) {
                                double temperatureLevel = spot.y;
                                Color pointColor;

                                // تخصيص الألوان بناءً على درجة الحرارة
                                if (temperatureLevel < 36.0) {
                                  pointColor = Colors.blue; // درجة حرارة منخفضة
                                } else if (temperatureLevel >= 36.0 &&
                                    temperatureLevel <= 37.5) {
                                  pointColor =
                                      Colors.green; // درجة حرارة طبيعية
                                } else {
                                  pointColor = Colors.red; // درجة حرارة مرتفعة
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
                        minY: 30, // الحد الأدنى لدرجة الحرارة
                        maxY: 42, // الحد الأقصى لدرجة الحرارة
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
