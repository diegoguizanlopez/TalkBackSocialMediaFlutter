import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:TalkBack/Provider/provider_settings.dart';

///Estilo de botón personalizado
class StyleButton extends StatelessWidget {
  Function() function;
  Widget text;
  IconData? icons;
  bool BlackWhite;
  double? width;
  double? height;
  double clip;
  EdgeInsets? edgeInsets;
  StyleButton(
      {Key? key,
      required this.function,
      required this.text,
      this.icons,
      this.BlackWhite = false,
      this.width,
      this.height,
      this.clip = 20,
      this.edgeInsets,
      })
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    ProviderSettings prov = Provider.of(context, listen: true);
    return Container(
      margin: edgeInsets == null?EdgeInsets.all(0):edgeInsets,
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.all(Radius.circular(clip / 2)),
        border: Border.all(
            color: BlackWhite
                ? (prov.lightMode ? Colors.black : Colors.deepPurple)
                : Colors.deepPurple),
      ),
      child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(clip)),
          ),
          height: height,
          width: width,
          child: icons == null
              ? TextButton(onPressed: function, child: text)
              : IconButton(onPressed: function, icon: Icon(icons))),
    );
  }
}
