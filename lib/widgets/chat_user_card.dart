import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../helper/api.dart';
import '../main.dart';
import '../models/message_model.dart';
import '../screens/dashboard/profile/chat_screen.dart';
import '../utils/my_date_util.dart';

class ChatUserCard extends StatefulWidget {
  final dynamic user;

  const ChatUserCard({super.key, required this.user});

  @override
  State<ChatUserCard> createState() => _ChatUserCardState();
}

class _ChatUserCardState extends State<ChatUserCard> {
  // last message info (if null --> show no message)
  MessageModel? _message;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: mq.width * .03, vertical: 4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      color: Theme.of(context).colorScheme.primary,
      elevation: 1,
      child: InkWell(
          borderRadius: BorderRadius.circular(15),

          // for navigating to chat screen
          onTap: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => ChatScreen(user: widget.user)));
          },
          child: StreamBuilder(
              stream: APIs.getLastMessages(widget.user),
              builder: (context, snapshot) {
                final data = snapshot.data?.docs;
                final list = data
                        ?.map((e) => MessageModel.fromJson(e.data()))
                        .toList() ??
                    [];
                if (list.isNotEmpty) {
                  _message = list[0];
                }

                return ListTile(
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(mq.height * .025),
                    child: CachedNetworkImage(
                      width: mq.height * .05,
                      height: mq.height * .05,
                      imageUrl: widget.user.imageUrl,
                      // placeholder: (context, url) => const CircularProgressIndicator(),
                      errorWidget: (context, url, error) => const CircleAvatar(
                          backgroundColor: Colors.grey,
                          child: Icon(CupertinoIcons.person)),
                    ),
                  ),
                  title: Text(widget.user.name),
                  subtitle: Text(
                    _message != null
                        ? _message!.msg
                        : '@${widget.user.username}',
                    maxLines: 1,
                    style: const TextStyle(color: Colors.grey),
                  ),
                  trailing: _message == null
                      ? const SizedBox()
                      : _message!.read.isEmpty &&
                              _message!.fromId != APIs.user.uid
                          ? const Icon(Icons.circle,
                              color: Colors.green, size: 10)
                          : Text(
                              MyDateUtil.getLastMessageTime(
                                  context: context, time: _message!.sent),
                              style: const TextStyle(color: Colors.grey),
                            ),
                );
              })),
    );
  }
}
