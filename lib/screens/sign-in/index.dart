import 'package:flutter/material.dart';

class SignIn extends StatefulWidget {
  @override
  _SignInState createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        alignment: Alignment.center,
        child: Column(
          children: <Widget>[
            Text("Ada Wifi"),
            Text("ada wifi disini"),
            Row(
              children: <Widget>[
                Container(
                  width: 63.02,
                  height: 63.02,
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      image: DecorationImage(
                          fit: BoxFit.fill,
                          image: AssetImage("assets/images/mtr_sosmed_fb.png")
                      )
                  )
                )
                
              ])
          ],)
        )
    );
  }
}