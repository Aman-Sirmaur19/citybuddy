import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../dashboard/dashboard_screen.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
        title: const Text(
          'Notifications',
          style: TextStyle(fontSize: 18),
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
      body: ListView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.only(left: 8, right: 8),
        children: [
          ...[
            const Text(
              'Today',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            _notificationCard(
              context: context,
              icon: const Icon(
                Icons.arrow_circle_up_rounded,
                color: Colors.green,
              ),
              title: 'Deepak upvoted your post!',
            ),
            _notificationCard(
              context: context,
              icon: const Icon(
                CupertinoIcons.text_bubble,
                color: Colors.deepPurpleAccent,
              ),
              title: 'Vasu commented on your post!',
            ),
          ],
          const SizedBox(height: 20),
          ...[
            const Text(
              'Yesterday',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            _notificationCard(
              context: context,
              icon: const Icon(
                Icons.arrow_circle_up_rounded,
                color: Colors.green,
              ),
              title: 'Vasu upvoted your post!',
            ),
            _notificationCard(
              context: context,
              icon: const Icon(
                CupertinoIcons.text_bubble,
                color: Colors.deepPurpleAccent,
              ),
              title: 'Deepak commented on your post!',
            ),
          ],
        ],
      ),
    );
  }

  Widget _notificationCard({
    required BuildContext context,
    required Widget icon,
    required String title,
  }) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: ListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        tileColor: Theme.of(context).colorScheme.primary,
        leading: icon,
        title: Text(title),
      ),
    );
  }
}
