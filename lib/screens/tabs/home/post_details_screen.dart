import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

import '../../../helper/api.dart';
import '../../../models/post_model.dart';
import '../../../widgets/post_card.dart';
import '../../../widgets/custom_text_field.dart';

class PostDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> tweetData;
  final dynamic userData;
  final VoidCallback onUpvote;

  const PostDetailsScreen({
    super.key,
    required this.tweetData,
    this.userData,
    required this.onUpvote,
  });

  @override
  State<PostDetailsScreen> createState() => _PostDetailsScreenState();
}

class _PostDetailsScreenState extends State<PostDetailsScreen> {
  final TextEditingController _replyController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            onPressed: () => Navigator.of(context).pop(),
            tooltip: 'Back',
            icon: const Icon(CupertinoIcons.chevron_back),
          ),
          centerTitle: true,
          title: const Text('Post'),
        ),
        body: FutureBuilder(
            future: APIs.getAllTweets(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                    child: CircularProgressIndicator(
                        color: Colors.deepPurpleAccent));
              }
              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(child: Text('No replies found.'));
              }
              List<Map<String, dynamic>> tweets = snapshot.data!
                  .map((doc) => doc.data() as Map<String, dynamic>)
                  .where((tweet) =>
                      widget.tweetData['replyIds'].contains(tweet['id']))
                  .toList();
              return Padding(
                padding: const EdgeInsets.only(
                  left: 10,
                  right: 10,
                  bottom: 4,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: ListView(
                        physics: const BouncingScrollPhysics(),
                        children: [
                          StreamBuilder<DocumentSnapshot>(
                              stream:
                                  APIs.getTweetStream(widget.tweetData['id']),
                              builder: (context, tweetSnapshot) {
                                if (!tweetSnapshot.hasData ||
                                    !tweetSnapshot.data!.exists) {
                                  return const SizedBox();
                                }
                                final tweetDatas = tweetSnapshot.data!.data()
                                    as Map<String, dynamic>;
                                return PostCard(
                                  tweetData: tweetDatas,
                                  userData: widget.userData,
                                  onUpvote: widget.onUpvote,
                                );
                              }),
                          if (tweets.isNotEmpty)
                            const Text(
                              'Replies',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ListView.builder(
                              shrinkWrap: true,
                              itemCount: tweets.length,
                              physics: const NeverScrollableScrollPhysics(),
                              itemBuilder: (context, index) {
                                return FutureBuilder(
                                    future: APIs.getUserInfo(
                                        tweets[index]['senderId']),
                                    builder: (context, userSnapshot) {
                                      if (!userSnapshot.hasData) {
                                        return const Center(
                                          child: CircularProgressIndicator(
                                              color: Colors.deepPurpleAccent),
                                        );
                                      }
                                      final userData = userSnapshot.data!;
                                      return StreamBuilder<DocumentSnapshot>(
                                          stream: APIs.getTweetStream(
                                              tweets[index]['id']),
                                          builder: (context, tweetSnapshot) {
                                            if (!tweetSnapshot.hasData ||
                                                !tweetSnapshot.data!.exists) {
                                              return const SizedBox();
                                            }
                                            final tweetData =
                                                tweetSnapshot.data!.data()
                                                    as Map<String, dynamic>;
                                            return PostCard(
                                              tweetData: tweetData,
                                              userData: userData,
                                              onUpvote: () =>
                                                  APIs.toggleUpvoteForPost(
                                                      tweetData['id']),
                                              isReply: true,
                                            );
                                          });
                                    });
                              }),
                        ],
                      ),
                    ),
                    // CustomTextField(
                    //   controller: _replyController,
                    //   keyboardType: TextInputType.multiline,
                    //   hintText: 'Reply',
                    //   prefixIcon: IconButton(
                    //     onPressed: () {},
                    //     padding: EdgeInsets.zero,
                    //     icon: const Icon(CupertinoIcons.photo_on_rectangle),
                    //   ),
                    //   suffixIcon: IconButton(
                    //     onPressed: () {
                    //       if (_replyController.text.trim().isEmpty) {
                    //         return;
                    //       }
                    //       PostModel post = PostModel(
                    //         id: const Uuid().v4(),
                    //         createdAt: DateTime.now().toString(),
                    //         senderId: APIs.user.uid,
                    //         receiverId: widget.userData.id,
                    //         latitude: '',
                    //         longitude: '',
                    //         message: _replyController.text.trim(),
                    //         isReplied: true,
                    //         upVotes: [],
                    //         replyIds: [],
                    //         imagesLink: [],
                    //       );
                    //       APIs.replyPost(post, widget.tweetData['id'])
                    //           .then((value) {
                    //         _replyController.clear();
                    //       });
                    //     },
                    //     padding: EdgeInsets.zero,
                    //     icon: const Icon(CupertinoIcons.arrow_turn_up_right),
                    //   ),
                    // ),
                  ],
                ),
              );
            }),
      ),
    );
  }
}
