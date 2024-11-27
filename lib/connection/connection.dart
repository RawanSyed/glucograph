import 'package:flutter/material.dart';
import 'package:mysql1/mysql1.dart';

class DatabaseHelper {
  static final String host = 'db9923.public.databaseasp.net';
  static final int port = 3306;
  static final String user = 'db9923';
  static final String password = 'Gy3+8QfxA_4';
  static final String db = 'db9923';

  static Future<MySqlConnection> connect() async {
    try {
      final conn = await MySqlConnection.connect(
        ConnectionSettings(
          host: host,
          port: port,
          user: user,
          password: password,
          db: db,
        ),
      );
      print('Connected to database!');
      return conn;
    } catch (e) {
      print('Error connecting to the database: $e');
      rethrow;
    }
  }
<<<<<<< HEAD
=======

  //fetch name from database
  static Future<List<Map<String, dynamic>>> fetchPatientNamesAndGender() async {
  final conn = await connect();
  List<Map<String, dynamic>> patients = [];
>>>>>>> 5cad30e1aabd3453c1e1b8f79395fe74b0899ca2

  // دالة لجلب بيانات المرضى مع إمكانية فلترة المرضى الذين لديهم health_status > 80
  static Future<List<Map<String, dynamic>>> fetchPatientNamesAndGender(
      {bool filterAbove80 = false}) async {
    final conn = await connect();
    List<Map<String, dynamic>> patients = [];

    try {
      // استعلام مع استخدام DISTINCT لضمان أن كل مريض يظهر مرة واحدة
      String query = '''
      SELECT DISTINCT p.name, p.gender
      FROM patient p
      JOIN biologicalindicators bi ON p.id = bi.patient_code
      WHERE 1
    ''';

      if (filterAbove80) {
        query += '''
        AND bi.health_status > 80
        AND bi.date = (SELECT MAX(bi2.date) 
                       FROM biologicalindicators bi2 
                       WHERE bi2.patient_code = p.id)
      '''; // إضافة الفلترة بناءً على آخر تاريخ للمريض مع health_status > 80
      }

      var results = await conn.query(query);
      if (results.isEmpty) {
        print('No patients found');
      }

      for (var row in results) {
        patients.add({'name': row[0] as String, 'gender': row[1] as String});
      }
    } catch (e) {
      print('Error fetching patient data: $e');
      throw Exception('Error fetching patient data');
    } finally {
      await conn.close();
    }

    return patients;
  }

  // دالة لجلب بيانات المؤشرات البيولوجية بناءً على اسم المريض
  static Future<List<Map<String, dynamic>>> getBiologicalIndicators(
      String patientName) async {
    final conn = await connect();

    try {
      var results = await conn.query(
          '''SELECT bi.avg_temperature, bi.blood_sugar_level, bi.blood_pressure, bi.date 
             FROM biologicalindicators bi
             JOIN patient p ON p.id = bi.patient_code
             WHERE p.name = ?''', [patientName]);

      // إذا لم توجد بيانات للمريض
      if (results.isEmpty) {
        print('No biological indicators found for $patientName.');
      } else {
        print('Found ${results.length} records for $patientName:');
        for (var row in results) {
          print(
              'Date: ${row[3]}, Temperature: ${row[0]}, Blood Sugar: ${row[1]}, Blood Pressure: ${row[2]}');
        }
      }

      return results.map((row) {
        return {
          'avg_temperature': row[0],
          'blood_sugar_level': row[1],
          'blood_pressure': row[2],
          'date': row[3],
        };
      }).toList();
    } catch (e) {
      print('Error fetching biological indicators: $e');
      throw Exception('Error fetching biological indicators');
    } finally {
      await conn.close();
    }
  }

  // دالة للحصول على عدد المرضى الذين لديهم health_status > 80 ضمن فترة محددة
  static Future<List<Map<String, dynamic>>> getHealthStatusOver80(
      DateTimeRange? selectedDateRange) async {
    final conn = await connect();
    List<Map<String, dynamic>> resultsList = [];

    try {
      String query = '''SELECT bi.date, COUNT(*) AS count
                        FROM biologicalindicators bi
                        JOIN patient p ON p.id = bi.patient_code
                        WHERE bi.health_status > 80
                        ${selectedDateRange != null ? 'AND bi.date BETWEEN ? AND ?' : ''}
                        GROUP BY bi.date
                        ORDER BY bi.date''';

      var results;
      if (selectedDateRange != null) {
        DateTime startUtc = selectedDateRange.start.toUtc();
        DateTime endUtc = selectedDateRange.end.toUtc();
        results = await conn.query(query, [startUtc, endUtc]);
      } else {
        results = await conn.query(query);
      }

      // تحويل النتائج إلى قائمة من الخرائط
      for (var row in results) {
        resultsList.add({
          'date': row[0] as DateTime, // تاريخ القياس
          'count': row[1] as int, // عدد المرضى في هذه الفترة
        });
      }
    } catch (e) {
      print('Error fetching health status data: $e');
      throw Exception('Error fetching health status data');
    } finally {
      await conn.close();
    }

    return resultsList;
  }
}
<<<<<<< HEAD
=======
  
}
>>>>>>> 5cad30e1aabd3453c1e1b8f79395fe74b0899ca2
