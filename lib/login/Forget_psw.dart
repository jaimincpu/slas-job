import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ForgetPsw extends StatefulWidget {
  const ForgetPsw({Key? key}) : super(key: key);

  @override
  State<ForgetPsw> createState() => _ForgetPswState();
}

class _ForgetPswState extends State<ForgetPsw> {
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> pswreset() async {
    try {
      await FirebaseAuth.instance
          .sendPasswordResetEmail(email: _emailController.text.trim()); 
      showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              content: Text('Link has been sent. Check your inbox.'),
            );
          });
           _emailController.clear();
    } on FirebaseAuthException catch (e) {
      print(e);
      showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              content: Text(e.message.toString()),
            );
          });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Forget Password',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white), // Set the text color to white
        ),
        backgroundColor: Color(0xFF27374D),
      ),
      backgroundColor: Color(0xFFDDE6ED),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(18.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Center(
                    child: Text(
                      'Slas Job',
                      style: GoogleFonts.birthstoneBounce(
                        textStyle: TextStyle(
                          fontSize: 50,
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
                  child: Text(
                    "Having Trouble Signing In?",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    "Enter your registered email address here to get a password reset link on your email.",
                    style: TextStyle(color: Color(0xFF9DB2BF)),
                    textAlign: TextAlign.center,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextFormField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25.0),
                        borderSide: BorderSide(),
                      ),
                      labelText: 'Email',
                      hintText: 'Enter your email',
                    ),
                  ),
                ),
                SizedBox(height: 10),
                MaterialButton(
                  onPressed: pswreset,
                  child: Text("Reset Password"),
                  color: Color(0xFF27374D),
                  textColor: Colors.white,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
