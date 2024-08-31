import 'package:flutter/material.dart';

void main() {
  runApp(update());
}

class update extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Status',
      home: UpdateStatus(),
    );
  }
}

class UpdateStatus extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final Color primaryColor = Color(0xFF27374D);
    final Color backgroundColor = Color(0xFF27374D);
    final Color textColor = Colors.white;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Status',
          textAlign: TextAlign.center,
          style: TextStyle(color: textColor),
        ),
        backgroundColor: primaryColor,
        centerTitle: true,
        // actions: [
        //   IconButton(
        //     onPressed: () async {
        //       try {
        //         // Sign out the user
        //         await FirebaseAuth.instance.signOut();

        //         // Navigate to the login screen (replace with your actual route)
        //         Navigator.pushAndRemoveUntil(
        //           context,
        //           MaterialPageRoute(builder: (context) => LoginPage()),
        //           (route) => false, // Remove all previous routes from the stack
        //         );
        //       } catch (e) {
        //         // Show an error snackbar
        //         ScaffoldMessenger.of(context).showSnackBar(
        //           SnackBar(
        //             content: Text('Error signing out. Please try again.'),
        //             duration: Duration(seconds: 3),
        //           ),
        //         );
        //       }
        //     },
        //     icon: Icon(Icons.logout, color: textColor),
        //   )
        // ],
      ),
      body: Center(
        child: Container(
          padding: EdgeInsets.all(16),
          margin: EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(color: textColor),
            borderRadius: BorderRadius.circular(10),
            color: backgroundColor,
          ),
          child: Text(
            "“Thank you for registering with us. As soon as our representative reviews your details, we will update and inform you at your registered email.”\n Thank you for choosing us.",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 18, color: textColor),
          ),
        ),
      ),
    );
  }
}
