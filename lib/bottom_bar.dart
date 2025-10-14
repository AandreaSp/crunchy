import 'package:flutter/material.dart';
import 'home.dart';
import 'menu.dart';
//import 'location.dart';
//import 'info.dart';

class CrunchyBottomBar extends StatefulWidget {
  const CrunchyBottomBar({super.key});

  @override
  State<CrunchyBottomBar> createState() => _CrunchyShellState();
}

class _CrunchyShellState extends State<CrunchyBottomBar> {
  int _currentIndex = 0;

  void _openMenuTab() => setState(() => _currentIndex = 1);

  late final List<Widget> _pages = <Widget>[
    HomePage(onOpenMenu: _openMenuTab),
    const MenuPage(),
    //    const LocationPage(),
    //    const InfoPage(),
  ];

  final List<String> _titles = const ['Crunchy', 'Menu', 'Location', 'Info'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_titles[_currentIndex]), centerTitle: true),
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
            tooltip: 'Vai alla Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.restaurant_menu),
            label: 'Menu',
            tooltip: 'Guarda il menù',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.place),
            label: 'Ristorante',
            tooltip: 'Trova ristorante',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.info),
            label: 'Info',
            tooltip: 'Informazioni',
          ),
        ],
      ),
    );
  }
}
