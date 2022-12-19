import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter/material.dart';
import 'package:ocr_application/index.dart';
import 'package:ocr_application/main.dart';
import 'package:ocr_application/reportQuery.dart';
import 'package:ocr_application/updateEmail.dart';
import 'package:ocr_application/updatePassword.dart';
import 'package:ocr_application/uploadImage.dart';

class SizeConfig {
  static late MediaQueryData _mediaQueryData;
  static late double screenWidth;
  static late double screenHeight;
  static double? defaultSize;
  static Orientation? orientation;

  void init(BuildContext context) {
    _mediaQueryData = MediaQuery.of(context);
    screenWidth = _mediaQueryData.size.width;
    screenHeight = _mediaQueryData.size.height;
    orientation = _mediaQueryData.orientation;
  }
}

// Get the proportionate height as per screen size
double getProportionateScreenHeight(double inputHeight) {
  double screenHeight = SizeConfig.screenHeight;
  // 812 is the layout height that designer use
  return (inputHeight / 812.0) * screenHeight;
}

// Get the proportionate height as per screen size
double getProportionateScreenWidth(double inputWidth) {
  double screenWidth = SizeConfig.screenWidth;
  // 375 is the layout width that designer use
  return (inputWidth / 375.0) * screenWidth;
}

const kPrimaryColor = Color(0xFFFF7643);
const kPrimaryLightColor = Color(0xFFFFECDF);
const kPrimaryGradientColor = LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [Color(0xFFFFA53E), Color(0xFFFF7643)],
);
const kSecondaryColor = Color(0xFF979797);
const kTextColor = Color(0xFF757575);

const kAnimationDuration = Duration(milliseconds: 200);

final headingStyle = TextStyle(
  fontSize: getProportionateScreenWidth(28),
  fontWeight: FontWeight.bold,
  color: Colors.black,
  height: 1.5,
);

const defaultDuration = Duration(milliseconds: 250);

// Form Error
final RegExp emailValidatorRegExp =
    RegExp(r"^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+");
const String kEmailNullError = "Please Enter your email";
const String kInvalidEmailError = "Please Enter Valid Email";
const String kPassNullError = "Please Enter your password";
const String kShortPassError = "Password is too short";
const String kMatchPassError = "Passwords don't match";
const String kNamelNullError = "Please Enter your name";
const String kPhoneNumberNullError = "Please Enter your phone number";
const String kAddressNullError = "Please Enter your address";

final otpInputDecoration = InputDecoration(
  contentPadding:
      EdgeInsets.symmetric(vertical: getProportionateScreenWidth(15)),
  border: outlineInputBorder(),
  focusedBorder: outlineInputBorder(),
  enabledBorder: outlineInputBorder(),
);

OutlineInputBorder outlineInputBorder() {
  return OutlineInputBorder(
    borderRadius: BorderRadius.circular(getProportionateScreenWidth(15)),
    borderSide: BorderSide(color: kTextColor),
  );
}

enum MenuState { home, favourite, message, profile }

class ProfilePic extends StatelessWidget {
  const ProfilePic({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 115,
      width: 115,
      child: Stack(
        fit: StackFit.expand,
        clipBehavior: Clip.none,
        children: <Widget>[
          FirebaseAuth.instance.currentUser!.photoURL != null
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(50.0),
                  child: Image.network(
                    FirebaseAuth.instance.currentUser!.photoURL!,
                  ),
                )
              : CircleAvatar(
                  // backgroundImage: AssetImage("assets/54955.jpg"),

                  backgroundImage: AssetImage('assets/land.png'),
                ),
          // ClipRRect(
          //   borderRadius: BorderRadius.circular(50.0),
          //   child: CircleAvatar(
          //     // backgroundImage: AssetImage("assets/54955.jpg"),

          //     backgroundImage: AssetImage('assets/land.png'),
          //   ),
          // ),
          Positioned(
            right: -16,
            bottom: 0,
            child: SizedBox(
              height: 46,
              width: 46,
              child: TextButton(
                style: TextButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50),
                    side: BorderSide(color: Colors.black),
                  ),
                  primary: Colors.black,
                  backgroundColor: Color(0xFFF5F6F9),
                ),
                onPressed: () => {
                  // print("checkingHere"),
                  // print(FirebaseAuth.instance.currentUser.photoURL),
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => UploadImage(),
                    ),
                  ),
                },
                child: Icon(Icons.edit),
              ),
            ),
          )
        ],
      ),
    );
  }
}

class ProfileMenu extends StatelessWidget {
  const ProfileMenu({
    Key? key,
    required this.text,
    required this.icon,
    this.press,
    required this.color,
    required this.iconRight,
  }) : super(key: key);

  final String text;
  final IconData icon;
  final VoidCallback? press;
  final Color color;
  final IconData iconRight;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: TextButton(
        style: TextButton.styleFrom(
          primary: color,
          padding: EdgeInsets.all(20),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          backgroundColor: Color(0xFFF5F6F9),
        ),
        onPressed: press,
        child: Row(
          children: [
            // SvgPicture.asset(
            //   icon,
            //   color: kPrimaryColor,
            //   width: 22,
            // ),
            Icon(icon),
            SizedBox(width: 20),
            Expanded(child: Text(text)),
            // Icon(Icons.arrow_forward_ios),
            Icon(iconRight),
          ],
        ),
      ),
    );
  }
}

class Body extends StatelessWidget {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  DateTime now = DateTime.now();

  @override
  Widget build(BuildContext context) {
    // final User? user = _auth.currentUser;
    // final username = user!.displayName;
    return Scaffold(
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(vertical: 20),
        child: Column(
          children: [
            ProfilePic(),
            SizedBox(height: 20),
            Text(
              // "change is here",
              _auth.currentUser!.displayName!,
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            SizedBox(height: 20),

            ProfileMenu(
              text: "Update Email",
              icon: Icons.email_rounded,
              press: () => {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => UpdateEmail(),
                  ),
                ),
              },
              color: Colors.black,
              iconRight: Icons.edit_note_rounded,
            ),
            ProfileMenu(
              text: "Change Password",
              icon: Icons.verified_user_rounded,
              press: () => {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => UpdatePassword(),
                  ),
                ),
              },
              color: Colors.black,
              iconRight: Icons.edit_note_rounded,
            ),
            // ProfileMenu(
            //   text: "Change Password",
            //   icon: Icons.password_rounded,
            //   press: () => {
            //     Navigator.push(
            //       context,
            //       MaterialPageRoute(
            //         builder: (context) => UpdatePassword(),
            //       ),
            //     ),
            //   },
            //   color: Colors.black,
            //   iconRight: Icons.edit_note_rounded,
            // ),
            ProfileMenu(
              text: "My Activity",
              icon: Icons.local_activity_rounded,
              press: () => {
                // Navigator.push(
                //   context,
                //   MaterialPageRoute(
                //     builder: (context) => GetUserActivity(),
                //   ),
                // ),
              },
              color: Colors.black,
              iconRight: Icons.arrow_forward_ios_rounded,
            ),
            // ProfileMenu(
            //   text: "My Account",
            //   icon: Icons.verified_user_rounded,
            //   press: () => {},
            // ),
            // ProfileMenu(
            //   text: "Notifications",
            //   icon: Icons.notification_add_rounded,
            //   press: () {},
            // ),
            // ProfileMenu(
            //   text: "Settings",
            //   icon: Icons.settings_accessibility_rounded,
            //   press: () {},
            // ),
            // ProfileMenu(
            //   text: "",
            //   icon: Icons.book_sharp,
            //   press: () => {
            //     // Navigator.push(
            //     //   context,
            //     //   MaterialPageRoute(
            //     //     builder: (context) => GetUserIssuedBooks(),
            //     //   ),
            //     // ),
            //   },
            //   color: Colors.orangeAccent,
            //   iconRight: Icons.arrow_forward_ios_rounded,
            // ),
            ProfileMenu(
              text: "Report Query",
              icon: Icons.whatsapp,
              press: () => {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ReportQueryNew(),
                  ),
                ),
              },
              color: Colors.black,
              iconRight: Icons.arrow_forward_ios_rounded,
            ),

            // ProfileMenu(
            //   text: "Log Out",
            //   icon: Icons.logout_rounded,
            //   press: () {},
            // ),
            // RichText(
            //   text: TextSpan(
            //     style: Theme.of(context).textTheme.headline5,
            //     children: [
            //       TextSpan(
            //         text: "InTime Records",
            //       ),
            //       TextSpan(
            //         text: "....",
            //         style: TextStyle(fontWeight: FontWeight.bold),
            //       ),
            //     ],
            //   ),
            // ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        height: 55.0,
        child: BottomAppBar(
          color: Colors.white,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              IconButton(
                icon: Icon(Icons.home, color: Colors.black),
                onPressed: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => Index()));
                },
              ),
              IconButton(
                icon: Icon(Icons.photo, color: Colors.black),
                onPressed: () {},
              ),
              IconButton(
                icon: Icon(Icons.person, color: Colors.black),
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => CompleteProfileScreen()));
                },
              ),
              IconButton(
                icon: Icon(Icons.logout, color: Colors.black),
                onPressed: () {
                  showAlertDialog(context);
                },
              )
            ],
          ),
        ),
      ),
    );
  }

  showAlertDialog(BuildContext context) {
    // set up the button
    // Widget logOutButton = SalomonBottomBarItem(
    //   icon: Icon(Icons.logout),
    //   title: Text("LogOut"),
    //   selectedColor: Colors.redAccent,
    // );
    Widget okButton = TextButton(
      child: Text("Logout"),
      onPressed: () {
        _auth.signOut();
        // Navigator.push(
        //     context, MaterialPageRoute(builder: (context) => HomePage()));
        Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => LandingPage()),
            (route) => false);
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("Logout Alert!!"),
      content: Text("Are you sure you want to logout?"),
      actions: [
        okButton,
      ],
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

class ProfileScreen extends StatelessWidget {
  static String routeName = "/profile";
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Profile"),
      ),
      // body: Body(),
      // bottomNavigationBar: CustomBottomNavBar(selectedMenu: MenuState.profile),
    );
  }
}

// import 'package:flutter/material.dart';

// import 'components/body.dart';

class CompleteProfileScreen extends StatefulWidget {
  @override
  State<CompleteProfileScreen> createState() => _CompleteProfileScreenState();
}

class _CompleteProfileScreenState extends State<CompleteProfileScreen> {
  int _currentIndex = 0;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'My Profile',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
      body: Body(),
    );
  }

  showAlertDialog(BuildContext context) {
    // set up the button
    // Widget logOutButton = SalomonBottomBarItem(
    //   icon: Icon(Icons.logout),
    //   title: Text("LogOut"),
    //   selectedColor: Colors.redAccent,
    // );
    Widget okButton = TextButton(
      child: Text("Logout"),
      onPressed: () {
        _auth.signOut();
        // Navigator.push(
        //     context, MaterialPageRoute(builder: (context) => HomePage()));
        Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => LandingPage()),
            (route) => false);
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("Logout Alert!!"),
      content: Text("Are You Sure You Want To LogOut?"),
      actions: [
        okButton,
      ],
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
