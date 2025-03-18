import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../helper/api.dart';
import 'home/home_tab_screen.dart';
import 'search/search_screen.dart';
import 'complaint/complaint_screen.dart';
import 'notification/notification_screen.dart';
import 'chat/chats_screen.dart';

class TabScreen extends StatefulWidget {
  const TabScreen({super.key});

  @override
  State<TabScreen> createState() => _TabScreenState();
}

class _TabScreenState extends State<TabScreen> {
  late List<Map<String, dynamic>> _pages;
  int _selectedPageIndex = 0;

  @override
  void initState() {
    super.initState();
    APIs.getSelfInfo();
    _pages = [
      {'page': const HomeTabScreen()},
      {'page': const ComplaintScreen()},
      {'page': const SearchScreen()},
      {'page': const NotificationScreen()},
      {'page': const ChatsScreen()},
    ];
  }

  void _selectPage(int index) {
    setState(() {
      _selectedPageIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedPageIndex]['page'],
      bottomNavigationBar: BottomNavigationBar(
        onTap: _selectPage,
        selectedItemColor: Colors.deepPurpleAccent,
        unselectedItemColor: Theme.of(context).colorScheme.secondary,
        currentIndex: _selectedPageIndex,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.house),
            activeIcon: Icon(CupertinoIcons.house_fill),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.square_favorites),
            activeIcon: Icon(CupertinoIcons.square_favorites_fill),
            label: 'Complaint',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.search_circle),
            activeIcon: Icon(CupertinoIcons.search_circle_fill),
            label: 'Search',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.bell),
            activeIcon: Icon(CupertinoIcons.bell_fill),
            label: 'Notification',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.chat_bubble_text),
            activeIcon: Icon(CupertinoIcons.chat_bubble_text_fill),
            label: 'Chats',
          ),
        ],
      ),
    );
  }
}
