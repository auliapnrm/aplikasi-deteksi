import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:lottie/lottie.dart';
import 'package:debenih_release/models/user_model.dart';
import 'package:permission_handler/permission_handler.dart';
import 'screens/login_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/realtime_detection.dart';
import 'screens/register_screen.dart';
import 'widgets/bottom_navbar.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Permission.camera.request();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "DeBenih Application",
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const InitialScreen(),
      routes: {
        '/onboarding': (context) => const OnBoardingScreen(),
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/home': (context) {
          final UserModel user =
              ModalRoute.of(context)!.settings.arguments as UserModel;
          return BottomNavBar(user: user);
        },
        '/realtime_detection': (context) => const RealTimeClassificationPage(),
      },
    );
  }
}

class InitialScreen extends StatefulWidget {
  const InitialScreen({super.key});

  @override
  _InitialScreenState createState() => _InitialScreenState();
}

class _InitialScreenState extends State<InitialScreen> {
  final storage = const FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    _showSplashScreen();
  }

  Future<void> _showSplashScreen() async {
    await Future.delayed(const Duration(seconds: 3));
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    try {
      String? token = await storage.read(key: 'access_token');
      String? userId = await storage.read(key: 'user_id');
      String? username = await storage.read(key: 'username');
      String? namaLengkap = await storage.read(key: 'nama_lengkap');

      if (token != null &&
          userId != null &&
          username != null &&
          namaLengkap != null) {
        UserModel user = UserModel(
          userId: int.parse(userId),
          username: username,
          namaLengkap: namaLengkap,
          accessToken: token,
        );
        Navigator.pushReplacementNamed(context, '/home', arguments: user);
      } else {
        Navigator.pushReplacementNamed(context, '/onboarding');
      }
    } catch (e) {
      print("Error checking login status: $e");
      Navigator.pushReplacementNamed(context, '/onboarding');
    }
  }

  @override
  Widget build(BuildContext context) {
    return const SplashScreen();
  }
}

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Lottie.asset('assets/animations/animation1.json', height: 150),
      ),
    );
  }
}
