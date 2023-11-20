import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:TalkBack/Provider/export_provider.dart';

///Widget de Texto con estilo predeterminado
class GoogleFontsStyle extends StatefulWidget {
  final String body;
  double size;
  bool white;
  GoogleFontsStyle({Key? key,required this.body,this.size=16,this.white=false}) : super(key: key);

  @override
  _GoogleFontsStyleState createState() => _GoogleFontsStyleState();
}

class _GoogleFontsStyleState extends State<GoogleFontsStyle> {
  @override
  Widget build(BuildContext context) {
    ProviderSettings prov =
    Provider.of<ProviderSettings>(context, listen: true);
    return Text(style: GoogleFonts.oswald(color: widget.white?Colors.white:prov.lightMode?Colors.black:Colors.white70,fontSize: widget.size),widget.body);
  }
}
