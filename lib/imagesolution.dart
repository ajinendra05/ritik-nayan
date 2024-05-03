import 'dart:convert';

import 'package:flutter/material.dart';
import './Modal/revisedpost.dart';
import 'package:http/http.dart' as http;
import './Modal/post.dart';
import 'config.dart';

class imagesolution extends StatefulWidget {
  const imagesolution({Key? key}) : super(key: key);

  @override
  State<imagesolution> createState() => _imagesolutionState();
}

class _imagesolutionState extends State<imagesolution> {
  Future<List<Revisedpost>> postsFuture = getApiData();

  static Future<List<Revisedpost>> getApiData() async {
    final url = psychologist;
    final uri = Uri.parse(url);
    final response = await http.post(uri);

    
    var body = jsonDecode(response.body);
    return revisedpostFromJson(body);
    
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: FutureBuilder<List<Revisedpost>>(
          future: postsFuture,
          builder: (context, snapshot){
            if(snapshot.connectionState == ConnectionState.waiting){
              return const CircularProgressIndicator();
            }else if (snapshot.hasData){
              final posts = snapshot.data!;
              return buildPosts(posts);
            } else{
              return const Text("No data found");
            }
          },
        ),
      ),

    );
  }


  Widget buildPosts(List<Revisedpost> posts){
    return ListView.builder(
      itemCount: posts.length,
        itemBuilder: (context, index){
        final post = posts[index];
        return Container(
          color: Colors.orange,
        );
        });
  }
}
