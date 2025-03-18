import 'package:flutter/material.dart';

import '../helper/api.dart';
import '../models/complaint_model.dart';
import '../models/organization_model.dart';
import '../utils/utils.dart';
import 'carousel_image.dart';
import 'expandable_text.dart';
import 'post_icon_button.dart';

class ComplaintCard extends StatefulWidget {
  final Map<String, dynamic> complaintData;
  final dynamic userData;
  final VoidCallback onUpvote;
  final bool isAdmin;

  const ComplaintCard({
    super.key,
    required this.complaintData,
    required this.userData,
    required this.onUpvote,
    this.isAdmin = false,
  });

  @override
  State<ComplaintCard> createState() => _ComplaintCardState();
}

class _ComplaintCardState extends State<ComplaintCard> {
  late String complaintStatus;

  @override
  void initState() {
    super.initState();
    complaintStatus = widget.complaintData['complaintStatus'] ??
        ComplaintStatus.pending.toString();
  }

  void _updateComplaintStatus(String status) async {
    try {
      await APIs.updateComplaintStatus(widget.complaintData['id'], status);
      setState(() {
        complaintStatus = status; // Update the UI in real time
      });
    } catch (e) {
      print("Error updating status: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final upVotes = List<String>.from(widget.complaintData['upVotes'] ?? []);
    final replies = List<String>.from(widget.complaintData['replyIds'] ?? []);
    final userHasUpvoted = upVotes.contains(APIs.auth.currentUser!.uid);
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              margin: const EdgeInsets.all(8),
              child: const CircleAvatar(
                backgroundImage: AssetImage('assets/images/avatar.png'),
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        widget.userData.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 4),
                      if (widget.userData is OrganizationModel &&
                          widget.userData.isDocVerified)
                        const Icon(
                          Icons.verified_rounded,
                          size: 17,
                          color: Colors.deepPurpleAccent,
                        ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          '@${widget.userData.username}',
                          style: const TextStyle(
                            fontSize: 15,
                            color: Colors.grey,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                      Text(
                        Utils.formatTimeAgo(widget.complaintData['created_at']),
                        style: const TextStyle(
                          fontSize: 15,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  ExpandableText(text: widget.complaintData['complaint']),
                  CarouselImage(
                      imageLinks: List<String>.from(
                          widget.complaintData['imagesLink'])),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Text(
                        'Receiver:',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          widget.complaintData['receiverEmail'],
                          style: const TextStyle(
                            fontSize: 15,
                            color: Colors.grey,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Text(
                        'Status:',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        decoration: BoxDecoration(
                          color: complaintStatus ==
                                  ComplaintStatus.pending.toString()
                              ? Colors.orange
                              : complaintStatus ==
                                      ComplaintStatus.resolved.toString()
                                  ? Colors.green
                                  : Colors.red,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          complaintStatus == ComplaintStatus.pending.toString()
                              ? 'Pending'
                              : complaintStatus ==
                                      ComplaintStatus.resolved.toString()
                                  ? 'Resolved'
                                  : 'Rejected',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        PostIconButton(
                          onPressed: null,
                          text: (upVotes.length + replies.length).toString(),
                          icon: Icons.bar_chart_rounded,
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                        // PostIconButton(
                        //   onPressed: () => Navigator.push(
                        //       context,
                        //       CupertinoPageRoute(
                        //           builder: (context) =>
                        //               const CreatePostScreen())),
                        //   text: replies.length.toString(),
                        //   icon: CupertinoIcons.text_bubble,
                        //   color: Theme.of(context).colorScheme.secondary,
                        // ),
                        PostIconButton(
                          onPressed: widget.onUpvote,
                          text: upVotes.length.toString(),
                          icon: Icons.arrow_circle_up_rounded,
                          color: userHasUpvoted
                              ? Colors.green
                              : Theme.of(context).colorScheme.secondary,
                        ),
                        PostIconButton(
                          onPressed: () => APIs.openGoogleMap(
                              double.parse(widget.complaintData['latitude']),
                              double.parse(widget.complaintData['longitude'])),
                          text: '',
                          icon: Icons.location_on_outlined,
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                        // PostIconButton(
                        //   onPressed: () {},
                        //   text: '',
                        //   icon: Icons.share_outlined,
                        //   color: Theme.of(context).colorScheme.secondary,
                        // ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ElevatedButton(
                        onPressed: () => _updateComplaintStatus(
                            ComplaintStatus.pending.toString()),
                        style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            minimumSize: const Size(50, 40),
                            foregroundColor:
                                Theme.of(context).colorScheme.secondary,
                            backgroundColor: Colors.orange,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12))),
                        child: const Text('Pending'),
                      ),
                      ElevatedButton(
                        onPressed: () => _updateComplaintStatus(
                            ComplaintStatus.resolved.toString()),
                        style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            minimumSize: const Size(50, 40),
                            foregroundColor:
                                Theme.of(context).colorScheme.secondary,
                            backgroundColor: Colors.green,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12))),
                        child: const Text('Resolved'),
                      ),
                      ElevatedButton(
                        onPressed: () => _updateComplaintStatus(
                            ComplaintStatus.rejected.toString()),
                        style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            minimumSize: const Size(50, 40),
                            foregroundColor:
                                Theme.of(context).colorScheme.secondary,
                            backgroundColor: Colors.red,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12))),
                        child: const Text('Rejected'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        const Divider(
          thickness: .3,
          color: Colors.grey,
        ),
      ],
    );
  }
}
