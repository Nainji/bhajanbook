import 'dart:async';
import 'package:bhajan_book/main.dart';
import 'package:bhajan_book/screens/Home.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';


class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: Duration(seconds: 3),
      vsync: this,
    );

    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
    );

    _controller.addListener(() {
      setState(() {});
    });

    _controller.forward();

    // Navigate to the next screen after a delay
    Timer(Duration(seconds: 3), () {

      if (mounted) { // Check if the widget is still in the widget tree
        _checkForExistingSession();
      }
    });
  }

  Future<void> _checkForExistingSession() async {
    final prefs = await SharedPreferences.getInstance();
    final hasData = prefs.getString('user') != null; // Adjust the key based on your storage

    // if (mounted) { // Ensure the widget is still mounted before calling Navigator
    if (hasData) {
      Navigator.pushReplacementNamed(context, '/Home',arguments: 'true');
    } else {
      Navigator.pushReplacementNamed(context, '/Home',arguments: 'true');
    }
    // }/
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Color(0xFFFFF2C2),
        child:  Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/images/logo_png.png', // Path to your image
                height: 200.0, // Adjust as needed
              ),
              const SizedBox(height: 20.0), // Space between image and text
              const Text(
                'श्री शुकदेव श्याम चरणदासो जयति',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: "TiroDevanagariHindi",
                  fontSize: 20.0,
                  color: Colors.black, // Text color
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
