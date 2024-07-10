import 'package:debenih_release/screens/home_screen.dart';
import 'package:debenih_release/screens/report_screen.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:debenih_release/models/user_model.dart';

class BottomNavBar extends StatefulWidget {
  final UserModel user;
  const BottomNavBar({super.key, required this.user});

  @override
  _BottomNavBarState createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      HomeScreen(user: widget.user),
      ReportScreen(user: widget.user),
      const Center(child: Text('Logging out...')),
    ];

    void onItemTapped(int index) {
      if (index == 2) {
        Navigator.pushReplacementNamed(context, '/login');
      } else {
        setState(() {
          _selectedIndex = index;
        });
      }
    }

    return Scaffold(
      body: pages.elementAt(_selectedIndex),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          BottomNavigationBar(
            elevation: 2,
            backgroundColor: Colors.white,
            items: const <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                icon: FaIcon(FontAwesomeIcons.home),
                label: 'Beranda',
              ),
              BottomNavigationBarItem(
                icon: FaIcon(FontAwesomeIcons.addressBook),
                label: 'Laporan',
              ),
              BottomNavigationBarItem(
                icon: FaIcon(FontAwesomeIcons.signOut),
                label: 'Keluar',
              ),
            ],
            currentIndex: _selectedIndex,
            selectedItemColor: Colors.blue,
            unselectedItemColor: Colors.black45,
            selectedLabelStyle: const TextStyle(color: Colors.blue),
            unselectedLabelStyle: const TextStyle(color: Colors.black45),
            onTap: onItemTapped,
            showUnselectedLabels: true,
          ),
        ],
      ),
    );
  }
}
