import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:TalkBack/Provider/export_provider.dart';
import 'package:TalkBack/Widgets/export_methods.dart';

///Scaffold que contienen todas las ventanas y que permite una navegación fluida entre ellas y dinámica
class ScaffoldDefault extends StatelessWidget {
  Widget body;
  bool scroll;
  ScaffoldDefault({Key? key, required this.body, required this.scroll})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    ProvBottomBar botombar = Provider.of<ProvBottomBar>(context);
    return _getScaffold(botombar:botombar,body: body,scroll: scroll,);
  }
}

class _getScaffold extends StatefulWidget {
  ProvBottomBar botombar;
  Widget body;
  bool scroll;
  _getScaffold({Key? key,required this.botombar, required this.body, required this.scroll}) : super(key: key);

  @override
  State<_getScaffold> createState() => _getScaffoldState();
}

class _getScaffoldState extends State<_getScaffold> {
  ConnectivityResult? result;

  @override
  Widget build(BuildContext context) {
    UsersData usersData = Provider.of<UsersData>(context);
    ProviderSettings settings = Provider.of<ProviderSettings>(context);
    return Scaffold(
      extendBody: true,
      bottomNavigationBar: result != ConnectivityResult.none ? (widget.scroll
          ? const getButtomBar()//
          : null) : Container(color: settings.lightMode?Colors.white:Colors.black87,child: Center(child: GoogleFontsStyle(body: "NO INTERNET CONNECTION",size: 30))),
      appBar: AppBar(
        actions: widget.scroll
            ? [
          result == ConnectivityResult.none? Container():IconButton(
              onPressed: () =>
              {Navigator.pushNamed(context, "profile",arguments: usersData.LocalUser)},
              icon: Icon(Icons.person)),
          IconButton(
              onPressed: () => {Navigator.pushNamed(context, "settings")},
              icon: Icon(Icons.settings)),
        ]
            : [
          IconButton(
              onPressed: () => {Navigator.pop(context)},
              icon: Icon(Icons.arrow_back))
        ],
        automaticallyImplyLeading: false,
        title: Text(
          "TalkBack",
          style: GoogleFonts.oswald(fontSize: 30),
        ),
        backgroundColor: Colors.black,
      ),
      body: result == ConnectivityResult.none ? Container() : widget.body,
    );
  }

  @override
  void initState() {
    super.initState();
    getConnection();
  }

  ///Escucha cambios de conexión si el Widget está montado para que no falle al realizar SetState
  void getConnection() async {
    Connectivity().onConnectivityChanged.listen((changed) {
      if (mounted) {
        setState(() {
          result = changed;
          widget.botombar.selectedTab=0;
        });
      }
    });
  }
}

