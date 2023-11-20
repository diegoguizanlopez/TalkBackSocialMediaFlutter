import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:splashscreen/splashscreen.dart';
import 'package:TalkBack/Provider/export_provider.dart';
import 'package:TalkBack/Screens/export_screens.dart';

import '../firebase_options.dart';

class Splash extends StatelessWidget {
  const Splash({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    UsersData userprov = Provider.of<UsersData>(context, listen: false);
    return _chargeSplash(userprov: userprov);
  }
}

class _chargeSplash extends StatefulWidget {
  UsersData userprov;
  _chargeSplash({Key? key,required this.userprov})
      : super(key: key);

  @override
  State<_chargeSplash> createState() => _chargeSplashState();
}

class _chargeSplashState extends State<_chargeSplash> {
  String? mail;
  String? passwd;
  final _storage = const FlutterSecureStorage();
  ConnectivityResult? _connectivityResult;

  @override
  void initState() {
    super.initState();
  }

  Future<Widget> _getConnection() async {
    ConnectivityResult result = await Connectivity().checkConnectivity();
    if (result != ConnectivityResult.none) {
      await SharedPreferences.getInstance()
          .then((value) async => await _getLocalUser(value));
    }
    return await Future.value(
        Future.delayed(const Duration(milliseconds: 3000), () async {
      await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
      return mail == null ? LoginScreen() : MainWindow();
    }));
  }

  _getLocalUser(SharedPreferences sharedPreferences) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    ProviderSettings prov =
        Provider.of<ProviderSettings>(context, listen: false);
    prov.lightMode = sharedPreferences.getBool("lightMode") ?? false;
    mail = sharedPreferences.getString("usermail");
    passwd = await _storage.read(key: "password");
    if (mail != null && _connectivityResult != ConnectivityResult.none) {
      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: mail!, password: passwd!);
      User? user = userCredential.user;
      if (user != null) {
        widget.userprov.setUserByEmail(mail!, user.uid);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    Future<Widget> _futureNavigation() async {
      return await _getConnection();
    }

    ///Permite crear una pantalla de carga mientras la app trabaja por detrás realizando conexiones a Firebase
    return SplashScreen(
        navigateAfterFuture: _futureNavigation(),
        photoSize: 100,
        loaderColor: Colors.black,
        imageBackground: const AssetImage("assets/Screens/BackGround.jpg"),
        loadingText: Text(
          "TalkBack",
          style: GoogleFonts.lato(fontWeight: FontWeight.bold, fontSize: 30.0),
        ));
  }
}
