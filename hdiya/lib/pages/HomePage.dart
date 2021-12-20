
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:hdiya/models/user.dart';
import 'package:hdiya/pages/CreateAccountPage.dart';
import 'package:hdiya/pages/NotificationsPage.dart';
import 'package:hdiya/pages/ProfilePage.dart';
import 'package:hdiya/pages/SearchPage.dart';
import 'package:hdiya/pages/TimeLinePage.dart';
import 'package:hdiya/pages/UploadPage.dart';


final GoogleSignIn gSingIn = GoogleSignIn();
final usersReference =  Firestore.instance.collection("users");
final postsReference =  Firestore.instance.collection("posts");
final activityFeedReference =  Firestore.instance.collection("feed");
final commentsReference =  Firestore.instance.collection("comments");
final followersReference =  Firestore.instance.collection("followers");
final followingReference =  Firestore.instance.collection("following");
final timelineReference =  Firestore.instance.collection("timeline");
final StorageReferences = FirebaseStorage.instance.ref().child("Posts Pictures");


final DateTime timestamp= DateTime.now();
User currentuser;



class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

bool isSignedIn =false;
PageController pageController ;
int pageindex = 0 ;

void initState() { 
  super.initState();
  pageController =PageController();
  gSingIn.onCurrentUserChanged.listen((gsignInAccount) {
    controlsingin(gsignInAccount);
  },onError: (e)
  {print("Error message"+e.toString());
  });


  gSingIn.signInSilently(suppressErrors: false).then((gsignInAccount)  {
        controlsingin(gsignInAccount);
  }).catchError((e)
  {print("Error message"+e.toString());
  });
}


controlsingin(GoogleSignInAccount signInAccount)async
{
  if(signInAccount != null){
    await saveUserInfoToFireStore();
    setState(() {
          isSignedIn = true;
        });
  }
  else{
    setState(() {
          isSignedIn=false;
        });
  }}

saveUserInfoToFireStore() async{
  final GoogleSignInAccount gCurrentUser = gSingIn.currentUser;
  DocumentSnapshot documentSnapshot = await usersReference.document(gCurrentUser.id).get();
    if(!documentSnapshot.exists){
      final username = await Navigator.push(context, MaterialPageRoute(builder: (context)=>CreateAccountPage()));
    
    usersReference.document(gCurrentUser.id).setData(
      {
        "id":gCurrentUser.id,
        "profileName":gCurrentUser.displayName,
        "username":username.trim().toLowerCase() ,
        "url":gCurrentUser.photoUrl,
        "email":gCurrentUser.email,
        "bio":"",
        "timestamp":timestamp
      }
    );
    documentSnapshot= await usersReference.document(gCurrentUser.id).get();
    }

currentuser = User.fromDocument(documentSnapshot); 

}


 void dispose() { 
   pageController.dispose();
   super.dispose();
 }

// ignore: non_constant_identifier_names
LoginUser(){
  gSingIn.signIn();
}
// ignore: non_constant_identifier_names
LogoutUser(){
  gSingIn.signOut();
}
// ignore: non_constant_identifier_names
WhenPageChange(int index){
  setState(() {
this.pageindex=index;
      
    });
}
onpagebarchange(int index){
  pageController.animateToPage(
    index, duration: Duration(milliseconds: 400), curve: Curves.bounceInOut) ;

}

Widget buildHomeScreen(){
  return Scaffold(
    body: PageView(
      children: [
        TimeLinePage(gCurrentUser: currentuser),
        SearchPage(),
        UploadPage(gCurrentUser: currentuser,),
        NotificationsPage(),
                // RaisedButton.icon(onPressed: LogoutUser, icon: Icon(Icons.close), label: Text("Sing Out")),

        ProfilePage(userprofileid:currentuser.id),

      ],
      controller: pageController,
      onPageChanged: WhenPageChange,
      physics: NeverScrollableScrollPhysics(),
    ),
    bottomNavigationBar: CupertinoTabBar(
      currentIndex: pageindex, 
      onTap: onpagebarchange,
      activeColor: Colors.purple[600],
      inactiveColor: Colors.black87,
      backgroundColor: Colors.pink[50],
      items: [
        BottomNavigationBarItem(icon: Icon(Icons.home)),
        BottomNavigationBarItem(icon: Icon(Icons.search)),
        BottomNavigationBarItem(icon: Icon(Icons.camera, size: 37.0,)),
        BottomNavigationBarItem(icon: Icon(Icons.favorite)),
        BottomNavigationBarItem(icon: Icon(Icons.person)),
      ],
    ),
  );
    // return RaisedButton.icon(onPressed: LogoutUser, icon: Icon(Icons.close), label: Text("Sing Out"));
}
// ignore: non_constant_identifier_names
Widget HomeBuildScreen(){

  return Text("home page");
}

// ignore: non_constant_identifier_names
Scaffold SingInScreen(){
  return Scaffold(
    backgroundColor: Colors.amber,

    body: Container(
      padding: EdgeInsets.only(top: 0),
      margin:EdgeInsets.all(0),

      decoration: BoxDecoration(
       gradient: LinearGradient(
colors: [
Colors.blue[900],
Color.fromRGBO(83, 184, 187, 1),
Colors.teal
],
begin: AlignmentDirectional.topStart,
end: AlignmentDirectional.bottomEnd)
      ),
      alignment: Alignment.center,
      child: Column(
        
        mainAxisAlignment:MainAxisAlignment.center,
          crossAxisAlignment:CrossAxisAlignment.center,
        children: <Widget>[
          Text("SingIn or SingUp ",
          textAlign: TextAlign.left,
          style: TextStyle(fontSize:36.0,color: Colors.black87, fontWeight: FontWeight.bold, fontFamily: "Lobster"),
          ),
          Text("                                   With your Google Account",
          textAlign: TextAlign.right,
          style: TextStyle(fontSize:19.0,color: Colors.black54, fontWeight: FontWeight.w400, fontFamily: "Lobster"),
          ),
          SizedBox(height: 55,),
           GestureDetector(
             onTap: 
               LoginUser,
             child: Container(
               width: 220.0,
               height: 65.0,
               decoration: BoxDecoration(
                 image: DecorationImage(
                   image: AssetImage("assets/google.png"),
                   fit:BoxFit.fill
                 )
               ),
             ),
           )

      ],),
    ),
  );
}



  @override
  Widget build(BuildContext context) {

    if (isSignedIn) {
          return buildHomeScreen();

    } else {
          return SingInScreen();

    }

  }
}
