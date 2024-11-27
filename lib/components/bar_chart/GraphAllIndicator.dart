import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:glucoograph/components/bar_chart/chart_graph.dart';
import 'package:intl/intl.dart';
import 'package:glucoograph/connection/connection.dart';
import 'package:glucoograph/constants/constants.dart';

class GraphAllIndicator extends StatelessWidget {
  final String patientName;

  const GraphAllIndicator({Key? key, required this.patientName})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          patientName,
          style: TextStyle(
              color: Colors.white, fontSize: 20, fontFamily: kPrimaryFont),
        ),
        backgroundColor: kPrimaryColor,
        actions: [
          IconButton(
              icon: Icon(
                Icons.bar_chart,
                color: Colors.white,
                size: 25,
              ),
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => AllGraph(
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

            // إعداد بيانات الرسم البياني
            List<BarChartGroupData> barChartGroups = data.map((biologicalData) {
              DateTime date = biologicalData['date'] is String
                  ? DateTime.parse(biologicalData['date'])
                  : biologicalData['date'];

              double bloodSugarLevel =
                  biologicalData['blood_sugar_level'] ?? 0.0;
              double bloodPressure = biologicalData['blood_pressure'] != null
                  ? double.tryParse(biologicalData['blood_pressure']) ?? 0.0
                  : 0.0;
              double temperature = biologicalData['avg_temperature'] ?? 0.0;

              return BarChartGroupData(
                x: date.millisecondsSinceEpoch,
                barRods: [
                  BarChartRodData(
                    toY: bloodSugarLevel,
                    color: Colors.green, // أخضر
                    width: 8,
                    borderRadius: BorderRadius.all(Radius.zero),
                  ),
                  BarChartRodData(
                    toY: bloodPressure,
                    color: Colors.blue, // أزرق
                    width: 8,
                    borderRadius: BorderRadius.all(Radius.zero),
                  ),
                  BarChartRodData(
                    toY: temperature,
                    color: Colors.orange, // برتقالي
                    width: 8,
                    borderRadius: BorderRadius.all(Radius.zero),
                  ),
                ],
              );
            }).toList();

            return GestureDetector(
              onTap: () {
                // عند الضغط في أي مكان على الرسم البياني، سيتم الانتقال إلى صفحة أخرى
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => AllGraph(
                          patientName: patientName,
                        )));
              },
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      "Combined Biological Indicators",
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
                      padding: const EdgeInsets.only(right: 8.0),
                      child: BarChart(
                        BarChartData(
                          gridData: FlGridData(show: true),
                          titlesData: FlTitlesData(
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                getTitlesWidget: (value, meta) {
                                  DateTime date =
                                      DateTime.fromMillisecondsSinceEpoch(
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
                              sideTitles: SideTitles(
                                showTitles: false,
                              ),
                            ),
                            rightTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: false,
                              ),
                            ),
                          ),
                          borderData: FlBorderData(show: true),
                          barGroups: barChartGroups,
                          alignment: BarChartAlignment.spaceAround,
                          maxY: 200,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }
        },
      ),
    );
  }
}
