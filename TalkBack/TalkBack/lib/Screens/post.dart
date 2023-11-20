import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:TalkBack/Provider/export_provider.dart';

class Post extends StatefulWidget {
  const Post({Key? key}) : super(key: key);

  @override
  State<Post> createState() => _PostState();
}

class _PostState extends State<Post> {
  @override
  Widget build(BuildContext context) {

    ///Acción de cámara
    Future<void> camera() async {
      XFile? pickedFile =
          await ImagePicker().pickImage(source: ImageSource.camera);
      if (pickedFile != null) {
        Navigator.of(context).pushNamed("infopost",arguments: {"photo":pickedFile});
      }
    }

    ///Acción de galería
    Future<void> gallery() async{
      XFile? pickedFile =
      await ImagePicker().pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        Navigator.of(context).pushNamed("infopost",arguments: {"photo":pickedFile});
      }
    }

    ProviderSettings prov =
        Provider.of<ProviderSettings>(context, listen: true);
    return Container(
      color: prov.lightMode ? Colors.white : Colors.black87,
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(children: [
          _container(
              inset: EdgeInsets.only(bottom: 15),
              icon: Icons.camera_alt_outlined,
              function: camera),
          _container(
              inset: EdgeInsets.only(bottom: 15, top: 16),
              icon: Icons.photo,
              function: gallery),
          _container(
              inset: EdgeInsets.only(top: 15),
              icon: Icons.chat_bubble_outline,
              function: () => {Navigator.of(context).pushNamed("infopost",arguments: {})}),
        ]),
      ),
    );
  }
}

class _container extends StatelessWidget {
  EdgeInsets inset;
  IconData icon;
  final Function function;
  _container(
      {Key? key,
      required this.inset,
      required this.icon,
      required this.function})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        margin: inset,
        child: GestureDetector(
          onTap: () => {function()},
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.deepPurple,width: 2),
                color: Colors.black87,
              ),
              width: double.infinity,
              child: Icon(icon, color: Colors.white, size: 150),
            ),
          ),
        ),
      ),
    );
  }
}
