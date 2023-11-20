import 'package:flutter/cupertino.dart';
import 'package:TalkBack/Screens/export_screens.dart';

///Manejo del ButomBar
class ProvBottomBar with ChangeNotifier {
  int selectedTab = 0;


  PageController controller = PageController(keepPage: true);


  List<String> listaTabs = [
    _SelectedTab.home.name,
    _SelectedTab.camera.name,
    _SelectedTab.search.name
  ];

  List<Widget> localScreens = const [Home(), Post(), Search()];

  String getValue(int i) => listaTabs[i].toString();

  void changeValue(int i) {
    selectedTab = i;
    notifyListeners();
  }

  void nextPage(){
    controller.animateToPage(controller.page!.toInt()+1, duration: Duration(milliseconds: 400), curve: Curves.easeIn);
    selectedTab=controller.page!.toInt()+1;
    notifyListeners();
  }

  void previusPage(){
    controller.animateToPage(controller.page!.toInt()-1, duration: Duration(milliseconds: 400), curve: Curves.easeIn);
    selectedTab=controller.page!.toInt()-1;
    notifyListeners();
  }

  void goToPage(int page) {
    controller.animateToPage(page, duration: Duration(milliseconds: 400), curve: Curves.easeIn);
    notifyListeners();
  }
}

enum _SelectedTab { home, camera, search }
