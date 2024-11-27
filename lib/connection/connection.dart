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

  static Future<List<Map<String, dynamic>>> fetchPatientNamesAndGender(
      {bool filterAbove80 = false}) async {
    final conn = await connect();
    List<Map<String, dynamic>> patients = [];

    try {
      String query = '''
     SELECT p.name, p.gender, bi.health_status,p.age
  FROM patient p
  JOIN biologicalindicators bi ON p.id = bi.patient_code
  WHERE bi.date = (
    SELECT MAX(bi2.date)
    FROM biologicalindicators bi2
    WHERE bi2.patient_code = p.id
  )
    ''';

      if (filterAbove80) {
        query += '''
        AND bi.health_status > 90
        AND bi.date = (SELECT MAX(bi2.date) 
                       FROM biologicalindicators bi2 
                       WHERE bi2.patient_code = p.id)
      ''';
      }

      var results = await conn.query(query);
      for (var row in results) {
        patients.add({
          'name': row[0] as String,
          'gender': row[1] as String,
          "health_status": row[2] as String,
          'age': row[3] as int
        });
      }
    } catch (e) {
      print('Error fetching patient data: $e');
      throw Exception('Error fetching patient data');
    } finally {
      await conn.close();
    }

    return patients;
  }

  static Future<List<Map<String, dynamic>>> getBiologicalIndicators(
      String patientName) async {
    final conn = await connect();

    try {
      var results = await conn.query(
          '''SELECT bi.avg_temperature, bi.blood_sugar_level, bi.blood_pressure, bi.date 
             FROM biologicalindicators bi
             JOIN patient p ON p.id = bi.patient_code
             WHERE p.name = ?''', [patientName]);

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

      for (var row in results) {
        resultsList.add({
          'date': row[0] as DateTime,
          'count': row[1] as int,
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
