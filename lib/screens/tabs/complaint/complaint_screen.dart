import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../widgets/glass_container.dart';
import '../../dashboard/dashboard_screen.dart';
import 'all complaints/all_complaints_screen.dart';
import 'post_complaint_screen.dart';

class ComplaintScreen extends StatelessWidget {
  const ComplaintScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> issuesList = [
      {
        'name': 'Road & Traffic',
        'image': 'assets/images/traffic.png',
      },
      {
        'name': 'Water Supply & Drainage',
        'image': 'assets/images/drainage.png',
      },
      {
        'name': 'Garbage',
        'image': 'assets/images/garbage.png',
      },
      {
        'name': 'Sanitation',
        'image': 'assets/images/sanitation.png',
      },
      {
        'name': 'Illegal Construction',
        'image': 'assets/images/construction.png',
      },
      {
        'name': 'Pollution',
        'image': 'assets/images/pollution.png',
      },
      {
        'name': 'Encroachments',
        'image': 'assets/images/encroachment.png',
      },
      {
        'name': 'Public Transport',
        'image': 'assets/images/transport.png',
      },
      {
        'name': 'Power Supply',
        'image': 'assets/images/electricity.png',
      },
      {
        'name': 'Animal Control',
        'image': 'assets/images/animal.png',
      },
    ];
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
          'Complaint',
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
        padding: const EdgeInsets.only(left: 8, right: 8, top: 20),
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildSquareButton(
                onPressed: () => Navigator.push(
                    context,
                    CupertinoPageRoute(
                        builder: (context) => const PostComplaintScreen(
                            isCustomComplaint: true))),
                icon: Icons.edit_rounded,
                label: "Post a complaint",
                color: Colors.deepPurpleAccent,
              ),
              _buildSquareButton(
                onPressed: () => Navigator.push(
                    context,
                    CupertinoPageRoute(
                        builder: (context) => const AllComplaintsScreen())),
                icon: Icons.list_alt_rounded,
                label: "All complaints",
                color: Colors.deepPurpleAccent,
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Text(
            'Report Issues',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2),
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: issuesList.length,
            itemBuilder: (context, index) {
              return InkWell(
                onTap: () => Navigator.push(
                    context,
                    CupertinoPageRoute(
                        builder: (context) => PostComplaintScreen(
                            title: issuesList[index]['name']))),
                borderRadius: BorderRadius.circular(30),
                child: GlassContainer(
                  color1: Colors.deepPurpleAccent,
                  color2: Colors.deepPurpleAccent.shade200,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Image.asset(
                        issuesList[index]['image']!,
                        width: 80,
                      ),
                      Text(
                        issuesList[index]['name']!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSquareButton({
    required Function() onPressed,
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        minimumSize: const Size(140, 80), // Square shape
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 28, color: Colors.white),
          const SizedBox(height: 4),
          Text(label,
              style: const TextStyle(color: Colors.white, fontSize: 14)),
        ],
      ),
    );
  }
}
