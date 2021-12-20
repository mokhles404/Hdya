import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:hdiya/models/user.dart';
import 'package:hdiya/pages/HomePage.dart';
import 'package:hdiya/widgets/ProgressWidget.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import 'package:image/image.dart' as Imd;

class UploadPage extends StatefulWidget {

final User gCurrentUser;

  UploadPage({this.gCurrentUser});

  @override
  _UploadPageState createState() => _UploadPageState();
}



class _UploadPageState extends State<UploadPage> with AutomaticKeepAliveClientMixin<UploadPage> {
  File file;
  bool uploading =false ; 
  String postid = Uuid().v4();
  TextEditingController descriptioncontroller = TextEditingController();
  TextEditingController locationcontroller = TextEditingController(); 

// ignore: non_constant_identifier_names
TakePicturewithcamera() async {
  Navigator.pop(context);
  File imagefile = await ImagePicker.pickImage(
    source: ImageSource.camera,
    maxHeight: 680,
    maxWidth: 970,

  );
  setState(() {

      this.file =imagefile;
    });

}



// ignore: non_constant_identifier_names
TakePicturefromgalery  () async{
   Navigator.pop(context);
  File imagefile = await ImagePicker.pickImage(
    source: ImageSource.gallery,
   

  );
  setState(() {

      this.file =imagefile;
    });

}

takeImage(mcontext){
    return showDialog(context: mcontext, builder: (context){

      return SimpleDialog(
        
        title:  Text("New Post",style: TextStyle(color: Colors.purple, fontWeight: FontWeight.bold), textAlign: TextAlign.center,),
        children: [
                    SizedBox(height: 12,),
          SimpleDialogOption(
            child: Text("Capture Image With camera ",style: TextStyle( color: Colors.white), textAlign: TextAlign.center,),
            onPressed: TakePicturewithcamera,
          ),
          SizedBox(height: 5,),
          SimpleDialogOption(
            child: Text("Select Image From Galery  ",style: TextStyle( color: Colors.white), textAlign: TextAlign.center,),
            onPressed: TakePicturefromgalery,
          ),
                    SizedBox(height: 12,),

          SimpleDialogOption(
            child: Text(" Cancel ",style: TextStyle( color: Colors.red), textAlign: TextAlign.center,),
            onPressed: ()=>Navigator.pop(context),
          ),
                    SizedBox(height: 3,),

        ],
      ) ;
    });

  }


  

uploadScreen(){
   return Container(
       child: Column(
       mainAxisAlignment: MainAxisAlignment.center,
       children: [
         Icon(Icons.add_photo_alternate, size: 150,),
         Padding(
           padding: EdgeInsets.only(top: 30.0),
           child: Container(
             height: 50,
             width: 180,
             child: RaisedButton(
               shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
               child: Text("Upload Image", style: TextStyle(color: Colors.black87 , fontSize: 20.0),),
               color: Colors.deepPurpleAccent,
               onPressed: ()=>takeImage(context),
               
               ),
           ),
         )
       ],
     ),
   );
}

clearpostInfo(){
  locationcontroller.clear();
    descriptioncontroller.clear();
  setState(() {
      file = null;
    });
}

getcurrentlocation() async{
  Position position = await Geolocator().getCurrentPosition(desiredAccuracy:LocationAccuracy.high);
  List<Placemark> placemarks = await Geolocator().placemarkFromCoordinates(position.latitude , position.longitude);
  Placemark mplacemark = placemarks[0];
  String specificAddress='${mplacemark.locality} ${mplacemark.country}';
  locationcontroller.text= specificAddress;
  

}

compressphoto() async{
final tempdirectctory = await getTemporaryDirectory();
final path = tempdirectctory.path; 
Imd.Image  mImageFile= Imd.decodeImage(file.readAsBytesSync());
final  compressimagefile=File('$path/img_$postid.jpg')..writeAsBytesSync(Imd.encodeJpg(mImageFile, quality: 60));

setState(() {
  
  file = compressimagefile;

});


}
Future<String> uploadphoto(mImageFile) async{
    // StorageUploadTask mstorageUploadTask = StorageReference.
  StorageUploadTask mstorageUploadTask = StorageReferences.child("post_$postid.jpg").putFile(mImageFile);
  StorageTaskSnapshot mstorageTaskSnapshot = await mstorageUploadTask.onComplete;
  String downloadURL = await mstorageTaskSnapshot.ref.getDownloadURL();
  return downloadURL;
  
}

savePostInfoToFirestore( {String url, String location , String description}){
postsReference.document(widget.gCurrentUser.id).collection("usersposts").document(postid).setData({
  "postId":postid,
  "ownerId":widget.gCurrentUser.id,
  "timestamp":DateTime.now(),
  "likes":{},
  "username":widget.gCurrentUser.username,
  "description":description,
  "location":location,
  "url":url
});

}

uploadandsave() async{
  setState(() {
      uploading = true;
    });

    await compressphoto();
    String downloadurl= await uploadphoto(file);

    savePostInfoToFirestore(url:downloadurl,location:locationcontroller.text,description:descriptioncontroller.text);
    locationcontroller.clear();
    descriptioncontroller.clear();
    setState(() {
          file = null;
          uploading=false;
          postid=Uuid().v4();
        });
}

formScreen(){

  return Scaffold(
    appBar: AppBar(
      backgroundColor: Colors.grey[300],
      leading: IconButton(icon:  Icon(Icons.arrow_back,color: Colors.black,), onPressed:  clearpostInfo,),
      title: Text(" New Post " ,style: TextStyle(fontSize: 24.0,color: Colors.black,fontWeight: FontWeight.bold),),
      actions: [
        FlatButton(
          onPressed:uploadandsave
        , child: Text("Share",style: TextStyle(color: Colors.purple[300], fontWeight: FontWeight.bold, fontSize: 16.0),)
        )
      ],
    ),
    body: ListView(
      children: [ 
        uploading ? linearProgress() : Text(""),
        Container(
          height: 250.0,
          padding: EdgeInsets.only(top: 10),
          margin: EdgeInsets.symmetric(horizontal: 10),
          width: MediaQuery.of(context).size.width*0.8,
          child: Center(child: AspectRatio(aspectRatio: 1.3,
          child: Container(
           
            decoration: BoxDecoration(
              image: DecorationImage(image: FileImage(file),fit: BoxFit.fill)
            ),
          ),
          ),),
        ),
        Padding(padding: EdgeInsets.only(top: 20.0)),
        ListTile(
          leading: ClipOval(
  child: Image.network( widget.gCurrentUser.url ,
    width: 60,
    height: 100,
    fit: BoxFit.cover,
  ),
),
title: Container(
  width: 250.0,
  child: TextField(
    style: TextStyle(color: Colors.black),
    controller: descriptioncontroller,
    decoration: InputDecoration(
      hintText: "Write somthing about your image",
      hintStyle: TextStyle(color: Colors.black),
      border: InputBorder.none,
    ),
  ),
),
        ),
        Divider(),
               ListTile(
          leading:Icon(Icons.person_pin_circle , color: Colors.black, size: 36.0,),
title: Container(
  width: 250.0,
  child: TextField(
    style: TextStyle(color: Colors.black),
    controller: locationcontroller,
    decoration: InputDecoration(
      hintText: "Write your location here",
      hintStyle: TextStyle(color: Colors.black),
      border: InputBorder.none,
    ),
  ),
),
        ),
        Container(
          width: 220.0,
          height: 110.0,
          alignment: Alignment.center,
          child: RaisedButton.icon(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(35.0)),
            color: Colors.green,
            icon: Icon(Icons.location_on ,color: Colors.white,),
            label: Text("Get my curent location", style: TextStyle(color: Colors.black),) ,
            onPressed: getcurrentlocation,
            
          ),
        )

      ],
    ),

  );
}


bool get wantKeepAlive =>true;






  @override
  Widget build(BuildContext context) {
    return file == null ? uploadScreen() : formScreen();
  }
}
