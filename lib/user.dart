import 'package:flutter/material.dart';
import 'package:glucoograph/connection/connection.dart';
import 'package:glucoograph/constants/constants.dart';
import 'package:glucoograph/graphs_type.dart';

class User extends StatefulWidget {
  const User({super.key});

  @override
  _UserState createState() => _UserState();
}

class _UserState extends State<User> {
  bool _filterAbove80 = false; // متغير لحفظ حالة الفلترة

  // دالة لتحديث الفلترة
  void _toggleFilter() {
    setState(() {
      _filterAbove80 = !_filterAbove80;
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: DatabaseHelper.fetchPatientNamesAndGender(
           filterAbove80: _filterAbove80), // تمرير حالة الفلتر
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
              child: CircularProgressIndicator(
            color: kPrimaryColor,
          ));
        } else if (snapshot.hasError) {
          return Center(child: Text("Error loading data"));
        } else {
          final users = snapshot.data ?? [];

          return Scaffold(
            backgroundColor: Colors.white,
            appBar: AppBar(
              backgroundColor: kPrimaryColor,
              title: Center(
                child: Text(
                  "Users ",
                  style: TextStyle(
                      fontSize: 28,
                      color: Colors.white,
                      fontFamily: kPrimaryFont),
                ),
              ),
              actions: [
                IconButton(
                    icon: Icon(
                      _filterAbove80
                          ? Icons.filter_list_off
                          : Icons.filter_list,
                    ),
                    color: Colors.white,
                    onPressed:
                        _toggleFilter, // عند الضغط نقوم بتغيير الفلتر
                    ),
              ],
            ),
            body: Padding(
              padding: const EdgeInsets.all(10),
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 1, // عدد الأعمدة
                  mainAxisSpacing: 10, // المسافة بين العناصر في الاتجاه الرأسي
                  crossAxisSpacing: 10, // المسافة بين العناصر في الاتجاه الأفقي
                  childAspectRatio: 3, // تحديد النسبة بين العرض والارتفاع
                ),
                itemCount: users.length, // استخدم المستخدمين المفلترين
                itemBuilder: (context, index) {
                  final user = users[index];
                  final imagePath = user['gender'] == 'Male'
                      ? 'assets/male.jpg'
                      : 'assets/female.jpg';
                  double healthStatus =
                      double.tryParse(user['health_status'] ?? '0') ??
                          0; // تحويل حالة الصحة
                  bool showAdditionalContainer =
                      healthStatus > 90; // التحقق إذا كانت أكبر من 90
                  return InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              Typee(patientName: user['name']),
                        ),
                      );
                    },
                    child: Container(
                      child: Card(
                        color: Color.fromRGBO(236, 236, 236, 1), // لون الخلفية
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(15), // حواف دائرية
                        ),
                        elevation: 3, // إضافة الظل
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              CircleAvatar(
                                radius: 40, // حجم الصورة
                                backgroundImage: AssetImage(imagePath),
                              ),
                              Container(
                                height: 60,
                                child: Column(
                                  children: [
                                    Text(
                                      user['name'],
                                      style: TextStyle(
                                        fontFamily: kPrimaryFont,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                    SizedBox(
                                      height: 8,
                                    ),
                                    Text(
                                      'Age: ${user["age"].toString()}',
                                      style: TextStyle(
                                        fontFamily: kPrimaryFont,
                                        fontSize: 15,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              ),
                              if (showAdditionalContainer)
                                Container(
                                  width: 75,
                                  height: 30,
                                  decoration: BoxDecoration(
                                    color:
                                        const Color.fromARGB(255, 165, 27, 18),
                                    borderRadius: BorderRadius.circular(25),
                                  ),
                                  child: Center(
                                      child: Text('Critical',
                                          style: TextStyle(
                                            color: Colors.white,
                                          ))),
                                )
                              else
                                Container(
                                  width: 75,
                                  height: 30,
                                )
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          );
        }
      },
    );
  }
}
