import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hdiya/pages/HomePage.dart';
import 'package:hdiya/pages/ProfilePage.dart';
import 'package:hdiya/widgets/HeaderWidget.dart';
import 'package:timeago/timeago.dart' as tAgo;
import 'package:hdiya/widgets/ProgressWidget.dart';

class NotificationsPage extends StatefulWidget {
  @override
  _NotificationsPageState createState() => _NotificationsPageState();
}


getnotification()async{
QuerySnapshot querySnapshot = await activityFeedReference.document(currentuser.id).collection("feeditems").orderBy("timestamp", descending: true).limit(50).getDocuments();
  List<NotificationsItem> notificationitems=[];

  querySnapshot.documents.forEach((element) {
      notificationitems.add(NotificationsItem.fromdocument(element));

  });

  return notificationitems;
}


class _NotificationsPageState extends State<NotificationsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: header(context,title: "Notification"),
      body:Container(
        child: FutureBuilder(
          future: getnotification(),
           builder: (context, dataSnapshot)
          {
            if(!dataSnapshot.hasData)
            {
              return circularProgress();
            }
            return ListView(children: dataSnapshot.data,);
          },
        ),
      ),
    );
  }
}


String notificationItemText;
Widget mediaPreview;

class NotificationsItem extends StatelessWidget {

  final String username;
  final String type;
  final String commenttext;
  final String postId;
  final String userId;
  final String userprofileimg;
  final String url;
  final Timestamp timestamp;

    NotificationsItem({this.username, this.type, this.commenttext, this.postId, this.userId, this.userprofileimg, this.url, this.timestamp});

factory NotificationsItem.fromdocument(DocumentSnapshot documentSnapshot)
  {
    return NotificationsItem(
      username: documentSnapshot["username"],
      type: documentSnapshot["type"],
      commenttext: documentSnapshot["commenttext"],
      postId: documentSnapshot["postId"],
      userId: documentSnapshot["userId"],
      userprofileimg: documentSnapshot["userprofileimg"],
      url: documentSnapshot["url"],
      timestamp: documentSnapshot["timestamp"],
    );
  }




  @override
  Widget build(BuildContext context) {
   configureMediaPreview(context);

    return Padding(
      padding: EdgeInsets.only(bottom: 2.0),
      child: Container(
        color: Colors.white54,
        child: ListTile(
          title: GestureDetector(
            onTap: ()=> showuserprofile(context, profileId: userId),
            child: RichText(
              overflow: TextOverflow.ellipsis,
              text: TextSpan(
                style: TextStyle(fontSize: 14.0, color: Colors.black),
                children: [
                  TextSpan(text: username, style: TextStyle(fontWeight: FontWeight.bold)),
                  TextSpan(text: " $notificationItemText"),
                ],
              ),
            ),
          ),
          leading: ClipOval(
            child: Image.network(userprofileimg,
              width: 50,
              height: 50,
              fit: BoxFit.fill,
            )
            ),
          subtitle: Text(tAgo.format(timestamp.toDate()), overflow: TextOverflow.ellipsis,),
          trailing: mediaPreview,
        ),
      ),
    );
  }

  configureMediaPreview(context)
  {
    if(type == "comment"  ||  type == "like")
    {
      mediaPreview = GestureDetector(
        onTap: ()=> showownprofileuser(context,),
        child: Container(
          height: 50.0,
          width: 50.0,
          child: AspectRatio(
            aspectRatio: 16/9,
            child: Image.network(url,
              
              fit: BoxFit.fill,
            ),
          ),
        ),
      );
    }
    else
    {
      mediaPreview = Text("");
    }

    if(type == "like")
    {
      notificationItemText = "liked your post.";
    }
    else if(type == "comment")
    {
      notificationItemText = "replied: $commenttext";
    }
    else if(type == "follow")
    {
      notificationItemText = "started following you.";
    }
    else
    {
      notificationItemText = "Error, Unknown type = $type";
    }
  }

  showownprofileuser(BuildContext context)
  {
    Navigator.push(context, MaterialPageRoute(builder: (context) => ProfilePage(userprofileid: currentuser.id)));
  }

   showuserprofile(BuildContext context,{String profileId}){

    Navigator.push(context, MaterialPageRoute(builder: (context)=>ProfilePage(userprofileid: profileId,)));
  }
}
