import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_signin_button/flutter_signin_button.dart';
import 'package:firebase_auth/firebase_auth.dart';
// import 'package:loginapp/login.dart';
// import 'package:loginapp/userProfile.dart';
// import 'package:loginapp/verifyOTP.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server/gmail.dart';
import 'package:ocr_application/verifyOTP.dart';
import 'main.dart';
import 'index.dart';
import 'package:google_sign_in/google_sign_in.dart';

class UpdateEmail extends StatefulWidget {
  @override
  State<UpdateEmail> createState() => _UpdateEmailState();
}

class _UpdateEmailState extends State<UpdateEmail> {
  @override
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late String _name, _name2;
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
      ..subject = 'No reply mail From Library IITJ::  ${DateTime.now()}'
      ..text = 'Heyy ' +
          personName +
          '!' +
          '\nThe mail is from admin @Library IITJ ' +
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

  updateEmail() async {
    _formKey.currentState?.save();
    print(_name);
    print(_name2);
    if (_name == _name2) {
      // FirebaseAuth.instance.currentUser.updateEmail(_name).then(
      //       (value) => {print("here")},
      //     );
      var rng = new Random();
      var code = rng.nextInt(9999);
      if (code < 1000) {
        code = code + 1000;
      }
      sendMail(_name, FirebaseAuth.instance.currentUser!.displayName!,
          code.toString());
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) =>
              Verificatoin(otp: code.toString(), email: _name),
        ),
        (route) => false,
      );
    } else {
      showError("Email and Confirm Email are different");
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
  void initState() {
    super.initState();
  }

  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        brightness: Brightness.light,
        backgroundColor: Colors.white,
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
          padding: EdgeInsets.symmetric(
            horizontal: 40,
          ),
          height: MediaQuery.of(context).size.height - 50,
          width: double.infinity,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              Column(
                children: <Widget>[
                  Text(
                    "Update Email",
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                ],
              ),
              Column(
                children: <Widget>[
                  // makeInput(label: "Email"),
                  // makeInput(label: "Password", obscureText: true),
                  // makeInput(label: "Confirm Password", obscureText: true),
                  Container(
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: <Widget>[
                          Container(
                            child: TextFormField(
                              validator: (input) {
                                if (input != null && input.isEmpty)
                                  return "Enter Name";
                              },
                              decoration: InputDecoration(
                                labelText: "Email",
                                prefixIcon: Icon(Icons.email),
                                contentPadding: EdgeInsets.symmetric(
                                    vertical: 30, horizontal: 10),
                                enabledBorder: (OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(50),
                                  borderSide: BorderSide(
                                    color: Colors.grey,
                                  ),
                                )),
                              ),
                              onSaved: (input) => _name = input!,
                            ),
                          ),
                          SizedBox(height: 10),
                          Container(
                            child: TextFormField(
                              validator: (input) {
                                if (input != null && input.isEmpty)
                                  return "Confirm Username";
                              },
                              decoration: InputDecoration(
                                labelText: "Confirm Email",
                                prefixIcon: Icon(Icons.email),
                                contentPadding: EdgeInsets.symmetric(
                                    vertical: 30, horizontal: 10),
                                enabledBorder: (OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(50),
                                  borderSide: BorderSide(
                                    color: Colors.grey,
                                  ),
                                )),
                              ),
                              onSaved: (input) => _name2 = input!,
                            ),
                          ),
                          // SizedBox(height: 10),
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
                          //           vertical: 30, horizontal: 10),
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
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              Column(
                children: [
                  Container(
                    padding: EdgeInsets.only(top: 3, left: 3),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(50),
                      border: Border(
                        bottom: BorderSide(color: Colors.black),
                        top: BorderSide(color: Colors.black),
                        left: BorderSide(color: Colors.black),
                        right: BorderSide(color: Colors.black),
                      ),
                    ),
                    child: MaterialButton(
                      minWidth: double.infinity,
                      height: 60,
                      onPressed: updateEmail,
                      color: Colors.black,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          50,
                        ),
                      ),
                      child: Text(
                        "Update",
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 18,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  // Row(
                  //   mainAxisAlignment: MainAxisAlignment.center,
                  //   children: <Widget>[
                  //     Text("Already have an account?"),
                  //     GestureDetector(
                  //         child: Text(
                  //           "  Login",
                  //           style: TextStyle(
                  //             fontWeight: FontWeight.w600,
                  //             fontSize: 18,
                  //           ),
                  //         ),
                  //         onTap: () {
                  //           Navigator.pushAndRemoveUntil(
                  //               context,
                  //               MaterialPageRoute(
                  //                   builder: (context) => LoginPage()),
                  //               (route) => false);
                  //         }),
                  //   ],
                  // ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget makeInput({label, obscureText = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          label,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w400,
            color: Colors.black87,
          ),
        ),
        SizedBox(
          height: 5,
        ),
        TextField(
          obscureText: obscureText,
          decoration: InputDecoration(
            contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 10),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: Colors.grey,
              ),
            ),
            border: OutlineInputBorder(
              borderSide: BorderSide(
                color: Colors.grey,
              ),
            ),
          ),
        ),
        SizedBox(
          height: 30,
        ),
      ],
    );
  }
}
