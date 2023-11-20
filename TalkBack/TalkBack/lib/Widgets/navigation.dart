import 'package:flutter/cupertino.dart';
import 'package:TalkBack/Screens/export_screens.dart';

///Pestañas
Map<String, WidgetBuilder> getRoutes() {
  return {
    "login":(_)=> const LoginScreen(),
    "register":(_)=> const Register(),
    "forgot":(_)=>const ForgotPassword(),
    "main": (_) => const MainWindow(),
    "splash": (_) => const Splash(),
    "settings":(_)=>const Settings(),
    "profile":(_)=>const Profile(),
    "infopost" : (_)=>const InfoPost(),
  };
}
