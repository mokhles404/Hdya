import 'package:flutter/material.dart';
import 'package:hdiya/pages/HomePage.dart';
import 'package:hdiya/widgets/HeaderWidget.dart';
import 'package:hdiya/widgets/PostWidget.dart';
import 'package:hdiya/widgets/ProgressWidget.dart';

class PostScreenPage extends StatelessWidget {  

  final String postId;
  final String userId;
  final String postusername;
  PostScreenPage({this.userId,this.postId,this.postusername});


  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: postsReference.document(userId).collection("usersposts").document(postId).get(),
      builder: (context,documentSnapshot){

          if(!documentSnapshot.hasData){

            return circularProgress();
          }

          Post post =Post.fromDocument(documentSnapshot.data);
          return Center(
            child: Scaffold(
              appBar: header(context,title: postusername.toString()),
              body: ListView(

                children: [

                  Container(

                    child: post,
                  )
                ],
              ),
              
              )
              
              ,
          );

      },

    );
  }
}
