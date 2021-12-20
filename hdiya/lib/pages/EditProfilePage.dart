import 'package:cloud_firestore/cloud_firestore.dart';
import "package:flutter/material.dart";
import 'package:hdiya/models/user.dart';
import 'package:hdiya/pages/HomePage.dart';
import 'package:hdiya/widgets/ProgressWidget.dart';

class EditProfilePage extends StatefulWidget {
  final String currentonlineuserid;
  EditProfilePage({this.currentonlineuserid});
  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {

  
  TextEditingController profilenamecontroller = TextEditingController();
  TextEditingController biocontroller = TextEditingController(); 
  final _scaffoldGlobalKey = GlobalKey<ScaffoldState>();
  bool loading=false;
  User user ;
  bool _biovalid= true;
  bool _profilenamevalid= true;

  void initState() { 
    super.initState();
    displayuserinformation();
  }

displayuserinformation() async{
  setState(() {
      loading=true;

    });

    DocumentSnapshot documentSnapshot = await usersReference.document(widget.currentonlineuserid).get();
    user = User.fromDocument(documentSnapshot);

    profilenamecontroller.text = user.profileName;
    biocontroller.text = user.bio;


    setState(() {
          loading= false;
        });

}

  updatedata(){
    setState(() {
          profilenamecontroller.text.trim().length <3 || profilenamecontroller.text.trim().length >15|| profilenamecontroller.text.trim().isEmpty ? _profilenamevalid = false : _profilenamevalid =true;
     biocontroller.text.trim().length >110 ? _biovalid = false : _biovalid =true;
     });

     if(_biovalid && _profilenamevalid){
       usersReference.document(widget.currentonlineuserid).updateData({
         "profileName":profilenamecontroller.text,
         "bio":biocontroller.text
       });
        }

        SnackBar successnakebar = SnackBar(content: Text("Profile Has been Updated successfully"));

        _scaffoldGlobalKey.currentState.showSnackBar(successnakebar);
  }
  
ProfileNametextfield(){  
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Padding(padding: EdgeInsets.only(top: 13.0),
      child: Text("Profile Name",style: TextStyle(color:Colors.blueAccent),),
      ),
      TextField(
        controller: profilenamecontroller,
        style: TextStyle(color: Colors.black),
        decoration: InputDecoration(
          hintText: "Write Profile Name here...",
          enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.black)),
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.purple)
          ),
          hintStyle: TextStyle(color: Colors.grey),
          errorText: _profilenamevalid ? null :"Profile Name is very short"
        ),
      ),
      
    ],
  );
}
  
biotextfield(){
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Padding(padding: EdgeInsets.only(top: 13.0),
      child: Text("Your Bio",style: TextStyle(color:Colors.blueAccent),),
      ),
      TextField(
        controller: biocontroller,
        style: TextStyle(color: Colors.black),
        decoration: InputDecoration(
          hintText: "Write Your Bio Here...",
          enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.black)),
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.purple)
          ),
          hintStyle: TextStyle(color: Colors.grey),
          errorText: _biovalid ? null :"Bio is very Long"
        ),
      )
    ],
  );
}


logoutuser() async{
   await gSingIn.signOut();
   Navigator.push(context, MaterialPageRoute(builder: (context)=>HomePage()));

}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key:_scaffoldGlobalKey,
      appBar: AppBar(
        backgroundColor: Colors.grey[300],
        iconTheme: IconThemeData(color: Colors.black87),
        title: Text("Edite Profile",style: TextStyle(color: Colors.blueGrey[800]),),
        actions: [
          IconButton(icon: Icon(Icons.done),color:  Color(0xff00b4b1),onPressed:()=> Navigator.pop(context))
        ],
      ),
      body: loading ?  circularProgress(): ListView(
        children: [
          Container(
            
            child: Column(
               children: [
                 Container(
                   
                   padding: EdgeInsets.only(top: 16.0,bottom: 7.0),
                   child:ClipOval(
                            child: Image.network( user.url ,
                              width: 100,
                              height: 100,
                              fit: BoxFit.fill,
                            ),
                          ),

                 ),
                 SizedBox(height: 10,),
                                                           Divider(),                 
                 Padding(padding: EdgeInsets.all(16.0),
                 child:Column(
                   children:[

                     ProfileNametextfield(),
                     SizedBox(height: 15.0,),
                     biotextfield(),
                     Padding(padding: EdgeInsets.only(top: 50.0 ,left: 50.0, right: 50.0),
                        child: RaisedButton(
                          color: Color(0xff00b4b1),
                          child: Text("         Update         ",
                          style: TextStyle(color:Colors.black, fontSize: 16.0),
                          ),
                          onPressed: updatedata,
                        ),),
                        Padding(padding: EdgeInsets.only(top: 10.0 ,left: 50.0, right: 50.0),
      child: RaisedButton(
        color: Color(0xffff8185),
        child: Text("        Logout      ",
        style: TextStyle(color:Colors.black, fontSize: 14.0),
        ),
        onPressed: logoutuser,
      ),)
                   ]

                 )

                 ),
               ],
            ),
          ),
        ],

      ),
    );
  }
}
