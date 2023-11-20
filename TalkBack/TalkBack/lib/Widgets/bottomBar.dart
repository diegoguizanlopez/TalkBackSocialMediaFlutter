import 'package:dot_navigation_bar/dot_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:TalkBack/Provider/export_provider.dart';

///Permite la navegación entre ventanas de forma visual y dinámica
class getButtomBar extends StatefulWidget {
  const getButtomBar({Key? key}) : super(key: key);

  @override
  State<getButtomBar> createState() => _getButtomBarState();
}

class _getButtomBarState extends State<getButtomBar> {
  @override
  Widget build(BuildContext context) {
    ProvBottomBar prov = Provider.of<ProvBottomBar>(context, listen: true);
    return _getNavigation(prov: prov);
  }
}

class _getNavigation extends StatefulWidget {
  ProvBottomBar prov;
  _getNavigation({Key? key, required this.prov}) : super(key: key);

  @override
  State<_getNavigation> createState() => _getNavigationState();
}

class _getNavigationState extends State<_getNavigation> {
  @override
  Widget build(BuildContext context) {
    return DotNavigationBar(
      enableFloatingNavBar: true,
      currentIndex: widget.prov.selectedTab,
      backgroundColor: Colors.black,
      selectedItemColor: Colors.white.withOpacity(1),
      enablePaddingAnimation: false,
      dotIndicatorColor: Colors.black12,
      unselectedItemColor: Colors.white30,
      onTap: (p0) => setState(() {
        if (widget.prov.controller.page!.toInt() != p0) {
          widget.prov.goToPage(p0);
        }
      }),
      items: [
        /// Home
        DotNavigationBarItem(
          icon: const Icon(Icons.home),
        ),
        //Camera
        DotNavigationBarItem(
          icon: const Icon(Icons.add_outlined),
        ),

        /// Search
        DotNavigationBarItem(
          icon: const Icon(Icons.search),
        ),
      ],
    );
  }

  @override
  void initState() {
    super.initState();
  }
}
