import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class ExpandableText extends StatefulWidget {
  final String text;
  final int maxLength;

  const ExpandableText({super.key, required this.text, this.maxLength = 100});

  @override
  State<ExpandableText> createState() => _ExpandableTextState();
}

class _ExpandableTextState extends State<ExpandableText> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    if (widget.text.length <= widget.maxLength) {
      return Text(
        widget.text,
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w300,
          color: Theme.of(context).colorScheme.secondary,
        ),
      );
    }

    return RichText(
      text: TextSpan(
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w300,
          color: Theme.of(context).colorScheme.secondary,
        ),
        children: [
          TextSpan(
            text: _isExpanded
                ? widget.text
                : "${widget.text.substring(0, widget.maxLength)}...",
          ),
          TextSpan(
            text: _isExpanded ? " See Less" : " See More",
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
            recognizer: TapGestureRecognizer()
              ..onTap = () {
                setState(() {
                  _isExpanded = !_isExpanded;
                });
              },
          ),
        ],
      ),
    );
  }
}
