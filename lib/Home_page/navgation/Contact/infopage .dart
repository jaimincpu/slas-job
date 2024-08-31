import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../../login/login_page.dart';

void main() {
  runApp(ContactPage());
}

class ContactPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primaryColor: Color(0xFF27374D),
        scaffoldBackgroundColor: Color(0xFFDDE6ED),
        appBarTheme: AppBarTheme(
          color: Color(0xFF27374D),
          centerTitle: true,
        ),
        textTheme: TextTheme(
          bodyLarge: TextStyle(color: Colors.white),
          bodyMedium: TextStyle(color: Colors.white),
        ),
      ),
      home: UpdateStatus(),
    );
  }
}

class UpdateStatus extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Contact Page',
          style: TextStyle(fontWeight: FontWeight.bold,color: Color.fromARGB(255, 255, 255, 255)),
        ),
        actions: [
          IconButton(
            onPressed: () async {
              try {
                // Sign out the user
                await FirebaseAuth.instance.signOut();

                // Navigate to the login screen (replace with your actual route)
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => LoginPage()),
                  (route) => false, // Remove all previous routes from the stack
                );
              } catch (e) {
                // Show an error snackbar
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Error signing out. Please try again.'),
                    duration: Duration(seconds: 3),
                  ),
                );
              }
            },
            icon: Icon(Icons.logout, color: Colors.white),
          )
        ],
      ),
      body: Center(
        child: Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Color(0xFF27374D),
            border: Border.all(color: Colors.white),
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                spreadRadius: 2,
                blurRadius: 5,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.contact_mail,
                size: 80,
                color: Colors.white,
              ),
              SizedBox(height: 16),
              Text(
                'Email : slasgroup7381@gmail.com',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Phone No:+91 97769 04103',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
