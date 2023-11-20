import 'package:flutter/material.dart';

///Estilo de Container predeterminado
class StyleContainer extends StatelessWidget {
  Widget child;
  EdgeInsets? edgeInsets;
  double? width;
  double? height;
  double clip;
  StyleContainer(
      {Key? key,
      required this.child,
      this.edgeInsets,
      this.width,
      this.height,
      this.clip = 0})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height ?? null,
      width: width ?? null,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.deepPurple),
        borderRadius: BorderRadius.all(Radius.circular(clip)),
        color: Colors.black,
      ),
      margin: edgeInsets == null ? EdgeInsets.all(0) : edgeInsets,
      child: ClipRRect(borderRadius: BorderRadius.circular(clip),child: child),
    );
  }
}
