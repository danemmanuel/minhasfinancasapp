import 'package:flutter/material.dart';

class PageContainer extends StatefulWidget {
  final List<Widget> pages;
  final List<BottomNavigationBarItem> bottomNavBarItems;

  PageContainer({required this.pages, required this.bottomNavBarItems});

  @override
  _PageContainerState createState() => _PageContainerState();
}

class _PageContainerState extends State<PageContainer> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: widget.pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: widget.bottomNavBarItems,
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
    );
  }
}
