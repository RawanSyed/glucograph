import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:glucoograph/connection/connection.dart';
import 'package:glucoograph/constants/constants.dart';
import 'package:glucoograph/user.dart';
import 'package:intl/intl.dart';

class HealthStatusChart extends StatefulWidget {
  @override
  _HealthStatusChartState createState() => _HealthStatusChartState();
}

class _HealthStatusChartState extends State<HealthStatusChart> {
  DateTimeRange? selectedDateRange;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Health Status ',
          style: TextStyle(
              color: Colors.white, fontSize: 20, fontFamily: kPrimaryFont),
        ),
        backgroundColor: kPrimaryColor,
        actions: [
          IconButton(
            icon: Icon(Icons.calendar_today, color: Colors.white),
            onPressed: () async {
              final DateTimeRange? picked = await showDateRangePicker(
                context: context,
                initialDateRange: selectedDateRange,
                firstDate: DateTime(2024, 11, 1),
                lastDate: DateTime(2101),
              );

              if (picked != null && picked != selectedDateRange) {
                setState(() {
                  selectedDateRange = picked;
                });
              }
            },
          ),
          IconButton(
              icon: Icon(Icons.people_alt, color: Colors.white),
              onPressed: () async {
                Navigator.of(context)
                    .push(MaterialPageRoute(builder: (context) => User()));
              }),
        ],
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: DatabaseHelper.getHealthStatusOver80(selectedDateRange),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No data available'));
          } else {
            var data = snapshot.data!;

            // نحتفظ فقط بأول 20 سجل
            if (data.length > 20) {
              data = data.sublist(0,20);
            }

            List<BarChartGroupData> barGroups = data.map((record) {
              DateTime date = record['date'];
              return BarChartGroupData(
                x: date.millisecondsSinceEpoch,
                barRods: [
                  BarChartRodData(
                    toY: record['count'].toDouble(),
                    color: kPrimaryColor,
                    width: 10,
                    borderRadius: BorderRadius.zero,
                  ),
                ],
              );
            }).toList();

            // تحديد حجم الخط بناءً على عدد النقاط
            double fontSize = data.length > 20 ? 8 : 12;

            return Container(
              height: 700,
              child: Padding(
                padding: const EdgeInsets.only(right: 15.0, left: 15, top: 50),
                child: BarChart(
                  BarChartData(
                    alignment: BarChartAlignment.spaceBetween,
                    barGroups: barGroups,
                    titlesData: FlTitlesData(
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, meta) {
                            DateTime date = DateTime.fromMillisecondsSinceEpoch(
                                value.toInt());
                            return RotatedBox(
                              quarterTurns: 1,
                              child: Text(
                                DateFormat('dd/MM/yyyy').format(date),
                                style: TextStyle(fontSize: fontSize),
                              ),
                            );
                          },
                          reservedSize: 100,
                        ),
                      ),
                      rightTitles: AxisTitles(
                          sideTitles: SideTitles(
                        showTitles: false,
                      )),
                      topTitles: AxisTitles(
                          sideTitles: SideTitles(
                        showTitles: false,
                      )),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, titleMeta) {
                            return Text(value.toStringAsFixed(0),
                                style: TextStyle(fontSize: 15));
                          },
                          reservedSize: 40,
                        ),
                      ),
                    ),
                    gridData: FlGridData(show: true),
                    maxY: 15, // تحديد الحد الأقصى للرسم البياني
                    minY: 0,

                    // تحديد الحد الأدنى للرسم البياني
                    borderData: FlBorderData(show: true),
                    barTouchData: BarTouchData(
                      touchTooltipData: BarTouchTooltipData(),
                      handleBuiltInTouches: true, // تفعيل التفاعل مع الأعمدة
                    ),
                  ),
                ),
              ),
            );
          }
        },
      ),
    );
  }
}
