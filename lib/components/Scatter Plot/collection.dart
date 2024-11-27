import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:glucoograph/components/Scatter%20Plot/charts.dart';
import 'package:intl/intl.dart';
import 'package:glucoograph/connection/connection.dart';
import 'package:glucoograph/constants/constants.dart';

class Collectionplot extends StatelessWidget {
  final String patientName;

  const Collectionplot({Key? key, required this.patientName}) : super(key: key);

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
                Icons.bubble_chart,
                color: Colors.white,
                size: 25,
              ),
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => all_plot(
                          patientName: patientName,
                        )));
              }),
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

            // تحويل البيانات إلى FlSpot
            for (var biologicalData in data) {
              DateTime date = biologicalData['date'] is String
                  ? DateTime.parse(biologicalData['date'])
                  : biologicalData['date'];

              // ضغط الدم
              bloodPressureSpots.add(
                FlSpot(
                  date.millisecondsSinceEpoch
                      .toDouble(), // التوقيت بالـ milliseconds
                  double.tryParse(
                        biologicalData['blood_pressure']?.toString() ?? '0',
                      ) ??
                      0.0, // القيمة الرقمية لضغط الدم
                ),
              );

              // سكر الدم
              bloodSugarSpots.add(
                FlSpot(
                  date.millisecondsSinceEpoch.toDouble(),
                  double.tryParse(
                        biologicalData['blood_sugar_level']?.toString() ?? '0',
                      ) ??
                      0.0,
                ),
              );

              // درجة الحرارة
              temperatureSpots.add(
                FlSpot(
                  date.millisecondsSinceEpoch.toDouble(),
                  double.tryParse(
                        biologicalData['avg_temperature']?.toString() ?? '0',
                      ) ??
                      0.0,
                ),
              );
            }

            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
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
                    padding: const EdgeInsets.only(right: 8),
                    child: LineChart(
                      LineChartData(
                        gridData: FlGridData(show: true),
                        titlesData: FlTitlesData(
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, titleMeta) {
                                var date = DateTime.fromMillisecondsSinceEpoch(
                                    value.toInt());
                                return RotatedBox(
                                  quarterTurns: 1,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 6.0),
                                    child: Text(
                                      DateFormat('dd/MM/yyyy').format(date),
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
                              showTitles: true,
                              getTitlesWidget: (value, titleMeta) {
                                return Center(
                                  child: Text(
                                    value.toStringAsFixed(0),
                                    style: TextStyle(fontSize: 15),
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
                          // خط ضغط الدم (إخفاء الخطوط، فقط النقاط)
                          LineChartBarData(
                            spots: bloodPressureSpots,
                            isCurved:
                                false, // يمكن تغييره لـ true إذا أردت منحنى للنقاط
                            color: Colors.blue, // لون ضغط الدم
                            barWidth: 0, // إخفاء الخطوط
                            dotData: FlDotData(show: true), // إظهار النقاط فقط
                            belowBarData: BarAreaData(show: false),
                          ),
                          // خط سكر الدم (إخفاء الخطوط، فقط النقاط)
                          LineChartBarData(
                            spots: bloodSugarSpots,
                            isCurved: false,
                            color: Colors.green, // لون سكر الدم
                            barWidth: 0, // إخفاء الخطوط
                            dotData: FlDotData(show: true), // إظهار النقاط فقط
                            belowBarData: BarAreaData(show: false),
                          ),
                          // خط درجة الحرارة (إخفاء الخطوط، فقط النقاط)
                          LineChartBarData(
                            spots: temperatureSpots,
                            isCurved: false,
                            color: Colors.orange, // لون درجة الحرارة
                            barWidth: 0, // إخفاء الخطوط
                            dotData: FlDotData(show: true), // إظهار النقاط فقط
                            belowBarData: BarAreaData(show: false),
                          ),
                        ],
                        minX: temperatureSpots.first.x,
                        maxX: temperatureSpots.last.x + 965000000,
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
