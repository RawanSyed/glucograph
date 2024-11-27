import 'package:flutter/material.dart';
import 'package:glucoograph/components/Scatter%20Plot/collection.dart';
import 'package:glucoograph/components/area_chart/collection.dart';
import 'package:glucoograph/components/bar_chart/GraphAllIndicator.dart';
import 'package:glucoograph/components/linw_chart/collection.dart';
import 'package:glucoograph/constants/constants.dart';
import 'package:lottie/lottie.dart';

class Typee extends StatelessWidget {
  final String patientName;
  Typee({super.key, required this.patientName});

  // قائمة تحتوي على بيانات الكروت (الاسم، الأنيميشن، الصفحة)
  final List<Map<String, dynamic>> cardData = [
    {
      "name": "Bar-chart",
      "animation": 'animation/chart.json',
      "page": (String patientName) =>
          GraphAllIndicator(patientName: patientName),
    },
    {
      "name": "Line-chart",
      "animation": 'animation/chart2.json',
      "page": (String patientName) => collection_line(
          patientName: patientName), // يمكن تعديل الصفحة هنا حسب الحاجة
    },
    {
      "name": "Plot-chart",
      "animation": 'animation/3.json',
      "page": (String patientName) => Collectionplot(
          patientName: patientName), // يمكن تعديل الصفحة هنا حسب الحاجة
    },
    {
      "name": "Area-chart",
      "animation": 'animation/4.json',
      "page": (String patientName) => collection_area(
          patientName: patientName), // يمكن تعديل الصفحة هنا حسب الحاجة
    }

    // أضف المزيد من الكروت هنا مع البيانات الخاصة بهم
  ];

  // وظيفة التنقل حسب الكارت
  void _navigateToNextPage(
      BuildContext context, Widget Function(String) pageBuilder) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            pageBuilder(patientName), // بناء الصفحة وتمرير الاسم
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: kPrimaryColor,
        title: Center(
          child: Text(
            "Types",
            style: TextStyle(
                fontSize: 28, color: Colors.white, fontFamily: kPrimaryFont),
          ),
        ),
      ),
      body: SingleChildScrollView(
        // إضافة التمرير
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Center(
            child: Wrap(
              spacing: 20, // المسافة بين الكروت
              runSpacing: 20, // المسافة بين الصفوف
              children: List.generate(cardData.length, (index) {
                final card = cardData[index];
                return GestureDetector(
                  onTap: () => _navigateToNextPage(
                      context, card["page"]), // التنقل حسب الصفحة
                  child: Card(
                    color: Color.fromRGBO(236, 236, 236, 1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15), // حواف دائرية
                    ),
                    elevation: 3, // إضافة الظل
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Lottie.asset(card["animation"],
                            height: 150, width: 150), // تغيير الأنيميشن
                        SizedBox(height: 5),
                        Text(
                          card["name"], // تغيير النص
                          style: TextStyle(
                            fontFamily: kPrimaryFont,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 10),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}
