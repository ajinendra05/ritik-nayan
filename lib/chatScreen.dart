import 'package:flutter/material.dart';
import 'package:wellnesswarriors/widget/messages.dart';
import 'package:wellnesswarriors/widget/new_chat.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Chat Screen"), backgroundColor: Colors.cyan,
          // actions: [
          //   DropdownButton(
          //     items: [
          //       DropdownMenuItem(
          //         value: 'logout',
          //         child: Container(
          //           child: Row(
          //             children: const [
          //               Icon(Icons.exit_to_app),
          //               SizedBox(
          //                 width: 8,
          //               ),
          //               Text("Logout")
          //             ],
          //           ),
          //         ),
          //       ),
          //     ],
          //     value: 'logout',
          //     onChanged: (value) {},
          //   )
          // ],
        ),
        body: Container(
          height: 700,
          
          child: Column(
            children: [Expanded(child: Messages()), NewChatField()],
          ),
        ));
  }
}
