import 'package:flutter/material.dart';
import 'package:flutter_signin_button/flutter_signin_button.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:ocr_application/userProfile.dart';
import 'main.dart';
import 'index.dart';
import 'package:google_sign_in/google_sign_in.dart';

class UpdatePassword extends StatefulWidget {
  @override
  State<UpdatePassword> createState() => _UpdatePasswordState();
}

class _UpdatePasswordState extends State<UpdatePassword> {
  @override
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String? _name, _name2;

  updatePassword() {
    _formKey.currentState?.save();
    print(_name);
    print(_name2);
    if (_name == _name2) {
      FirebaseAuth.instance.currentUser!.updatePassword(_name!).then(
            (value) => {print("here")},
          );
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => CompleteProfileScreen(),
        ),
        (route) => false,
      );
    } else {
      showError("Password and confirm password are different");
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
                    "Update Password",
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
                                labelText: "New Password",
                                prefixIcon: Icon(Icons.person),
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
                                  return "Confirm Password";
                              },
                              decoration: InputDecoration(
                                labelText: "Confirm password",
                                prefixIcon: Icon(Icons.person),
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
                      onPressed: updatePassword,
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
