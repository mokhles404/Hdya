import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hdiya/models/user.dart';
import 'package:hdiya/widgets/HeaderWidget.dart';
import 'package:hdiya/widgets/PostWidget.dart';
import 'package:hdiya/widgets/ProgressWidget.dart';
import 'package:hdiya/pages/HomePage.dart';


class TimeLinePage extends StatefulWidget {

    final User gCurrentUser;

  TimeLinePage({this.gCurrentUser});

  @override
  _TimeLinePageState createState() => _TimeLinePageState();
}

class _TimeLinePageState extends State<TimeLinePage> {
  List<Post> posts=[];
  List<String> followingsList = [];
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  Post postt;


  @override
  void initState() {
    super.initState();
    getpost();
    
  }

   getfollowing() async
  {
    QuerySnapshot querySnapshot = await followingReference.document(currentuser.id).collection("usersfollowing").getDocuments();
    
    setState(() {
      followingsList = querySnapshot.documents.map((document) => document.documentID).toList();
    });
   
  }

  getpost()  async{
   await getfollowing();
   print("folowingg "+followingsList.length.toString());
  List<Post> followingpost=[];
    followingsList.forEach((followingid) async {
     QuerySnapshot querySnapshot = await postsReference.document(followingid).collection("usersposts").getDocuments();
        print("mmmmmmmMMMMMMMMMMMMMMMMMMMMMM");
      querySnapshot.documents.forEach((element) {
        // print("\n\n\n");
        // print(element.data.toString());
              print("bbbbbbbbbbbbbbbbbbbbbbbbbbbbb");
        postt = Post.fromDocument(element);
              print("kkkkkkkkkkkkkkkkkkkkkkk");
        print(postt.username);
              print("jjjjjjjjjjjjjjjjjjjjjjjjj");
        followingpost.add( Post.fromDocument(element));
      });
                         print("aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa");
     print("taille followig   "+followingpost.length.toString());
     setState(() {
            this.posts=followingpost;
          });


     });
     print("taille followig baraaa   "+followingpost.length.toString());



     
    
  }



//   gettimeline() async{

//     QuerySnapshot querySnapshot = await timelineReference.document(widget.gCurrentUser.id).collection("timelinePosts").orderBy("timestamp",descending: true).getDocuments();
//       List<Post> allPosts = querySnapshot.documents.map((document) => Post.fromDocument(document)).toList();
//  setState(() {
//       this.posts = allPosts;
//     });
//   }


  
  createUserTimeLine()
  {
    if(posts == null)
    {
      return circularProgress();
    }
    else if (posts.isEmpty){
      return notimeline();
    }
    else
    {
      return ListView(children: posts,);
    }
  }

  notimeline(){

    return Container(
      padding: EdgeInsets.all(17.0),
      alignment: Alignment.center,
      child: Text("No Post Yet \n\n  search for your Freinds   ",style: TextStyle(fontSize: 30.0,color: Colors.grey[800] ,fontWeight: FontWeight.bold),textAlign: TextAlign.center,),
    );
  }

  @override
  Widget build(context) { 
    return Scaffold(
      key: _scaffoldKey,
      appBar: header(context, isapptitle: true,),
      body: RefreshIndicator(child: createUserTimeLine(), onRefresh: () => getpost()),
    );
  }
}
