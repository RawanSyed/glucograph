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
  bool _filterAbove90 = false; // متغير لحفظ حالة الفلترة
  final GlobalKey<ScaffoldState> _scaffoldKey =
      GlobalKey<ScaffoldState>(); // إضافة GlobalKey لسكافولد

  // دالة لتحديث الفلترة
  void _toggleFilter() {
    setState(() {
      _filterAbove90 = !_filterAbove90;
    });
  }

  bool del = true;
  void _toggle() {
    setState(() {
      del = !del;
      print('del value: $del'); // طباعة قيمة del للتحقق من تغييرها
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      // FutureBuilder للـ users
      future: DatabaseHelper.fetchPatientNamesAndGender(
          filterAbove90: _filterAbove90), // تمرير حالة الفلتر
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
            key: _scaffoldKey, // ربط GlobalKey بالـ Scaffold
            backgroundColor: Colors.white,
            appBar: AppBar(
              backgroundColor: kPrimaryColor,
              title: Center(
                child: Text(
                  "Patients ",
                  style: TextStyle(
                      fontSize: 28,
                      color: Colors.white,
                      fontFamily: kPrimaryFont),
                ),
              ),
              actions: [
                IconButton(
                  icon: Icon(
                    _filterAbove90 ? Icons.filter_list_off : Icons.filter_list,
                  ),
                  color: Colors.white,
                  onPressed: _toggleFilter, // عند الضغط نقوم بتغيير الفلتر
                ),
                IconButton(
                  icon: Icon(Icons.notifications_active),
                  color: Colors.white,
                  onPressed: () {
                    _scaffoldKey.currentState
                        ?.openDrawer(); // استخدام الـ GlobalKey لفتح الـ Drawer
                  },
                ),
              ],
            ),
            drawer: del
                ? Container(
                    width: 500,
                    child: Drawer(
                      child: Container(
                        color: Colors.white,
                        child: ListView(
                          padding: EdgeInsets.zero,
                          children: <Widget>[
                            Container(
                                height: 95,
                                child: DrawerHeader(
                                  decoration: BoxDecoration(
                                    color: kPrimaryColor,
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        "Notifications",
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontFamily: kPrimaryFont,
                                            fontSize: 22,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      IconButton(
                                        icon: Icon(Icons.delete),
                                        color: Colors.white,
                                        onPressed: () {
                                          _toggle();
                                        },
                                      )
                                    ],
                                  ),
                                )),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Card(
                                color: Color.fromRGBO(
                                    236, 236, 236, 1), // لون الخلفية
                                shape: RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.circular(15), // حواف دائرية
                                ),
                                elevation: 3,
                                child: Container(
                                  height: 120,
                                  child: Center(
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 50),
                                      child: ListTile(
                                        title: Row(
                                          children: [
                                            Icon(
                                              Icons
                                                  .people, // اختر الأيقونة التي تريدها
                                              color: Colors.black,
                                            ),
                                            Text(
                                              'Total Patients :  ${users.length}',
                                              style: TextStyle(
                                                fontSize: 18,
                                                color: Colors.black,
                                                fontFamily: kPrimaryFont,
                                              ),
                                            ),
                                          ],
                                        ),
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => User(),
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Card(
                                color: Color.fromRGBO(236, 236, 236, 1),
                                shape: RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.circular(15), // حواف دائرية
                                ),
                                elevation: 3,
                                child: Container(
                                  height: 120,
                                  child: Center(
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 50),
                                      child: FutureBuilder<int>(
                                        future: DatabaseHelper
                                            .getHealthStatusAbove90Count(),
                                        builder: (context, snapshot) {
                                          if (snapshot.connectionState ==
                                              ConnectionState.waiting) {
                                            return Padding(
                                              padding:
                                                  const EdgeInsets.all(16.0),
                                              child:
                                                  CircularProgressIndicator(),
                                            );
                                          } else if (snapshot.hasError) {
                                            return Padding(
                                              padding:
                                                  const EdgeInsets.all(16.0),
                                              child:
                                                  Text('Error fetching count'),
                                            );
                                          } else if (snapshot.hasData) {
                                            return ListTile(
                                                title: Text(
                                                  'Total Critical Patients: ${snapshot.data}',
                                                  style: TextStyle(
                                                    fontFamily: kPrimaryFont,
                                                    fontSize: 18,
                                                  ),
                                                ),
                                                onTap: () {
                                                  _toggleFilter();
                                                });
                                          } else {
                                            return Padding(
                                              padding:
                                                  const EdgeInsets.all(16.0),
                                              child: Text('No data available'),
                                            );
                                          }
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 10,
                            ), // هنا نعرض آخر مريض في ListTile بدلاً من DrawerHeader
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Card(
                                color: Color.fromRGBO(236, 236, 236, 1),
                                shape: RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.circular(15), // حواف دائرية
                                ),
                                elevation: 3,
                                child: Container(
                                  height: 120,
                                  child: Center(
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 50),
                                      child:
                                          FutureBuilder<Map<String, dynamic>>(
                                        future: DatabaseHelper
                                            .getLastPatient(), // جلب آخر مريض من قاعدة البيانات
                                        builder: (context, snapshot) {
                                          if (snapshot.connectionState ==
                                              ConnectionState.waiting) {
                                            return Padding(
                                              padding:
                                                  const EdgeInsets.all(16.0),
                                              child: CircularProgressIndicator(
                                                  color: Colors.black),
                                            );
                                          } else if (snapshot.hasError) {
                                            return Padding(
                                              padding:
                                                  const EdgeInsets.all(16.0),
                                              child: Text(
                                                  'Error fetching patient'),
                                            );
                                          } else if (snapshot.hasData) {
                                            final patient = snapshot.data;
                                            return ListTile(
                                              title: Text(
                                                'Last Patient Tested : ${patient?['name'] ?? 'No data available'}',
                                                style: TextStyle(
                                                    fontSize: 18,
                                                    color: Colors.black,
                                                    fontFamily: kPrimaryFont),
                                              ),
                                              subtitle: Text(
                                                'Gender: ${patient?['gender'] ?? 'No data'}',
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  color: Colors.grey[600],
                                                  fontFamily: kPrimaryFont,
                                                ),
                                              ),
                                              onTap: () {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) => Typee(
                                                        patientName:
                                                            patient?['name']),
                                                  ),
                                                );
                                              },
                                            );
                                          } else {
                                            return Padding(
                                              padding:
                                                  const EdgeInsets.all(16.0),
                                              child: Text('No data available'),
                                            );
                                          }
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Card(
                                color: Color.fromRGBO(
                                    236, 236, 236, 1), // لون الخلفية
                                shape: RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.circular(15), // حواف دائرية
                                ),
                                elevation: 3,
                                child: Container(
                                  height: 120,
                                  child: Center(
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 50),
                                      child:
                                          FutureBuilder<Map<String, dynamic>?>(
                                        future: DatabaseHelper
                                            .getLastPatientByCode(), // جلب آخر مريض من قاعدة البيانات
                                        builder: (context, snapshot) {
                                          if (snapshot.connectionState ==
                                              ConnectionState.waiting) {
                                            return Padding(
                                              padding:
                                                  const EdgeInsets.all(16.0),
                                              child: CircularProgressIndicator(
                                                  color: Colors.black),
                                            );
                                          } else if (snapshot.hasError) {
                                            return Padding(
                                              padding:
                                                  const EdgeInsets.all(16.0),
                                              child: Text(
                                                  'Error fetching patient'),
                                            );
                                          } else if (snapshot.hasData &&
                                              snapshot.data != null) {
                                            final patient = snapshot.data;
                                            return ListTile(
                                              title: Text(
                                                'Last Patient: ${patient?['name'] ?? 'No data available'}',
                                                style: TextStyle(
                                                    fontSize: 18,
                                                    color: Colors.black,
                                                    fontFamily: kPrimaryFont),
                                              ),
                                              subtitle: Text(
                                                'Gender: ${patient?['gender'] ?? 'No data'}',
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  color: Colors.grey[600],
                                                  fontFamily: kPrimaryFont,
                                                ),
                                              ),
                                              onTap: () {
                                                // عند الضغط على ListTile يمكنك الانتقال إلى شاشة تفاصيل المريض
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) => Typee(
                                                        patientName:
                                                            patient?['name']),
                                                  ),
                                                );
                                              },
                                            );
                                          } else {
                                            return Padding(
                                              padding:
                                                  const EdgeInsets.all(16.0),
                                              child: Text('No data available'),
                                            );
                                          }
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                : Drawer(
                    child: Container(
                      color: Colors.white,
                      child: ListView(
                        padding: EdgeInsets.zero,
                        children: <Widget>[
                          Container(
                            height: 95,
                            child: DrawerHeader(
                              decoration: BoxDecoration(
                                color: kPrimaryColor,
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "Notifications",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontFamily: kPrimaryFont,
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.restore),
                                    color: Colors.white,
                                    onPressed: () {
                                      _toggle();
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 300,
                          ),
                          Center(
                            child: Text(
                              "No Notifications",
                              style: TextStyle(
                                  fontSize: 25,
                                  color: Colors.black,
                                  fontFamily: kPrimaryFont),
                            ),
                          )
                        ],
                      ),
                    ),
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
