import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:TalkBack/Provider/export_provider.dart';
import 'package:TalkBack/Widgets/export_methods.dart';

class MainWindow extends StatefulWidget {
  const MainWindow({Key? key}) : super(key: key);

  @override
  State<MainWindow> createState() => _MainWindowState();
}

class _MainWindowState extends State<MainWindow> {
  @override
  Widget build(BuildContext context) {
    ProvBottomBar prov = Provider.of<ProvBottomBar>(context, listen: true);
    ConnectivityResult? _connectivityResult;

    ///Revisa el estado der conexión para saber si debe llevarle al menú o también si nunca usó la app
    void _getLocalUser() async {
      Connectivity().onConnectivityChanged.listen((result) {
        setState(() {
          _connectivityResult = result;
        });
      });
      if (_connectivityResult != ConnectivityResult.none) {
        SharedPreferences sharedPreferences =
        await SharedPreferences.getInstance();
        String mail = sharedPreferences.getString("usermail")!;
        String passwd = sharedPreferences.getString("userpassw")!;
        UserCredential userCredential = await FirebaseAuth.instance
            .signInWithEmailAndPassword(email: mail!, password: passwd!);
        User user = userCredential.user!;
      }
    }

    @override
    void initState() {
      super.initState();
      _getLocalUser();
    }

    return ScaffoldDefault(
      ///Importante es ek controll del movimiento lateral de ventanas
      body: PageView(
          onPageChanged: (value) => setState(() {
                prov.changeValue(value);
              }),
          controller: prov.controller,
          scrollDirection: Axis.horizontal,
          children: prov.localScreens),
      scroll: true,
    );
  }
}
