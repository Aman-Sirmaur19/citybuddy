import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';

import '../../../../helper/api.dart';
import '../../../../widgets/complaint_card.dart';
import '../../../../providers/filter_provider.dart';
import 'complaint_details_screen.dart';

class MyCityComplaints extends StatefulWidget {
  const MyCityComplaints({super.key});

  @override
  State<MyCityComplaints> createState() => _MyCityComplaintsState();
}

class _MyCityComplaintsState extends State<MyCityComplaints> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: APIs.getAllComplaints(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
                child:
                    CircularProgressIndicator(color: Colors.deepPurpleAccent));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No complaints found.'));
          }
          final filterProvider = Provider.of<FilterProvider>(context);
          List<Map<String, dynamic>> complaints = snapshot.data!
              .map((doc) => doc.data() as Map<String, dynamic>)
              .where((complaint) => complaint['isReplied'] == false)
              .toList();
          if (filterProvider.filterType == 'latest') {
            complaints.sort((a, b) => DateTime.parse(b['created_at'])
                .compareTo(DateTime.parse(a['created_at'])));
          } else if (filterProvider.filterType == 'most_upvoted') {
            complaints.sort(
                (a, b) => (b['upVotes'].length).compareTo(a['upVotes'].length));
          } else if (filterProvider.filterType == 'most_viewed') {
            complaints.sort((a, b) =>
                (b['upVotes'].length + b['replyIds'].length)
                    .compareTo(a['upVotes'].length + a['replyIds'].length));
          }
          return ListView.builder(
            padding: const EdgeInsets.only(left: 10, right: 10, top: 20),
            physics: const BouncingScrollPhysics(),
            itemCount: complaints.length,
            itemBuilder: (context, index) {
              return FutureBuilder(
                  future: APIs.getUserInfo(complaints[index]['senderId']),
                  builder: (context, userSnapshot) {
                    if (!userSnapshot.hasData) {
                      return const SizedBox();
                    }
                    final userData = userSnapshot.data!;
                    return StreamBuilder<DocumentSnapshot>(
                        stream: APIs.getComplaintStream(complaints[index]['id']),
                        builder: (context, complaintSnapshot) {
                          if (!complaintSnapshot.hasData ||
                              !complaintSnapshot.data!.exists) {
                            return const SizedBox();
                          }
                          final complaintData = complaintSnapshot.data!.data()
                              as Map<String, dynamic>;
                          return InkWell(
                            onTap: () => Navigator.push(
                                context,
                                CupertinoPageRoute(
                                    builder: (context) => ComplaintDetailsScreen(
                                          tweetData: complaintData,
                                          userData: userData,
                                          onUpvote: () =>
                                              APIs.toggleUpvoteForPost(
                                                  complaintData['id']),
                                        ))),
                            borderRadius: BorderRadius.circular(10),
                            child: ComplaintCard(
                              complaintData: complaintData,
                              userData: userData,
                              onUpvote: () => APIs.toggleUpvoteForComplaint(
                                  complaintData['id']),
                            ),
                          );
                        });
                  });
            },
          );
        });
  }
}
