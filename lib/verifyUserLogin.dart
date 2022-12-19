import 'dart:math';

import 'package:animate_do/animate_do.dart';
// import 'package:firebaseFireBaseAuth.instance/firebaseFireBaseAuth.instance.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter_verification_code/flutter_verification_code.dart';
import 'package:ocr_application/index.dart';
// import 'package:loginapp/userProfile.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server/gmail.dart';

class VerifyUserLogin extends StatefulWidget {
  // const VerifyUserLogin({Key? key}) : super(key: key);
  final String otp;
  final String email;
  final String password;
  final String name;

  @override
  _VerifyUserLoginState createState() => _VerifyUserLoginState();
  VerifyUserLogin(
      {required this.otp,
      required this.email,
      required this.password,
      required this.name});
}

class _VerifyUserLoginState extends State<VerifyUserLogin> {
  bool _isResendAgain = false;
  bool _isVerified = false;
  bool _isLoading = false;

  String _code = '';

  late Timer _timer;
  int _start = 60;
  int _currentIndex = 0;
  int _isResend = 0;
  late int _resentCode;
  void resend() {
    setState(() async {
      _isResend = 1;
      Future<void> sendMail(
          String email, String? personName, String code) async {
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
              personName! +
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

        // final sendReport2 = await send(message, smtpServer);

        // Sending multiple messages with the same connection
        //
        // Create a smtp client that will persist the connection
        var connection = PersistentConnection(smtpServer);

        // Send the first message
        // await connection.send(message);

        // send the equivalent message
        // await connection.send(equivalentMessage);

        // close the connection
        await connection.close();
      }

      var rng = new Random();
      var code = rng.nextInt(9999);
      if (code < 1000) {
        code = code + 1000;
      }
      _resentCode = code;
      await sendMail(widget.email,
          FirebaseAuth.instance.currentUser!.displayName, code.toString());
    });

    const oneSec = Duration(seconds: 1);
    _timer = new Timer.periodic(oneSec, (timer) {
      setState(() {
        if (_start == 0) {
          _start = 60;
          _isResendAgain = false;
          timer.cancel();
        } else {
          _start--;
        }
      });
    });
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

  signUp() async {
    try {
      UserCredential user = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
              email: widget.email, password: widget.password);
      if (user != null) {
        await FirebaseAuth.instance.currentUser
            ?.updateProfile(displayName: widget.name);
      }
    } catch (e) {
      showError("Error Here");
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

  verify() {
    print("idahr aa rha hai");
    setState(() {
      _isLoading = true;
      if (_isResend == 0) {
        if (_code == widget.otp) {
          setState(() {
            _isLoading = false;
            _isVerified = true;
          });
          print("hereItIs");
          _isResendAgain = true;
          // FirebaseAuth.instance.currentUser.updateEmail(widget.email).then(
          //       (value) => {print("Email Updated")},
          //     );
          signUp();
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (context) => Index(),
            ),
            (route) => false,
          );
        } else {
          showError("Invalid OTP");
        }
      } else {
        if (_code == _resentCode) {
          setState(() {
            _isLoading = false;
            _isVerified = true;
          });
          print("hereItIs");
          _isResendAgain = true;
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (context) => Index(),
            ),
            (route) => false,
          );
        } else {
          showError("Invalid OTP");
        }
      }
    });

    const oneSec = Duration(milliseconds: 2000);
    _timer = new Timer.periodic(oneSec, (timer) {});
  }

  @override
  void initState() {
    Timer.periodic(Duration(seconds: 5), (timer) {
      setState(() {
        _currentIndex++;

        if (_currentIndex == 3) _currentIndex = 0;
      });
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        body: SingleChildScrollView(
          child: Container(
              padding: EdgeInsets.symmetric(horizontal: 20),
              height: MediaQuery.of(context).size.height,
              width: double.infinity,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    height: 250,
                    child: Stack(children: [
                      Positioned(
                        top: 0,
                        left: 0,
                        right: 0,
                        bottom: 0,
                        child: AnimatedOpacity(
                          opacity: _currentIndex == 0 ? 1 : 0,
                          duration: Duration(
                            seconds: 1,
                          ),
                          curve: Curves.linear,
                          child: Image.network(
                            'https://ouch-cdn2.icons8.com/eza3-Rq5rqbcGs4EkHTolm43ZXQPGH_R4GugNLGJzuo/rs:fit:784:784/czM6Ly9pY29uczgu/b3VjaC1wcm9kLmFz/c2V0cy9zdmcvNjk3/L2YzMDAzMWUzLTcz/MjYtNDg0ZS05MzA3/LTNkYmQ0ZGQ0ODhj/MS5zdmc.png',
                          ),
                        ),
                      ),
                      Positioned(
                        top: 0,
                        left: 0,
                        right: 0,
                        bottom: 0,
                        child: AnimatedOpacity(
                          opacity: _currentIndex == 1 ? 1 : 0,
                          duration: Duration(seconds: 1),
                          curve: Curves.linear,
                          child: Image.network(
                            'https://ouch-cdn2.icons8.com/pi1hTsTcrgVklEBNOJe2TLKO2LhU6OlMoub6FCRCQ5M/rs:fit:784:666/czM6Ly9pY29uczgu/b3VjaC1wcm9kLmFz/c2V0cy9zdmcvMzAv/MzA3NzBlMGUtZTgx/YS00MTZkLWI0ZTYt/NDU1MWEzNjk4MTlh/LnN2Zw.png',
                          ),
                        ),
                      ),
                      Positioned(
                        top: 0,
                        left: 0,
                        right: 0,
                        bottom: 0,
                        child: AnimatedOpacity(
                          opacity: _currentIndex == 2 ? 1 : 0,
                          duration: Duration(seconds: 1),
                          curve: Curves.linear,
                          child: Image.network(
                            'https://ouch-cdn2.icons8.com/ElwUPINwMmnzk4s2_9O31AWJhH-eRHnP9z8rHUSS5JQ/rs:fit:784:784/czM6Ly9pY29uczgu/b3VjaC1wcm9kLmFz/c2V0cy9zdmcvNzkw/Lzg2NDVlNDllLTcx/ZDItNDM1NC04YjM5/LWI0MjZkZWI4M2Zk/MS5zdmc.png',
                          ),
                        ),
                      )
                    ]),
                  ),
                  SizedBox(
                    height: 30,
                  ),
                  FadeInDown(
                      duration: Duration(milliseconds: 500),
                      child: Text(
                        "Verification",
                        style: TextStyle(
                            fontSize: 30, fontWeight: FontWeight.bold),
                      )),
                  SizedBox(
                    height: 30,
                  ),
                  FadeInDown(
                    delay: Duration(milliseconds: 500),
                    duration: Duration(milliseconds: 500),
                    child: Text(
                      "Please enter the 4 digit code sent to \n your previous email",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey.shade500,
                          height: 1.5),
                    ),
                  ),
                  SizedBox(
                    height: 30,
                  ),

                  // Verification Code Input
                  FadeInDown(
                    delay: Duration(milliseconds: 600),
                    duration: Duration(milliseconds: 500),
                    child: VerificationCode(
                      length: 4,
                      textStyle: TextStyle(fontSize: 20, color: Colors.black),
                      underlineColor: Colors.black,
                      keyboardType: TextInputType.number,
                      underlineUnfocusedColor: Colors.black,
                      onCompleted: (value) {
                        setState(() {
                          _code = value;
                        });
                      },
                      onEditing: (value) {},
                    ),
                  ),

                  SizedBox(
                    height: 20,
                  ),
                  FadeInDown(
                    delay: Duration(milliseconds: 700),
                    duration: Duration(milliseconds: 500),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Don't recive the OTP?",
                          style: TextStyle(
                              fontSize: 14, color: Colors.grey.shade500),
                        ),
                        TextButton(
                            onPressed: () {
                              if (_isResendAgain) return;
                              resend();
                            },
                            child: Text(
                              _isResendAgain
                                  ? "Try again in " + _start.toString()
                                  : "Resend",
                              style: TextStyle(color: Colors.black),
                            ))
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 50,
                  ),
                  FadeInDown(
                    delay: Duration(milliseconds: 800),
                    duration: Duration(milliseconds: 500),
                    child: MaterialButton(
                      elevation: 0,
                      onPressed: _code.length < 4
                          ? () => {}
                          : () {
                              verify();
                            },
                      color: Colors.black,
                      minWidth: MediaQuery.of(context).size.width * 0.8,
                      height: 50,
                      child: _isLoading
                          ? Container(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                backgroundColor: Colors.white,
                                strokeWidth: 3,
                                color: Colors.black,
                              ),
                            )
                          : _isVerified
                              ? Icon(
                                  Icons.check_circle,
                                  color: Colors.white,
                                  size: 30,
                                )
                              : Text(
                                  "Verify",
                                  style: TextStyle(color: Colors.white),
                                ),
                    ),
                  )
                ],
              )),
        ));
  }

  showAlertDialog(BuildContext context) {
    // set up the button
    // Widget logOutButton = SalomonBottomBarItem(
    //   icon: Icon(Icons.logout),
    //   title: Text("LogOut"),
    //   selectedColor: Colors.redAccent,
    // );
    // Widget okButton = TextButton(
    //   child: Text("Logout"),
    //   onPressed: () {
    //     // Navigator.push(
    //     //     context, MaterialPageRoute(builder: (context) => HomePage()));

    //   },
    // );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("Incorrect OTP"),
      content: Text("Please fill the correct otp"),
      actions: [],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }
}
