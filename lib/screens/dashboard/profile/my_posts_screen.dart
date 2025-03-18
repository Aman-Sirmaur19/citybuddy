import 'package:flutter/material.dart';

import '../../../widgets/post_card.dart';

class MyPostsScreen extends StatefulWidget {
  const MyPostsScreen({super.key});

  @override
  State<MyPostsScreen> createState() => _MyPostsScreenState();
}

class _MyPostsScreenState extends State<MyPostsScreen> {
  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.only(top: 8, right: 8),
      children: const [
        // PostCard(),
        // PostCard(),
        // PostCard(),
      ],
    );
  }
}
