import 'package:flutter/material.dart';

AppBar header(context,{bool isapptitle=false,String title,disablebackbutton=false}) {
  return AppBar(
    iconTheme: IconThemeData(color: Colors.purple[600]),
    automaticallyImplyLeading: disablebackbutton ? false : true,
    title: Text(
      isapptitle ? "Hdya" : title,
      style: TextStyle(
        color: isapptitle ? Colors.deepPurple:Color(0xff7e57fe) ,
        fontFamily: isapptitle ? "selena": "lobster",
        fontSize:  isapptitle ? 27.0 : 32.0
      ),
      overflow: TextOverflow.ellipsis,
    ),
    centerTitle: true,
    backgroundColor: Colors.grey[300],
  );
}
