// import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:ocr_application/index.dart';
import 'package:ocr_application/login.dart';
import 'package:ocr_application/signup.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_downloader/flutter_downloader.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();
  // await availableCameras();
  await FlutterDownloader.initialize(
      debug: true // optional: set false to disable printing logs to console
      );

  runApp(
    MaterialApp(
      home: LandingPage(),
      debugShowCheckedModeBanner: false,
    ),
  );
}

class LandingPage extends StatefulWidget {
  @override
  _LandingPageState createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  // FirebaseFirestore firestore = FirebaseFirestore.instance;
  late User user;
  bool isloggedin = false;
  getUser() async {
    User? firebaseUser = _auth.currentUser;
    await firebaseUser!.reload();
    firebaseUser = _auth.currentUser;

    if (firebaseUser != null) {
      setState(() {
        this.user = firebaseUser!;
        this.isloggedin = true;
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => Index()));
      });
    }
  }

  @override
  void initState() {
    // this.checkAuthentification();
    this.getUser();
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    return Scaffold(
      // appBar: AppBar(
      // backgroundColor: Colors.transparent,
      //   elevation: 0,
      //   // title: Text(
      //   //   "Light Mode",
      //   //   style: TextStyle(color: Colors.grey.shade900),
      //   // ),
      //   // actions: [
      //   //   IconButton(
      //   //       icon: Icon(Icons.wb_sunny, color: Colors.grey.shade900),
      //   //       onPressed: () {})
      //   // ],
      // ),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        // leading: IconButton(
        //   onPressed: () {
        //     Navigator.pop(context);
        //   },
        //   icon: Icon(
        //     Icons.arrow_back_ios,
        //     size: 20,
        //     color: Colors.black,
        //   ),
        // ),
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
                "Welcome, \nYour one stop for all OCR work!",
                style: Theme.of(context).textTheme.headline1!.copyWith(
                      fontSize: size.width * 0.1,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              Container(
                height: MediaQuery.of(context).size.height / 3,
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/20944142.jpg'),
                  ),
                ),
              ),
              Column(
                children: [
                  RaisedButton(
                    onPressed: () => {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) => LoginPage())),
                    },
                    elevation: 0,
                    padding: EdgeInsets.all(18),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20)),
                    color: Colors.indigo.shade900,
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
                  RaisedButton(
                    onPressed: () => {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => SignUpPage())),
                    },
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
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
