import 'package:beras_app/screens/home_screen.dart';
import 'package:beras_app/screens/report_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:beras_app/models/user_model.dart';

class BottomNavBar extends StatefulWidget {
  final UserModel user;
  const BottomNavBar({Key? key, required this.user}) : super(key: key);

  @override
  _BottomNavBarState createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final List<Widget> _pages = [
      HomeScreen(user: widget.user),
      ReportScreen(user: widget.user),
      const Center(child: Text('Logging out...')),
    ];

    void _onItemTapped(int index) {
      if (index == 2) {
        Navigator.pushReplacementNamed(context, '/login');
      } else {
        setState(() {
          _selectedIndex = index;
        });
      }
    }

    return Scaffold(
      body: _pages.elementAt(_selectedIndex),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          BottomNavigationBar(
            elevation: 2,
            backgroundColor: Colors.white,
            items: const <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                icon: Icon(FlutterIcons.home_outline_mco),
                label: 'Beranda',
              ),
              BottomNavigationBarItem(
                icon: Icon(FlutterIcons.book_open_variant_mco),
                label: 'Laporan',
              ),
              BottomNavigationBarItem(
                icon: Icon(FlutterIcons.logout_variant_mco),
                label: 'Keluar',
              ),
            ],
            currentIndex: _selectedIndex,
            selectedItemColor: Colors.blue,
            unselectedItemColor: Colors.black45,
            selectedLabelStyle: const TextStyle(color: Colors.blue),
            unselectedLabelStyle: const TextStyle(color: Colors.black45),
            onTap: _onItemTapped,
            showUnselectedLabels: true,
          ),
        ],
      ),
    );
  }
}
