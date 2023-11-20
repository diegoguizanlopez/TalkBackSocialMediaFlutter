import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:TalkBack/Provider/export_provider.dart';
import 'package:TalkBack/Widgets/export_methods.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({Key? key}) : super(key: key);

  Future<FirebaseApp> _getFireBase() async {
    FirebaseApp firebaseApp = await Firebase.initializeApp();
    return firebaseApp;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Padding(
      padding: EdgeInsets.only(top: 20, right: 20, left: 20),
      child: FutureBuilder(
        future: _getFireBase(),
        builder: (BuildContext context, AsyncSnapshot<FirebaseApp> snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return _screenlogin();
          } else {
            return Center(
              child: StyleCircularprogress(),
            );
          }
        },
      ),
    ));
  }
}

class _screenlogin extends StatefulWidget {
  const _screenlogin({Key? key}) : super(key: key);

  @override
  State<_screenlogin> createState() => _screenloginState();
}

class _screenloginState extends State<_screenlogin> {
  TextEditingController emailtextEditingController = TextEditingController();
  TextEditingController passwdtextEditingController = TextEditingController();
  bool notvisiblepassword = true;
  String actualText = "";
  final _storage = const FlutterSecureStorage();

  @override
  void dispose() {
    emailtextEditingController.dispose();
    passwdtextEditingController.dispose();
    super.dispose();
  }

  ///Hace login en la autentificación y coloca el usuario en el provider
  Future<User?> login(
      {required String email,
      required String password,
      required UsersData providerUser,
      required BuildContext context}) async {
    FirebaseAuth firebaseAuth = FirebaseAuth.instance;
    User? user;
    try {
      UserCredential userCredential = await firebaseAuth
          .signInWithEmailAndPassword(email: email, password: password);
      user = userCredential.user;
      if (user!.emailVerified) {
        final SharedPreferences sharedPreferences =
            await SharedPreferences.getInstance();
        sharedPreferences.setString("usermail", email.trim());
        await _storage.write(key: "password", value: password.trim());
        await providerUser.setUserByEmail(email.trim(), user.uid);
        return user;
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text("Verify your email. Check spam if you don´t se it")));
        await FirebaseAuth.instance.signOut();
      }
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.message!)));
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    UsersData providerUser = Provider.of<UsersData>(context, listen: false);
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: SizedBox()),
        Text(
          "New user?",
          style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
        ),
        Text(
          "Login or register",
          style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
        ),
        Container(
          margin: EdgeInsets.only(top: 30),
          child: TextField(
            maxLength: 100,
            controller: emailtextEditingController,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
                counterText: '',
                hintText: "YOUR EMAIL",
                prefixIcon: Icon(
                  Icons.mail,
                  color: Colors.black87,
                )),
          ),
        ),
        Container(
          margin: EdgeInsets.only(top: 15, bottom: 5),
          child: TextField(
            controller: passwdtextEditingController,
            obscureText: notvisiblepassword,
            maxLength: 30,
            decoration: InputDecoration(
                counterText: '',
                hintText: "YOUR PASSWORD",
                prefixIcon: IconButton(
                    onPressed: () => setState(
                          () {
                            notvisiblepassword = !notvisiblepassword;
                          },
                        ),
                    icon: Icon(Icons.remove_red_eye_outlined))),
          ),
        ),
        Container(
          height: 20,
          child: GestureDetector(
            onTap: () => {Navigator.of(context).pushNamed("forgot")},
            child: Text(
              "You forgot your password? Let me help you",
              style: TextStyle(color: Colors.blueAccent),
            ),
          ),
        ),
        Container(
          margin: EdgeInsets.only(top: 50),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: Container(
              color: Colors.black87,
              width: double.infinity,
              child: TextButton(
                onPressed: () async {
                  User? user = await login(
                      email: emailtextEditingController.text.trim(),
                      password: passwdtextEditingController.text.trim(),
                      providerUser: providerUser,
                      context: context);
                  if (user != null) {
                    Navigator.of(context).pushReplacementNamed("main");
                  }
                },
                child: Text(
                  "Login",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ),
        ),
        Expanded(child: SizedBox()),
        GestureDetector(
          onTap: () => {Navigator.of(context).pushNamed("register")},
          child: Container(
            height: 40,
            child: Text(
              "Not a member? Register now It´s free (;",
              style: TextStyle(color: Colors.blueAccent),
            ),
          ),
        ),
      ],
    );
  }
}
