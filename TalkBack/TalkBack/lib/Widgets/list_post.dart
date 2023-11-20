import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:TalkBack/Models/export_models.dart';
import 'package:TalkBack/Widgets/export_methods.dart';

///Lista de Posts
class ListPostw extends StatefulWidget {
  UserApp userApp;
  ListPostw({Key? key, required this.userApp}) : super(key: key);

  @override
  State<ListPostw> createState() => ListPostState();
}

class ListPostState extends State<ListPostw> {
  final postRef = FirebaseFirestore.instance.collection("posts");
  bool isLoading = false;
  int postCount = 0;
  List<Post_Model> posts = [];

  @override
  Widget build(BuildContext context) {
    return getProfilePost();
  }

  Widget getProfilePost() {
    return StreamBuilder(
        stream: postRef
            .doc(widget.userApp.username)
            .collection("Posts")
            .snapshots(),
        builder: (BuildContext context, snapshot) {
          if (snapshot.hasData) {
            postCount = snapshot.data!.docs.length;
            posts =
                snapshot.data!.docs.map((e) => Post_Model.FromDoc(e)).toList();
            return  ListView.builder(
                itemCount: posts.length,
                itemBuilder: (BuildContext context, int index) {
                  return PostFromUser(
                    isFromOtherProfile: true,
                    post_model: posts[index],
                    user: widget.userApp,
                  );
                },
            );
          } else {
            return StyleCircularprogress();
          }
        });
    //QuerySnapshot snapshot =
    //await postRef.doc(widget.userApp.username).collection("Posts").get();
  }
}
