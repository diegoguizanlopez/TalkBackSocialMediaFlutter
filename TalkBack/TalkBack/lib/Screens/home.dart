import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:TalkBack/Models/export_models.dart';
import 'package:TalkBack/Provider/export_provider.dart';
import 'package:TalkBack/Widgets/export_methods.dart';

class Home extends StatelessWidget {
  const Home({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    ProviderSettings prov =
        Provider.of<ProviderSettings>(context, listen: true);
    UsersData providerUsuario = Provider.of<UsersData>(context, listen: false);
    return Container(
      color: !prov.lightMode ? Colors.black87 : Colors.white,
      child: _DisenhoHome(prov: prov, providerUsuario: providerUsuario),
    );
  }
}

class _DisenhoHome extends StatefulWidget {
  ProviderSettings prov;
  UsersData providerUsuario;
  _DisenhoHome({Key? key, required this.prov, required this.providerUsuario})
      : super(key: key);

  @override
  State<_DisenhoHome> createState() => _DisenhoHomeState();
}

class _DisenhoHomeState extends State<_DisenhoHome>
    with AutomaticKeepAliveClientMixin {
  bool loading = true;
  List<Post_Model> PostModelList = [];
  List<UserApp> UserAppList = [];
  ConnectivityResult? result;

  @override
  void initState() {
    super.initState();
    _loadFotos();
    _loadLightMode();
  }

  ///Carga las fotos de los usuarios
  Future<void> _loadFotos() async {
    ///Lista de quien sigue el usuario incluido él
    List<String> usersNames = [widget.providerUsuario.LocalUser.username];
    final following = FirebaseFirestore.instance.collection("following");
    ///Obtiene datos de quien lo sigue
    QuerySnapshot doc = (await following
        .doc(widget.providerUsuario.LocalUser!.username)
        .collection("userFollowing")
        .get());
    usersNames.addAll(doc.docs.map((e) => e.id).toList());
    await GetPosts(usersNames);
    setState(() {});
  }

  ///Obtiene los Post de cada usuario ordenados a más nuevo
  Future<void> GetPosts(List<String> listUsernames) async {
    final posts = FirebaseFirestore.instance.collection("posts");
    List<QuerySnapshot> list = [];
    for (var element in listUsernames) {
      ///Por cada uno de los elementos obtiene el post
      list.add((await posts
          .doc(element)
          .collection("Posts")
          .orderBy("time", descending: true)
          .get()));
    }

    List<List<Post_Model>> lista = list
        .map((e) => e.docs.map((e) => Post_Model.FromDoc(e)).toList())
        .toList();
    PostModelList = [];
    ///Añade el Post en una lista
    for (var element in lista) {
      for (var element2 in element) {
        PostModelList.add(element2);
      }
    }
    UserAppList = [];
    PostModelList.sort((a, b) => b.time!.compareTo(a.time!));
    for (var Post in PostModelList) {
      if (UserAppList.any((element) => element.username == Post.username)) {
        UserAppList.add(
            UserAppList.where((element) => element.username == Post.username)
                .first);
      } else {
        UserAppList.add(await widget.providerUsuario
            .getByExactValue(Post.username!, false));
      }
    }
    loading = false;
  }

  ///Recoge el modo
  Future _loadLightMode() async {
    SharedPreferences shared = await SharedPreferences.getInstance();
    final boolean = shared.getBool("lightMode");
    if (boolean == null) {
      return true;
    } else {
      setState(() {
        widget.prov.lightMode = boolean;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return (loading
        ? Center(child: StyleCircularprogress())
        : LiquidPullToRefresh(
            backgroundColor: Colors.white,
            color: Colors.black,
            height: 100,
            showChildOpacityTransition: false,
            onRefresh: () => _loadFotos(),
            child: PostModelList.isNotEmpty
                ? ListView.builder(
                    itemCount: PostModelList.length,
                    itemBuilder: (BuildContext context, int index) {
                      return PostFromUser(
                        isFromOtherProfile: false,
                        post_model: PostModelList[index],
                        user: UserAppList[index],
                        setState: () => setState(() {
                          _loadFotos();
                        }),
                      );
                    })
                : ListView(shrinkWrap: true, children: [
                    Container(
                      child: Center(
                        child: GoogleFontsStyle(
                            body:
                                "Follow someone and refresh the page to see new posts",
                            size: 16),
                      ),
                      margin: EdgeInsets.symmetric(
                          vertical: MediaQuery.of(context).size.height / 2.5),
                    ),
                  ]),
          ));
  }

  @override
  bool get wantKeepAlive => true;
}
