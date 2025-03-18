import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';

import '../../../helper/api.dart';
import '../../../providers/filter_provider.dart';
import '../../../widgets/post_card.dart';
import 'post_details_screen.dart';

class AcrossIndiaScreen extends StatefulWidget {
  const AcrossIndiaScreen({super.key});

  @override
  State<AcrossIndiaScreen> createState() => _AcrossIndiaScreenState();
}

class _AcrossIndiaScreenState extends State<AcrossIndiaScreen> {
  Future<List<DocumentSnapshot>>? _futureTweets;

  @override
  void initState() {
    super.initState();
    _futureTweets = APIs.getAllTweets();
  }

  Future<void> _refreshData() async {
    setState(() {
      _futureTweets = APIs.getAllTweets();
    });
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
        backgroundColor: Colors.deepPurpleAccent,
        onRefresh: _refreshData,
        child: FutureBuilder(
            future: _futureTweets,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                    child: CircularProgressIndicator(
                        color: Colors.deepPurpleAccent));
              }
              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(child: Text('No posts found.'));
              }
              final filterProvider = Provider.of<FilterProvider>(context);
              List<Map<String, dynamic>> tweets = snapshot.data!
                  .map((doc) => doc.data() as Map<String, dynamic>)
                  .where((tweet) => tweet['isReplied'] == false)
                  .toList();
              if (filterProvider.filterType == 'latest') {
                tweets.sort((a, b) => DateTime.parse(b['created_at'])
                    .compareTo(DateTime.parse(a['created_at'])));
              } else if (filterProvider.filterType == 'most_upvoted') {
                tweets.sort((a, b) =>
                    (b['upVotes'].length).compareTo(a['upVotes'].length));
              } else if (filterProvider.filterType == 'most_viewed') {
                tweets.sort((a, b) =>
                    (b['upVotes'].length + b['replyIds'].length)
                        .compareTo(a['upVotes'].length + a['replyIds'].length));
              }
              return ListView.builder(
                padding: const EdgeInsets.only(left: 10, right: 10, top: 20),
                physics: const BouncingScrollPhysics(),
                itemCount: tweets.length,
                itemBuilder: (context, index) {
                  return FutureBuilder(
                      future: APIs.getUserInfo(tweets[index]['senderId']),
                      builder: (context, userSnapshot) {
                        if (!userSnapshot.hasData) {
                          return const SizedBox();
                        }
                        final userData = userSnapshot.data!;
                        return StreamBuilder<DocumentSnapshot>(
                            stream: APIs.getTweetStream(tweets[index]['id']),
                            builder: (context, tweetSnapshot) {
                              if (!tweetSnapshot.hasData ||
                                  !tweetSnapshot.data!.exists) {
                                return const SizedBox();
                              }
                              final tweetData = tweetSnapshot.data!.data()
                              as Map<String, dynamic>;
                              return InkWell(
                                onTap: () => Navigator.push(
                                    context,
                                    CupertinoPageRoute(
                                        builder: (context) => PostDetailsScreen(
                                          tweetData: tweetData,
                                          userData: userData,
                                          onUpvote: () =>
                                              APIs.toggleUpvoteForPost(
                                                  tweetData['id']),
                                        ))),
                                borderRadius: BorderRadius.circular(10),
                                child: PostCard(
                                  tweetData: tweetData,
                                  userData: userData,
                                  onUpvote: () =>
                                      APIs.toggleUpvoteForPost(tweetData['id']),
                                ),
                              );
                            });
                      });
                },
              );
            }));
  }
}
