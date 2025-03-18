import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../helper/api.dart';
import '../../../widgets/custom_text_field.dart';
import '../../dashboard/dashboard_screen.dart';
import '../../dashboard/profile/profile_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.trim().toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          titleSpacing: 0,
          leadingWidth: 64,
          leading: Padding(
            padding: const EdgeInsets.all(4),
            child: Image.asset(
              Theme.of(context).brightness == Brightness.dark
                  ? 'assets/images/logo_dark.png'
                  : 'assets/images/logo_light.png',
            ),
          ),
          title: CustomTextField(
            controller: _searchController,
            keyboardType: TextInputType.text,
            hintText: 'Search',
          ),
          actions: [
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
        body: _searchQuery.isEmpty
            ? const Center(
                child: Text(
                  'Search for users...',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              )
            : StreamBuilder<QuerySnapshot>(
                stream: APIs.firestore
                    .collection('users')
                    .where('username', isGreaterThanOrEqualTo: _searchQuery)
                    .where('username',
                        isLessThanOrEqualTo: '$_searchQuery\uf8ff')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(
                        child: CircularProgressIndicator(
                            color: Colors.deepPurpleAccent));
                  }

                  var users = snapshot.data!.docs;

                  if (users.isEmpty) {
                    return const Center(
                      child: Text('No users found'),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    physics: const BouncingScrollPhysics(),
                    itemCount: users.length,
                    itemBuilder: (context, index) {
                      var user = users[index].data() as Map<String, dynamic>;

                      return ListTile(
                        onTap: () => Navigator.push(
                          context,
                          CupertinoPageRoute(
                            builder: (context) =>
                                ProfileScreen(userId: user['id']),
                          ),
                        ),
                        leading: CircleAvatar(
                          backgroundImage: user['profilePic'] != null
                              ? NetworkImage(user['profilePic'])
                              : const AssetImage('assets/images/avatar.png')
                                  as ImageProvider,
                        ),
                        title: Row(
                          children: [
                            Text(
                              user['name'] ?? 'Unknown',
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(width: 4),
                            if (user['verified'] == true)
                              const Icon(
                                Icons.verified_rounded,
                                size: 17,
                                color: Colors.deepPurpleAccent,
                              ),
                          ],
                        ),
                        subtitle: Text(
                          '@${user['username']}',
                          style: const TextStyle(color: Colors.grey),
                        ),
                      );
                    },
                  );
                },
              ),
      ),
    );
  }
}
