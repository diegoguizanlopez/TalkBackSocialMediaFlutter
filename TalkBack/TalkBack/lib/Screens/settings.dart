import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:TalkBack/Provider/export_provider.dart';

import '../Widgets/export_methods.dart';

class Settings extends StatelessWidget {
  const Settings({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    ProviderSettings prov =
        Provider.of<ProviderSettings>(context, listen: true);
    return ScaffoldDefault(
      scroll: false,
        body: _ContainerListSettings(prov: prov));
  }
}

class _ContainerListSettings extends StatefulWidget {
  ProviderSettings prov;
  _ContainerListSettings({Key? key, required this.prov}) : super(key: key);

  @override
  State<_ContainerListSettings> createState() => _ContainerListSettingsState();
}

class _ContainerListSettingsState extends State<_ContainerListSettings> {

  @override
  Widget build(BuildContext context) {
    return Container(
      height: double.infinity,
      width: double.infinity,
      color: widget.prov.lightMode ? Colors.white : Colors.black87,
      child: Column(
        children: [
          ///Switch personalizado
          Padding(padding: EdgeInsets.all(5),child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,children: [GoogleFontsStyle(body: "Dark/Light"),SwitchDarkMode()])),
          Expanded(child:Container()),
          Row(
            children: [Expanded(child: Container()),StyleButton(
              height: MediaQuery.of(context).size.height/15,
              width: MediaQuery.of(context).size.width/5,
              edgeInsets: EdgeInsets.all(15),
              function: () async {
                ProvBottomBar prov = Provider.of<ProvBottomBar>(context, listen: false);
                FirebaseAuth.instance.signOut();
                final SharedPreferences sharedPreferences =
                await SharedPreferences.getInstance();
                sharedPreferences.remove("usermail");
                sharedPreferences.remove("userpassw");
                prov.changeValue(0);
                prov.controller=PageController(keepPage: true);
                Navigator.pop(context);
                Navigator.of(context).pushReplacementNamed("login");
              },
              text:GoogleFontsStyle(body: "Log out",white: true),
            ),]
          ),
        ],
      ),
    );
  }
}
