import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:TalkBack/Models/export_models.dart';
import 'package:TalkBack/Provider/export_provider.dart';
import 'package:TalkBack/Widgets/export_methods.dart';

class Profile extends StatelessWidget {
  const Profile({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    UserApp userApp = ModalRoute.of(context)?.settings.arguments as UserApp;
    UsersData provider = Provider.of<UsersData>(context);
    ProviderSettings prov =
        Provider.of<ProviderSettings>(context, listen: false);
    return ScaffoldDefault(
      ///El CustomScrollViewer permite la utilización de Expanded en el
      body: CustomScrollView(slivers: [
        SliverFillRemaining(
          hasScrollBody: false,
          child: Container(
              color: !prov.lightMode ? Colors.black87 : Colors.white,
              child: _getProfileInfo(userApp: userApp, provider: provider)),
        ),
      ]),
      scroll: false,
    );
  }
}

class _getProfileInfo extends StatefulWidget {
  UserApp userApp;
  UsersData provider;
  _getProfileInfo({Key? key, required this.userApp, required this.provider})
      : super(key: key);

  @override
  State<_getProfileInfo> createState() => _getProfileInfoState();
}

class _getProfileInfoState extends State<_getProfileInfo> {
  final followers = FirebaseFirestore.instance.collection("followers");
  final following = FirebaseFirestore.instance.collection("following");
  bool isFollowing = false;
  bool loadedButton = false;
  int followersN = 0;
  int followingN = 0;
  String imageURL = "";

  @override
  void initState() {
    super.initState();
    getFollowers();
    getFollowing();
    checkFollow();
  }

  ///Obtiene si lo sigue
  void checkFollow() async {
    DocumentSnapshot doc = await followers
        .doc(widget.userApp.username)
        .collection("userFollowers")
        .doc(widget.provider.LocalUser!.username)
        .get();
    setState(() {
      isFollowing = doc.exists;
      loadedButton = true;
    });
  }

  ///Obtiene sus seguidores
  void getFollowers() async {
    QuerySnapshot snapshot = await followers
        .doc(widget.userApp.username)
        .collection("userFollowers")
        .get();
    setState(() {
      followersN = snapshot.docs.length;
    });
  }

  ///Obtiene a quien sigue
  void getFollowing() async {
    QuerySnapshot snapshot = await following
        .doc(widget.userApp.username)
        .collection("userFollowing")
        .get();
    setState(() {
      followingN = snapshot.docs.length;
    });
  }

  ///En caso de que deje de seguirlo
  void _handdleUnfollow(UsersData prov) {
    setState(() {
      isFollowing = false;
    });
    followers
        .doc(widget.userApp.username)
        .collection("userFollowers")
        .doc(prov.LocalUser!.username)
        .delete();
    following
        .doc(prov.LocalUser!.username)
        .collection("userFollowing")
        .doc(widget.userApp.username)
        .delete();
    getFollowers();
  }

  ///En caso de que empiece a seguirlo
  void _handdleFollow(UsersData prov) {
    setState(() {
      isFollowing = true;
    });
    followers
        .doc(widget.userApp.username)
        .collection("userFollowers")
        .doc(prov.LocalUser!.username)
        .set({});
    following
        .doc(prov.LocalUser!.username)
        .collection("userFollowing")
        .doc(widget.userApp.username)
        .set({});
    getFollowers();
  }

  ///Para cambiar imagen de perfil
  void _imagePicker(UsersData provider) async {
    XFile? pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      File imageFile = File(pickedFile.path);
      Reference ref = (FirebaseStorage.instance)
          .ref()
          .child("ProfilePictures")
          .child("${provider.LocalUser!.username}profilepicture.jpg");
      await ref.putFile(imageFile);
      imageURL = await ref.getDownloadURL();
      provider.LocalUser!.foto = imageURL;
      await provider.updateUser(provider.LocalUser!, provider.keyUser);
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    UsersData usersData = Provider.of<UsersData>(context);
    return Column(children: [
      Column(
        children: [
          Row(
            children: [
              Center(
                child: StyleContainer(
                  height: 150,
                  width: 150,
                  clip: 200,
                  edgeInsets: EdgeInsets.only(top: 20, left: 20, right: 20),
                  child: FadeInImage(
                      fit: BoxFit.cover,
                      placeholder: AssetImage("assets/Util/Loading.gif"),
                      image: NetworkImage(widget.userApp.foto)),
                ),
              ),
              Column(
                children: [
                  GoogleFontsStyle(body: "Followers:$followersN"),
                  GoogleFontsStyle(body: "Following:$followingN"),
                ],
              ),
            ],
          ),
          usersData.LocalUser.username == widget.userApp.username
              ? StyleButton(
                  width: MediaQuery.of(context).size.width / 2,
                  edgeInsets: EdgeInsets.all(20),
                  clip: 20,
                  function: () => {_imagePicker(usersData)},
                  text: GoogleFontsStyle(
                    body: "Change picture",
                    white: true,
                  ))
              : (loadedButton
                  ? StyleButton(
                      width: MediaQuery.of(context).size.width / 2,
                      edgeInsets: EdgeInsets.all(20),
                      function: () => {
                            isFollowing
                                ? _handdleUnfollow(widget.provider)
                                : _handdleFollow(widget.provider)
                          },
                      text: GoogleFontsStyle(
                        body: isFollowing ? "Unfollow user" : "Follow",
                        white: true,
                      ))
                  : Container()),
        ],
      ),
      _getPosts(userApp: widget.userApp),
    ]);
  }
}

class _getPosts extends StatefulWidget {
  UserApp userApp;
  _getPosts({Key? key, required this.userApp}) : super(key: key);

  @override
  State<_getPosts> createState() => _getPostsState();
}

class _getPostsState extends State<_getPosts> {
  final postRef = FirebaseFirestore.instance.collection("posts");
  bool isLoading = false;
  int postCount = 0;
  List<Post_Model> posts = [];

  @override
  Widget build(BuildContext context) {
    return getProfilePost();
  }

  ///Permite estar escuchando los cambios en el stream y cuando los notifique se redibuja el apartado
  Widget getProfilePost() {
    return StreamBuilder(
        stream: postRef
            .doc(widget.userApp.username)
            .collection("Posts")
            .orderBy("time", descending: true)
            .snapshots(),
        builder: (BuildContext context, snapshot) {
          if (snapshot.hasData) {
            postCount = snapshot.data!.docs.length;
            posts =
                snapshot.data!.docs.map((e) => Post_Model.FromDoc(e)).toList();
            return posts.isNotEmpty
                ? Column(
                    children: posts
                        .map(
                          (e) => PostFromUser(
                            isFromOtherProfile: true,
                            post_model: e,
                            user: widget.userApp,
                          ),
                        )
                        .toList(),
                  )
                : IntrinsicHeight(
                    child: Container(
                    width: 100,
                    color: Colors.red,
                  ));
          } else {return StyleCircularprogress();
          }
        });
  }
}
