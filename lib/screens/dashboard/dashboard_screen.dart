import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../helper/api.dart';
import '../../models/organization_model.dart';
import '../../utils/utils.dart';
import '../auth/login_screen.dart';
import 'admin_panel.dart';
import 'profile/profile_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Future showLogOutAlertDialog() {
      return showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text(
                'Do you want to logout?',
                style: TextStyle(fontSize: 20),
                textAlign: TextAlign.center,
              ),
              content: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  TextButton(
                    child: Text(
                      'Yes',
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.secondary),
                    ),
                    onPressed: () async {
                      // for showing progress dialog
                      Utils.showProgressBar(context);

                      // sign out from app
                      await APIs.auth.signOut().then((value) async {
                        // for hiding progress dialog
                        Navigator.pop(context);

                        // for removing dashboard screen
                        Navigator.pop(context);

                        // for removing home screen
                        Navigator.pop(context);

                        // for replacing home screen with login screen
                        Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const LoginScreen()));
                      });
                    },
                  ),
                  TextButton(
                      child: Text(
                        'No',
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.secondary),
                      ),
                      onPressed: () => Navigator.pop(context)),
                ],
              ),
            );
          });
    }

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          tooltip: 'Back',
          icon: const Icon(CupertinoIcons.chevron_back),
        ),
        centerTitle: true,
        title: const Text(
          'Dashboard',
          style: TextStyle(fontSize: 18),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.only(left: 10, right: 10, top: 10),
        child: Column(
          children: [
            _customContainer(
                context: context,
                child: ListTile(
                  leading:
                      const Icon(Icons.star_rate_rounded, color: Colors.amber),
                  title: RichText(
                    text: TextSpan(
                      text: 'City',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                      children: const [
                        TextSpan(
                          text: 'Buddy',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.deepPurpleAccent,
                          ),
                          children: [
                            TextSpan(
                              text: ' Pro',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.amber,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  trailing: const Icon(
                    CupertinoIcons.chevron_forward,
                    color: Colors.grey,
                  ),
                )),
            const SizedBox(height: 20),
            _customContainer(
              context: context,
              child: Column(
                children: [
                  _customListTile(
                    onTap: () => Navigator.push(
                        context,
                        CupertinoPageRoute(
                            builder: (context) =>
                                ProfileScreen(userId: APIs.user.uid))),
                    icon: Icons.person_outline_rounded,
                    title: 'Profile',
                  ),
                  if (APIs.me is OrganizationModel && APIs.me.isDocVerified)
                    _customListTile(
                      onTap: () => Navigator.push(
                          context,
                          CupertinoPageRoute(
                              builder: (context) => const AdminPanel())),
                      icon: Icons.admin_panel_settings_outlined,
                      title: 'Admin Panel',
                    ),
                  _customListTile(
                    onTap: () {
                      APIs.pickLocation();
                    },
                    icon: Icons.map_rounded,
                    title: 'Map',
                  ),
                  _customListTile(
                    onTap: () {},
                    icon: Icons.settings_outlined,
                    title: 'Settings',
                  ),
                  _customListTile(
                    onTap: () {},
                    icon: Icons.send_outlined,
                    title: 'Send feedback',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            _customContainer(
              context: context,
              child: Column(
                children: [
                  _customListTile(
                    onTap: () {},
                    icon: Icons.lock_outline_rounded,
                    title: 'Privacy policy',
                  ),
                  _customListTile(
                    onTap: () {},
                    icon: Icons.sticky_note_2_outlined,
                    title: 'Terms of use',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            _customContainer(
              context: context,
              child: Column(
                children: [
                  _customListTile(
                    onTap: showLogOutAlertDialog,
                    icon: Icons.logout_rounded,
                    title: 'Logout',
                  ),
                ],
              ),
            ),
            const Spacer(),
            const Text(
              'MADE WITH ❤️ IN 🇮🇳',
              textAlign: TextAlign.center,
              style: TextStyle(
                letterSpacing: 1,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _customContainer({
    required BuildContext context,
    required Widget child,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Theme.of(context).colorScheme.primary,
      ),
      child: child,
    );
  }

  Widget _customListTile({
    required Function() onTap,
    required IconData icon,
    required String title,
  }) {
    return ListTile(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      onTap: onTap,
      leading: Icon(icon, color: title == 'Logout' ? Colors.red : null),
      title: Text(
        title,
        style: TextStyle(color: title == 'Logout' ? Colors.red : null),
      ),
      trailing: Icon(
        CupertinoIcons.chevron_forward,
        color: title == 'Logout' ? Colors.red : Colors.grey,
      ),
    );
  }
}
