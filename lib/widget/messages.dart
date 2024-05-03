import 'message_bubble.dart';
import 'package:flutter/material.dart';

class Messages extends StatelessWidget {
  Messages({super.key});
  List<Map<String, String>> chatdata = [
    {
      'userName': "AR",
      'text': "name batao",
      'userId': '1',
    },
    {
      'userName': "BR",
      'text': "Ajinendra rajpoot",
      'userId': '2',
    },
    {
      'userName': "AR",
      'text': "name batao",
      'userId': '1',
    },
    {
      'userName': "AR",
      'text': "name batao",
      'userId': '1',
    },
    {
      'userName': "BR",
      'text': "name batao",
      'userId': '2',
    }
  ];
  @override
  Widget build(BuildContext context) {
    // final user = FirebaseAuth.instance.currentUser;
    // final stream = FirebaseFirestore.instance
    //     .collection('chat')
    //     .orderBy('createAt', descending: true)
    //     .snapshots();
    //   return StreamBuilder(
    //     stream: stream,
    //     builder: (context, snapshot) {
    //       if (snapshot.connectionState == ConnectionState.waiting) {
    //         return const Center(
    //           child: CircularProgressIndicator(),
    //         );
    //       }
    //       final chatdata = snapshot.data!.docs;
    //       return ListView.builder(
    //         reverse: true,
    //         itemCount: chatdata.length,
    //         itemBuilder: (context, index) {
    //           return MessageBubble(
    //             userName: chatdata[index]['userName'],
    //             message: chatdata[index]['text'],
    //             isMe: chatdata[index]['userId'] == user!.uid,
    //           );
    //         },
    //       );
    //     },
    //   );
    // }

    return ListView.builder(
      reverse: true,
      itemCount: chatdata.length,
      itemBuilder: (context, index) {
        return MessageBubble(
          userName: chatdata[index]['userName']!,
          message: chatdata[index]['text']!,
          isMe: chatdata[index]['userId'] == '1',
        );
      },
    );
  }
}
