import 'package:mysql1/mysql1.dart';

class DatabaseHelper {
  static final String host = 'db9923.public.databaseasp.net';
  static final int port = 3306;
  static final String user = 'db9923';
  static final String password = 'Gy3+8QfxA_4';
  static final String db = 'db9923';

  static Future<MySqlConnection> connect() async {
    try {
      // Set up the connection settings
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
      rethrow;  // Rethrow the exception to handle it higher up if needed
    }
  }

  //fetch name from database
  static Future<List<Map<String, dynamic>>> fetchPatientNamesAndGender() async {
  final conn = await connect();
  List<Map<String, dynamic>> patients = [];

  try {
    var results = await conn.query('SELECT name, gender FROM patient');
    for (var row in results) {
      patients.add({'name': row[0] as String, 'gender': row[1] as String});
    }
  } catch (e) {
    print('Error fetching patient data: $e');
  } finally {
    await conn.close();
  }

  return patients;
}
  
}
