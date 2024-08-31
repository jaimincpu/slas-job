import 'dart:math';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server/gmail.dart';
import 'login_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';

class SignUp extends StatefulWidget {
  @override
  _SignUpState createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  final _formKey = GlobalKey<FormState>();
  String? _email, _password, _confirmPassword, _name;
  final _receivedCodeController = TextEditingController();
  final _verificationService = VerificationService();
  final _regCodeService = RegCodeService();

  void _register() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      try {
        UserCredential userCredential =
            await _auth.createUserWithEmailAndPassword(
          email: _email!,
          password: _password!,
        );
        int REGID = await _regCodeService.fetchAndIncrementRegId();

        await _firestore.collection('users').doc(userCredential.user!.uid).set({
          'name': _name,
          'email': _email,
          'User': 'Employ',
          'Reg': 'NO',
          'REGID': REGID,
        });
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => LoginPage()),
          (route) => false, // Remove all previous routes from the stack
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Registration Failed: $e')),
        );
      }
    }
  }

  void _checkEmailAvailability() async {
    try {
      final emailQuery = await _firestore
          .collection('users')
          .where('email', isEqualTo: _email)
          .get();
      if (emailQuery.docs.isNotEmpty) {
        _showErrorDialog('Email already registered.');
        return;
      }

      _register();
    } catch (e) {
      _showErrorDialog('Error: $e');
    }
  }

  void _otp(String generatedOtp) async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      String receivedCode = _receivedCodeController.text.trim();
      if (receivedCode == generatedOtp) {
        _checkEmailAvailability();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('OTP is valid!')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Invalid OTP')),
        );
      }
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Error'),
        content: Text(message),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    var screenSize = MediaQuery.of(context).size;
    var screenHeight = screenSize.height;
    var screenWidth = screenSize.width;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Sign-Up Page',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white), // Set the text color to white
        ),
        backgroundColor: Color(0xFF27374D),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Container(
            height: screenHeight,
            width: screenWidth,
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
                          fontSize: 50,
                          color: Color.fromARGB(255, 2, 44, 35),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
                Center(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: TextFormField(
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(25.0),
                                borderSide: BorderSide(),
                              ),
                              labelText: 'Name',
                              hintText:
                                  'Enter your name as per the Adhar card / Marksheet',
                            ),
                            validator: (input) => input!.isEmpty
                                ? 'Please enter your name'
                                : null,
                            onSaved: (input) => _name = input,
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
                              labelText: 'Email',
                              hintText: 'Enter your email',
                            ),
                            validator: (input) => !input!.contains('@')
                                ? 'Please enter a valid email'
                                : null,
                            onSaved: (input) => _email = input,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: TextFormField(
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(25.0),
                              ),
                              labelText: 'Password',
                              hintText: 'Enter your password',
                            ),
                            obscureText: true,
                            validator: (input) {
                              if (input!.isEmpty) {
                                return 'Please enter a password';
                              }

                              RegExp regex = RegExp(
                                r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#\$&*~]).{8,}$',
                              );

                              RegExp specialCharRegex = RegExp(r'[!@#\$&*~]');

                              if (!regex.hasMatch(input)) {
                                return 'Password must contain uppercase, lowercase, digit, special character, and be at least 8 characters long.';
                              }

                              if (!specialCharRegex.hasMatch(input)) {
                                return 'Password must include at least one special character (e.g., !, @, #, \$, &, *, ~).';
                              }

                              _password = input;
                              return null;
                            },
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: TextFormField(
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(25.0),
                              ),
                              labelText: 'Confirm Password',
                              hintText: 'Enter your password again',
                            ),
                            obscureText: true,
                            validator: (input) {
                              if (input!.isEmpty) {
                                return 'Please confirm your password';
                              } else if (input != _password) {
                                return 'Passwords do not match';
                              }
                              return null;
                            },
                            onSaved: (input) => _confirmPassword = input,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: ElevatedButton(
                            onPressed: () async {
                              if (_formKey.currentState!.validate()) {
                                _formKey.currentState!.save();
                                if (_email != null) {
                                  // Generate and send OTP
                                  await _verificationService.generateCode();

                                  // Get the generated OTP
                                  final generatedOtp =
                                      await _verificationService.getStoredOtp();

                                  if (generatedOtp != null) {
                                    await _verificationService
                                        .sendVerification(_email!);

                                    // Show dialog for OTP entry
                                    showDialog(
                                      context: context,
                                      builder: (context) {
                                        return AlertDialog(
                                          title: Text(
                                              'Enter Your OTP that has been sent to your registered Email Address , Check Your Email for the OTP'),
                                          content: TextFormField(
                                            controller: _receivedCodeController,
                                            decoration: InputDecoration(
                                              hintText: 'Enter OTP',
                                            ),
                                          ),
                                          actions: [
                                            TextButton(
                                              onPressed: () {
                                                Navigator.pop(context);
                                              },
                                              style: TextButton.styleFrom(
                                                backgroundColor: Color(
                                                    0xFF27374D), // Set the background color
                                              ),
                                              child: Text('Cancel',
                                                  style: TextStyle(
                                                      color: Colors.white)),
                                            ),
                                            TextButton(
                                              onPressed: () {
                                                Navigator.pop(context);
                                                _otp(
                                                    generatedOtp); // Pass the generated OTP for verification
                                              },
                                              style: TextButton.styleFrom(
                                                backgroundColor: Color(
                                                    0xFF27374D), // Set the background color
                                              ),
                                              child: Text('Verify',
                                                  style: TextStyle(
                                                      color: Colors.white)),
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                  } else {
                                    // Handle the case where OTP could not be generated or retrieved
                                    _showSnackBar(
                                        'Failed to generate OTP. Please try again.');
                                  }
                                }
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(
                                  0xFF27374D), // Set the background color for the ElevatedButton
                            ),
                            child: Text(
                              'Generate OTP',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color:
                                    Colors.white, // Set the text color to white
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class VerificationService {
  static const String otpKey = 'generated_otp';
  static const String timestampKey = 'otp_timestamp';
  static const int otpValidityMinutes = 5; // OTP validity period in minutes
  String generatedCode = '';

  Future<void> generateCode() async {
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now();

    // Retrieve last generated time
    final timestamp = prefs.getString(timestampKey);
    if (timestamp != null) {
      final lastGeneratedTime = DateTime.parse(timestamp);
      // Check if the existing OTP is still valid
      if (now.difference(lastGeneratedTime).inMinutes < otpValidityMinutes) {
        generatedCode = prefs.getString(otpKey)!;
        return;
      }
    }

    final code = List<int>.generate(6, (index) => Random().nextInt(10));
    generatedCode = code.join();

    await prefs.setString(otpKey, generatedCode);
    await prefs.setString(timestampKey, now.toIso8601String());
  }

  Future<String?> getStoredOtp() async {
    final prefs = await SharedPreferences.getInstance();
    final timestamp = prefs.getString(timestampKey);

    if (timestamp != null) {
      final lastGeneratedTime = DateTime.parse(timestamp);
      final now = DateTime.now();

      if (now.difference(lastGeneratedTime).inMinutes < otpValidityMinutes) {
        return prefs.getString(otpKey);
      } else {
        // OTP has expired, clear the stored OTP and timestamp
        await prefs.remove(otpKey);
        await prefs.remove(timestampKey);
      }
    }
    return null;
  }

  Future<void> sendVerification(String email) async {
    String username = 'slasgroup7381@gmail.com';
    String password = 'zdbpbkftivduorru';

    final smtpServer = gmail(username, password);

    final message = Message()
      ..from = Address(username, 'Slas job')
      ..recipients.add(email)
      ..subject = 'Your OTP Code'
      ..text = 'Your OTP code is valid for 5 min : $generatedCode';

    try {
      final sendReport = await send(message, smtpServer);
      print('Message sent: ' + sendReport.toString());
    } on MailerException catch (e) {
      print('Message not sent.');
      for (var p in e.problems) {
        print('Problem: ${p.code}: ${p.msg}');
      }
    }
  }
}

class RegCodeService {
  int _currentNumber = 0; // Initialize with 0

  int get currentNumber => _currentNumber;

  Future<int> fetchAndIncrementRegId() async {
    // Fetch the value from Firestore (assuming it is stored as an integer)
    DocumentSnapshot snapshot = await FirebaseFirestore.instance
        .collection('Unique_Code_Generate')
        .doc('reg_code')
        .get();

    if (snapshot.exists) {
      final data = snapshot.data() as Map<String, dynamic>;
      if (data.containsKey('REGID')) {
        _currentNumber = data['REGID'];
      } else {
        // If the field doesn't exist, initialize with a value of 0
        _currentNumber = 0;
      }
    } else {
      // If the document doesn't exist, initialize with a value of 0
      _currentNumber = 0;
    }

    // Increment the number
    _currentNumber++;

    // Update the document with the incremented value
    await FirebaseFirestore.instance
        .collection('Unique_Code_Generate')
        .doc('reg_code')
        .set({'REGID': _currentNumber});

    return _currentNumber;
  }
}
