import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../helper/api.dart';
import '../../../main.dart';
import '../../../models/citizen_model.dart';
import '../../../models/organization_model.dart';
import '../../../widgets/chat_user_card.dart';
import '../../dashboard/dashboard_screen.dart';
import '../../dashboard/profile/profile_screen.dart';

class ChatsScreen extends StatefulWidget {
  const ChatsScreen({super.key});

  @override
  State<ChatsScreen> createState() => _ChatsScreenState();
}

class _ChatsScreenState extends State<ChatsScreen> {
  // for storing all users
  List<dynamic> _list = [];

  //for storing searched items
  final List<dynamic> _searchList = [];

  // for storing search status
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    APIs.getSelfInfo();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      // for hiding keyboard when a tap is detected on screen
      onTap: () => FocusScope.of(context).unfocus(),
      child: WillPopScope(
        onWillPop: () {
          if (_isSearching) {
            setState(() {
              _isSearching = !_isSearching;
            });
            return Future.value(false);
          } else {
            return Future.value(true);
          }
        },
        child: Scaffold(
          appBar: AppBar(
            titleSpacing: 0,
            leadingWidth: 64,
            centerTitle: true,
            leading: Padding(
              padding: const EdgeInsets.all(4),
              child: Image.asset(
                Theme.of(context).brightness == Brightness.dark
                    ? 'assets/images/logo_dark.png'
                    : 'assets/images/logo_light.png',
              ),
            ),
            title: _isSearching
                ? TextField(
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Name / Email',
                    ),
                    autofocus: true,
                    style: const TextStyle(fontSize: 17, letterSpacing: 1),

                    // when search text changes, update search list
                    onChanged: (val) {
                      // search logic
                      _searchList.clear();
                      for (var i in _list) {
                        if (i.name.toLowerCase().contains(val.toLowerCase()) ||
                            i.email.toLowerCase().contains(val.toLowerCase())) {
                          _searchList.add(i);
                        }
                        setState(() {
                          _searchList;
                        });
                      }
                    },
                  )
                : const Text(
                    'Chats',
                    style: TextStyle(fontSize: 18),
                  ),
            actions: [
              IconButton(
                onPressed: () {
                  setState(() {
                    _isSearching = !_isSearching;
                  });
                },
                tooltip: 'Search',
                icon: Icon(_isSearching
                    ? CupertinoIcons.clear_circled_solid
                    : CupertinoIcons.search),
              ),
              IconButton(
                onPressed: () => Navigator.push(
                    context,
                    CupertinoPageRoute(
                        builder: (context) => const DashboardScreen())),
                tooltip: 'Dashboard',
                icon: const Icon(CupertinoIcons.square_grid_2x2),
              ),
            ],
          ),
          body: StreamBuilder(
            stream: APIs.getAllUsers(),
            builder: (context, snapshot) {
              switch (snapshot.connectionState) {
                // if data is loading
                case ConnectionState.waiting:
                case ConnectionState.none:
                  return const Center(child: CircularProgressIndicator());

                // if data is loaded then show it
                case ConnectionState.active:
                case ConnectionState.done:
                  final data = snapshot.data?.docs;

                  if (data == null || data.isEmpty) {
                    return const Center(child: Text('No users found.'));
                  }

                  _list = data.map((e) {
                    final userData = e.data();
                    if (userData.containsKey('organizationType')) {
                      return OrganizationModel.fromJson(userData);
                    } else {
                      return CitizenModel.fromJson(userData);
                    }
                  }).toList();

                  if (_list.isNotEmpty) {
                    return ListView.builder(
                      padding: EdgeInsets.only(top: mq.height * .01),
                      physics: const BouncingScrollPhysics(),
                      itemCount:
                          _isSearching ? _searchList.length : _list.length,
                      itemBuilder: (context, index) {
                        return ChatUserCard(
                            user: _isSearching
                                ? _searchList[index]
                                : _list[index]);
                      },
                    );
                  } else {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'No connections found!',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.black.withOpacity(.68),
                            ),
                          ),
                        ],
                      ),
                    );
                  }
              }
            },
          ),
        ),
      ),
    );
  }
}
