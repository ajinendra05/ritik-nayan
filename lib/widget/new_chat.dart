import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';

class NewChatField extends StatefulWidget {
  const NewChatField({super.key});

  @override
  State<NewChatField> createState() => _NewChatFieldState();
}

class _NewChatFieldState extends State<NewChatField> {
  final messageController = TextEditingController();
  var messageInput = '';

  void sendMessage() async {
    FocusScope.of(context).unfocus();

    messageController.clear();
    setState(() {
      messageInput = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.1,
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(8),
      color: Color.fromARGB(255, 101, 226, 243),
      child: Row(
        children: [
          Expanded(
              child: TextField(
            style: TextStyle(color: Colors.black),
            controller: messageController,
            onChanged: (value) {
              setState(() {
                messageInput = value;
              });
            },
            decoration: const InputDecoration(
                label: Text('Type your message'), fillColor: Colors.black),
          )),
          ElevatedButton(
              // style: ,
              onPressed: messageInput.trim().isEmpty ? null : sendMessage,
              child: const Icon(Icons.send))
        ],
      ),
    );
  }
}
