import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hdiya/models/user.dart';
import 'package:hdiya/pages/HomePage.dart';
import 'package:hdiya/pages/ProfilePage.dart';
import 'package:hdiya/widgets/ProgressWidget.dart';

class SearchPage extends StatefulWidget {

  
  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> with AutomaticKeepAliveClientMixin<SearchPage> {

    TextEditingController searchtextcontroller = TextEditingController();
    Future<QuerySnapshot> searchresult;


  controllsearching(String str){
    print("namesearchging   "+str);
    Future<QuerySnapshot> alluser = usersReference.where("username",isGreaterThanOrEqualTo: str.trim().toLowerCase() ).getDocuments();
    setState(() {
          searchresult = alluser ;

        });
  }

  clearsearchtext(){
    searchtextcontroller.clear();
  }

  AppBar searchheader(){
    return AppBar(
        backgroundColor: Colors.white,
      title: TextFormField(
        style: TextStyle(
          fontSize: 18.0, color: Colors.black87
        ),
        controller: searchtextcontroller,
        decoration: InputDecoration(
          hintText: "Search here ...",
          hintStyle: TextStyle(color: Colors.black),
          enabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.black)
          ),
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.black38)
          ),
          filled: true ,
          prefixIcon: Icon(Icons.person_pin, color: Colors.indigo,size:  30.0,),
          suffixIcon: IconButton(icon:Icon(Icons.clear , color: Colors.black87),onPressed: clearsearchtext,),
        ),
        onFieldSubmitted: controllsearching,

      ),
    );
  }

nosearchresultscreen (){
  final Orientation orientation =MediaQuery.of(context).orientation;
  return Container(
    child: Center(
      child: ListView(
        shrinkWrap: true,
        children: [
          Icon(Icons.group, color: Colors.indigo,size: 150.0, ),
          Text(
            "Search Users",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.blueGrey[400], fontWeight: FontWeight.w500, fontSize: 45.0 ),
          )
        ],
      ) ,));

  
}

searchresultscreen(){
  return FutureBuilder(
    future: searchresult,
    builder: (context,dataSnapshot){
      if(!dataSnapshot.hasData){
        return circularProgress();
      }
      List<UserResult> searchUsersResult = [];
      dataSnapshot.data.documents.forEach((document){
        User eachuser= User.fromDocument(document);
        print("profile namee    "+eachuser.profileName);
        print("email             "+eachuser.email);
        UserResult userResult = UserResult(eachuser);
        searchUsersResult.add(userResult);
      });
      return ListView(children: searchUsersResult,);
    },
  );
}

bool get wantKeepAlive =>true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(255, 255, 255, 1),
      appBar: searchheader(),
      body: searchresult == null ? nosearchresultscreen() : searchresultscreen(),
    );
  }
}

class UserResult extends StatelessWidget {

  final User eachUser;
  UserResult(this.eachUser);


  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(3.0),
      child: Container(
        color: Colors.white,
        child: Column(children: [
          GestureDetector(
            onTap: ()=>showuserprofile(context,profileId:eachUser.id),
            child: ListTile(
              leading:ClipOval(
  child: Image.network(eachUser.url,
    width: 60,
    height: 100,
    fit: BoxFit.cover,
  ),
),
              // leading: CircleAvatar(backgroundColor: Colors.white ,backgroundImage: Image.network(eachUser.url)),
               title: Text(eachUser.profileName ,
               style: TextStyle( color: Colors.black87, fontSize: 16.0, fontWeight: FontWeight.bold),),
            subtitle: Text(eachUser.username,style:  TextStyle(color: Colors.black, fontSize: 13.0),),
            ),
          )
        ],),
      ),
    );
  }


  showuserprofile(BuildContext context,{String profileId}){

    Navigator.push(context, MaterialPageRoute(builder: (context)=>ProfilePage(userprofileid: profileId,)));
  }
}
