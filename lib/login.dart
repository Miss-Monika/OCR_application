// import 'package:day_24/themes/theme_model.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:ocr_application/index.dart';
import 'package:ocr_application/signup.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String? _email, _password;
  Future<UserCredential> googleSignIn() async {
    GoogleSignIn googleSignIn = GoogleSignIn();
    GoogleSignInAccount? googleUser = await googleSignIn.signIn();
    if (googleUser != null) {
      GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      if (googleAuth.idToken != null && googleAuth.accessToken != null) {
        final AuthCredential credential = GoogleAuthProvider.credential(
            accessToken: googleAuth.accessToken, idToken: googleAuth.idToken);

        final UserCredential user =
            await _auth.signInWithCredential(credential);

        await Navigator.push(
            context, MaterialPageRoute(builder: (context) => Index()));
        return user;
      } else {
        throw StateError('Missing Google Auth Token');
      }
    } else
      throw StateError('Sign in Aborted');
  }

  login() async {
    if (_formKey != null &&
        _formKey.currentState != null &&
        _formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      try {
        await _auth.signInWithEmailAndPassword(
            email: _email!, password: _password!);
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => Index()));
      } catch (e) {
        showError("Error here");
      }
    }
  }

  showError(String errormessage) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('ERROR'),
          content: Text(errormessage),
          actions: <Widget>[
            FlatButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                'OK',
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(
            Icons.arrow_back_ios,
            size: 20,
            color: Colors.black,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          width: size.width,
          height: size.height,
          padding: EdgeInsets.only(
              left: 20,
              right: 20,
              bottom: size.height * 0.2,
              top: size.height * 0.05),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Hello, \nWelcome Back",
                style: Theme.of(context).textTheme.headline1!.copyWith(
                      fontSize: size.width * 0.1,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      GestureDetector(
                        child: Image(
                          width: 30,
                          image: AssetImage('assets/google.png'),
                        ),
                        onTap: googleSignIn,
                      ),
                      SizedBox(width: 40),
                      Image(width: 30, image: AssetImage('assets/facebook.png'))
                    ],
                  ),
                  SizedBox(
                    height: 50,
                  ),
                  Form(
                    key: _formKey,
                    child: Column(
                      children: <Widget>[
                        Container(
                          padding:
                              EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                          decoration: BoxDecoration(
                              color: Colors.grey.shade200,
                              borderRadius:
                                  BorderRadius.all(Radius.circular(20))),
                          child: TextFormField(
                            validator: (input) {
                              if (input != null && input.isEmpty)
                                return "Enter Email";
                            },
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText: "Email or Phone number",
                              prefixIcon: Icon(Icons.email),
                            ),
                            onSaved: (input) => _email = input!,
                          ),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        Container(
                          padding:
                              EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                          decoration: BoxDecoration(
                              color: Colors.grey.shade200,
                              borderRadius:
                                  BorderRadius.all(Radius.circular(20))),
                          child: TextFormField(
                            validator: (input) {
                              if (input != null && input.isEmpty)
                                return "Enter Email";
                            },
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText: "Password",
                              prefixIcon: Icon(Icons.lock),
                            ),
                            obscureText: true,
                            onSaved: (input) => _password = input!,
                          ),
                        ),
                        // Container(
                        //   child: TextFormField(
                        //     validator: (input) {
                        //       if (input != null && input.length < 6)
                        //         return "Provide Minimum 6 character";
                        //     },
                        //     decoration: InputDecoration(
                        //       labelText: "Password",
                        //       prefixIcon: Icon(Icons.lock),
                        //       contentPadding: EdgeInsets.symmetric(
                        //         vertical: 10,
                        //         horizontal: 10,
                        //       ),
                        //       enabledBorder: (OutlineInputBorder(
                        //         borderSide: BorderSide(
                        //           color: Colors.grey,
                        //         ),
                        //       )),
                        //     ),
                        //     obscureText: true,
                        //     onSaved: (input) => _password = input!,
                        //   ),
                        // ),
                        SizedBox(height: 20.0),
                        // Container(
                        //     child: SignInButton(Buttons.Google,
                        //         text: "Log In with Google",
                        //         onPressed: googleSignIn)),
                      ],
                    ),
                  ),
                  // Container(
                  //   padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                  //   decoration: BoxDecoration(
                  //       color: Colors.grey.shade200,
                  //       borderRadius: BorderRadius.all(Radius.circular(20))),
                  //   child: TextField(
                  //     decoration: InputDecoration(
                  //       border: InputBorder.none,
                  //       hintText: "Email or Phone number",
                  //       prefixIcon: Icon(Icons.email),
                  //     ),
                  //   ),
                  // ),
                  // SizedBox(
                  //   height: 20,
                  // ),
                  // Container(
                  //   padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                  //   decoration: BoxDecoration(
                  //       color: Colors.grey.shade200,
                  //       borderRadius: BorderRadius.all(Radius.circular(20))),
                  //   child: TextField(
                  //     obscureText: true,
                  //     decoration: InputDecoration(
                  //         border: InputBorder.none,
                  //         hintText: "Password",
                  //         prefixIcon: Icon(Icons.lock)),
                  //   ),
                  // ),
                  // SizedBox(
                  //   height: 20,
                  // ),
                  Text(
                    "Forgot Password?",
                    style: Theme.of(context).textTheme.bodyText1,
                  )
                ],
              ),
              Column(
                children: [
                  RaisedButton(
                    onPressed: login,
                    elevation: 0,
                    padding: EdgeInsets.all(18),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20)),
                    color: Colors.grey.shade900,
                    child: Center(
                        child: Text(
                      "Login",
                      style: TextStyle(
                          fontWeight: FontWeight.bold, color: Colors.white),
                    )),
                  ),
                  SizedBox(
                    height: 30,
                  ),
                  // Text("Create account",
                  //     style: Theme.of(context).textTheme.bodyText1)
                  GestureDetector(
                      child: Text(
                        "Create Account",
                        style: Theme.of(context).textTheme.bodyText1,
                      ),
                      onTap: () {
                        Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                                builder: (context) => SignUpPage()),
                            (route) => false);
                      }),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
