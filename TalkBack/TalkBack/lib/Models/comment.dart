import 'package:cloud_firestore/cloud_firestore.dart';

/// Modelo de comentario
class Comment{
  String? key;
  String? userName;
  String? url;
  String? comment;
  Timestamp? time;


  Comment({this.userName, this.url, this.comment, this.time,this.key});

  factory Comment.fromDoc(DocumentSnapshot doc){
    return Comment(
      userName: doc["username"],
      url: doc["avatarUrl"],
      time: doc["timestamp"],
      comment: doc["comment"],
      key: doc["key"],
    );
  }

}