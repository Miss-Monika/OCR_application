// import 'package:day_24/themes/theme_model.dart';
import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server/gmail.dart';
import 'package:ocr_application/index.dart';
import 'package:ocr_application/login.dart';
import 'package:ocr_application/verifyUserLogin.dart';
import 'package:google_sign_in/google_sign_in.dart';

class SignUpPage extends StatefulWidget {
  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String? _email, _password, _name, _password2;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  checkAuthentification() async {
    _auth.authStateChanges().listen((user) async {
      if (user != null) {
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => Index()));
      }
    });
  }

  signUp() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
    }
    try {
      UserCredential user = await _auth.createUserWithEmailAndPassword(
          email: _email!, password: _password!);
      if (user != null) {
        await _auth.currentUser?.updateProfile(displayName: _name);
      }
    } catch (e) {
      showError("Error Here");
    }
  }

  Future<void> sendMail(String email, String personName, String code) async {
    String username = 'goswamipranav11@gmail.com';
    String password = 'Pranav@2002';

    final smtpServer = gmail(username, password);
    // Use the SmtpServer class to configure an SMTP server:
    // final smtpServer = SmtpServer('smtp.domain.com');
    // See the named arguments of SmtpServer for further configuration
    // options.

    // Create our message.
    final message = Message()
      ..from = Address(username, username.toString())
      ..recipients.add(email)
      // ..ccRecipients.addAll(['destCc1@example.com', 'destCc2@example.com'])
      // ..bccRecipients.add(Address('bccAddress@example.com'))
      ..subject = 'No reply mail From OCR Application::  ${DateTime.now()}'
      ..text = 'Heyy ' +
          personName +
          '!' +
          '\nThe mail is from admin OCR Application ' +
          ' on ${DateTime.now()}' +
          '\nYour 4 digit one time password is' +
          '\n' +
          code.toString() +
          '\nRegards.';
    // ..html = "<h1>Test</h1>\n<p>Hey! Here's some HTML content</p>";

    try {
      final sendReport = await send(message, smtpServer);
      print('Message sent: ' + sendReport.toString());
    } on MailerException catch (e) {
      print('Message not sent.');
      for (var p in e.problems) {
        print('Problem: ${p.code}: ${p.msg}');
      }
    }
    // DONE

    // Let's send another message using a slightly different syntax:
    //
    // Addresses without a name part can be set directly.
    // For instance `..recipients.add('destination@example.com')`
    // If you want to display a name part you have to create an
    // Address object: `new Address('destination@example.com', 'Display name part')`
    // Creating and adding an Address object without a name part
    // `new Address('destination@example.com')` is equivalent to
    // adding the mail address as `String`.

    // final equivalentMessage = Message()
    //   ..from = Address(username, 'Your name 😀')
    //   ..recipients.add(Address('goswamipranav11@gmail.com'))
    //   // ..ccRecipients
    //   //     .addAll([Address('destCc1@example.com'), 'destCc2@example.com'])
    //   // ..bccRecipients.add('bccAddress@example.com')
    //   ..subject = 'Test Dart Mailer library :: 😀 :: ${DateTime.now()}'
    //   ..text = 'This is the plain text.\nThis is line 2 of the text part.'
    //   ..html =
    //       '<h1>Test</h1>\n<p>Hey! Here is some HTML content</p><img src="cid:myimg@3.141"/>'
    //   ..attachments = [
    //     // FileAttachment(File('exploits_of_a_mom.png'))
    //     //   ..location = Location.inline
    //     //   ..cid = '<myimg@3.141>'
    //   ];

    final sendReport2 = await send(message, smtpServer);

    // Sending multiple messages with the same connection
    //
    // Create a smtp client that will persist the connection
    var connection = PersistentConnection(smtpServer);

    // Send the first message
    await connection.send(message);

    // send the equivalent message
    // await connection.send(equivalentMessage);

    // close the connection
    await connection.close();
  }

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

  sendOTP() async {
    _formKey.currentState?.save();

    if (_email == null ||
        _name == null ||
        _password == null ||
        _password2 == null) {
      print("here it is");
      showError("Please fill the details!!");
    } else {
      if (_password == _password2) {
        var rng = new Random();
        var code = rng.nextInt(9999);
        if (code < 1000) {
          code = code + 1000;
        }
        sendMail(_email!, _name!, code.toString());
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
                builder: (context) => VerifyUserLogin(
                      email: _email!,
                      name: _name!,
                      otp: code.toString(),
                      password: _password!,
                    )),
            (route) => false);
      } else {
        showError("Password and Confirm Password are different");
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
                "Create your account!",
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
                              hintText: "Username",
                              prefixIcon: Icon(Icons.person),
                            ),
                            onSaved: (input) => _name = input!,
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
                              hintText: "Confirm Password",
                              prefixIcon: Icon(Icons.lock),
                            ),
                            obscureText: true,
                            onSaved: (input) => _password2 = input!,
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
                  // decoration: InputDecoration(
                  //   border: InputBorder.none,
                  //   hintText: "Username",
                  //   prefixIcon: Icon(Icons.person),
                  // ),
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
                  //       border: InputBorder.none,
                  //       hintText: "Password",
                  //       prefixIcon: Icon(Icons.lock),
                  //     ),
                  //   ),
                  // ),
                  // SizedBox(
                  //   height: 10,
                  // ),
                  // Text(
                  //   "Forgot Password?",
                  //   style: Theme.of(context).textTheme.bodyText1,
                  // )
                ],
              ),
              Column(
                children: [
                  RaisedButton(
                    onPressed: sendOTP,
                    elevation: 0,
                    padding: EdgeInsets.all(18),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20)),
                    color: Colors.grey.shade900,
                    child: Center(
                        child: Text(
                      "SignUp",
                      style: TextStyle(
                          fontWeight: FontWeight.bold, color: Colors.white),
                    )),
                  ),
                  SizedBox(
                    height: 30,
                  ),
                  // Text("Already have an account? Create account",
                  //     style: Theme.of(context).textTheme.bodyText1)
                  // Text("Already have an account?"),
                  GestureDetector(
                      child: Text(
                        "Already have an account? Login",
                        style: Theme.of(context).textTheme.bodyText1,
                      ),
                      onTap: () {
                        Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                                builder: (context) => LoginPage()),
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
