import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:TalkBack/Provider/export_provider.dart';

///Modelo de las Publicaciones
class Post_Model {
  String? username;
  String? loc;
  String? urlImage;
  Map? likes;
  int? likeCount;
  String? title;
  Timestamp? time;
  String? key;
  List<dynamic>? commentsKey;

  Post_Model({
    this.username,
    this.loc,
    this.urlImage,
    this.likes,
    this.likeCount,
    this.title,
    this.time,
    this.key,
    this.commentsKey,
  });

  ///Convierte un Doc de FireStore en Post
  factory Post_Model.FromDoc(DocumentSnapshot documentSnapshot){
    return Post_Model(
      username: documentSnapshot["username"],
      loc: documentSnapshot["loc"],
      urlImage: documentSnapshot["urlImage"],
      likes: documentSnapshot["likes"],
      likeCount: documentSnapshot["likeCount"],
      title: documentSnapshot["title"],
      time: documentSnapshot["time"],
      key: documentSnapshot["key"],
      commentsKey: documentSnapshot["commentsKey"],
    );
  }

  ///Transforma en mapa
  Map<String,dynamic> ToMap(){
    return {
      "username" : username,
      "loc" : loc,
      "urlImage" : urlImage,
      "likes" : likes,
      "likeCount" : likeCount,
      "title" : title,
      "time" : time,
      "key" : key,
      "commentsKey" : commentsKey
    };
  }

  bool IncreaseLike(String userName){
    if(likes!.containsKey(userName)){
      return false;
    }
    likes?.putIfAbsent(userName, () => true);
    likeCount=likeCount!+1;
    return true;
  }

  bool DecreaseLike(String username) {
    if(!likes!.containsKey(username)){
      return false;
    }
    likes?.removeWhere((key, value) => key==username);
    likeCount=likeCount!-1;
    return true;
  }
}
