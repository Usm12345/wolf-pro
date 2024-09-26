import 'package:flutter/material.dart';
import 'package:wolfpak/constants/colors.dart';
import 'package:wolfpak/screens/home_screen.dart';
import 'package:wolfpak/screens/settings_screen.dart';

class BottomNavigationMenuScreen extends StatefulWidget {
  const BottomNavigationMenuScreen({super.key});

  @override
  State<BottomNavigationMenuScreen> createState() =>
      _BottomNavigationMenuScreenState();
}

class _BottomNavigationMenuScreenState
    extends State<BottomNavigationMenuScreen> {
  int _selectedIndex = 0;

  static const List<Widget> _widgetOptions = [
    HomeScreen(),
    SettingsScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: "Home",
            backgroundColor: Color(0xFF202020),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: "Settings",
            backgroundColor: Color(0xFF202020),
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: secondaryAccent,
        unselectedItemColor: white3,
        onTap: _onItemTapped,
      ),
    );
  }
}
