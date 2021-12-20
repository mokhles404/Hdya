import 'dart:async';

import 'package:flutter/material.dart';
import 'package:hdiya/widgets/HeaderWidget.dart';

class CreateAccountPage extends StatefulWidget {
  @override
  _CreateAccountPageState createState() => _CreateAccountPageState();
}

class _CreateAccountPageState extends State<CreateAccountPage> {
  final _scafoldkey=GlobalKey<ScaffoldState>();
  final _formkey=GlobalKey<FormState>();
  String username ;

  submitusername(){
    final form =_formkey.currentState;
    if(form.validate()){
      form.save();
      SnackBar snackBar =SnackBar(content: Text(" Welcome  "+ username));
      _scafoldkey.currentState.showSnackBar(snackBar);
      Timer(Duration(seconds: 4), (){
        Navigator.pop(context,username);
      });
    }

  }
  @override
  Widget build(BuildContext parentContext) {
    return Scaffold(
      key: _scafoldkey,
      appBar: header(context,title: "Settings",disablebackbutton: true),
      body: ListView(
        children: [
          Container(
            child: Column(
              children: [
                Padding(
                      padding: EdgeInsets.only(top:26.0),
                      child: Center(child: Text("Your UserName Please", style: TextStyle(fontSize: 26.0),)),
                        ),
                Padding(padding: EdgeInsets.all(17.0),
                      child:Container(
                        child: Form(
                          key: _formkey ,
                          autovalidate: true,
                          child: TextFormField(
                            style: TextStyle(color: Colors.black),
                            validator: (val){
                              if(val.trim().length<5|| val.isEmpty){
                                return "UserName is very short";
                              }
                              else if(val.trim().length>15|| val.isEmpty){
                                return "UserName is very long";
                              }
                              else {
                                return null ;
                              }
                            },
                            onSaved: (val)=>username = val,
                            decoration: InputDecoration(
                              enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color:Colors.grey)
                              ),
                              focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.black87)),
                              border: OutlineInputBorder(),
                              labelText: "UserName",
                              labelStyle: TextStyle(fontSize: 16.0),
                              hintText: "must be at least 5 characters",
                              hintStyle: TextStyle(color: Colors.grey)

                            ),
                          ),
                        ),

                      )
                      ),
                      GestureDetector(
                        onTap: submitusername,
                        child: Container(
                          height: 55.0,
                          width: 350.0,
                          decoration: BoxDecoration(color: Colors.green ,borderRadius: BorderRadius.circular(8.0)),
                          child: Center(child: Text(
                            "Submit" ,
                            style: TextStyle(color: Colors.black87 , fontSize: 16.0, fontWeight: FontWeight.bold),
                          ),),
                        ),
                      )
                      
                      
              ],
            ),
          )
        ],
      ),
    );
  }
}
