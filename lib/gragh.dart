// import 'package:flutter/material.dart';
// import 'package:glucograph/model/model.dart';
// import 'package:fl_chart/fl_chart.dart';
// import 'package:mysql1/mysql1.dart';
// import 'database.dart'; // Assuming you placed your database code in database.dart

// class GraphPage extends StatefulWidget {
//   const GraphPage({super.key});

//   @override
//   _GraphPageState createState() => _GraphPageState();
// }

// class _GraphPageState extends State<GraphPage> {
//   late Future<List<Model>> _infoListFuture;

//   // Fetch data from the database
//   Future<List<Model>> fetchBloodSugarData() async {
//     try {
//       var conn = await DatabaseHelper.connect();

//       // Define your query to fetch blood sugar data
//       var results = await conn.query('SELECT date, bloodSugarLevel FROM blood_sugar_data ORDER BY date DESC');

//       List<Model> fetchedData = [];
//       for (var row in results) {
//         fetchedData.add(Model(
//           date: row[0] as String,
//           bloodSugarLevel: row[1] as String,
//         ));
//       }

//       await conn.close();
//       return fetchedData;
//     } catch (e) {
//       print('Error fetching data: $e');
//       return [];
//     }
//   }

//   @override
//   void initState() {
//     super.initState();
//     _infoListFuture = fetchBloodSugarData(); // Initialize the future to fetch data
//   }

//   List<Model> getSortedInfoList(List<Model> infoList) {
//     List<Model> sortedList = List.from(infoList);
//     sortedList.sort((a, b) => DateTime.parse(a.date.split('-').reversed.join())
//         .compareTo(DateTime.parse(b.date.split('-').reversed.join())));
//     return sortedList;
//   }

//   double getBarWidth(int itemCount) {
//     if (itemCount <= 10) return 15;
//     return (150 / itemCount).clamp(5.0, 15.0);
//   }

//   double getMaxY(List<Model> infoList) {
//     return infoList
//             .map((e) => double.parse(e.bloodSugarLevel))
//             .reduce((a, b) => a > b ? a : b) +
//         20;
//   }

//   List<BarChartGroupData> getBarGroups(List<Model> sortedList) {
//     double barWidth = getBarWidth(sortedList.length);

//     return List.generate(sortedList.length, (index) {
//       double bloodSugar = double.parse(sortedList[index].bloodSugarLevel);

//       Color barColor;
//       if (bloodSugar > 120) {
//         barColor = Colors.red;
//       } else if (bloodSugar < 80) {
//         barColor = Colors.orange;
//       } else {
//         barColor = Colors.green;
//       }

//       return BarChartGroupData(
//         x: index,
//         barRods: [
//           BarChartRodData(
//             toY: bloodSugar,
//             color: barColor,
//             width: barWidth,
//             borderRadius: BorderRadius.circular(4),
//           ),
//         ],
//       );
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text(
//           "Blood Sugar Levels - Bar Chart",
//           style: TextStyle(fontFamily: "Pacifico", fontSize: 20),
//         ),
//       ),
//       body: FutureBuilder<List<Model>>(
//         future: _infoListFuture,
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return const Center(child: CircularProgressIndicator());
//           } else if (snapshot.hasError) {
//             return Center(child: Text('Error: ${snapshot.error}'));
//           } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
//             return const Center(child: Text('No data available.'));
//           }

//           final sortedInfoList = getSortedInfoList(snapshot.data!);
//           final maxY = getMaxY(sortedInfoList);

//           return Padding(
//             padding: const EdgeInsets.all(16.0),
//             child: BarChart(
//               BarChartData(
//                 alignment: BarChartAlignment.spaceAround,
//                 maxY: maxY,
//                 barGroups: getBarGroups(sortedInfoList),
//                 titlesData: FlTitlesData(
//                   bottomTitles: AxisTitles(
//                     sideTitles: SideTitles(
//                       showTitles: true,
//                       getTitlesWidget: (value, meta) {
//                         final int index = value.toInt();
//                         if (index >= 0 && index < sortedInfoList.length) {
//                           // تحديد حجم النص بناءً على عدد العناصر
//                           double fontSize = sortedInfoList.length > 5 ? 6 : 7;
//                           return Text(
//                             sortedInfoList[index].date,
//                             style: TextStyle(fontSize: fontSize),
//                           );
//                         }
//                         return const Text('');
//                       },
//                     ),
//                   ),
//                   leftTitles: AxisTitles(
//                     sideTitles: SideTitles(
//                       showTitles: true,
//                       reservedSize: 40,
//                       interval: 20,
//                       getTitlesWidget: (value, meta) =>
//                           Text(value.toInt().toString()),
//                     ),
//                   ),
//                 ),
//                 borderData: FlBorderData(
//                   show: false,
//                 ),
//                 gridData: const FlGridData(show: true),
//               ),
//             ),
//           );
//         },
//       ),
//     );
//   }
// }