import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';

class MessageBubble extends StatelessWidget {
  final String message;
  final bool isMe;
  final String userName;
  const MessageBubble(
      {super.key,
      required this.message,
      required this.isMe,
      required this.userName});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment:
          isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        // Padding(
        //   padding: const EdgeInsets.only(left: 10, right: 10),
        //   child: Text(
        //     userName,
        //     style: const TextStyle(
        //       fontWeight: FontWeight.bold,
        //     ),
        //   ),
        // ),
        Container(
          width: MediaQuery.of(context).size.width * 0.6,
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
          margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
          decoration: BoxDecoration(
            color: isMe
                ? Color.fromARGB(179, 200, 198, 198)
                : Theme.of(context).colorScheme.secondary.withOpacity(0.8),
            borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(12),
                topRight: const Radius.circular(12),
                bottomLeft:
                    isMe ? const Radius.circular(12) : const Radius.circular(0),
                bottomRight: isMe
                    ? const Radius.circular(0)
                    : const Radius.circular(12)),
          ),
          child: Column(
            children: [
              Text(message),
            ],
          ),
        ),
      ],
    );
  }
}
