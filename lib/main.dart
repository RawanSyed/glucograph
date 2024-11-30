import 'package:flutter/material.dart';
import 'package:glucoograph/HealthStatusChart.dart';
import 'package:glucoograph/connection/connection.dart';
import 'package:glucoograph/constants/constants.dart';
import 'package:glucoograph/welcome.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'auth/auth.dart';
// استيراد ملف الاتصال بقاعدة البيانات

void main() async {
  WidgetsFlutterBinding
      .ensureInitialized(); // تأكد من تهيئة التطبيقات قبل القيام بأي عملية async
  try {
    // اختبار الاتصال بالقاعدة
    await DatabaseHelper.connect();
    print('Connection successful!');
  } catch (e) {
    print('Connection failed: $e');
  }

  runApp(MyApp()); // بعد التأكد من الاتصال، يتم تشغيل التطبيق
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(360, 690), // Adjust to your design's dimensions
      minTextAdapt: true,
      builder: (context, child) {
        return InteractiveViewer(
          panEnabled: true, // Enable panning
          scaleEnabled: true, // Enable scaling
          child: GetMaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Database Connection Test',
            theme: ThemeData(
              primaryColor: kPrimaryColor, // Set your preferred color
              progressIndicatorTheme: ProgressIndicatorThemeData(
                color: kPrimaryColor, // Customize loading indicator color
              ),
            ),
            home: const Auth(), // Auth widget as the home page
          ),
        );
      },
    );
  }
}
