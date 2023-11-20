import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:TalkBack/Provider/export_provider.dart';
import 'package:TalkBack/Widgets/export_methods.dart';

void main() async{
  runApp(const _getMaterialApp());
}

class _getMaterialApp extends StatefulWidget {
  const _getMaterialApp({Key? key}) : super(key: key);

  @override
  State<_getMaterialApp> createState() => _getMaterialAppState();
}

class _getMaterialAppState extends State<_getMaterialApp> {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<ProvBottomBar>(
          create: (_) => ProvBottomBar(),
        ),
        ChangeNotifierProvider<ProviderSettings>(
          create: (BuildContext context) => ProviderSettings(),
        ),
        ChangeNotifierProvider<UsersData>(
          create: (BuildContext context) => UsersData(),
        )
      ],
      child: MaterialApp(
        routes: getRoutes(),
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        initialRoute: "splash",
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    initComponents();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp
    ]);
  }

  Future<void> initComponents() async {
    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp();
  }
}
