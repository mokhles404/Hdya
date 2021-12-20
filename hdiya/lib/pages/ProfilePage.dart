

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hdiya/models/user.dart';
import 'package:hdiya/pages/EditProfilePage.dart';
import 'package:hdiya/widgets/HeaderWidget.dart';
import 'package:hdiya/widgets/PostTileWidget.dart';
import 'package:hdiya/widgets/PostWidget.dart';
import 'package:hdiya/widgets/ProgressWidget.dart';
import 'package:hdiya/pages/HomePage.dart';

class ProfilePage extends StatefulWidget {

  final String userprofileid;

    ProfilePage({this.userprofileid}); 
  @override
  _ProfilePageState createState() => _ProfilePageState();
}



class _ProfilePageState extends State<ProfilePage> {

final String currentonlineuserid = currentuser?.id;
bool loading = false;
int countpost = 0;
List<Post> postlist = [];
String postorientation ="grid";
int totalfollowers=0;
int totalfollowing=0;
bool following=false;



void initState() { 
  super.initState();
  getallpost();
  getfollowers();
  getfollowing();
  checkinitfollow();
  }
    getfollowing() async{
      QuerySnapshot querySnapshot = await followingReference.document(widget.userprofileid).collection("usersfollowing").getDocuments();

      setState(() {
              totalfollowing = querySnapshot.documents.length;
            });
    }
    getfollowers() async{
      QuerySnapshot querySnapshot = await followersReference.document(widget.userprofileid).collection("usersfollowers").getDocuments();

      setState(() {
              totalfollowers = querySnapshot.documents.length;
            });
    }

  checkinitfollow() async{
    DocumentSnapshot documentSnapshot = await followersReference.document(widget.userprofileid).collection("usersfollowers").document(currentonlineuserid).get();
    setState(() {
          following =documentSnapshot.exists;
        });
  }

  createProfiletopview(){
    return FutureBuilder(
      future: usersReference.document(widget.userprofileid).get(),
      builder: (context,datasnapshot){
        if( !datasnapshot.hasData){
          return circularProgress();
        }
        User user =User.fromDocument(datasnapshot.data);
        return Padding(padding: EdgeInsets.all(17.0), 
        child:  Column(
          children: [
            Row(
              children: [
                
                          ClipOval(
            child: Image.network(user.url,
              width: 90,
              height: 90,
              fit: BoxFit.fill,
            )
            ),
            Expanded(
              flex: 1,
              child: Column(
                children: [
                  Padding(padding: EdgeInsets.only(top: 13)),
                  Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      createcolum("Post",countpost),
                      createcolum("Followers",totalfollowers),
                      createcolum("Following",totalfollowing),
                    ],
                  ),
                   Row(
                     
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      createbutton(),
                    ],

                  ),
                  
                ],
              ),
            )
            
              ],
            ), 
             Container(
              alignment: Alignment.centerLeft ,
              padding: EdgeInsets.only(top: 20.0),
              child: Text(
                "${user.profileName}",
                style: TextStyle(fontSize: 18.0,color: Colors.black),
              ),
            ),
            Container(
              alignment: Alignment.centerLeft ,
              padding: EdgeInsets.only(top: 7.0),
              child: Text(
                "${user.username}",
                style: TextStyle(fontSize: 14.0,color: Colors.black),
              ),
            ),
           
            Container(
              alignment: Alignment.centerLeft ,
              padding: EdgeInsets.only(top: 3.0),
              child: Text(
                "${user.bio}",
                style: TextStyle(fontSize: 14.0,color: Colors.black),
              ),
            ),
          ],
        ),
        );
      },
    );

  }


  createbutton(){
    bool selfprofile = currentonlineuserid == widget.userprofileid ;
     if(selfprofile) {
       return createfunctionbutton(title:"Edit Profile" , performFunction :edituserprofile) ;
     } 
     else if(following){
       return createfunctionbutton(title:"Unfollow" , performFunction :unfollowuser) ;
     }
     else if (!following){
       return createfunctionbutton(title:"Follow" , performFunction :followuser) ;

     }
  }

    followuser(){
      setState(() {
          following=true;
        });

      followersReference.document(widget.userprofileid).collection("usersfollowers").document(currentonlineuserid).setData({

      });

      followingReference.document(currentonlineuserid).collection("usersfollowing").document(widget.userprofileid).setData({

      });

      activityFeedReference.document(widget.userprofileid).collection("feeditems").document(currentonlineuserid).setData({
        "type":"follow",
          "ownerId":widget.userprofileid,
          "username":currentuser.username,
          "timestamp":DateTime.now(),
          "userprofileimg":currentuser.url,
          "userId":currentonlineuserid

      });
    }
  unfollowuser(){
    setState(() {
          following=false;
        });

        followersReference.document(widget.userprofileid).collection("usersfollowers").document(currentonlineuserid).get().then((document){
          if(document.exists){
            document.reference.delete();
          }
        });
        followingReference.document(currentonlineuserid).collection("usersfollowing").document(widget.userprofileid).get().then((document){
          if(document.exists){
            document.reference.delete();
          }
        });
        activityFeedReference.document(widget.userprofileid).collection("feeditems").document(currentonlineuserid).get().then((document) {
          if(document.exists){
            document.reference.delete();
          }
        });
        
  }
createfunctionbutton ({String title , Function performFunction }){

      return Container(
        padding: EdgeInsets.only(top: 3.0),
        child: FlatButton(
          onPressed: performFunction,
          child: Container(
            margin: EdgeInsets.only(top: 20),
            width: MediaQuery.of(context).size.width*0.55,
            height: 30.0,
            child: Text(title , style: TextStyle(color: Colors.grey[300], fontWeight: FontWeight.bold),
          ),
          alignment: Alignment.center,
          decoration: BoxDecoration(color:  Color(0xff7e57fe) , border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(8.0)

        )
        )));
}
edituserprofile(){
Navigator.push(context, MaterialPageRoute(builder: (context) =>EditProfilePage(currentonlineuserid: currentonlineuserid)));


}

  Column  createcolum(String title , int count ,){

    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment:MainAxisAlignment.center,
      children: [
        Text(count.toString(),
        style: TextStyle( fontSize: 20.0,color: Colors.black ,fontWeight: FontWeight.bold ),
        ),
        Container(
          margin: EdgeInsets.only(top: 5.0),
          child: Text(
            title,
            style: TextStyle( fontSize: 16.0,color: Colors.grey ,fontWeight: FontWeight.w400 ),

          ),
        )

      ],
    );

}


createlistandgridpostorientation(){

  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceEvenly,

    children: [
      IconButton(icon: Icon(Icons.grid_on), 
      onPressed: ()=>setorientatio("grid"),
      color: postorientation == "grid" ? Colors.black :Colors.grey,
      ),
      IconButton(icon: Icon(Icons.list), 
      onPressed: ()=>setorientatio("list"),
      color: postorientation == "list" ? Colors.black :Colors.grey,
      ),
  ],);
}
setorientatio(String orientation){
  setState(() {
      this.postorientation= orientation;
    });
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: header(context,title: "Profile"),
      body: ListView(
        children: [
          createProfiletopview(),
          Divider(),
          createlistandgridpostorientation(),
          Divider(height: 0.0,),
          ProfilePost(),
        ],

      ),
    );
  }

ProfilePost(){
  if(loading) { return circularProgress();}
  else if (postlist.isEmpty){
    return Container(
      child: Column(
        mainAxisAlignment:MainAxisAlignment.center,
        children: [
          Padding(padding: EdgeInsets.all(30.0 ),
          child:Icon(Icons.photo_library, color: Colors.pinkAccent,size: 120.0,),
                    ),
          Padding(padding: EdgeInsets.only(top: 0.0),
          child: Text("No post yet", style: TextStyle(color: Colors.pinkAccent, fontSize: 40.0, fontWeight: FontWeight.bold ,fontFamily: "lobster"),),
          )
      ],
      ),
    );
      
  }
    else if (postorientation =="grid"){
      
      List<GridTile> gridetitle = [];

      postlist.forEach((element) { 

          gridetitle.add(GridTile(child: PostTile(element)));

      });
      return GridView.count(
        crossAxisCount: 3,
        childAspectRatio: 1.0,
        mainAxisSpacing: 1.5 ,
        crossAxisSpacing: 1.5,
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        children: gridetitle,
        
        );


    }
    else if (postorientation =="list"){
      return Column( 
    children: postlist,
  );
    }

  
  

}

getallpost()async{
  setState(() {
      loading=true;
    });

      QuerySnapshot querySnapshot = await postsReference.document(widget.userprofileid).collection("usersposts").orderBy("timestamp",descending: true).getDocuments();
      setState(() {
              loading=false;
              countpost= querySnapshot.documents.length;  
              postlist = querySnapshot.documents.map((e) => Post.fromDocument(e)).toList();
            });

}

}
