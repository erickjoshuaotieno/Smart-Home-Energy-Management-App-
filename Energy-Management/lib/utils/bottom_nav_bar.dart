import 'package:energy_management/screens/device_usage.dart';
import 'package:energy_management/screens/energy_usage.dart';
import 'package:energy_management/screens/home_page.dart';
import 'package:energy_management/screens/homepage.dart';
import 'package:flutter/material.dart';
import 'package:energy_management/screens/ai_recommendations_screen.dart'; // Import the new screen

class MyBottomNavBar extends StatefulWidget {
  const MyBottomNavBar({super.key});

  @override
  State<MyBottomNavBar> createState() => _MyBottomNavBarState();
}

class _MyBottomNavBarState extends State<MyBottomNavBar> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    if (index == 4) {
      // Redirect to HomePage when "Log Out" is tapped
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomePage()),
      );
    } else {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  static const List<Widget> _pages = <Widget>[
    EnergyHomePage(),
    DeviceUsage(),
    EnergyUsageGraph(),
    AIRecommendationsScreen()
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _selectedIndex < _pages.length ? _pages[_selectedIndex] : const HomePage(),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed, // Ensures equal spacing
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Colors.blueAccent,
        unselectedItemColor: Colors.grey,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.energy_savings_leaf),
            label: 'Devices & Meter',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.trending_up),
            label: 'Reports',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.android_outlined), // Choose an appropriate icon
            label: 'AI overview',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.logout_sharp),
            label: 'Log Out',
          ),
        ],
      ),
    );
  }
}