import 'package:flutter/material.dart';

import '../helper/api.dart';
import '../main.dart';
import '../models/message_model.dart';
import '../utils/my_date_util.dart';

// for showing single message details
class MessageCard extends StatefulWidget {
  final MessageModel message;

  const MessageCard({super.key, required this.message});

  @override
  State<MessageCard> createState() => _MessageCardState();
}

class _MessageCardState extends State<MessageCard> {
  @override
  Widget build(BuildContext context) {
    return APIs.user.uid == widget.message.fromId
        ? _greenMessage()
        : _blueMessage();
  }

  // sender or another user message
  Widget _blueMessage() {
    // update last read message if sender and receiver are different
    if (widget.message.read.isEmpty) {
      APIs.updateMessageStatus(widget.message);
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Container(
            padding: EdgeInsets.all(mq.width * .03),
            margin: EdgeInsets.symmetric(
                horizontal: mq.width * .03, vertical: mq.height * .01),
            decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                border: Border.all(color: Colors.deepPurpleAccent),
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(30),
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                )),
            child: Text(
              widget.message.msg,
              style: TextStyle(
                  fontSize: 15, color: Theme.of(context).colorScheme.secondary),
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.only(right: mq.width * .03),
          child: Text(
            MyDateUtil.getFormattedTime(
                context: context, time: widget.message.sent),
            style: const TextStyle(fontSize: 10, color: Colors.black54),
          ),
        ),
      ],
    );
  }

  // our or user message
  Widget _greenMessage() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Padding(
          padding: EdgeInsets.only(left: mq.width * .03),
          child: Row(
            children: [
              // sent time
              Text(
                MyDateUtil.getFormattedTime(
                    context: context, time: widget.message.sent),
                style: const TextStyle(fontSize: 10, color: Colors.black54),
              ),
              const Text(' '),

              // double tick blue icon for message read
              if (widget.message.read.isNotEmpty)
                const Icon(Icons.done_all_rounded,
                    size: 15, color: Colors.green),
            ],
          ),
        ),
        Flexible(
          child: Container(
            padding: EdgeInsets.all(mq.width * .03),
            margin: EdgeInsets.symmetric(
                horizontal: mq.width * .03, vertical: mq.height * .01),
            decoration: BoxDecoration(
                color: Colors.deepPurpleAccent,
                border: Border.all(color: Colors.deepPurpleAccent),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                  bottomLeft: Radius.circular(30),
                )),
            child: Text(
              widget.message.msg,
              style: const TextStyle(fontSize: 15, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }
}
