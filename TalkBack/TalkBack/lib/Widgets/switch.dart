import 'package:flutter/material.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:TalkBack/Provider/export_provider.dart';

///Widget Switch de cambio de color
class SwitchDarkMode extends StatefulWidget {
  SwitchDarkMode({Key? key}) : super(key: key);

  @override
  State<SwitchDarkMode> createState() => _SwitchDarkModeState();
}

class _SwitchDarkModeState extends State<SwitchDarkMode> {
  @override
  Widget build(BuildContext context) {
    ProviderSettings prov = Provider.of<ProviderSettings>(context);
    return FlutterSwitch(
      width: 125.0,
      height: 30.0,
      valueFontSize: 25.0,
      toggleSize: 45.0,
      value: prov.lightMode,
      borderRadius: 30.0,
      onToggle: (val) {
        _onTogle(prov);
      },
    );
  }

  void _onTogle(ProviderSettings prov) async {
    setState(() {
      prov.changeLightMode(!prov.lightMode);
    });
    SharedPreferences preferences = await SharedPreferences.getInstance();
    await preferences.setBool("lightMode", prov.lightMode);
  }
}