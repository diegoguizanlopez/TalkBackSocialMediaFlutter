import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:TalkBack/Models/export_models.dart';
import 'package:TalkBack/Provider/export_provider.dart';
import 'package:TalkBack/Widgets/default_scaffold.dart';
import 'package:TalkBack/Widgets/export_methods.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'google_fonts_style.dart';


///Lista de comentarios de una aplicación
class Comments extends StatefulWidget {
  final Post_Model post;
  const Comments({Key? key, required this.post}) : super(key: key);

  @override
  _CommentsState createState() => _CommentsState();
}

class _CommentsState extends State<Comments> {
  TextEditingController comment = TextEditingController();
  final commentsRef = FirebaseFirestore.instance.collection("comments");

  ///Devuelve los comentarios de un post en forma de Stream para escuchar cambios
  Widget getComments(UsersData usersData, ProviderSettings prov) {
    return StreamBuilder(
      stream: commentsRef
          .doc(widget.post.key)
          .collection("comments")
          .orderBy("timestamp", descending: true)
          .snapshots(),
      builder: (context, snaps) {
        if (!snaps.hasData) {
          return Container(
              width: double.infinity,
              color: prov.lightMode ? Colors.white : Colors.black87,
              child: StyleCircularprogress());
        }

        List<_IndividualComment> comments = [];
        snaps.data!.docs.forEach((element) {
          comments.add(_IndividualComment(
            comment: Comment.fromDoc(element),
            userApp: usersData.LocalUser,
            post: widget.post,
          ));
        });
        return Container(
          color: prov.lightMode ? Colors.white : Colors.black87,
          child: ListView(
            children: comments,
          ),
        );
      },
    );
  }

  ///Añade un comentario con clave random
  void addComment(UsersData usersData, Post_Model post) async {
    const ch = 'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz';
    Random r = Random();
    var key = String.fromCharCodes(
        Iterable.generate(20, (_) => ch.codeUnitAt(r.nextInt(ch.length))));
    await commentsRef.doc(widget.post.key).collection("comments").doc(key).set({
      "username": usersData.LocalUser!.username,
      "comment": comment.text,
      "timestamp": Timestamp.now(),
      "avatarUrl": usersData.LocalUser!.foto,
      "key": key,
    });
    var value =
        (await commentsRef.doc(widget.post.key).collection("comments").get())
            .docs
            .map((e) => e.id)
            .toList();
    post.commentsKey = value;
    await FirebaseFirestore.instance
        .collection("posts")
        .doc(post.username)
        .collection("Posts")
        .doc(post.key)
        .update(post.ToMap());
    comment.clear();
  }

  @override
  Widget build(BuildContext context) {
    final GlobalKey<FormState> _formKey = GlobalKey();
    UsersData usersData = Provider.of<UsersData>(context);
    ProviderSettings provSettings = Provider.of<ProviderSettings>(context);
    return ScaffoldDefault(
        body: Column(
          children: [
            Expanded(child: getComments(usersData, provSettings)),
            Form(
              key: _formKey,
              child: StyleContainer(
                child: ListTile(
                  title: TextFormField(
                    maxLength: 120,
                    validator: (value) {
                      if(value == null || value.isEmpty){
                        return "You can't post a empty comment";
                      }
                      return null;
                    },
                    style: TextStyle(
                        color:
                            provSettings.lightMode ? Colors.black : Colors.white),
                    controller: comment,
                    decoration: InputDecoration(
                        labelText: "Write comment",
                        counterText: '',
                        hintStyle: TextStyle(
                            color: provSettings.lightMode
                                ? Colors.black
                                : Colors.white)),
                  ),
                  trailing: StyleButton(
                    function: () => {_formKey.currentState!.validate()?addComment(usersData, widget.post):ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        shape: RoundedRectangleBorder(
                          side: BorderSide(color: Colors.deepPurple),
                          borderRadius:
                          BorderRadius.all(new Radius.circular(10)),
                        ),
                        duration: Duration(seconds: 3),
                        //margin: EdgeInsets.only(bottom: MediaQuery.of(context).size.height / 3),
                        dismissDirection: DismissDirection.none,
                        behavior: SnackBarBehavior.floating,
                        content: StyleContainer(
                            height: 50,
                            child: Center(
                              child: GoogleFontsStyle(
                                  white: true, body: "Please check the values"),
                            )))),},
                    text: GoogleFontsStyle(body: "Post",white: true,),
                  ),
                ),
              ),
            )
          ],
        ),
        scroll: false);
  }
}

class _IndividualComment extends StatefulWidget {
  final Comment comment;
  final UserApp userApp;
  final Post_Model post;
  const _IndividualComment(
      {Key? key,
      required this.comment,
      required this.userApp,
      required this.post})
      : super(key: key);

  @override
  State<_IndividualComment> createState() => _IndividualCommentState();
}

class _IndividualCommentState extends State<_IndividualComment> {

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
            onTap: () async => {await _deleteComment(widget.comment)},
            child: GoogleFontsStyle(body: "Delete", white: true, size: 10)),
      ],
    );
  }

  ///Borra el comentario si le pertenece al usuario
  Future<void> _deleteComment(Comment comment) async {
    final commentsRef = FirebaseFirestore.instance.collection("comments");
    final postRef = FirebaseFirestore.instance.collection("posts");
    List<dynamic> listCommentKey = (await postRef
            .doc(widget.post.username)
            .collection("Posts")
            .doc(widget.post.key)
            .get())
        .data()!["commentsKey"];
    listCommentKey.removeWhere((element) => element == comment.key);
    widget.post.commentsKey = listCommentKey;
    await postRef
        .doc(widget.post.username)
        .collection("Posts")
        .doc(widget.post.key)
        .set(widget.post.ToMap());
    await commentsRef
        .doc(widget.post.key)
        .collection("comments")
        .doc(comment.key)
        .delete();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          color: Colors.black87,
          child: ListTile(
            title: Text(
              widget.comment.comment!,
              style: GoogleFonts.oswald(
                  color: widget.comment.userName == widget.userApp.username
                      ? Colors.white54
                      : Colors.white),
            ),
            leading: CircleAvatar(
              backgroundImage: NetworkImage(widget.comment.url!),
            ),
            subtitle: Text(
              ///Formatea la fecha si supera las 24 horas
              DateTime.now()
                  .difference(widget.comment.time!.toDate())
                  .inHours >
                  24
                  ? DateFormat.yMMMEd().format(widget.comment.time!.toDate())
                  : timeago.format(widget.comment!.time!.toDate()),
              style: GoogleFonts.oswald(
                  color: widget.comment.userName == widget.userApp.username
                      ? Colors.white54
                      : Colors.white),
            ),
            trailing: widget.comment.userName == widget.userApp.username
                ? GestureDetector(
                    onTapDown: (tap) => {
                      _showPopupMenu(tap.globalPosition),
                    },
                    child: Icon(
                      Icons.more_vert,
                      color: Colors.white,
                    ),
                  )
                : Text(""),
          ),
        ),
        Divider(
          height: 0,
          color: Colors.white,
        )
      ],
    );
  }
}
