import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import '../Admin/NavgationPanel.dart';
import '../Home_page/log_check/HomeCheck.dart';
import '../screen/Developer_page.dart';
import 'Forget_psw.dart';
import 'SignUP.dart';
import 'auth.service/authservice.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: const Login(),
    );
  }
}

class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);

  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final _formKey = GlobalKey<FormState>();
  final _auth = FirebaseAuth.instance;
  final AuthService _authService = AuthService();
  String _email = '';
  String _password = '';

  Future<void> checkUserRole(
      UserCredential userCredential, BuildContext context) async {
    DocumentSnapshot docSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(userCredential.user!.uid)
        .get();
    if (docSnapshot.exists) {
      Map<String, dynamic> data = docSnapshot.data() as Map<String, dynamic>;
      if (data['User'] == 'Employ') {
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => HomeChecker()));
      } else if (data['User'] == 'Admin') {
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => NavPanel()));
      }
    } else {
      Fluttertoast.showToast(
          msg: "User does not exist",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.red,
          textColor: Colors.white);
    }
  }

  @override
  Widget build(BuildContext context) {
       final screenWidth = MediaQuery.of(context).size.width;

    // Define your base font size
    final baseFontSize = 50.0;

    // Adjust font size based on screen width
    final adjustedFontSize = baseFontSize * (screenWidth / 400);
    return Scaffold(
      backgroundColor: Color(0xFFDDE6ED),
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Padding(
            padding: const EdgeInsets.all(37.0),
            child: Column(
              children: [
                SizedBox(height: 60),
                Padding(
                  padding: const EdgeInsets.all(60.0),
                  child: Center(
                    child: Text(
                      'Slas Job',
                      style: GoogleFonts.birthstoneBounce(
                        textStyle: TextStyle(
                          fontSize: adjustedFontSize,
                          color: Color.fromARGB(255, 2, 44, 35),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 60),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextFormField(
                    textAlign: TextAlign.center,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25.0),
                        borderSide: BorderSide(),
                      ),
                      labelText: 'Email',
                      hintText: 'Enter your Email',
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your email';
                      }
                      return null;
                    },
                    onSaved: (value) => _email = value!,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextFormField(
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25.0),
                        borderSide: BorderSide(),
                      ),
                      labelText: 'Password',
                      hintText: 'Enter your password',
                    ),
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your password';
                      }
                      return null;
                    },
                    onSaved: (value) => _password = value!,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>ForgetPsw(),
                        ),
                      );
                    },
                    child: Container(
                      alignment: Alignment.centerRight,
                      child: Text(
                        'Forget password',
                        style: TextStyle(fontSize: 14),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(0.5),
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        child: Center(
                          child: ElevatedButton(
                            child: Text(
                              'LogIN',
                              style: TextStyle(
                                color: Colors.white,
                                //  fontWeight: FontWeight.bold,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xFF526D82),
                            ),
                            onPressed: () async {
                              if (_formKey.currentState!.validate()) {
                                _formKey.currentState!.save();
                                try {
                                  final userCredential =
                                      await _auth.signInWithEmailAndPassword(
                                    email: _email,
                                    password: _password,
                                  );
                                  if (userCredential != null) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Login Successful'),
                                      ),
                                    );
                                    // Get FCM token and save it to Firestore
                                    _authService.storeFCMToken(
                                        userCredential.user!.uid);

                                    await checkUserRole(
                                        userCredential, context);
                                  }
                                } on FirebaseAuthException catch (e) {
                                  String message;
                                  if (e.code == 'user-not-found') {
                                    message = 'No user found for that email.';
                                  } else if (e.code == 'wrong-password') {
                                    message =
                                        'Wrong password provided for that user.';
                                  } else {
                                    message = 'An error occurred during login.';
                                  }
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text(message)),
                                  );
                                } catch (e) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text(e.toString())),
                                  );
                                }
                              }
                            },
                          ),
                        ),
                      ),
                      Expanded(
                        child: Center(
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => SignUp(),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xFF526D82),
                            ),
                            child: Text(
                              'SignUp',
                              style: TextStyle(
                                color: Colors.white,
                                //  fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            ProfileScreen(), // Replace with your actual developer page widget
                      ),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Center(
                      child: Text(
                        '-:Developer Page:-',
                        style: GoogleFonts.caveat(
                          textStyle: TextStyle(
                            fontSize: 24,
                            color: Color.fromARGB(255, 2, 44, 35),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
