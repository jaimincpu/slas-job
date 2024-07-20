import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../login/login_page.dart';
import 'Edu_detail/10.dart';
import 'Edu_detail/12.dart';
import 'Edu_detail/ITI.dart';
import 'Edu_detail/pg_ug.dart';

class ByEducationVic extends StatelessWidget {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> _signOut(BuildContext context) async {
    await _auth.signOut();
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => LoginPage()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TweenAnimationBuilder(
          tween: Tween<double>(begin: 0, end: 1),
          duration: Duration(milliseconds: 500),
          builder: (context, value, child) {
            return Transform.translate(
              offset: Offset(-200 * (1 - value), 0),
              child: child,
            );
          },
          child: Text('Education wise'),
        ),
        backgroundColor: Color(0xFFA555EC),
        actions: [
          IconButton(
            icon: TweenAnimationBuilder(
              tween: Tween<double>(begin: 0, end: 1),
              duration: Duration(milliseconds: 500),
              builder: (context, value, child) {
                return Transform.translate(
                  offset: Offset(200 * (1 - value), 0),
                  child: child,
                );
              },
              child: Icon(Icons.exit_to_app),
            ),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text('Logout'),
                  content: Text('Are you sure you want to log out?'),
                  actions: [
                    ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text('Cancel'),
                    ),
                    ElevatedButton(
                      onPressed: () => _signOut(context),
                      child: Text('Logout'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: Container(
        // color: Color(0xFFFFFFD0),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            buildAnimatedButton(
              context,
              '10 passed',
              TEN(),
              BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomLeft,
                  end: Alignment.topRight,
                  colors: [
                    Color(0xFFD09CFA),
                    Color(0xFFFFFFD0),
                  ],
                ),
                borderRadius: BorderRadius.circular(8.0),
              ),
            ),
            buildAnimatedButton(
              context,
              '12 passed',
              BARVI(),
              BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomLeft,
                  end: Alignment.topRight,
                  colors: [
                    Color(0xFFD09CFA),
                    Color(0xFFFFFFD0),
                  ],
                ),
                borderRadius: BorderRadius.circular(8.0),
              ),
            ),
            buildAnimatedButton(
              context,
              'ITI passed',
              ITI(),
              BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomLeft,
                  end: Alignment.topRight,
                  colors: [
                    Color(0xFFD09CFA),
                    Color(0xFFFFFFD0),
                  ],
                ),
                borderRadius: BorderRadius.circular(8.0),
              ),
            ),
            buildAnimatedButton(
              context,
              'PU/UG passed',
              PGUG(),
              BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomLeft,
                  end: Alignment.topRight,
                  colors: [
                    Color(0xFFD09CFA),
                    Color(0xFFFFFFD0),
                  ],
                ),
                borderRadius: BorderRadius.circular(8.0),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildAnimatedButton(BuildContext context, String label, Widget page, BoxDecoration decoration) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Container(
        decoration: decoration,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
          ),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => page),
            );
          },
          child: TweenAnimationBuilder(
            tween: Tween<double>(begin: 0, end: 1),
            duration: Duration(milliseconds: 500),
            builder: (context, value, child) {
              return Transform.translate(
                offset: Offset(-200 * (1 - value), 0),
                child: child,
              );
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 25.0),
              child: Text(
                label,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
