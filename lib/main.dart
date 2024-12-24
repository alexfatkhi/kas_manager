import 'package:kas_manager/controller/userController.dart';
import 'package:kas_manager/view/login.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'controller/reportController.dart';
import 'controller/transactionController.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'constFiles/colors.dart';
import 'controller/transDetailController.dart';
import 'view/home.dart';

Future<bool> isUserLoggedIn() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.containsKey('username'); // Cek apakah ada data login
}

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future<void> _initializeNotifications() async {
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings(
          '@mipmap/ic_launcher'); // Gunakan icon default

  final InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
  );

  await flutterLocalNotificationsPlugin.initialize(
    initializationSettings,
  );
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  bool isLoggedIn = await isUserLoggedIn();

    await _initializeNotifications();

  runApp(MyApp(isLoggedIn: isLoggedIn));
}

class MyApp extends StatefulWidget {
    final bool isLoggedIn;

  const MyApp({required this.isLoggedIn});

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

 void checkPermissions() async {
  if (await Permission.notification.isDenied) {
    var status = await Permission.notification.request();
    if (status.isGranted) {
      print("Notification permission granted.");
    } else {
      print("Notification permission denied.");
    }
  } else if (await Permission.notification.isPermanentlyDenied) {
    print("Notification permission is permanently denied.");
    // Opsional: arahkan pengguna ke pengaturan aplikasi.
    openAppSettings();
  } else {
    print("Notification permission already granted.");
  }
  }



  

  @override
    void initState() {
      // TODO: implement initState
      super.initState();
      checkPermissions();

    }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ReportController()),
        ChangeNotifierProvider(create: (_) => TransactionController()),
        ChangeNotifierProvider(create: (_) => TransDetailController()),
        ChangeNotifierProvider(create: (_) => UserController()),
      ],
      child: MaterialApp(
        title: 'Day Manager',
        theme: ThemeData(
            primaryColor: primaryColor, scaffoldBackgroundColor: Colors.white),
        debugShowCheckedModeBanner: false,
        home: widget.isLoggedIn ? Home() : LoginPage(),
      ),
    );
  }
}
