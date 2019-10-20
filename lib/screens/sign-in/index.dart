import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:device_id/device_id.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
 
// GoogleSignIn _googleSignIn = GoogleSignIn(scopes: ['email']);

class SignIn extends StatefulWidget {
  @override
  _SignInState createState() => _SignInState();
}


class _SignInState extends State<SignIn> {
  String deviceId;
  final GoogleSignIn _googleSignIn = GoogleSignIn(scopes: [
    'email'
  ],);
  final FirebaseAuth _auth = FirebaseAuth.instance;
  // GoogleSignInAccount _currentUser;

  void initState() {
    super.initState();
    _getDeviceId();
  }

  void _getDeviceId() async {
    String id = await DeviceId.getID;
    setState(() {
      deviceId = id;
    });
    // var url = "http://adawifi.api.meteor.co.id/check-auth?device_id=$device_id";
    // var response = await http.get(url);
    // print("================================");
    // print(response);
  }

  handleNavigate() {
    Navigator.pushReplacementNamed(context, "/");
  }
  
  Future<FirebaseUser> _handleSignIn() async {
    try {
      bool isSignIn = await _googleSignIn.isSignedIn();
      if (isSignIn) {
        await _googleSignIn.signOut();
      }
      final GoogleSignInAccount googleUser = await _googleSignIn.signIn();
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      final AuthCredential credential = GoogleAuthProvider.getCredential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final FirebaseUser user = (await _auth.signInWithCredential(credential)).user;
      final IdTokenResult idTokenResult = await user.getIdToken(refresh: true);
      String idToken = idTokenResult.token;
      var url = DotEnv().env['BASE_URL'] + "verify-token?idToken=$idToken";
      var response = await http.get(url);

        if (response.statusCode == 200) {
          var url1 = DotEnv().env['BASE_URL'] + "check-auth?deviceId=$deviceId";
          var response1 = await http.get(url1);

          if (response1.statusCode == 200) {
            print("user already - sign in");
            handleNavigate();
          } else {
            var email = googleUser.email;
            var name = googleUser.displayName;
            var url2 = DotEnv().env['BASE_URL'] + "create-user?email=$email&name=$name&deviceId=$deviceId";
            var response2 = await http.get(url2);

            if (response2.statusCode == 200) {
              print("user created - sign in");
              handleNavigate();
            } else {
              throw("error when created user");
            }
          }

        } else {
          throw("token is invalid");
        }
      print("============================================");
      return user;
    } catch (e) {
      print(e);
      return null;
    }
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