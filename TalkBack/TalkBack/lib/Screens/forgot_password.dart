import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ForgotPassword extends StatelessWidget {
  const ForgotPassword({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: reset_password(),
    );
  }
}

class reset_password extends StatefulWidget {
  const reset_password({Key? key}) : super(key: key);

  @override
  State<reset_password> createState() => _reset_passwordState();
}

class _reset_passwordState extends State<reset_password> {
  TextEditingController emailtextEditingController = TextEditingController();

  ///Método para mandar Email de reseteo
  Future passwordReset() async {
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: emailtextEditingController.text.trim());
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Check your email ${emailtextEditingController.text.trim()}")));
      Navigator.of(context).pop();
    }on FirebaseAuthException catch(e){
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.message!)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(20),
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
            "Put your email",
            style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
          ),
          Container(
            margin: EdgeInsets.only(top: 20, bottom: 5),
            child: TextField(
                maxLength: 100,
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
              margin: EdgeInsets.only(top: 30),
              child: ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: Container(
                    width: double.infinity,
                    color: Colors.black,
                    child: TextButton(
                      onPressed: () => {passwordReset()},
                      child: Text("Reset password",
                          style: TextStyle(color: Colors.white)),
                    ),
                  ))),
          Expanded(child: Container()),
        ],
      ),
    );
  }
}
