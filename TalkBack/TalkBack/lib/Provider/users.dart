import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:TalkBack/Models/export_models.dart';

///Toda la información de usuarios subidas,actualizaciones... .Incluido el usuario Local
class UsersData with ChangeNotifier {
  var urlJSON =
      "X.json";
  var url =
      "Y";

  String urlBase =
      "Z";

  var urlImage = "gs://talkback-W.appspot.com";

  late UserApp LocalUser;
  late String keyUser;

  List<UserApp> LUsuarios = [];

  void writeUser(
      {required String name,
      required email,
      foto = "https://i.stack.imgur.com/GNhxO.png"}) async {
    final response = await http.post(Uri.parse(urlJSON),
        body: json.encode({
          "username": name,
          "email": email,
          "foto": foto,
        }));
  }

  Future<void> updateUser(UserApp user, String key) async {
    final urlKey = "$url$key.json";
    Map<String, dynamic> map = user.toMap();
    await http.patch(Uri.parse(urlKey), body: json.encode(map));
  }


  set localUser(UserApp value) {
    LocalUser = value;
  }

  Future<void> setUserByEmail(String email,String uid) async {
    var u = Uri.https(urlBase, "user.json");
    var response = await http.get(u);
    Map<String, dynamic> decode = await json.decode(response.body);
    decode.forEach((key, value) {
      UserApp userLocal = UserApp.fromMap(value);
      if (userLocal.email == email) {
        localUser = userLocal;
        keyUser = key;
        return;
      }
    });
  }

  Future<List<UserApp>> getListByValue({String busq=""}) async {
    if (busq.isNotEmpty) {
      final response = await http.get(Uri.parse(urlJSON));
      Map<String, dynamic> decode = await json.decode(response.body);
      LUsuarios = [];
      decode.forEach((key, value) {
        UserApp user = UserApp.fromMap(value);
        if (user.username.startsWith(busq) &&
            user.username != LocalUser!.username) {
          LUsuarios.add(user);
        }
      });
    } else {
      LUsuarios = [];
    }
    return LUsuarios;
  }
  Future<UserApp> getByExactValue(String busq,bool quitUser) async {
    late UserApp userApp;
    if (busq.isNotEmpty) {
      final response = await http.get(Uri.parse(urlJSON));
      Map<String, dynamic> decode = await json.decode(response.body);
      decode.forEach((key, value) {
        UserApp user = UserApp.fromMap(value);
        if (user.username == busq) {
          if (quitUser) {
            if(user.username != LocalUser!.username){
              userApp = user;
            }
          }else{
            userApp = user;
          }
        }
      });
    }
    return userApp;
  }
}
