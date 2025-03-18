import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../helper/api.dart';
import '../models/organization_model.dart';
import '../screens/tabs/post/create_post_screen.dart';
import '../utils/utils.dart';
import 'carousel_image.dart';
import 'expandable_text.dart';
import 'post_icon_button.dart';

class PostCard extends StatelessWidget {
  final Map<String, dynamic> tweetData;
  final dynamic userData;
  final VoidCallback onUpvote;
  final bool isReply;

  const PostCard({
    super.key,
    required this.tweetData,
    required this.userData,
    required this.onUpvote,
    this.isReply = false,
  });

  @override
  Widget build(BuildContext context) {
    final upVotes = List<String>.from(tweetData['upVotes'] ?? []);
    final replies = List<String>.from(tweetData['replyIds'] ?? []);
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
                      Flexible(
                        child: Text(
                          userData.name,
                          style: const TextStyle(
                            fontSize: 16,
                            overflow: TextOverflow.ellipsis,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 4),
                      if (userData is OrganizationModel &&
                          userData.isDocVerified)
                        const Icon(
                          Icons.verified_rounded,
                          size: 17,
                          color: Colors.deepPurpleAccent,
                        ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          '@${userData.username}',
                          style: const TextStyle(
                            fontSize: 15,
                            color: Colors.grey,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                      Text(
                        Utils.formatTimeAgo(tweetData['created_at']),
                        style: const TextStyle(
                          fontSize: 15,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  if (isReply)
                    FutureBuilder(
                        future: APIs.getUserInfo(tweetData['receiverId']),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const SizedBox();
                          }
                          final tweetUser = snapshot.data!;
                          return RichText(
                              text: TextSpan(
                            text: 'Replying to ',
                            style: TextStyle(
                                color: Theme.of(context).colorScheme.secondary),
                            children: [
                              TextSpan(
                                text: '@${tweetUser.username}',
                                style: const TextStyle(
                                    color: Colors.deepPurpleAccent),
                              )
                            ],
                          ));
                        }),
                  ExpandableText(text: tweetData['message']),
                  CarouselImage(
                      imageLinks: List<String>.from(tweetData['imagesLink'])),
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
                        PostIconButton(
                          onPressed: () => Navigator.push(
                              context,
                              CupertinoPageRoute(
                                  builder: (context) => CreatePostScreen(
                                        userId: userData.id,
                                        tweetId: tweetData['id'],
                                      ))),
                          text: replies.length.toString(),
                          icon: CupertinoIcons.text_bubble,
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                        PostIconButton(
                          onPressed: onUpvote,
                          text: upVotes.length.toString(),
                          icon: Icons.arrow_circle_up_rounded,
                          color: userHasUpvoted
                              ? Colors.green
                              : Theme.of(context).colorScheme.secondary,
                        ),
                        PostIconButton(
                          onPressed: () => APIs.openGoogleMap(
                              double.parse(tweetData['latitude']),
                              double.parse(tweetData['longitude'])),
                          text: '',
                          icon: Icons.location_on_outlined,
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                        PostIconButton(
                          onPressed: () {},
                          text: '',
                          icon: Icons.share_outlined,
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                      ],
                    ),
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
