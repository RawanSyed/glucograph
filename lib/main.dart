import 'package:flutter/material.dart';
import 'package:glucoograph/connection/connection.dart';
import 'package:glucoograph/welcome.dart';
  // استيراد ملف الاتصال بقاعدة البيانات

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
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Database Connection Test',
      home: Welcome()
        
    
    );
  }
}