import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../helper/api.dart';
import '../../../models/organization_model.dart';
import '../../../widgets/expandable_text.dart';
import 'edit_profile_screen.dart';
import 'my_posts_screen.dart';
import 'my_upvoted_screen.dart';

class ProfileScreen extends StatefulWidget {
  final String userId;

  const ProfileScreen({super.key, required this.userId});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder(
          stream: APIs.getUserStream(widget.userId),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                  child: CircularProgressIndicator(
                      color: Colors.deepPurpleAccent));
            }
            if (snapshot.hasError) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.error, color: Colors.red, size: 50),
                    const SizedBox(height: 10),
                    Text(
                      'Something went wrong!\n${snapshot.error}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.red, fontSize: 16),
                    ),
                  ],
                ),
              );
            }
            if (!snapshot.hasData || snapshot.data == null) {
              return const Center(
                child: Text(
                  'No user found!',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              );
            }
            final user = snapshot.data;
            bool isFollowing = user.followers.contains(APIs.me.id);
            return NestedScrollView(
              headerSliverBuilder: (context, innerBoxIsScrolled) {
                return [
                  SliverAppBar(
                    leading: IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      tooltip: 'Back',
                      color: Colors.white,
                      icon: const Icon(CupertinoIcons.chevron_back),
                    ),
                    expandedHeight: 150,
                    floating: true,
                    snap: true,
                    flexibleSpace: Stack(
                      children: [
                        Container(color: Colors.deepPurpleAccent),
                        const Positioned(
                          left: 8,
                          bottom: 4,
                          child: CircleAvatar(
                            backgroundImage:
                                AssetImage('assets/images/avatar.png'),
                            radius: 45,
                          ),
                        ),
                        Container(
                          alignment: Alignment.bottomRight,
                          margin: const EdgeInsets.only(bottom: 4, right: 8),
                          child: OutlinedButton(
                            onPressed: () async {
                              if (user.id == APIs.me.id) {
                                Navigator.push(
                                    context,
                                    CupertinoPageRoute(
                                        builder: (context) =>
                                            const EditProfileScreen()));
                              } else {
                                await APIs.toggleFollow(user.id);
                              }
                            },
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.white,
                              side: const BorderSide(color: Colors.white),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                            ),
                            child: Text(user.id == APIs.me.id
                                ? 'Edit Profile'
                                : isFollowing
                                    ? 'Following'
                                    : 'Follow'),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.all(8),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        Row(
                          children: [
                            Expanded(
                              child: Row(
                                children: [
                                  Flexible(
                                    child: Text(
                                      user.name,
                                      style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      maxLines: 1,
                                    ),
                                  ),
                                  if (user is OrganizationModel &&
                                      user.isDocVerified) ...[
                                    const SizedBox(width: 4),
                                    const Icon(
                                      Icons.verified_rounded,
                                      size: 20,
                                      color: Colors.deepPurpleAccent,
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            IconButton(
                              onPressed: () {},
                              tooltip: 'Chat',
                              icon: const Icon(CupertinoIcons.chat_bubble_text),
                            ),
                          ],
                        ),
                        Text(
                          '@${user.username}',
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const ExpandableText(
                          text:
                              'Lorem ipsum dolor sit amet. Non incidunt eaque sed cupiditate consequatur sed aliquam laborum ex doloremque dolore id placeat consequatur nam odio architecto ut autem perspiciatis. Est fuga omnis est quas reiciendis rem sapiente repellendus a harum omnis. Et enim ipsam vel nemo natus et vero quis eos expedita quidem qui repellendus nesciunt ut ipsam enim qui voluptate omnis.',
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                color: Theme.of(context)
                                    .colorScheme
                                    .primaryContainer,
                              ),
                              child: Row(
                                children: [
                                  Text(
                                    user.followers.length.toString(),
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    user.followers.length == 1
                                        ? 'Follower'
                                        : 'Followers',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 30),
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                color: Theme.of(context)
                                    .colorScheme
                                    .primaryContainer,
                              ),
                              child: Row(
                                children: [
                                  Text(
                                    user.following.length.toString(),
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  const Text(
                                    'Following',
                                    style: TextStyle(
                                        fontSize: 16, color: Colors.grey
                                        // fontWeight: FontWeight.bold,
                                        ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ]),
                    ),
                  ),
                ];
              },
              body: const DefaultTabController(
                length: 2,
                child: Column(
                  children: [
                    TabBar(
                      dividerHeight: .3,
                      dividerColor: Colors.grey,
                      labelColor: Colors.deepPurpleAccent,
                      indicatorColor: Colors.deepPurpleAccent,
                      unselectedLabelColor: Colors.grey,
                      labelStyle: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                      tabs: [
                        Tab(text: 'Posts'),
                        Tab(text: 'Upvoted'),
                      ],
                    ),
                    Expanded(
                      child: TabBarView(
                        children: [
                          MyPostsScreen(),
                          MyUpvotedScreen(),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
    );
  }
}
