import 'package:flutter/material.dart';

circularProgress() {
  return Container(
    alignment: Alignment.center,
    padding: EdgeInsets.only(top: 13.0),
    child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation(Colors.lightBlue),),
  );
}

linearProgress() {
 return Container(
    alignment: Alignment.center,
    padding: EdgeInsets.only(top: 13.0),
    child: LinearProgressIndicator(valueColor: AlwaysStoppedAnimation(Colors.lightBlue),),
  );
}
