import 'package:flutter/cupertino.dart';

///Provider de ajustes con el modo oscuro
class ProviderSettings with ChangeNotifier{


  bool lightMode=true;

  void changeLightMode(bool b){
    lightMode=b;
    notifyListeners();
  }
}