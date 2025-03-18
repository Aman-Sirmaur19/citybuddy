import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../helper/api.dart';
import '../../widgets/complaint_card.dart';

class AdminPanel extends StatelessWidget {
  const AdminPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          tooltip: 'Back',
          icon: const Icon(CupertinoIcons.chevron_back),
        ),
        centerTitle: true,
        title: const Text(
          'Admin Panel',
          style: TextStyle(fontSize: 18),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.only(left: 10, right: 10, top: 10),
        child: FutureBuilder(
          future: APIs.getAllComplaints(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child:
                    CircularProgressIndicator(color: Colors.deepPurpleAccent),
              );
            }
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text('No complaints found.'));
            }

            List<Map<String, dynamic>> complaints = snapshot.data!
                .map((doc) => doc.data() as Map<String, dynamic>)
                .where((complaint) =>
                    complaint['receiverEmail'] == APIs.user.email)
                .toList();

            // ✅ Check if complaints list is empty
            if (complaints.isEmpty) {
              return const Center(child: Text('No complaints found.'));
            }

            return ListView.builder(
              itemCount: complaints.length, // ✅ Fix: Add itemCount
              itemBuilder: (context, index) {
                return FutureBuilder(
                  future: APIs.getUserInfo(complaints[index]['senderId']),
                  builder: (context, userSnapshot) {
                    if (!userSnapshot.hasData) {
                      return const SizedBox();
                    }
                    final userData = userSnapshot.data!;
                    return ComplaintCard(
                      complaintData: complaints[index],
                      userData: userData,
                      onUpvote: () {},
                    );
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }
}
