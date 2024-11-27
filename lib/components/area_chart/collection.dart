import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:glucoograph/components/area_chart/charts.dart';
import 'package:intl/intl.dart';
import 'package:glucoograph/connection/connection.dart';
import 'package:glucoograph/constants/constants.dart';

class collection_area extends StatelessWidget {
  final String patientName;

  const collection_area({Key? key, required this.patientName})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          patientName, // اسم المريض
          style: TextStyle(
              color: Colors.white, fontSize: 20, fontFamily: kPrimaryFont),
        ),
        backgroundColor: kPrimaryColor,
        actions: [
          IconButton(
            icon: Icon(
              Icons.area_chart,
              color: Colors.white,
              size: 25,
            ),
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => all_area(
                        patientName: patientName,
                      )));
            },
          ),
        ],
      ),
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

            // إعداد بيانات كل خط (ضغط الدم، سكر الدم، ودرجة الحرارة)
            List<FlSpot> bloodPressureSpots = [];
            List<FlSpot> bloodSugarSpots = [];
            List<FlSpot> temperatureSpots = [];

            DateTime? previousDate;

            for (var biologicalData in data) {
              DateTime date = biologicalData['date'] is String
                  ? DateTime.parse(biologicalData['date'])
                  : biologicalData['date'];

              // إضافة بيانات المؤشرات حسب التاريخ
              bloodPressureSpots.add(
                FlSpot(
                    date.millisecondsSinceEpoch.toDouble(),
                    double.tryParse(
                            biologicalData['blood_pressure']?.toString() ??
                                '0') ??
                        0),
              );

              bloodSugarSpots.add(
                FlSpot(
                    date.millisecondsSinceEpoch.toDouble(),
                    double.tryParse(
                            biologicalData['blood_sugar_level']?.toString() ??
                                '0') ??
                        0),
              );

              temperatureSpots.add(
                FlSpot(
                    date.millisecondsSinceEpoch.toDouble(),
                    double.tryParse(
                            biologicalData['avg_temperature']?.toString() ??
                                '0') ??
                        0),
              );

              previousDate = date;
            }

            // تحديد minX و maxX بناءً على البيانات المتاحة (من أول نقطة إلى آخر نقطة)
            double minX = bloodPressureSpots.first.x;
            double maxX = bloodPressureSpots.last.x;

            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    "Combined Biological Indicators", // العنوان
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
                    padding: const EdgeInsets.only(
                      right: 15,
                    ),
                    child: LineChart(
                      LineChartData(
                        gridData: FlGridData(show: true),
                        titlesData: FlTitlesData(
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, meta) {
                                DateTime date =
                                    DateTime.fromMillisecondsSinceEpoch(
                                        value.toInt());

                                // تحديد تنسيق التاريخ بناءً على المسافة الزمنية بين النقاط
                                return Container(
                                  child: RotatedBox(
                                    quarterTurns: 1, // تدوير النص ليصبح عمودياً
                                    child: Container(
                                      child: Text(
                                        DateFormat('dd/MM/yyyy')
                                            .format(date), // تنسيق التاريخ
                                        style: TextStyle(fontSize: 10),
                                      ),
                                    ),
                                  ),
                                );
                              },
                              reservedSize: 80, // تخصيص مساحة أكبر للتواريخ
                            ),
                          ),
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, titleMeta) {
                                return Center(
                                  child: Text(
                                    value.toStringAsFixed(0),
                                    style: TextStyle(fontSize: 12),
                                  ),
                                );
                              },
                              reservedSize: 40,
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
                          // خط ضغط الدم
                          LineChartBarData(
                            spots: bloodPressureSpots,
                            isCurved: true,
                            color: Colors.blue, // لون ضغط الدم
                            barWidth: 3,
                            dotData: FlDotData(show: true),
                            belowBarData: BarAreaData(
                              show: true,
                              color: Colors.blue
                                  .withOpacity(0.3), // شفافية المساحة
                            ),
                          ),
                          // خط سكر الدم
                          LineChartBarData(
                            spots: bloodSugarSpots,
                            isCurved: true,
                            color: Colors.green, // لون سكر الدم
                            barWidth: 3,
                            dotData: FlDotData(show: true),
                            belowBarData: BarAreaData(
                              show: true,
                              color: Colors.green
                                  .withOpacity(0.3), // شفافية المساحة
                            ),
                          ),
                          // خط درجة الحرارة
                          LineChartBarData(
                            spots: temperatureSpots,
                            isCurved: true,
                            color: Colors.orange, // لون درجة الحرارة
                            barWidth: 3,
                            dotData: FlDotData(show: true),
                            belowBarData: BarAreaData(
                              show: true,
                              color: Colors.orange
                                  .withOpacity(0.3), // شفافية المساحة
                            ),
                          ),
                        ],
                        minX: minX, // الحد الأدنى للـ X (أول تاريخ)
                        maxX: maxX + 560000000, // الحد الأقصى للـ X (آخر تاريخ)
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
