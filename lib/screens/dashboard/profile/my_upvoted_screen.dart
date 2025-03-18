import 'package:flutter/material.dart';

import '../../../widgets/post_card.dart';

class MyUpvotedScreen extends StatefulWidget {
  const MyUpvotedScreen({super.key});

  @override
  State<MyUpvotedScreen> createState() => _MyUpvotedScreenState();
}

class _MyUpvotedScreenState extends State<MyUpvotedScreen> {
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
