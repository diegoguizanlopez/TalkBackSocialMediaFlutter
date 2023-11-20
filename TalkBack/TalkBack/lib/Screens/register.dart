import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:TalkBack/Provider/export_provider.dart';

class Register extends StatelessWidget {
  const Register({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: _screenRegister());
  }
}

class _screenRegister extends StatefulWidget {
  const _screenRegister({Key? key}) : super(key: key);

  @override
  State<_screenRegister> createState() => _screenRegisterState();
}

class _screenRegisterState extends State<_screenRegister> {
  TextEditingController emailtextEditingController = TextEditingController();
  TextEditingController passwdtextEditingController = TextEditingController();
  TextEditingController confirmpasswdtextEditingController =
      TextEditingController();
  TextEditingController username = TextEditingController();
  bool notvisiblepassword = true;

  @override
  void dispose() {
    emailtextEditingController.dispose();
    passwdtextEditingController.dispose();
    confirmpasswdtextEditingController.dispose();
    username.dispose();
    super.dispose();
  }

  ///Registra el usuario en la Auth pero debe ser confirmado para iniciar sesión
  Future register(
      {required String email,
      required String password,
      required String userName,
      required UsersData provider}) async {
    try {
      UserCredential user = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
              email: email.trim(), password: password.trim());
      await user.user!.sendEmailVerification();
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Your verification email has been send")));
      provider.writeUser(name: userName, email: email);
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.message!)));
    }
  }

  @override
  Widget build(BuildContext context) {
    UsersData prov = Provider.of<UsersData>(context);
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
              margin: EdgeInsets.only(top: 20),
              child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    child: IconButton(
                        icon: Icon(
                          Icons.arrow_back,
                          color: Colors.white,
                        ),
                        onPressed: () => {Navigator.of(context).pop()}),
                    color: Colors.black,
                  ))),
          Expanded(child: Container()),
          Text(
            "Register now",
            style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
          ),
          Text(
            "and enjoy",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          Container(
            margin: EdgeInsets.only(top: 20),
            child: TextField(
                maxLength: 100,
                controller: username,
                decoration: InputDecoration(
                    counterText: '',
                    hintText: "USER NAME",
                    prefixIcon: Icon(
                      Icons.person,
                      color: Colors.black,
                    ))),
          ),
          Container(
            margin: EdgeInsets.only(top: 20, bottom: 5),
            child: TextField(
                controller: emailtextEditingController,
                decoration: InputDecoration(
                    counterText: '',
                    hintText: "YOUR EMAIL",
                    prefixIcon: Icon(
                      Icons.mail,
                      color: Colors.black,
                    ))),
          ),
          Container(
            margin: EdgeInsets.only(top: 15, bottom: 5),
            child: TextField(
              maxLength: 30,
              controller: passwdtextEditingController,
              obscureText: notvisiblepassword,
              decoration: InputDecoration(
                  counterText: '',
                  hintText: "YOUR PASSWORD",
                  prefixIcon: IconButton(
                      onPressed: () => setState(
                            () {
                              notvisiblepassword = !notvisiblepassword;
                            },
                          ),
                      icon: Icon(Icons.remove_red_eye_outlined,
                          color: Colors.black))),
            ),
          ),
          Container(
            margin: EdgeInsets.only(top: 15, bottom: 5),
            child: TextField(
                maxLength: 30,
                controller: confirmpasswdtextEditingController,
                obscureText: notvisiblepassword,
                decoration: InputDecoration(
                    counterText: '',
                    hintText: "CONFIRM YOUR PASSWORD",
                    prefixIcon: Icon(Icons.password, color: Colors.black))),
          ),
          Container(
              margin: EdgeInsets.only(top: 30),
              child: ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: Container(
                    height: 40,
                    width: double.infinity,
                    color: Colors.black,
                    child: TextButton(
                      onPressed: () => {
                        passwdtextEditingController.text ==
                                confirmpasswdtextEditingController.text
                            ? register(
                                email: emailtextEditingController.text,
                                password: passwdtextEditingController.text,
                                userName: username.text,
                                provider: prov)
                            : ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                    content:
                                        Text("NOT SAME PASSWORD CHECK VALUES")))
                      },
                      child: Text("Register",
                          style: TextStyle(color: Colors.white)),
                    ),
                  ))),
          Expanded(child: Container()),
        ],
      ),
    );
  }
}
