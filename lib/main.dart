import 'dart:convert';
import 'package:bhajan_book/screens/Home.dart';
import 'package:bhajan_book/screens/about.dart';
import 'package:bhajan_book/screens/appDetails.dart';
import 'package:bhajan_book/screens/books.dart';
import 'package:bhajan_book/screens/chapter.dart';
import 'package:bhajan_book/screens/content.dart';
import 'package:bhajan_book/screens/darshan.dart';
import 'package:bhajan_book/screens/panchang.dart';
import 'package:bhajan_book/screens/policy.dart';
import 'package:bhajan_book/screens/shareScreen.dart';
import 'package:bhajan_book/screens/socialMedia.dart';
import 'package:bhajan_book/screens/splash.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: Color(0xFFFFD500), // Yellow theme color
        colorScheme: ColorScheme.fromSwatch().copyWith(
          secondary: Color(0xFF8C4A03), // Brown accent color
        ),
        textTheme: TextTheme(
          bodyText2: TextStyle(color: Color(0xFF8C4A03)), // Text color
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.amber[100],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(25.0),
            borderSide: BorderSide.none,
          ),
        ),
      ),
      routes: {
        '/Social Media': (context) => SocialMediaScreen(),
        '/Daily Darshan': (context) => Darshan(),
        '/Utsav Panchang': (context) => Panchang(),
        '/About Saras Nikunj': (context) => SarasNikunjScreen(),
        '/Privacy Policy':(context)=>PrivacyPolicyScreen(),
        '/Share App with Others':(contex)=>ShareAppScreen(),
        '/App version':(context)=>AppDetailsScreen()


      },
      onGenerateRoute: (settings) {
        final args = settings.arguments ;
        switch (settings.name) {

          case '/Home':
            return MaterialPageRoute(builder: (context) => Home());
          case '/file':
            return MaterialPageRoute(builder: (context)=>FileViewerScreen(file: args));
          case '/Shri Shuk Sampraday':

            return MaterialPageRoute(builder: (context) => Books(category:args));
          case '/chapters':
            return MaterialPageRoute(builder: (context) => Chapters(id: args)); // You can handle args if needed
          default:
            return MaterialPageRoute(builder: (context) => SplashScreen());
        }
      },
      home: SplashScreen(),
    );
  }
}

class LoginPage extends StatelessWidget {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  Map<String, String> user = {};

  @override
  Widget build(BuildContext context) {
    // Move login method here to have access to `context`
    Future<void> login() async {
      if (_emailController.text.isNotEmpty) {
        user['role'] = 'user-menu';
        if (_emailController.text == 'user') {
          user['email'] = _emailController.text;
          user['role'] = 'user-menu';
        } else if (_emailController.text == 'admin') {
          user['email'] = _emailController.text;
          user['role'] = 'admin-menu';
        } else if (_emailController.text == 'super') {
          user['email'] = _emailController.text;
          user['role'] = 'superadmin-menu';
        }

        final SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('user', json.encode(user));


        // Navigate to home after login
        Navigator.pushNamedAndRemoveUntil(
            context, '/Home', (Route<dynamic> route) => false);
      }
    }

    return Scaffold(
      backgroundColor: Color(0xFFFFD500),  // Yellow background
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: 100),
              // Image or Logo
              Image.asset(
                'assets/images/logo_png.png', // Add your logo here
                height: 220,
              ),
              SizedBox(height: 16),
              Text(
                "श्री राधा सरस विहारणे नमः\nश्रीशुकदेव श्यामचरण दासोजयति",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Color(0xFF8C4A03),
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 30),
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Login",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF8C4A03),
                      ),
                    ),
                    SizedBox(height: 20),
                    TextField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        labelText: 'Enter Email',
                        labelStyle: TextStyle(color: Colors.brown),
                      ),
                    ),
                    SizedBox(height: 20),
                    TextField(
                      controller: _passwordController,
                      decoration: InputDecoration(
                        labelText: 'Enter Password',
                        labelStyle: TextStyle(color: Colors.brown),
                      ),
                      obscureText: true,
                    ),
                    SizedBox(height: 10),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {
                          // Forgot password logic here
                        },
                        child: Text(
                          'Forgot Password?',
                          style: TextStyle(
                            color: Color(0xFF8C4A03),
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    Center(
                      child: ElevatedButton(
                        onPressed: () {
                          login(); // Call the login method here
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF8C4A03), // Use backgroundColor instead of primary
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                          padding: EdgeInsets.symmetric(horizontal: 100, vertical: 15),
                        ),
                        child: Text(
                          'SUBMIT',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
