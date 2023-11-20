import 'dart:io';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:TalkBack/Models/export_models.dart';
import 'package:TalkBack/Provider/export_provider.dart';
import 'package:TalkBack/Widgets/export_methods.dart';

class InfoPost extends StatefulWidget {
  const InfoPost({Key? key}) : super(key: key);

  @override
  State<InfoPost> createState() => _InfoPostState();
}

class _InfoPostState extends State<InfoPost> {
  final GlobalKey<FormState> _formKey = GlobalKey();
  bool isUploading = false;
  @override
  Widget build(BuildContext context) {
    ProviderSettings prov =
        Provider.of<ProviderSettings>(context, listen: false);
    TextEditingController location = TextEditingController();
    TextEditingController title = TextEditingController();
    Map? values = ModalRoute.of(context)?.settings.arguments as Map?;

    ///Relleno variables si el valor post del mapa es nulo
    if (values!["post"] != null) {
      Post_Model tempo = values!["post"];
      title.text = tempo.title!;
      location.text = tempo.loc!;
    }
    return ScaffoldDefault(
        body: isUploading
            ? Container(
                color: !prov.lightMode ? Colors.black87 : Colors.white,
                height: MediaQuery.of(context).size.height,
                width: MediaQuery.of(context).size.width,
                child: StyleCircularprogress())
            : Container(
                color: !prov.lightMode ? Colors.black87 : Colors.white,
                child: Form(
                  key: _formKey,
                  child: ListView(
                    children: [
                      values!["photo"] != null
                          ? _showFoto(photo: values["photo"])
                          : Container(),
                      _currentLocation(
                          margin: values["photo"] == null ? 200 : 10,
                          location: location),
                      _title(title: title),
                      _buttonUpload(
                        formKey: _formKey,
                        location: location,
                        title: title,
                        photo: values["photo"],
                        function: title.text.isEmpty ? upload : update,
                        post_model:
                            title.text.isNotEmpty ? values!["post"] : null,
                        keyPost: title.text.isNotEmpty
                            ? (values!["post"] as Post_Model).key
                            : null,
                      ),
                    ],
                  ),
                ),
              ),
        scroll: false);
  }

  ///Actualiza el post con los nuevos datos
  Future<void> update(
      UsersData userApp,
      XFile? photo,
      TextEditingController location,
      TextEditingController title,
      String key,
      Post_Model post) async {
    String? urlUpload;
    setState(() {
      isUploading = true;
    });
    final postRef = FirebaseFirestore.instance.collection("posts");
    await postRef
        .doc(userApp.LocalUser!.username)
        .collection("Posts")
        .doc(key)
        .update({
      "username": userApp.LocalUser!.username,
      "loc": location.text,
      "urlImage": post.urlImage,
      "likes": post.likes,
      "likeCount": post.likeCount,
      "title": title.text,
      "time": post.time,
      "key": key,
      "commentsKey": post.commentsKey,
    });
    setState(() {
      isUploading = false;
    });
    Navigator.pop(context);
  }

  ///Inserta el post en la firestore
  Future<void> upload(UsersData userApp, XFile? photo,
      TextEditingController location, TextEditingController title) async {
    String? urlUpload;
    setState(() {
      isUploading = true;
    });
    final postRef = FirebaseFirestore.instance.collection("posts");

    ///Genera una contraseña random
    const ch = 'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz';
    Random r = Random();
    var key = String.fromCharCodes(
        Iterable.generate(20, (_) => ch.codeUnitAt(r.nextInt(ch.length))));
    if (photo != null) {
      urlUpload = await _uploadPhoto(userApp, key, photo);
    }
    await postRef
        .doc(userApp.LocalUser!.username)
        .collection("Posts")
        .doc(key)
        .set({
      "username": userApp.LocalUser!.username,
      "loc": location.text,
      "urlImage": urlUpload,
      "likes": {},
      "likeCount": 0,
      "title": title.text,
      "time": DateTime.now(),
      "key": key,
      "commentsKey": List<String>.empty(growable: true),
    });
    setState(() {
      isUploading = false;
    });
    Navigator.pop(context);
  }

  ///Sube la foto a FireStorage
  Future<String> _uploadPhoto(
      UsersData userApp, String key, XFile photo) async {
    File imageFile = File(photo!.path);
    Reference ref = FirebaseStorage.instance
        .ref()
        .child("Upload")
        .child(userApp.LocalUser!.username)
        .child("$key.jpg");
    await ref.putFile(imageFile);
    return await ref.getDownloadURL();
  }
}

class _showFoto extends StatelessWidget {
  XFile photo;
  _showFoto({Key? key, required this.photo}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(20),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: SizedBox(
            width: double.infinity,
            height: 300,
            child: Image.file(
              File(photo.path),
              fit: BoxFit.cover,
            )),
      ),
    );
  }
}

class _currentLocation extends StatefulWidget {
  double margin;
  TextEditingController location;
  _currentLocation({Key? key, required this.margin, required this.location})
      : super(key: key);

  @override
  State<_currentLocation> createState() => _currentLocationState();
}

class _currentLocationState extends State<_currentLocation> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: widget.margin),
      child: Row(children: [
        StyleContainer(
          clip: 10,
          edgeInsets: EdgeInsets.all(5),
          width: MediaQuery.of(context).size.width / 1.5,
          child: TextFormField(
            style: TextStyle(color: Colors.white),
            maxLength: 60,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return "Empty location";
              }
              return null;
            },
            controller: widget.location,
            decoration: const InputDecoration(
                counterText: '',
                hintStyle: TextStyle(color: Colors.white, fontSize: 14),
                hintText: "Your place",
                icon: Icon(
                  Icons.map,
                  color: Colors.white,
                )),
          ),
        ),
        Expanded(
          child: StyleButton(
              edgeInsets: EdgeInsets.all(5),
              function: () async => {await _getLocation()},
              text: GoogleFontsStyle(
                body: "Get your location",
                white: true,
              )),
        ),
      ]),
    );
  }

  ///Devuelve la ciudad situada si se prefiere ahorrar tiempo
  Future<void> _getLocation() async {
    LocationPermission permission;
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Allow location first');
      }
    }
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.medium);
    List<Placemark> placemarks =
        await placemarkFromCoordinates(position.latitude, position.longitude);
    setState(() {
      widget.location.text = placemarks[0].locality!;
    });
  }
}

class _title extends StatefulWidget {
  TextEditingController title;
  _title({Key? key, required this.title}) : super(key: key);

  @override
  State<_title> createState() => _titleState();
}

class _titleState extends State<_title> {
  @override
  Widget build(BuildContext context) {
    return StyleContainer(
      clip: 10,
      edgeInsets: EdgeInsets.only(top: 50, right: 10, left: 10),
      width: MediaQuery.of(context).size.width / 1.5,
      child: TextFormField(
        style: TextStyle(color: Colors.white),
        maxLength: 60,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return "Empty title";
          }
          return null;
        },
        controller: widget.title,
        decoration: const InputDecoration(
            counterText: '',
            hintStyle: TextStyle(fontSize: 14, color: Colors.white),
            hintText: "Title",
            icon: Icon(
              Icons.title,
              color: Colors.white,
            )),
      ),
    );
  }
}

class _buttonUpload extends StatefulWidget {
  GlobalKey<FormState> formKey;
  TextEditingController location;
  TextEditingController title;
  XFile? photo;
  Function function;
  String? keyPost;
  Post_Model? post_model;
  _buttonUpload({
    Key? key,
    required this.formKey,
    required this.location,
    required this.title,
    required this.photo,
    required this.function,
    this.keyPost,
    this.post_model,
  }) : super(key: key);

  @override
  State<_buttonUpload> createState() => _buttonUploadState();
}

class _buttonUploadState extends State<_buttonUpload> {
  @override
  Widget build(BuildContext context) {
    UsersData userApp = Provider.of<UsersData>(context);
    return Container(
      margin: EdgeInsets.only(top: 75, left: 75, right: 75),
      decoration: BoxDecoration(
          color: Colors.black87, borderRadius: BorderRadius.circular(10)),
      child: StyleButton(
          function: () => {
                widget.formKey.currentState!.validate()
                    ? (widget.keyPost == null
                        ? widget.function(userApp, widget.photo,
                            widget.location, widget.title)
                        : widget.function(
                            userApp,
                            widget.photo,
                            widget.location,
                            widget.title,
                            widget.keyPost,
                            widget.post_model))
                    : ScaffoldMessenger.of(context).showSnackBar(SnackBar(
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
                            )))),
              },
          text: GoogleFontsStyle(
            body: widget.title.text.isEmpty ? "Upload" : "Update",
            size: 26,
            white: true,
          )),
    );
  }
}
