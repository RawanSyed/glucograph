import 'package:flutter/material.dart';
import 'package:glucoograph/auth/login.dart';
import 'package:glucoograph/connection/connection.dart';
import 'package:glucoograph/constants/constants.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // تأكد من تهيئة التطبيقات قبل القيام بأي عملية async
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
  @override
  Widget build(BuildContext context) {
    return InteractiveViewer(
        panEnabled: true, // تمكين السحب
        scaleEnabled: true, // تمكين التكبير
        child: MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Database Connection Test',
            theme: ThemeData(
              primaryColor: kPrimaryColor, // اختر اللون الذي ترغب فيه
              progressIndicatorTheme: ProgressIndicatorThemeData(
                color: kPrimaryColor, // تغيير لون اللودنج
              ),
            ),
            home: LogInView()));
  }
}
