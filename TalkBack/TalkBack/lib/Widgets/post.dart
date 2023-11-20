import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:like_button/like_button.dart';
import 'package:provider/provider.dart';
import 'package:TalkBack/Models/export_models.dart';
import 'package:TalkBack/Provider/export_provider.dart';
import 'package:TalkBack/Widgets/export_methods.dart';
import 'package:timeago/timeago.dart' as timeago;

import 'comments.dart';
import 'google_fonts_style.dart';
import 'heart_animation_widget.dart';

class PostFromUser extends StatefulWidget {
  Post_Model post_model;
  UserApp user;
  bool isFromOtherProfile;
  Function? setState;

  PostFromUser(
      {Key? key,
      required this.post_model,
      required this.user,
      required this.isFromOtherProfile,
      this.setState})
      : super(key: key);

  ///Devuelve los likes
  int _getLikes() {
    if (post_model.likes == null) {
      return 0;
    }
    int count = 0;
    post_model.likes?.values.forEach((val) {
      if (val == true) {
        count++;
      }
    });
    return count;
  }

  @override
  _PostFromUserState createState() => _PostFromUserState();
}

class _PostFromUserState extends State<PostFromUser> {
  final postRef = FirebaseFirestore.instance.collection("posts");

  ///Acción de dar o quitar like
  Future<bool> _like(UsersData usersData) async {
    bool liked;
    if (widget.post_model.IncreaseLike(usersData.LocalUser!.username)) {
      liked = true;
    } else {
      widget.post_model.DecreaseLike(usersData.LocalUser!.username);
      liked = false;
    }
      await postRef
          .doc(widget.user.username)
          .collection("Posts")
          .doc(widget.post_model.key!.trim())
          .update(widget.post_model.ToMap());
    setState(() {});
    return liked;
  }

  @override
  Widget build(BuildContext context) {
    UsersData usersData = Provider.of<UsersData>(context);
    return Container(
      margin: EdgeInsets.all(20),
      decoration: BoxDecoration(
          border: Border.all(color: Colors.indigo),
          color: Colors.black26,
          borderRadius: BorderRadius.circular(20)),
      child: Column(
        children: [
          _top(
            post_model: widget.post_model,
            user: widget.user,
            isFromOtherProfile: widget.isFromOtherProfile,
            function: widget.setState,
          ),
          _bottom(post_model: widget.post_model, like: _like),
        ],
      ),
    );
  }
}

class _top extends StatefulWidget {
  Post_Model post_model;
  UserApp user;
  bool isFromOtherProfile;
  Function? function;
  _top(
      {Key? key,
      required this.post_model,
      required this.user,
      required this.isFromOtherProfile,
      this.function})
      : super(key: key);

  @override
  State<_top> createState() => _topState();
}

class _topState extends State<_top> {
  @override
  Widget build(BuildContext context) {
    UsersData prov = Provider.of<UsersData>(context);
    return ListTile(
      leading: GestureDetector(
        onTap: () => widget.isFromOtherProfile
          ? Navigator.of(context)
          .pushReplacementNamed("profile", arguments: widget.user)
          : Navigator.of(context).pushNamed("profile", arguments: widget.user),
        child: CircleAvatar(
          backgroundImage: NetworkImage(widget.user.foto),
        ),
      ),
      title: GoogleFontsStyle(body: widget.user.username),
      subtitle: widget.post_model.loc == null
          ? Container()
          : GoogleFontsStyle(body: widget.post_model.loc!),
      trailing: widget.post_model.username == prov.LocalUser.username
          ? GestureDetector(
              onTapDown: (tap) => {
                _showPopupMenu(tap.globalPosition),
              },
              child: Icon(Icons.more_vert,color: Colors.white70,),
            )
          : Container(
              height: 0,
              width: 0,
            ),
    );
  }

  void _showPopupMenu(Offset offset) async {
    double left = offset.dx;
    double top = offset.dy;
    await showMenu(
        shape: RoundedRectangleBorder(
          side: BorderSide(color: Colors.deepPurple),
          borderRadius: BorderRadius.all(new Radius.circular(10)),
        ),
        color: Colors.black,
        context: context,
        position: RelativeRect.fromLTRB(left, top, 0, 0),
        items: [
          PopupMenuItem(
              value: 0,
              onTap: () async =>
                  {await _deletePost(widget.post_model, widget.function)},
              child: GoogleFontsStyle(body: "Delete", white: true, size: 10)),
          PopupMenuItem(
              onTap: () => {
                    Future(
                      //PopMenuItem works different remember @diego
                      () => Navigator.of(context).pushNamed("infopost",
                          arguments: {"post": widget.post_model}),
                    )
                  },
              child: GoogleFontsStyle(body: "Update", white: true, size: 10)),
        ]);
  }

  ///En caso de que se borre el post si es tuyo
  Future<void> _deletePost(Post_Model post_model, Function? function) async {
    int value = 5;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        duration: Duration(seconds: value),
        dismissDirection: DismissDirection.none,
        behavior: SnackBarBehavior.floating,
        content: StyleContainer(
          height: 100,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              GoogleFontsStyle(
                body: "Are you sure about that?",
                white: true,
              ),
              Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
                StyleButton(
                    function: () async => {
                          ScaffoldMessenger.of(context).hideCurrentSnackBar(),
                          await _delete(post_model),
                          if (function != null) {function()}
                        },
                    text: GoogleFontsStyle(
                      white: true,
                      body: "Confirm",
                    )),
                StyleButton(
                    function: () =>
                        {ScaffoldMessenger.of(context).hideCurrentSnackBar()},
                    text: GoogleFontsStyle(
                      white: true,
                      body: "Cancel",
                    ))
              ])
            ],
          ),
        )));
  }

  ///Borra los comentarios del Post y imagen
  Future<void> _delete(Post_Model post) async {
    final commentsRef = FirebaseFirestore.instance.collection("comments");
    final postRef = FirebaseFirestore.instance.collection("posts");
    List<dynamic> listCommentKey =
    (await postRef.doc(widget.user.username).collection("Posts").doc(post.key).get())
        .data()!["commentsKey"];
    await postRef
        .doc(widget.user.username)
        .collection("Posts")
        .doc(post.key)
        .delete();
    //Un doc con valores intermedios no se permite borrar por ende hay que borrar uno a uno
    //Se recoge los comentarios de último momento en caso de que se añadiera uno mientras se estaba en la pantalla
    listCommentKey.forEach((element) async {
      await commentsRef
          .doc(post.key)
          .collection("comments")
          .doc(element)
          .delete();
    });
    if (post.urlImage != null) {
      File imageFile = File(post.urlImage!);
      await FirebaseStorage.instance
          .ref()
          .child("Upload")
          .child(post.username!)
          .child("${post.key}.jpg")
          .delete();
    }
  }
}

class _bottom extends StatefulWidget {
  Post_Model post_model;
  Function like;
  _bottom({
    Key? key,
    required this.post_model,
    required this.like,
  }) : super(key: key);

  @override
  State<_bottom> createState() => _bottomState();
}

class _bottomState extends State<_bottom> {
  bool animation = false;

  ///Duración entre animaciones
  void setTimeVisibility() {
    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        animation = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    UsersData usersData = Provider.of<UsersData>(context);
    return Padding(
      padding: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
              onDoubleTap: () => {
                    widget.like(usersData),
                    if (widget.post_model.likes!
                        .containsKey(usersData.LocalUser!.username))
                      {
                        animation = true,
                        setTimeVisibility(),
                      }
                  },
              child: StyleContainer(
                clip: 10,
                child: Padding(
                  padding: EdgeInsets.all(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          widget.post_model.urlImage == null
                              ? Container()
                              : Container(
                                  height:
                                      MediaQuery.of(context).size.height / 3,
                                  width: double.infinity,
                                  child: FadeInImage(
                                      fit: BoxFit.fill,
                                      placeholder: AssetImage(
                                          "assets/Widget/Loading.gif"),
                                      image: NetworkImage(
                                          widget.post_model.urlImage!))),
                          HeartAnimationWidget(visibility: animation),
                        ],
                      ),
                      Divider(
                        color: Colors.white,
                        thickness: 1,
                      ),
                      GoogleFontsStyle(
                          body: widget.post_model.title!, white: true),
                      Divider(
                        color: Colors.white,
                        thickness: 1,
                      ),
                    ],
                  ),
                ),
              )),
          Row(mainAxisAlignment: MainAxisAlignment.start, children: [
            LikeButton(
                likeCount: widget.post_model.likeCount,
                isLiked: widget.post_model.likes!
                    .containsKey(usersData.LocalUser!.username),
                onTap: (isLiked) => widget.like(usersData),
                likeBuilder: (bool isLiked) {
                  return Icon(
                    Icons.favorite,
                    color: isLiked ? Colors.red : Colors.white70,
                    size: 27,
                  );
                }),
            Expanded(
              child: Container(),
            ),
            GoogleFontsStyle(
              body: DateTime.now()
                          .difference(widget.post_model.time!.toDate())
                          .inHours >
                      24
                  ? DateFormat.yMMMEd().format(widget.post_model.time!.toDate())
                  : timeago.format(widget.post_model!.time!.toDate()),
            )
          ]),
          Padding(
            padding: EdgeInsets.only(top: 10),
            child: GestureDetector(
              onTap: () => {ShowComments(context, post: widget.post_model!)},
              child: Icon(Icons.chat,color: Colors.white70,),
            ),
          ),
        ],
      ),
    );
  }
}

///Muestra los comentarios en caso de que se le de al icono
Widget? ShowComments(BuildContext cont, {required Post_Model post}) {
  Navigator.push(cont, MaterialPageRoute(builder: (cont) {
    return Comments(
      post: post,
    );
  }));
}
