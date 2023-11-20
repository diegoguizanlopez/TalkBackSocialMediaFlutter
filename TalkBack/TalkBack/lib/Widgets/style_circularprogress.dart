import 'package:flutter/material.dart';
import 'package:TalkBack/Widgets/export_methods.dart';

///Estilo de CircularProgres predeterminado
class StyleCircularprogress extends StatelessWidget {
  StyleCircularprogress({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
            margin: EdgeInsets.all(20),
            height: 150,
            width: 150,
            child: CircularProgressIndicator(color: Colors.black,)),
        GoogleFontsStyle(body: "Working...",size: 26),
      ],
    );
  }
}
