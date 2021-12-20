import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hdiya/models/user.dart';
import 'package:hdiya/pages/CommentsPage.dart';
import 'package:hdiya/pages/HomePage.dart';
import 'package:hdiya/pages/ProfilePage.dart';
import 'package:hdiya/widgets/ProgressWidget.dart';

class Post extends StatefulWidget {
final String url;
final String location;
final String description;
final String username;
final dynamic likes;
final String ownerId;
final String postId;

  Post({ 
    this.postId,
    this.ownerId,
    this.username,
    this.description,
    this.location,
    this.url,
    this.likes 
  });



    factory  Post.fromDocument(DocumentSnapshot documentSnapshot) {
    return Post(
       postId: documentSnapshot["postId"],
        ownerId: documentSnapshot["ownerId"],
        username: documentSnapshot["username"],
        description: documentSnapshot["description"],
        location: documentSnapshot["location"],
        url: documentSnapshot["url"],
        likes: documentSnapshot["likes"],
    );
  }


  int gettotalnumberoflikes(likes){
    if(likes==0) {return 0 ;}
    int counter=0;

    likes.values.forEach((eachvalue){
      if(eachvalue == true){ counter=counter+1;}
    });
      return counter;
  }

  @override
  _PostState createState() => _PostState(
        postId: this.postId,
        ownerId: this.ownerId,
        username: this.username,
        description: this.description,
        location: this.location ,
        url: this.url,   
        likes: this.likes,
        likescount:gettotalnumberoflikes(this.likes)
  );
}

class _PostState extends State<Post> {
  final String url;
final String location;
final String description;
final String username;
Map likes;
final String ownerId;
final String postId;
int likescount;
bool isliked;
bool showheart = false;
final String currentonlineuser= currentuser?.id;

  _PostState({ 
    this.postId,
    this.ownerId,
    this.username,
    this.description,
    this.location,
    this.url,
    this.likes ,
    this.likescount
  });





  @override
  Widget build(BuildContext context) {

    isliked =(likes[currentonlineuser]== true);
    return Padding(
      padding: EdgeInsets.only(bottom: 12.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          PostHeader(),
          PostPicture(),
          PostFooter(),
          
        ],
      ),

    );
  }

  PostHeader(){
    return FutureBuilder(
      future: usersReference.document(ownerId).get(),
      builder: (context,datasnapshot){
        if(!datasnapshot.hasData){ return circularProgress();}
        User user = User.fromDocument(datasnapshot.data);
        bool ispostowner = currentonlineuser ==ownerId;
        return ListTile(
          leading:ClipOval(
            child: Image.network(user.url,
              width: 50,
              height: 50,
              fit: BoxFit.fill,
            )
            ),
            title: GestureDetector(
              onTap: ()=>showuserprofile(context,profileId: user.id),
              child: Text(user.username, style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),)),
            subtitle: Text(location,style: TextStyle(color: Colors.black),),
            trailing: ispostowner ? IconButton(
              icon: Icon(Icons.more_vert,color: Colors.black,),
               onPressed: ()=>deleteownerpost(context)
              ):Text(""),
        ); 
      },
    );
  }

deleteownerpost(BuildContext contextt){
  return showDialog(
    context:contextt
  , builder: (context){
    return SimpleDialog(
      backgroundColor: Color(0xffe5e0d7),
      title: Text("Do you want to delete this post? ",style: TextStyle(color: Colors.blueGrey[900] , fontWeight: FontWeight.bold),),
      children: [
        SimpleDialogOption(
          child: Text("Confirme",style: TextStyle(color: Color(0xff272262) ,fontWeight: FontWeight.bold,fontSize: 18.0),),
          onPressed: ()=>deletePostfromfirebase(context),
        ),
        SimpleDialogOption(
          child: Text("Cancel",style: TextStyle(color: Color(0xff00b4b1) ,fontWeight: FontWeight.bold,fontSize: 18.0,),),
          onPressed: ()=>Navigator.pop(context),
        ),
      ],
    );
  });
}

deletePostfromfirebase(BuildContext contextt) async{

  Navigator.pop(contextt);
  postsReference.document(ownerId).collection("usersposts").document(postId).get().then((doc) {
    if(doc.exists){
      doc.reference.delete();
    }

  });
  StorageReferences.child("post_$postId.jpg").delete();

  QuerySnapshot querySnapshot = await activityFeedReference.document(ownerId).collection("feeditems").where("postId",isEqualTo: postId).getDocuments();

  querySnapshot.documents.forEach((doc) {
    if(doc.exists){
      doc.reference.delete();
    }

  });

  QuerySnapshot commentquery= await commentsReference.document(postId).collection("comments").getDocuments();

  commentquery.documents.forEach((doc) {
    if(doc.exists){
      doc.reference.delete();
    }
  });

}

 showuserprofile(BuildContext context,{String profileId}){

    Navigator.push(context, MaterialPageRoute(builder: (context)=>ProfilePage(userprofileid: profileId,)));
  }
  removelike(){
    bool notpostowner= currentonlineuser!=ownerId;
    if(notpostowner){
      activityFeedReference.document(ownerId).collection("feeditems").document(postId).get().then((document) {
        if(document.exists){
          document.reference.delete();
        }

      });
    }
  }

addlike(){
      bool notpostowner= currentonlineuser!=ownerId;
      if(notpostowner){ 

        activityFeedReference.document(ownerId).collection("feeditems").document(postId).setData({
          "type":"like",
          "username":currentuser.username,
          "userId":currentuser.id,
           "timestamp":DateTime.now(),
           "url":url,
           "postId":postId,
           "userprofileimg": currentuser.url,
          
        });

      }
  
}
controluserlikespost (){
  bool _liked =likes[currentonlineuser] == true  ;

    if(_liked){
      postsReference.document(ownerId).collection("usersposts").document(postId).updateData({"likes.$currentonlineuser":false});
      removelike();
      setState(() {
              likescount=likescount-1;
              isliked=false;
              likes[currentonlineuser]=false;
            });
    }
    else if (!_liked){
      postsReference.document(ownerId).collection("usersposts").document(postId).updateData({"likes.$currentonlineuser":true});
      addlike();
      setState(() {
              likescount=likescount+1;
              isliked=true;
              likes[currentonlineuser]=true;
              showheart =true;

            });
      Timer(Duration(milliseconds: 800),(){
        setState(() {
                  
                  showheart=false;
                });

      });

    }
    
}


  PostPicture(){
    return GestureDetector(
      onDoubleTap: ()=> controluserlikespost(),
      child: Stack(
        children: [
          Image.network(url),
          showheart ? Icon(Icons.favorite,size: 140.0,color: Colors.pink,):Text(""),
        ],
      ),
    );
  }

  PostFooter(){
    return Column(
      children:[ Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Padding(padding: EdgeInsets.only(top: 40.0 , left: 20.0)),
          GestureDetector(
            onTap: ()=>controluserlikespost(),
            child: Icon(
              isliked ? Icons.favorite : Icons.favorite_border,
              // Icons.favorite,
              size: 28.0,
              color: Colors.pink,
            ),
          ),
          Padding(padding: EdgeInsets.only(right: 20.0)),
          GestureDetector(
            onTap: ()=>showcomment(context,postId:postId,ownerId:ownerId,url:url ),
            child: Icon(Icons.chat_bubble_outline, size: 28.0,color: Colors.black, ),
          ),
        ],
      ),
      Row(
        children: [
          Container(
            margin: EdgeInsets.only(left: 20.0),
            child: Text(
              "$likescount Likes",
              style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
            ),
          )
        ],
      ),
      Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: EdgeInsets.only(left: 20.0),
            child:  Text("$username ",style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold),),
          ),
          Expanded(
            child: Text(description, style:TextStyle(color: Colors.black),),
          )
        ],
      )
      ],
    );
  }

showcomment(BuildContext context ,{String postId,String ownerId,String url }){

    Navigator.push(context, MaterialPageRoute(builder: (context){

      return CommentsPage(postId:postId,ownerId:ownerId,url:url);
    }));

    
}

}
