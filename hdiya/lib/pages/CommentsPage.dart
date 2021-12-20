

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hdiya/pages/HomePage.dart';
import 'package:timeago/timeago.dart' as  tago ;
import 'package:hdiya/widgets/HeaderWidget.dart';
import 'package:hdiya/widgets/ProgressWidget.dart';

class CommentsPage extends StatefulWidget {

  final String url;
  final String ownerId;
  final String postId;

  CommentsPage({this.postId,this.ownerId,this.url});

  @override
  CommentsPageState createState() => CommentsPageState(url: url,ownerId: ownerId,postId: postId);
}

class CommentsPageState extends State<CommentsPage> {

  final String url;
  final String ownerId;
  final String postId;
  TextEditingController commentController=TextEditingController();


  CommentsPageState({this.postId,this.ownerId,this.url});

showcomment(){
  return StreamBuilder(
    stream: commentsReference.document(postId).collection("comments").orderBy("timestamp",descending: false).snapshots(),
    builder: (context,datasnapshot){
      if (!datasnapshot.hasData){ return circularProgress();}

      List<Comment> comments =[];
        datasnapshot.data.documents.forEach((document){

          comments.add(Comment.fromDocument(document));
        });

        return ListView(
          children: comments,
        );

    },
  );
}

savecomment(){
  commentsReference.document(postId).collection("comments").add({
    "username":currentuser.username,
    "comment":commentController.text,
    "timestamp":DateTime.now(),
    "url":currentuser.url,
    "userId":currentuser.id
  });

bool notpostowner = ownerId != currentuser.id;
if(notpostowner){
  activityFeedReference.document(ownerId).collection("feeditems").add({
    "type":"comment",
    "commenttext":commentController.text,
    "postId":postId,
    "userId":currentuser.id,
    "username":currentuser.username,
    "userprofileimg":currentuser.url,
    "url":url,
    "timestamp":timestamp,

  });
}
  commentController.clear();
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: header(context,title: "Comments"),
      body: Column(
        children: [
          Expanded(
            child: showcomment(),
          ),
          Divider(),
          ListTile(
            title: TextFormField(
              controller: commentController ,
              decoration: InputDecoration(
                labelText: "Write Comment Here",
                labelStyle: TextStyle(color: Colors.black),
                enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
                focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.purple)),
              ),
              style: TextStyle(color: Colors.black),
               ),
               trailing: OutlineButton(
                 onPressed: savecomment,
                  borderSide: BorderSide.none,
                  child: Text("Publish",style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),),
               ),
          )
        ],
      ),
    );
  }
}

class Comment extends StatelessWidget {

  final String username;
  final String userId;
  final String url ;
  final String comment ;
  final Timestamp timestamp ;
  Comment({this.username,this.comment,this.url,this.userId,this.timestamp});

  factory Comment.fromDocument(DocumentSnapshot documentSnapshot){
    return Comment(
      username: documentSnapshot["username"],
      userId: documentSnapshot["userId"],
      url: documentSnapshot["url"],
      comment: documentSnapshot["comment"],
      timestamp: documentSnapshot["timestamp"],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(padding: EdgeInsets.only(bottom: 6.0)
    ,child: Container(
      color: Color(0xff272262),
      child: Column(
        children: [
          ListTile(
            title: Text(username + ":   \t "+comment,style: TextStyle(fontSize: 18.0,color:Colors.white),),
            leading:ClipOval(
            child: Image.network(url,
              width: 50,
              height: 50,
              fit: BoxFit.fill,
            )
            ),
            subtitle: Text(tago.format(timestamp.toDate()),style: TextStyle(color: Colors.white60 ,fontSize: 11.0) ,),
          )
        ],
      ),
    ),

    );
  }
}
