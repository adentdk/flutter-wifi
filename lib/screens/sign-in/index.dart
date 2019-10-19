import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';

GoogleSignIn _googleSignIn = GoogleSignIn(scopes: ['email']);

class SignIn extends StatefulWidget {
  @override
  _SignInState createState() => _SignInState();
}


class _SignInState extends State<SignIn> {
  GoogleSignInAccount _currentUser;

  void initState() {
    _googleSignIn.onCurrentUserChanged.listen((GoogleSignInAccount account) {
      setState(() {
        _currentUser = account;
      });
    });
    _googleSignIn.signInSilently();
  }

  handleNavigate() {
    Navigator.pushNamed(context, '/');
  }
  
  Future<void> _handleSignIn() async {
    try {
      _currentUser = await _googleSignIn.signIn();
      print("success");
      // _signInWithGoogle(_currentUser);
    } catch (error) {
      print(error);
    }
  }

  Future<Null> _signInWithGoogle(GoogleSignInAccount _googleAccount) async {
    if (_googleAccount == null) {
      _googleAccount = await _googleSignIn.signIn();
    }
    FirebaseAuth _auth = FirebaseAuth.instance;
    GoogleSignInAuthentication _googleAuth = await _googleAccount.authentication; 
    AuthCredential credential = GoogleAuthProvider.getCredential(accessToken: _googleAuth.accessToken, idToken: _googleAuth.idToken);
    print(_googleAuth.accessToken);
    return await _auth.signInWithCredential(credential);
  }



  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text("Ada Wifi"),
            Text("ada wifi disini"),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                GestureDetector(
                  child: Container(
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
                ),
                GestureDetector(
                  onTap: _handleSignIn,
                  child: Container(
                    width: 63.02,
                    height: 63.02,
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        image: DecorationImage(
                            fit: BoxFit.fill,
                            image: AssetImage("assets/images/mtr_sosmed_g+.png")
                        )
                    )
                  )
                )
              ])
          ],)
        )
    );
  }
}