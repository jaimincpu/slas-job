import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../login/LogChecker.dart';

class SplashScreen extends StatefulWidget {
  final Widget? child;
  const SplashScreen({super.key, this.child});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(seconds: 5), () {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => LogChecker()),
        (route) => false,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
           Positioned.fill(
            child: Image.asset(
              'assets/slas_job.png', 
              fit: BoxFit.contain, // Cover the entire screen
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Opacity(
                opacity: 0.5, // Adjust opacity (0.0 to 1.0)
                child: Text(
                  'Develop by MR_NATURE',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.freehand(
                    textStyle: TextStyle(
                      fontSize: 16,
                      color: Color.fromARGB(255, 2, 44, 35),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
