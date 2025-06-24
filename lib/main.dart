import 'package:flutter/material.dart';
import 'package:imunisasiku/firebase_options.dart';
import 'screens/login_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'screens/notificationservice.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  tz.initializeTimeZones();
  tz.setLocalLocation(tz.getLocation('Asia/Jakarta'));

  // Request notification permission (Android 13+ & iOS)
  await Permission.notification.request();

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final NotificationService _notificationService = NotificationService();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Initialize notification service here to avoid context issues
    _notificationService.initialize(context);
    // Jangan panggil scheduleNotification() di sini,
    // tapi panggil saat user ingin buat pengingat
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Imunisasiku',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/login',
      routes: {
        '/login': (context) => const LoginScreen(),
        // Tambahkan rute lain sesuai kebutuhan
      },
    );
  }
}
