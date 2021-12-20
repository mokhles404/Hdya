import 'package:flutter/material.dart';
import 'package:hdiya/pages/PostScreenPage.dart';
import 'package:hdiya/widgets/PostWidget.dart';

class PostTile extends StatelessWidget {


  final Post post ;

  PostTile(this.post);

displayfullpost(context){

  Navigator.push(context, MaterialPageRoute(builder: (context)=>PostScreenPage(postId:post.postId ,userId:post.ownerId,postusername:post.username)));
}

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: ()=>displayfullpost(context),
      child: Image.network(post.url),
    );
  }
}
