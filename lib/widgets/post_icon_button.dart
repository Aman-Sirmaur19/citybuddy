import 'package:flutter/material.dart';

class PostIconButton extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color color;
  final VoidCallback? onPressed;

  const PostIconButton({
    Key? key,
    required this.icon,
    required this.text,
    required this.color,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
          ),
          child: IconButton(
            onPressed: onPressed,
            padding: EdgeInsets.zero,
            icon: Icon(icon),
            color: color,
          ),
        ),
        Text(
          text,
          style: TextStyle(fontSize: 14, color: color),
        ),
      ],
    );
  }
}
