// To parse this JSON data, do
//
//     final welcome = welcomeFromMap(jsonString);

import 'dart:convert';

///Modelo de los usuarios de la app
class UserApp {
  UserApp({
    required this.email,
    required this.foto,
    required this.username,
  });

  String email;
  String foto;
  String username;


  factory UserApp.fromMap(Map<String, dynamic> json) => UserApp(
        email: json["email"],
        foto: json["foto"],
        username: json["username"],
      );

  Map<String, dynamic> toMap() => {
        "email": email,
        "foto": foto,
        "username": username,
      };
}
