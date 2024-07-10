// import 'package:device_frame/device_frame.dart';
// import 'package:flutter/material.dart';

// void main() {
//   runApp(const MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       title: "Unhusked Rice Detection Apps",
//       theme: ThemeData(
//         primarySwatch: Colors.blue,
//       ),
//       home: const DevicePreviewScreen(),
//       routes: {
//         '/onboarding': (context) => const OnBoardingScreen(),
//         '/login': (context) => const LoginScreen(),
//         '/register': (context) => const RegisterScreen(),
//         '/home': (context) => const BottomNavBar(),
//       },
//     );
//   }
// }

// class DevicePreviewScreen extends StatelessWidget {
//   const DevicePreviewScreen({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: DeviceFrame(
//         device: Devices.ios.iPhone13,
//         screen: const BottomNavBar(),
//       ),
//     );
//   }
// }

              // child: Column(
              //   mainAxisAlignment: MainAxisAlignment.center,
              //   children: const [
              //     CustomCircularProgressIndicator(
              //       imagePath: 'assets/logo/circularcustom.png', size: 25
              //     ),
              //     SizedBox(height: 16),
              //     Text(
              //       "Sedang memproses foto, tunggu sebentar ya...",
              //       style: TextStyle(
              //         fontFamily: 'Poppins',
              //         fontSize: 16,
              //       ),
              //     ),
              //   ],
              // ),

                              // PreventCard(
                              //   text:
                              //       "◉ Unggah gambar gabah \natau melalui video\n◉ Sistem memproses foto \nataupun video \n ◉ Hasil deteksi keluar \n➤ Export ke PDF, deh :)",
                              //   lottieAnimation:
                              //       "assets/animations/animation7.json",
                              //   title: "Langkah proses",
                              // ),
                              //                               PreventCard(
                              //   text:
                              //       "◉ Unggah gambar gabah \n◉ Pilih gambar gabah yang\n ingin dideteksi \n◉ Hasil deteksi keluar",
                              //   lottieAnimation:
                              //       "assets/animations/animation6.json",
                              //   title: "Melalui Foto",
                              // ),
                              //                               PreventCard(
                              //   text:
                              //       "◉ Buka kamera kamu \n◉ Pilih menggunakan video \n◉ Hasil deteksi keluar\n secara real-time",
                              //   lottieAnimation:
                              //       "assets/animations/animation9.json",
                              //   title: "Secara Realtime",
                              // ),
                              //                               PreventCard(
                              //   text:
                              //       "◉ Setelah melakukan \npendeteksian\n◉ Pilih menu laporan \n◉ Riwayat deteksi keluar\nsecara langsung\n ◉ Pilih Export data",
                              //   lottieAnimation:
                              //       "assets/animations/animation8.json",
                              //   title: "Export Hasil",
                              // ),

// class BottomNavBar extends StatefulWidget {
//   const BottomNavBar({Key? key}) : super(key: key);

//   @override
//   _BottomNavBarState createState() => _BottomNavBarState();
// }

// class _BottomNavBarState extends State<BottomNavBar> {
//   int _selectedIndex = 0;

//   static final List<Widget> _pages = <Widget>[
//     const HomeScreen(),
//     const ReportScreen(),
//     const Center(child: Text('Logging out...')),
//   ];

//   void _onItemTapped(int index) {
//     if (index == 2) {
//       // Logout action
//       Navigator.pushReplacementNamed(context, '/login');
//     } else {
//       setState(() {
//         _selectedIndex = index;
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: _pages.elementAt(_selectedIndex),
//       bottomNavigationBar: BottomNavigationBar(
//         backgroundColor: Colors.white,
//         items: const <BottomNavigationBarItem>[
//           BottomNavigationBarItem(
//             icon: Icon(Icons.home_outlined),
//             label: 'Home',
//           ),
//           BottomNavigationBarItem(
//             icon: Icon(FlutterIcons.line_chart_faw),
//             label: 'Report',
//           ),
//           BottomNavigationBarItem(
//             icon: Icon(Icons.login_outlined),
//             label: 'Logout',
//           ),
//         ],
//         currentIndex: _selectedIndex,
//         selectedItemColor: Colors.blue,
//         unselectedItemColor: Colors.black,
//         onTap: _onItemTapped,
//         showUnselectedLabels: true,
//       ),
//     );
//   }
// }

// class HomeScreen extends StatelessWidget {
//   const HomeScreen({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Container(
//         decoration: BoxDecoration(
//           gradient: LinearGradient(
//             colors: [
//               Colors.white,
//               const Color(0xFF5B86E5).withOpacity(0.3),
//               const Color(0xFF36D1DC).withOpacity(0.3)
//             ],
//             begin: Alignment.topLeft,
//             end: Alignment.bottomRight,
//             stops: const [0.7, 1.3, 0.2],
//           ),
//         ),
//         child: const Center(
//           child: Text(
//             'Welcome to Home Screen',
//             style: TextStyle(
//               fontSize: 24,
//               fontWeight: FontWeight.bold,
//               color: Colors.black,
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
